//
//  Register.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Foundation
class Register {
    var amount = "00.0"
    var date = "Some Date   "
    var payee = "Nobody"
    var cat = "None"
    
    func printData() {
        print ("Registering the Check")
        print (amount)
        print (payee)
        print ("Category = \(cat)")
    }
}
class Data {
    var balance:Float = 1000.00
    var number:Int32 = 1000
    var categories = ["Home", "Miscellaneous", "Business"]
}
