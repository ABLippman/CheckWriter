//
//  Preferences.swift
//  CheckWriter
//
//  Created by lip on 1/27/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//
/*
 *  User Defaults code goes here.
 *
 */

import Foundation
class Preferences {
    

    var printer:String {
        get {
            let defaultPrinter = UserDefaults.standard.string(forKey: "printer")
            if (defaultPrinter) != nil {
                return defaultPrinter!}
            return "Lip_Upstairs"
        
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "printer")
        }
    }
/*    var accountDir:URL {
        get {
            let defaultAccount = UserDefaults.standard.string(forKey: "account")
            if (defaultAccount) != nil {
                return URL.init(fileURLWithPath:defaultAccount!)
            }
            return URL.init(fileURLWithPath: "~/tmp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "account")
        }
    }
 */
    var accountDir:URL {
        get {return URL.init(fileURLWithPath:"/Users/lip/tmp")}
        set {}
    }

    
}
