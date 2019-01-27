//
//  PrefsViewController.swift
//  CheckWriter
//
//  Created by lip on 1/27/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {
    @IBOutlet weak var accoutChoice: NSPopUpButton!
    @IBOutlet weak var printer: NSTextField!
    
    //  Preferences
    var prefs = Preferences()  //  Instantiate preferences
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showPrefs()
    }
    
    @IBAction func changeAccount(_ sender: Any) {
        print("Account changed ...")
    }
    
    @IBAction func cancelPref(_ sender: Any) {
        print("Cancel Prefs")
    }
    
    @IBAction func acceptPref(_ sender: Any) {
        print("Accept Prefs")
    }
    //  Preferences functions
    func showPrefs() {
        print ("Got here")
        // var cPrinter = prefs.checkPrinter  // Doesn't work yet
    }

    
}
