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

    
    func storeRegisteredCheck() {
        let serialNumber: NSDate = NSDate() // new serialization date each time
        print ("Registering the Check")
        print ("\(date):\(Int (serialNumber.timeIntervalSince1970)):\(amount):\(payee):\(cat):\(memo):Out:")
        print (Int (serialNumber.timeIntervalSince1970))
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
    func changeAccount() {
        //  Close current accounts if any, open new account
        //  Called with account number
    }
}





class Data {
    var balance:Float = 1000.00
    var number:Int32 = 1000
    var categories = ["None","Home", "Miscellaneous", "Business"]
}
