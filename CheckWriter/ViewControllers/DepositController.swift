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
        amountField.becomeFirstResponder()  //  This does nothing
    }

    func setDate() {
        let dateFormatter = DateFormatter()
        let shortDate = DateFormatter()
        _ = dateFormatter.dateFormat = "d MMMM, yyyy"
        _ = shortDate.dateFormat = "d MMM yyyy"
        
        todayString = dateFormatter.string(from: today)
        registerDate = shortDate.string(from: today)
        dateField.stringValue = todayString;
        amountField.selectText(self)  //  This does nothing on startup
    }
    
    @IBAction func doDeposit(_ sender: Any) {
        print ("Doing a Deposit! \(amountField.floatValue)")
        setDate()  //  Reset the date for when the deposit is made
        check.seq = 0  //  Want this to be formatted as 0000
        check.amount = amountField.floatValue //  Want this to be formatted as well
        check.date = registerDate
        check.memo = fixRegisterText(commentField.stringValue)
        //  check.cat = "????"   //  We don't add a category for deposits yet but we could
        filer.registerCheck(account: currentAccount, checkData: check)
        myCheckController?.updateBalanceField(delta: amountField.floatValue)
        amountField.selectText(self)

    }

    @IBAction func doDebit(_ sender: Any) {
        print ("Doing a Debit! \(amountField.floatValue)")
        setDate()  //  Reset the date for when the deposit is made
        check.seq = 8000  //  Want this to be formatted as 0000
        check.amount = amountField.floatValue //  Want this to be formatted as well
        check.date = registerDate
        check.memo = fixRegisterText(commentField.stringValue)
        //  check.cat = "????"   //  We don't add a category for debits yet but we could
        filer.registerCheck(account: currentAccount, checkData: check)
        myCheckController?.updateBalanceField(delta: -amountField.floatValue)
        amountField.selectText(self)

    }

    
}
