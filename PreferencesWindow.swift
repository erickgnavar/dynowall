//
//  PreferencesWindow.swift
//  DynoWall
//
//  Created by Erick Navarro on 6/8/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController {

    @IBOutlet weak var authorizationCodeTextField: NSTextField!
    @IBOutlet weak var searchQueryTextField: NSTextField!
    @IBOutlet weak var statusTextField: NSTextField!

    let defaults = NSUserDefaults.standardUserDefaults()

    let api = UnsplashAPI()

    var status = false

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)

        self.checkStatus()
        self.loadSavedData()
    }
    
    @IBAction func authorizeClicked(sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "A web page will be open to generate an authorization code, please copy that code and come back to complete the setup"
        alert.addButtonWithTitle("Continue")
        alert.addButtonWithTitle("Cancel")
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            api.authorize()
        }
    }

    @IBAction func requestTokenClicked(sender: NSButton) {
        if authorizationCodeTextField.stringValue.characters.count > 0 {
            api.requestToken(authorizationCodeTextField.stringValue)
        } else {
            let alert = NSAlert()
            alert.messageText = "Please enter the authorization code before request a token"
            alert.runModal()
        }
    }

    @IBAction func searchQueryChanged(sender: NSTextField) {
        defaults.setValue(searchQueryTextField.stringValue, forKey: constants.keys.QUERY)
    }

    func checkStatus() {
        if let accessToken = defaults.stringForKey(constants.keys.ACCESS_TOKEN) {
            if accessToken.characters.count != 0 {
                status = true
            }
        }
        // UI actions
        let message: String

        if status {
            message = "Everything is OK"
        } else {
            message = "Please authorize the application"
        }
        statusTextField.stringValue = message
    }

    func loadSavedData() {
        if let query = defaults.stringForKey(constants.keys.QUERY) {
            searchQueryTextField.stringValue = query
        }
    }
}
