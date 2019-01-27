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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
}
