//
//  StatusMenuController.swift
//  DynoWall
//
//  Created by Erick Navarro on 6/8/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//

import Cocoa

protocol ImageProtocol: class {
    func imageDidUpdate(image: Image)
}


class StatusMenuController: NSObject, ImageProtocol {

    @IBOutlet weak var statusMenu: NSMenu!

    @IBOutlet weak var neverMenuItem: NSMenuItem!
    @IBOutlet weak var everyHourMenuItem: NSMenuItem!
    @IBOutlet weak var every3HoursMenuItem: NSMenuItem!
    @IBOutlet weak var every6HoursMenuItem: NSMenuItem!
    @IBOutlet weak var every12HoursMenuItem: NSMenuItem!
    @IBOutlet weak var imageDetails: NSMenuItem!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var preferencesWindow: PreferencesWindow!

    let defaults = NSUserDefaults.standardUserDefaults()
    let api = UnsplashAPI()

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        preferencesWindow = PreferencesWindow()
        self.loadSavedData()
    }

    @IBAction func openImagePage(sender: NSMenuItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.valueForKey(constants.keys.IMAGE) {
            let image = Image.decode(data as! NSDictionary)
            OSManager.openUrl(image.url)
        } else {
            NSLog("No image saved")
        }
    }
    @IBAction func openAuthorProfilePage(sender: NSMenuItem) {
        if let data = defaults.valueForKey(constants.keys.IMAGE) {
            let image = Image.decode(data as! NSDictionary)
            OSManager.openUrl(image.user.url)
        } else {
            NSLog("No image saved")
        }
    }

    @IBAction func changeWallpaperClicked(sender: NSMenuItem) {
        api.delegate = self
        api.randomImage()
    }

    @IBAction func intervalClicked(sender: NSMenuItem) {
        disableAllIntervalItems()
        toggleIntervalMenuItem(sender)
    }

    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
        NSApp.activateIgnoringOtherApps(true)
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func imageDidUpdate(image: Image) {
        let defaults = NSUserDefaults.standardUserDefaults()
        // is not possible save directly a struct in user preferences
        defaults.setValue(image.dict, forKey: constants.keys.IMAGE)
        imageDetails.title = "Photo by \(image.user.name)"
    }

    func loadSavedData() {
        // Setup interval from user preferences
        if let interval = defaults.stringForKey(constants.keys.INTERVAL) {
            disableAllIntervalItems()
            switch Int(interval)! {
            case 0:
                neverMenuItem.state = 1
            case 60:
                everyHourMenuItem.state = 1
            case 60 * 3:
                every3HoursMenuItem.state = 1
            case 60 * 6:
                every6HoursMenuItem.state = 1
            case 60 * 12:
                every12HoursMenuItem.state = 1
            default:
                NSLog("Value not considered")
            }
        } else {
            defaults.setInteger(constants.INTERVAL, forKey: constants.keys.INTERVAL)
        }
        // Setup photo data from user preferences
        if let data = defaults.valueForKey(constants.keys.IMAGE) {
            let image = Image.decode(data as! NSDictionary)
            imageDetails.title = "Photo by \(image.user.name)"
            imageDetails.hidden = false
        } else {
            // Hide menu item if no exists image data saved in user preferences
            imageDetails.hidden = true
            NSLog("No image saved")
        }
    }

    private func disableAllIntervalItems() {
        neverMenuItem.state = 0
        everyHourMenuItem.state = 0
        every3HoursMenuItem.state = 0
        every6HoursMenuItem.state = 0
        every12HoursMenuItem.state = 0
    }

    private func toggleIntervalMenuItem(item: NSMenuItem) {
        // use tag value as minutes quantity
        if item.state == 0 {
            item.state = 1
            OSManager.sharedInstance.setTimerInterval(item.tag)
        } else {
            item.state = 0
        }
        defaults.setInteger(item.tag, forKey: constants.keys.INTERVAL)
    }

}