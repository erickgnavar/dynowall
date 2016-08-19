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

    var timer: NSTimer!

    override private init() {
        super.init()
        if let interval = NSUserDefaults.standardUserDefaults().stringForKey(constants.keys.INTERVAL) {
            if Int(interval)! > 0 {
                self.timer = self.createTimer(Int(interval)!)
            }
        }
    }

    func setTimerInterval(interval: Int) {
        // interval must be in minutes
        if (self.timer != nil) {
            self.timer.invalidate() // invalidate previous timer
            NSLog("Previous timer invalidated")
        }
        if interval > 0 {
            self.timer = self.createTimer(interval)
        }
    }

    private func createTimer(interval: Int) -> NSTimer {
        NSLog("New timer created")
        return NSTimer.scheduledTimerWithTimeInterval(60 * Double(interval), target: self, selector: #selector(OSManager.requestNewImage), userInfo: nil, repeats: true)
    }

    func requestNewImage() {
        let api = UnsplashAPI()
        api.delegate = delegate
        api.randomImage()
    }

    static func openUrl(url: String) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
    }

    static func setWallpaper(imageUrl: String, fileName: String) {
        let imagesPath = "/tmp/images/"   
        let sharedWorkspace = NSWorkspace.sharedWorkspace()
        let mainScreen = NSScreen.mainScreen()

        let fileManager = NSFileManager.defaultManager()

        try! fileManager.createDirectoryAtPath(imagesPath, withIntermediateDirectories: true, attributes: [:]) // try to create the image directory if not exists

        let session = NSURLSession.sharedSession()
        let task = session.downloadTaskWithURL(NSURL(string: imageUrl)!) { location, response, err in
            if let error = err {
                NSLog("Download error: \(error)")
            }
            do {
                let path = imagesPath + fileName
                let destination = NSURL.fileURLWithPath(path)
                try fileManager.moveItemAtURL(location!, toURL: destination)
                try sharedWorkspace.setDesktopImageURL(NSURL.fileURLWithPath(path), forScreen: mainScreen!, options: [:])
            } catch(let error) {
                NSLog("Error: \(error)")
            }
        }
        task.resume()
    }

}