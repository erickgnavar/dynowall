//
//  OSController.swift
//  DynoWall
//
//  Created by Erick Navarro on 6/9/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//


import Foundation
import AppKit

class OSManager: NSObject {

    static let sharedInstance = OSManager()
    weak var delegate: ImageProtocol?

    var timer: Timer!

    override fileprivate init() {
        super.init()
        if let interval = UserDefaults.standard.string(forKey: constants.keys.INTERVAL) {
            if Int(interval)! > 0 {
                self.timer = self.createTimer(Int(interval)!)
            }
        }
    }

    func setTimerInterval(_ interval: Int) {
        // interval must be in minutes
        if (self.timer != nil) {
            self.timer.invalidate() // invalidate previous timer
            NSLog("Previous timer invalidated")
        }
        if interval > 0 {
            self.timer = self.createTimer(interval)
        }
    }

    fileprivate func createTimer(_ interval: Int) -> Timer {
        NSLog("New timer created")
        return Timer.scheduledTimer(timeInterval: 60 * Double(interval), target: self, selector: #selector(OSManager.requestNewImage), userInfo: nil, repeats: true)
    }

    func requestNewImage() {
        let api = UnsplashAPI()
        api.delegate = delegate
        api.randomImage()
    }

    static func openUrl(_ url: String) {
        NSWorkspace.shared().open(URL(string: url)!)
    }

    static func setWallpaper(_ imageUrl: String, fileName: String) {
        var imagesPath = "/tmp/images/"

        if let path = UserDefaults.standard.string(forKey: constants.keys.FOLDER_PATH) {
            imagesPath = path + "/"
        }

        let sharedWorkspace = NSWorkspace.shared()
        let mainScreen = NSScreen.main()

        let fileManager = FileManager.default

        try! fileManager.createDirectory(atPath: imagesPath, withIntermediateDirectories: true, attributes: [:]) // try to create the image directory if not exists

        let session = URLSession.shared
        let task = session.downloadTask(with: URL(string: imageUrl)!, completionHandler: { location, response, err in
            if let error = err {
                NSLog("Download error: \(error)")
            }
            do {
                let path = imagesPath + fileName
                let destination = URL(fileURLWithPath: path)
                try fileManager.moveItem(at: location!, to: destination)
                try sharedWorkspace.setDesktopImageURL(URL(fileURLWithPath: path), for: mainScreen!, options: [:])
            } catch(let error) {
                NSLog("Error: \(error)")
            }
        }) 
        task.resume()
    }

}
