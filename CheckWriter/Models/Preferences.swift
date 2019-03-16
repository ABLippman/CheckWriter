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
   var accountDir:URL {  // for some reason this gets called a lot...
        get {
            let defaultAccount = UserDefaults.standard.string(forKey: "account")
            if (defaultAccount) != nil {
//                print ("Default account is: \(defaultAccount!)")
                return URL.init(fileURLWithPath:defaultAccount!)
            }
            return URL.init(fileURLWithPath: "/Users/lip/Check")
        }
        set {
            UserDefaults.standard.set(newValue.path, forKey: "account")
        }
    }
}
