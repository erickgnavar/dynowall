//
//  StatusMenuController.swift
//  DynoWall
//
//  Created by Erick Navarro on 6/8/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//

import Cocoa

protocol ImageProtocol: class {
    func imageDidUpdate(_ image: Image)
}

class StatusMenuController: NSObject, ImageProtocol {

    @IBOutlet weak var statusMenu: NSMenu!

    @IBOutlet weak var neverMenuItem: NSMenuItem!
    @IBOutlet weak var everyHourMenuItem: NSMenuItem!
    @IBOutlet weak var every3HoursMenuItem: NSMenuItem!
    @IBOutlet weak var every6HoursMenuItem: NSMenuItem!
    @IBOutlet weak var every12HoursMenuItem: NSMenuItem!
    @IBOutlet weak var imageDetails: NSMenuItem!

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var preferencesWindow: PreferencesWindow!

    let defaults = UserDefaults.standard
    let api = UnsplashAPI()

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        preferencesWindow = PreferencesWindow()
        self.loadSavedData()
        OSManager.sharedInstance.delegate = self // assign instance of controller to update menu data
    }

    @IBAction func openImagePage(_ sender: NSMenuItem) {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: constants.keys.IMAGE) {
            let image = Image.decode(data as! NSDictionary)
            OSManager.openUrl(image.url)
        } else {
            NSLog("No image saved")
        }
    }
    @IBAction func openAuthorProfilePage(_ sender: NSMenuItem) {
        if let data = defaults.value(forKey: constants.keys.IMAGE) {
            let image = Image.decode(data as! NSDictionary)
            OSManager.openUrl(image.user.url)
        } else {
            NSLog("No image saved")
        }
    }

    @IBAction func changeWallpaperClicked(_ sender: NSMenuItem) {
        api.delegate = self
        api.randomImage()
    }

    @IBAction func intervalClicked(_ sender: NSMenuItem) {
        disableAllIntervalItems()
        toggleIntervalMenuItem(sender)
    }

    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

    func imageDidUpdate(_ image: Image) {
        let defaults = UserDefaults.standard
        // is not possible save directly a struct in user preferences
        defaults.setValue(image.dict, forKey: constants.keys.IMAGE)
        imageDetails.title = "Photo by \(image.user.name)"
    }

    func loadSavedData() {
        // Setup interval from user preferences
        if let interval = defaults.string(forKey: constants.keys.INTERVAL) {
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
            defaults.set(constants.INTERVAL, forKey: constants.keys.INTERVAL)
        }
        // Setup photo data from user preferences
        if let data = defaults.value(forKey: constants.keys.IMAGE) {
            let image = Image.decode(data as! NSDictionary)
            imageDetails.title = "Photo by \(image.user.name)"
            imageDetails.isHidden = false
        } else {
            // Hide menu item if no exists image data saved in user preferences
            imageDetails.isHidden = true
            NSLog("No image saved")
        }
    }

    fileprivate func disableAllIntervalItems() {
        neverMenuItem.state = 0
        everyHourMenuItem.state = 0
        every3HoursMenuItem.state = 0
        every6HoursMenuItem.state = 0
        every12HoursMenuItem.state = 0
    }

    fileprivate func toggleIntervalMenuItem(_ item: NSMenuItem) {
        // use tag value as minutes quantity
        if item.state == 0 {
            item.state = 1
            OSManager.sharedInstance.setTimerInterval(item.tag)
        } else {
            item.state = 0
        }
        defaults.set(item.tag, forKey: constants.keys.INTERVAL)
    }

}
