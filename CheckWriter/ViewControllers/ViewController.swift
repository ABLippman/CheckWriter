//
//  ViewController.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    @IBOutlet weak var amountField: NSTextField!
    @IBOutlet weak var output: NSTextField!
    @IBOutlet weak var dateField: NSTextFieldCell!
    @IBOutlet weak var toField: NSTextField!
    @IBOutlet weak var memoField: NSTextField!
    @IBOutlet weak var balanceField: NSTextField!
    @IBOutlet weak var numberField: NSTextField!
    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet weak var updateChosen: NSButton!
    @IBOutlet weak var printChosen: NSButton!
    
    
    @IBOutlet weak var jointAccount: NSButton!
    @IBOutlet weak var andyAccount: NSButton!
    @IBOutlet weak var llcAccount: NSButton!
   
    let today:NSDate = NSDate()
    var registerDate:String = ""
    var todayString = ""
    var categoryChosen:Bool = false
    var category:String = "None"
    var moneyMaker: MoneyMaker = MoneyMaker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDate()  //And display it in dateField
        print ("View did load")
        data.categories.forEach {entry in
            categoryPopup.addItem(withTitle:entry)
        }
    }
    
    override func viewDidAppear() { // This occurs later than the load...
        super.viewDidAppear()
        print ("View Appeared")
        radioButtonChanged(AnyObject.self as AnyObject)
        numberField.intValue = data.number
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            print ("Represented Object")  // No idea about this
        }
    }
    
    //  Make radio buttons group action
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        print("Account Changed")
        if jointAccount.state == NSControl.StateValue.on {
            print ("Joint Account Chosen")
            self.view.window?.title = "CheckWriter: Joint Account"
        }
        else if andyAccount.state == NSControl.StateValue.on {
            print ("Andy account selected")
            self.view.window?.title = "CheckWriter: Andy's Account"
        }
        else if llcAccount.state == NSControl.StateValue.on {
            print ("LLC Account selected")
            self.view.window?.title = "CheckWriter: LLC Account"
        }
    }
    
    
    @IBAction func amountEntered(_ sender: Any) {
        output.stringValue = moneyMaker.makeMoney(amountField.stringValue)
        print("Amount Entered")
    }
    
    @IBAction func toEntered(_ sender: Any) {
        print("Recipient Entered")
    }
    
    @IBAction func memoEntered(_ sender: Any) {
        print("Memo Entered")
    }
    
    @IBAction func setCategoryChosen(_ sender: NSPopUpButton) {
        categoryChosen = true
        category = categoryPopup.selectedItem?.title ?? "None"
    }
    
    @IBAction func printCheck(_ sender: Any) {
        //  First check category, then proceed...
        
        if !categoryChosen {
            category = "None"
            let answer = alertOKCancel(question: "No Category", text: "Please enter a category, proceed?")
            if !answer { return }
        }
        else {
            register.cat = category
        }
        
        print(amountField.stringValue)
        print (moneyMaker.makeMoney(amountField.stringValue))
        // self.becomeFirstResponder()
        // amountField.selectText(sender)
        self.amountField.becomeFirstResponder()
        check.amount  = output.stringValue
        print ("Printing a check for: \(check.amount)")
        if updateChosen != nil {
            register.amount = amountField.floatValue
            register.date = registerDate
            register.payee = toField.stringValue
            register.memo = memoField.stringValue
            register.printData()  // Now we have to write this to a file. Perhaps via ObjC intermediary
        }
        if printChosen != nil {
            check.amount = amountField.stringValue
            check.date = todayString
            check.payee = toField.stringValue
            check.memo = memoField.stringValue
            check.amountWords = output.stringValue
            check.printData()  // use when Check is a class rather than struct
            // Use the following when Check is a struct
            // print ("Printed check: \(check.date):\(check.amount):\(check.payee):\(check.cat):\(check.memo)")
        }
        categoryChosen = false; category = "None"; register.cat = "None"  //Reset category selection, cat req'd for each check
    }
    
    @IBAction func showName(_ sender: Any) {
        print(masterAppName)
    }
    
    
    
    func setDate() {
        let dateFormatter = DateFormatter()
        let shortDate = DateFormatter()
        
        _ = dateFormatter.dateFormat = "d MMMM, yyyy"
        _ = shortDate.dateFormat = "d MMM yyyy"
        
        
        todayString = dateFormatter.string(from: today as Date);
        registerDate = shortDate.string(from: today as Date)
        dateField.stringValue = todayString;
    }
    
    func alertOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    

    
}


