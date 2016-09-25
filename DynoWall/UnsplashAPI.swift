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
        let defaults = UserDefaults.standard
        var url = "/photos/random"

        if let query = defaults.string(forKey: "query") {
            url.append("?query=\(query.components(separatedBy: " ").joined(separator: "+"))")
        }
        fetchImage(url)
    }

    func authorize() {
        let url = BASE_URL + "/oauth/authorize?client_id=\(CLIENT_ID)&redirect_uri=\(REDIRECT_URI)&response_type=code&scope=public"
        OSManager.openUrl(url)
    }

    fileprivate func fetchImage(_ resourceUrl: String) {
        let session = URLSession.shared
        let url = URL(string: BASE_API_URL + resourceUrl)

        NSLog("Processing: \(url)")

        let defaults = UserDefaults.standard
        if let accessToken = defaults.string(forKey: constants.keys.ACCESS_TOKEN) {
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let task = session.dataTask(with: request, completionHandler: self.processResponse)
            task.resume()
        } else {
            // notify user
        }
    }

    fileprivate func processResponse(_ data: Data?, response: URLResponse?, err: Error?) -> Void {
        if let error = err {
            NSLog("API error: \(error)")
        }
        if let httpResponse = response as? HTTPURLResponse {
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

    func requestToken(_ authorizationCode: String) {
        let session = URLSession.shared
        let url = URL(string: BASE_URL + "/oauth/token/")
        var request = URLRequest(url: url!)
        let data = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "redirect_uri": REDIRECT_URI,
            "code": authorizationCode,
            "grant_type": "authorization_code"
            ] as Dictionary<String, String>
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        try! request.httpBody = JSONSerialization.data(withJSONObject: data, options: [])
        let task = session.dataTask(with: request, completionHandler: { data, response, err in
            let json : JSONDict = self.parseData(data!)
            let defaults = UserDefaults.standard
            defaults.setValue(json["access_token"], forKey: constants.keys.ACCESS_TOKEN)
            defaults.setValue(json["refresh_token"], forKey: constants.keys.REFRESH_TOKEN)
        }) 
        task.resume()
    }

    func refreshToken() {
        let defaults = UserDefaults.standard
        let session = URLSession.shared
        let url = URL(string: BASE_URL + "/oauth/token/")
        var request = URLRequest(url: url!)
        let data = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "redirect_uri": REDIRECT_URI,
            "refresh_token": defaults.string(forKey: constants.keys.REFRESH_TOKEN)!,
            "grant_type": "refresh_token"
            ] as Dictionary<String, String>
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        try! request.httpBody = JSONSerialization.data(withJSONObject: data, options: [])
        let task = session.dataTask(with: request, completionHandler: { data, response, err in
            let json : JSONDict = self.parseData(data!)
            defaults.setValue(json["access_token"], forKey: constants.keys.ACCESS_TOKEN)
            defaults.setValue(json["refresh_token"], forKey: constants.keys.REFRESH_TOKEN)
        }) 
        task.resume()
    }

    fileprivate func parseData(_ data: Data) -> JSONDict {
        let json : JSONDict = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        return json
    }
    
}
