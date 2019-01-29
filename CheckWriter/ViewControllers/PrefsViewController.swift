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
        showPrefs()
    }
    
    @IBAction func cancelPref(_ sender: Any) {
        print("Cancel Prefs")
    }
    
    @IBAction func acceptPref(_ sender: Any) {
        print("Accept Prefs")
        prefs.printer = p.stringValue  // this seems wrong with prefs as a struct...
        prefs.accountDir = a.stringValue
    }
    //  Preferences functions
    func showPrefs() {  // check defaults
        print ("Got here")
        // var cPrinter = prefs.checkPrinter  // Doesn't work yet
    }

    
}
