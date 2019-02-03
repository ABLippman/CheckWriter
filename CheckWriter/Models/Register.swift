//
//  Register.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Foundation
class Register {
    var amount:Float = 0.0
    var date = "Some Date"
    var payee = "Nobody"
    var cat = "None"
    var memo = ""
    var serialNumber: NSDate = NSDate()
    
    func storeRegisteredCheck() {
        print ("Registering the Check")
        print ("\(date):\(amount):\(payee):\(cat):\(memo)")
        print (serialNumber)
    }
    func updateBalance(amt:Float) -> Float {
        let newBalance = amt - amount
        print("Writing Balance to file, \(newBalance)")
        return newBalance
    }
    func updateSequence(num:Int32) -> Int32 {
        let newSeq = num + 1
        print ("Writing Seq to file: \(newSeq)")
        return newSeq
    }
    func closeAllFiles(account:String){
        print("Closing Balance, Sequence, register and cats? for account \(account)")
    }
    func openAccount(account:String) {
        print ("Opening account \(account)")
    }
}





class Data {
    var balance:Float = 1000.00
    var number:Int32 = 1000
    var categories = ["None","Home", "Miscellaneous", "Business"]
}
