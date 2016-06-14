//
//  AppDelegate.swift
//  DynoWall
//
//  Created by Erick Navarro on 6/8/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let defaults = NSUserDefaults.standardUserDefaults()
        if let interval = defaults.stringForKey(constants.keys.INTERVAL) {
            OSManager.sharedInstance.setTimerInterval(Int(interval)!)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

