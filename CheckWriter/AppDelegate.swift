//
//  AppDelegate.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

let masterAppName = "New_Checkwriter"
var check = Check()
let register = Register()
let data=Data()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var name: NSMenuItem!
    let testConstant = "This is a constant in the app delegate"
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print ("App Launched, amount =  \(check.amount)")
        print ("App Launched, register date is \(register.date)")
        
        //  Preferences go here?
    
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func showName(_ sender: Any) {
        print(masterAppName)
    }
    
}

