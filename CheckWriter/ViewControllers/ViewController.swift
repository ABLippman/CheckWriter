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
 
 // MARK: - Preferences
    
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
    @IBOutlet weak var numberField: NSTextField!
    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet weak var updateChosen: NSButton!
    @IBOutlet weak var printChosen: NSButton!
    @IBOutlet weak var sequenceButton: NSButton!
    
    
    @IBOutlet weak var jointAccount: NSButton!
    @IBOutlet weak var andyAccount: NSButton!
    @IBOutlet weak var llcAccount: NSButton!
    var prefs = Preferences()
   
    let today:NSDate = NSDate()
    var registerDate:String = ""
    var todayString = ""
    var categoryChosen:Bool = false
    var category:String = "None"
    var moneyMaker: MoneyMaker = MoneyMaker()
    let appDelegate = NSApplication.shared.delegate as! AppDelegate  // We now have a reference to the app delegate...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDate()  //And display it in dateField
        print ("View did load")
        data.categories.forEach {entry in
            categoryPopup.addItem(withTitle:entry)
        }
        self.setupPrefs()
    }
    
    override func viewDidAppear() { // This occurs later than the load...
        super.viewDidAppear()
        print ("View Appeared")
        radioButtonChanged(AnyObject.self as AnyObject)
        numberField.intValue = data.number
        print (" AccountRoot is: \(prefs.accountDir)")
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
    }
    
    @IBAction func toEntered(_ sender: Any) {
    }
    
    @IBAction func memoEntered(_ sender: Any) {
    }
    
    @IBAction func setCategoryChosen(_ sender: NSPopUpButton) {
        categoryChosen = true
        category = categoryPopup.selectedItem?.title ?? "None"
    }
    
    @IBAction func issueCheck(_ sender: Any) {
        
        /*  Main routine
         *   sets printer, verifies category
         *   Prints if req'd, registers if req'd
         */
        //  Currently bypasses Check structure, is there a need?
        
        printACheck.p = prefs.printer as NSString  //  Set printer from Prefs each time...
        if !categoryChosen {
            category = "None"
            let answer = alertOKCancel(question: "No Category", text: "Please enter a category, proceed?")
            if !answer { return }
        }
        else {
            register.cat = category
        }

        if updateChosen.state == NSControl.StateValue.on {
            print ("Update button: \(updateChosen)")
            register.amount = amountField.floatValue
            register.date = registerDate
            register.payee = toField.stringValue
            register.memo = memoField.stringValue
            register.cat = (categoryPopup.selectedItem?.title)!
            register.storeRegisteredCheck()  // Now we have to write this to a file. Perhaps via ObjC intermediary
            balanceField.floatValue = register.updateBalance(amt: balanceField.floatValue)
            if sequenceButton != nil {
                numberField.intValue = register.updateSequence(num: numberField.intValue)
            }
        }
        
        if printChosen.state == NSControl.StateValue.on {
            printACheck.amount = amountField.stringValue as NSString
            printACheck.date = todayString as NSString
            printACheck.payee = toField.stringValue as NSString
            printACheck.memo1 = memoField.stringValue as NSString
            printACheck.numText = output.stringValue as NSString
            printACheck.printWithNoPanel(self) // PRINTS the check
        }
        categoryChosen = false; category = "None"; register.cat = "None"  //Reset category selection, cat req'd for each check
        
        categoryPopup.selectItem(at: 0)
        // self.becomeFirstResponder()
        // amountField.selectText(sender)
        self.amountField.becomeFirstResponder()
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
    
    func updateFromPrefs() {
        print("Got the Preference notification")
    }
    
}


