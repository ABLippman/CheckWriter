//
//  PrefsViewController.swift
//  CheckWriter
//
//  Created by lip on 1/27/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {

    @IBOutlet weak var a: NSTextField!
    @IBOutlet weak var p: NSTextField!
    
    //  Preferences
    var prefs = Preferences()  //  Instantiate preferences
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showExistingPrefs()
    }
    
    @IBAction func cancelPref(_ sender: Any) {
        print("Cancel Prefs")
    }
    
    @IBAction func acceptPref(_ sender: Any) {
        print("Accept Prefs")
        prefs.printer = p.stringValue 
        prefs.accountDir = a.stringValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }
    //  Preferences functions
    func showExistingPrefs() {  // check defaults
        print ("Got here")
        let selectedPrinter = prefs.printer
    }


}
