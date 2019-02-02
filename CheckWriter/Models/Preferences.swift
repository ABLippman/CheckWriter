//
//  Preferences.swift
//  CheckWriter
//
//  Created by lip on 1/27/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Foundation
struct Preferences {
    var printer:String {
        get {
            let defaultPrinter = UserDefaults.standard.string(forKey: "printer")
            if (defaultPrinter) != "" {
                return defaultPrinter!}
            return "Lip_Upstairs"
        
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "printer")
        }
    }
    var accountDir:String {
        get {
            let defaultAccount = UserDefaults.standard.string(forKey: "account")
            if (defaultAccount) != "" {
                return defaultAccount!
            }
            return "~/tmp"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "account")
        }
    }
    
}
