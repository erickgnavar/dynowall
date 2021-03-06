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
    @IBOutlet weak var currentFolderTextField: NSTextField!

    let defaults = UserDefaults.standard

    let api = UnsplashAPI()

    var status = false

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.checkStatus()
        self.loadSavedData()
    }
    
    @IBAction func authorizeClicked(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "A web page will be open to generate an authorization code, please copy that code and come back to complete the setup"
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            api.authorize()
        }
    }

    @IBAction func requestTokenClicked(_ sender: NSButton) {
        if authorizationCodeTextField.stringValue.count > 0 {
            api.requestToken(authorizationCodeTextField.stringValue)
        } else {
            let alert = NSAlert()
            alert.messageText = "Please enter the authorization code before request a token"
            alert.runModal()
        }
    }

    @IBAction func searchQueryChanged(_ sender: NSTextField) {
        defaults.setValue(searchQueryTextField.stringValue, forKey: constants.keys.QUERY)
    }

    @IBAction func chooseFolderClicked(_ sender: NSButton) {
        let panel = NSOpenPanel();
        panel.canChooseFiles = false;
        panel.canChooseDirectories = true;
        panel.canCreateDirectories = true;
        panel.begin { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                let path = panel.url?.path;
                UserDefaults.standard.set(path, forKey: constants.keys.FOLDER_PATH);
                self.currentFolderTextField.stringValue = path!
            }
        }
    }

    func checkStatus() {
        if let accessToken = defaults.string(forKey: constants.keys.ACCESS_TOKEN) {
            if accessToken.count != 0 {
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
        if let query = defaults.string(forKey: constants.keys.QUERY) {
            searchQueryTextField.stringValue = query
        }
        if let path = defaults.string(forKey: constants.keys.FOLDER_PATH) {
            currentFolderTextField.stringValue = path
        }
    }
}
