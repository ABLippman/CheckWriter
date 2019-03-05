//
//  ViewController.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//
/*
 *   Note that this controller sets up and initializes the print view (called
 *  LipScrollView for historical reasons...
 *
 *
 */

import Cocoa


extension ViewController {
    
  //  Insert notification code here
    func setupPrefs() {
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                                                self.updateFromPrefs()
        }
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var amountField: NSTextField!
    @IBOutlet weak var output: NSTextField!
    @IBOutlet weak var dateField: NSTextFieldCell!
    @IBOutlet weak var toField: NSTextField!
    @IBOutlet weak var memoField: NSTextField!
    @IBOutlet weak var balanceField: NSTextField!
    @IBOutlet weak var numberField: NSTextField!  //  Wants to be an int or unpolluted string, no \n
    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet weak var updateChosen: NSButton!
    @IBOutlet weak var printChosen: NSButton!
    @IBOutlet weak var sequenceButton: NSButton!
    @IBOutlet weak var doIt: NSButton!
    @IBOutlet weak var manual: NSButton!
    @IBOutlet weak var accountPulldown: NSPopUpButton!
    
    

    var prefs = Preferences()
    let today:Date = Date()
    var registerDate:String = ""
    var todayString = ""
    var categoryChosen:Bool = false
    var moneyMaker: MoneyMaker = MoneyMaker()
    let appDelegate = NSApplication.shared.delegate as! AppDelegate  // We now have a reference to the app delegate...
    var accountInfo:[[String]] = []  // Global for the array of account arrays
    
    func setDate() {
        let dateFormatter = DateFormatter()
        let shortDate = DateFormatter()
        _ = dateFormatter.dateFormat = "d MMMM, yyyy"
        _ = shortDate.dateFormat = "d MMM yyyy"
        
        todayString = dateFormatter.string(from: today)
        registerDate = shortDate.string(from: today)
        dateField.stringValue = todayString;
    }
    
    func initializeInterfaceForAccounts() {
        //  Uses Global Accounts array of arrays, fills in acccounts Pulldown
        accountInfo = filer.findAccounts()
        for  i in 0..<accountInfo.count {
            accountPulldown.addItem(withTitle: accountInfo[i][3])
        }
    }
    
    func initializeAccount (account a:[String]){    //  Fill in the title, Balance, seq, and cats for an account
        self.view.window?.title = a[3]
        balanceField.stringValue = filer.balance(account: a[0])!
        self.colorBalanceField()
        numberField.stringValue = filer.seq(account: a[0])
        for i in 0..<filer.cat(account: a[0]).count {
            categoryPopup.addItem(withTitle: filer.cat(account: a[0])[i])
        }
    }
    
    func colorBalanceField() {
        //  Dirty code in that it talks directly to interface
        if balanceField.floatValue < 0.0 {
            balanceField.backgroundColor = NSColor.red
        }
        else {
            balanceField.backgroundColor = NSColor.green.withAlphaComponent(0.999)
        }
    }
    
    func fixRegisterText(_ s:String) -> String {
        var q = ""
        for char in s { char == ":" ? q.append("-") : q.append(char)}
        return q
    }
    
    func alertOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Proceed")
        alert.addButton(withTitle: "Fix")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func updateFromPrefs() {  // does nothing now, should if account base changes...
        print("Got the Preference notification")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDate()  //  ****  Should be Duplicated in issue check.  Set Date then, and at launch
        setupPrefs()
    }

    override func viewDidAppear() { // This occurs later than the load...
        super.viewDidAppear()
        print (" AccountRoot is: \(prefs.accountDir)")
        manual.state = NSControl.StateValue.off
        initializeInterfaceForAccounts()
        initializeAccount(account: accountInfo[0]) //  Use first account in accounts file
    }

    /*  WHy do we need this???
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            print ("Represented Object")  // No idea about this
        }
    }
    */
    
    @IBAction func accountPulldownChanged(_ sender: AnyObject) {
        print("Account Changed")
        //  THis is now hard.  Have to get the array, not just the number
        //  Iterate through the accounts until the number matches the pulldown title
        for i in 0..<accountInfo.count {
            if accountInfo[i][3] == accountPulldown.titleOfSelectedItem {
                initializeAccount(account: accountInfo[i])
            }
        }
    }
    
    @IBAction func amountEntered(_ sender: Any) {
        output.stringValue = moneyMaker.makeMoney(amountField.stringValue)
    }
    
    @IBAction func toEntered(_ sender: Any) {
        toField.stringValue = fixRegisterText(toField.stringValue)
    }
    
    @IBAction func memoEntered(_ sender: Any) {
        memoField.stringValue = fixRegisterText(memoField.stringValue)
    }
    
    @IBAction func setCategoryChosen(_ sender: NSPopUpButton) {
        categoryChosen = true
    }

    @IBAction func issueCheck(_ sender: Any) {
        
        /*  Main routine
         *   sets printer, verifies category
         *   Prints if req'd, registers if req'd
         */
        //  Currently bypasses Check structure, is there a need for it?
        
        self.setDate()  //  Why not reset the date in case it runs overnight...
        if categoryChosen {
            register.cat = (categoryPopup.selectedItem?.title)!
        }
        else {
            let answer = alertOKCancel(question: "No Category", text: "Please enter a category, proceed?")
            if !answer { return }
        }
        
        if updateChosen.state == NSControl.StateValue.on {
            check.seq = numberField.integerValue
            check.amount = amountField.floatValue
            check.date = registerDate
            check.payee = toField.stringValue
            check.memo = memoField.stringValue
            check.cat = (categoryPopup.selectedItem?.title)!
            filer.registerCheck(account: "16641301", checkData:check)  //  Need to fix for accounts and lose checks!!!
            //  Finish update details:  Update seq and bal only when registering a check
            if sequenceButton != nil {
                numberField.intValue += 1
                filer.updateSeq(account: "16641301", sequence: numberField.stringValue)  // This is correct for new FileInterface
            }
            balanceField.floatValue -= amountField.floatValue
            _ = filer.balance(account: "16641301", balance: balanceField.stringValue)  //  Result is unused
            self.colorBalanceField()
        }

        
        
        if printChosen.state == NSControl.StateValue.on {
            printACheck.p = prefs.printer as NSString  //  Set printer from Prefs each time...
            printACheck.number = numberField.stringValue as NSString
            printACheck.amount = amountField.stringValue as NSString
            printACheck.date = todayString as NSString
            printACheck.payee = toField.stringValue as NSString
            printACheck.memo1 = memoField.stringValue as NSString
            printACheck.numText = output.stringValue as NSString
            printACheck.printWithNoPanel(self) // PRINTS the check
        }
        //  Finish setting up for next check...

        categoryChosen = false
        categoryPopup.selectItem(at: 0)  // Revert to first title == "None"
        self.amountField.becomeFirstResponder()
    }
    
    @IBAction func showName(_ sender: Any) {
        print(masterAppName)
    }
   

}


