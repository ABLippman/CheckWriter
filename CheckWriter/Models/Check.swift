//
//  Check.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Foundation
class Check {  // playing with struct rather than class for value-based rather than reference-based
    var seq:Int = 1
    var amount:Float = 00.0
    var date = "today"
    var payee = "Nobody"
    var cat = "None"
    var memo = "None"
    var amountWords = "No Dollars"
    
    func printData() {  // UNUSED 5/7/18
        Swift.print ("Printed check: \(check.seq):\(check.date):\(check.amount):\(amountWords):\(check.payee):\(check.cat):\(check.memo)")
    }
}
