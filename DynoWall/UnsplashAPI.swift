//
//  UnsplashAPI.swift
//  DynoWall
//
//  Created by Erick Navarro on 6/8/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//

import Foundation

class UnsplashAPI: NSObject {

    let BASE_URL = "https://unsplash.com"
    let BASE_API_URL = "https://api.unsplash.com"
    let REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"

    let CLIENT_ID = ""
    let CLIENT_SECRET = ""

    typealias JSONDict = [String: AnyObject]

    weak var delegate: ImageProtocol?

    func randomImage() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var url = "/photos/random"

        if let query = defaults.stringForKey("query") {
            url.appendContentsOf("?query=\(query.componentsSeparatedByString(" ").joinWithSeparator("+"))")
        }
        fetchImage(url)
    }

    func authorize() {
        let url = BASE_URL + "/oauth/authorize?client_id=\(CLIENT_ID)&redirect_uri=\(REDIRECT_URI)&response_type=code&scope=public"
        OSManager.openUrl(url)
    }

    private func fetchImage(resourceUrl: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: BASE_API_URL + resourceUrl)

        NSLog("Processing: \(url)")

        let defaults = NSUserDefaults.standardUserDefaults()
        if let accessToken = defaults.stringForKey(constants.keys.ACCESS_TOKEN) {
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let task = session.dataTaskWithRequest(request, completionHandler: self.processResponse)
            task.resume()
        } else {
            // notify user
        }
    }

    private func processResponse(data: NSData?, response: NSURLResponse?, err: NSError?) -> Void {
        if let error = err {
            NSLog("API error: \(error)")
        }
        if let httpResponse = response as? NSHTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                let json : JSONDict = self.parseData(data!)
                let urls = json["urls"] as! JSONDict
                let links = json["links"] as! JSONDict
                let user = json["user"] as! JSONDict
                let userLinks = user["links"] as! JSONDict
                let id = json["id"] as! String
                OSManager.setWallpaper(urls["full"] as! String, fileName: "\(id).jpg")
                let image = Image(url: links["html"] as! String, user: User(name: user["name"] as! String, url: userLinks["html"] as! String))
                delegate?.imageDidUpdate(image)
                NSLog("Wallpaper changed!")
            case 401:
                NSLog("unauthorized error")
            default:
                NSLog("An error ocurred, %d", httpResponse.statusCode)
            }
        }
    }

    func requestToken(authorizationCode: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: BASE_URL + "/oauth/token/")
        let request = NSMutableURLRequest(URL: url!)
        let data = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "redirect_uri": REDIRECT_URI,
            "code": authorizationCode,
            "grant_type": "authorization_code"
            ] as Dictionary<String, String>
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        try! request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: [])
        let task = session.dataTaskWithRequest(request) { data, response, err in
            let json : JSONDict = self.parseData(data!)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(json["access_token"], forKey: constants.keys.ACCESS_TOKEN)
            defaults.setValue(json["refresh_token"], forKey: constants.keys.REFRESH_TOKEN)
        }
        task.resume()
    }

    func refreshToken() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: BASE_URL + "/oauth/token/")
        let request = NSMutableURLRequest(URL: url!)
        let data = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "redirect_uri": REDIRECT_URI,
            "refresh_token": defaults.stringForKey(constants.keys.REFRESH_TOKEN)!,
            "grant_type": "refresh_token"
            ] as Dictionary<String, String>
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        try! request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: [])
        let task = session.dataTaskWithRequest(request) { data, response, err in
            let json : JSONDict = self.parseData(data!)
            defaults.setValue(json["access_token"], forKey: constants.keys.ACCESS_TOKEN)
            defaults.setValue(json["refresh_token"], forKey: constants.keys.REFRESH_TOKEN)
        }
        task.resume()
    }

    private func parseData(data: NSData) -> JSONDict {
        let json : JSONDict = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        return json
    }
    
}
