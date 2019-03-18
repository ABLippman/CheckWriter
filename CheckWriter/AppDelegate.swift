//
//  AppDelegate.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//
/*
 *  Delegate now creates global LipScrollView for printing
 *
 */

import Cocoa

let masterAppName = "New_Checkwriter"
// var check = Check()  // Global for both deposits and checks
let data=Data()
let prefs = Preferences()  //  Instantiate preferences GLOBAL
let filer = FileInterface()  // Instantiate file Manager GLOBAL
let printACheck:LipScrollView = LipScrollView.init(frame: NSMakeRect(0, 0, (8.0*72), (10.5*72))) //  Creates the check printing view with appropriate frame size. MARGINS!!!
var currentAccount = "16641301"
var myCheckController:ViewController? = nil   //  Trying to do it via a global

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var name: NSMenuItem!
    let testConstant = "This is a constant in the app delegate"
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print("Startup... Printer is \(prefs.printer), account is \(prefs.accountDir)")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func showName(_ sender: Any) {
        print(masterAppName)
    }
    
}

