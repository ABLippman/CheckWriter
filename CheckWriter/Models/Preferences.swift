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
            return (defaultPrinter)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "printer")
        }
    }
    var accountDir:String {
        get {
            let defaultAccount = UserDefaults.standard.string(forKey: "account")
            return (defaultAccount)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "account")
        }
    }}
