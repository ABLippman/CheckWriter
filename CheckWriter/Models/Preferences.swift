//
//  Preferences.swift
//  CheckWriter
//
//  Created by lip on 1/27/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//
/*
 *  User Defaults code goes here.
 *  NOTE:  Defaults command line access is Lippman.CHeckWriter
 *  No idea why it needs a capital H
 *
 *  Quick and dirty slider for volumer control  Did not scale slider, just /100 the default
 *  Doesn't play a sound on slider change
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

    var volume:Float? {
        get {
            let defaultVolume = UserDefaults.standard.string(forKey: "volume")
            if (defaultVolume) != nil {
                return Float(defaultVolume!)}
            return 0.25
            
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "volume")
        }
    }
}
