//
//  DepositController.swift
//  CheckWriter
//
//  Created by lip on 2/2/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

class DepositController: NSViewController {
    let today:Date = Date()
    var registerDate:String = ""
    var todayString = ""

    @IBOutlet weak var dateField: NSTextField!
    @IBOutlet weak var amountField: NSTextField!
    @IBOutlet weak var commentField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDate()
        // Do view setup here.
    }
    
    @IBAction func doDeposit(_ sender: Any) {
        print ("Doing a Deposit! \(amountField.floatValue)")
    }
    func setDate() {
        let dateFormatter = DateFormatter()
        let shortDate = DateFormatter()
        _ = dateFormatter.dateFormat = "d MMMM, yyyy"
        _ = shortDate.dateFormat = "d MMM yyyy"
        
        todayString = dateFormatter.string(from: today)
        registerDate = shortDate.string(from: today)
        dateField.stringValue = todayString;
    }
    
    
    
}
