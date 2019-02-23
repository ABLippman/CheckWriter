//
//  PrefsViewController.swift
//  CheckWriter
//
//  Created by lip on 1/27/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var a: NSTextField!
    @IBOutlet weak var p: NSTextField!
    
    
    //  Preferences
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showExistingPrefs()
        self.a.delegate = self
    }
    
    override func viewDidAppear() { // This occurs later than the load...
        super.viewDidAppear()
        self.view.window?.title = "Checkwriter preferences"
    }
    
    @IBAction func cancelPref(_ sender: Any) {
        print("Cancel Prefs")
        self.view.window?.close()
    }
    
    @IBAction func acceptPref(_ sender: Any) {
        print("Accept Prefs")
        prefs.printer = p.stringValue 
        prefs.accountDir = a.stringValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"), object: nil)
        self.view.window?.close()
    }
    //  Preferences functions
    func showExistingPrefs() {  // check defaults
        print ("Got here")
        p.stringValue = prefs.printer
        a.stringValue = prefs.accountDir
    }
    //  Code to make text field press button
    //  This has to be bogus.  ANY text field will do it
    func textFieldShouldReturn(textField: NSTextField) -> Bool {
    textField.resignFirstResponder()  //if desired
        acceptPref(self)
    return true
    }

}
