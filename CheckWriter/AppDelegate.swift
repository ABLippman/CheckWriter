//
//  AppDelegate.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

let masterAppName = "New_Checkwriter"
let check = Check()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var name: NSMenuItem!
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print ("App Launched, amount =  \(check.amount)")
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func showName(_ sender: Any) {
        print(masterAppName)
    }
    
}

