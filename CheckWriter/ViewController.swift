//
//  ViewController.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

let today:NSDate = NSDate()
class ViewController: NSViewController {
    @IBOutlet weak var amountField: NSTextField!
    @IBOutlet weak var output: NSTextField!
    @IBOutlet weak var dateField: NSTextFieldCell!
    @IBOutlet weak var toField: NSTextField!
    @IBOutlet weak var memoField: NSTextField!
    @IBOutlet weak var balanceField: NSTextField!
    
    
    @IBOutlet weak var jointAccount: NSButton!
    @IBOutlet weak var andyAccount: NSButton!
    @IBOutlet weak var llcAccount: NSButton!
    
    
    var moneyMaker: MoneyMaker = MoneyMaker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDate()  //And display it in dateField
        radioButtonChanged(AnyObject.self as AnyObject)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    //  Make radio buttons group action
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        print("Account Changed")
        if jointAccount.state == NSControl.StateValue.on {
            print ("Joint Account Chosen")
        }
        else if andyAccount.state == NSControl.StateValue.on {
            print ("Andy account selected")
        }
        else if llcAccount.state == NSControl.StateValue.on {
            print ("LLC Account selected")
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
    
    @IBAction func printCheck(_ sender: Any) {
        print(amountField.stringValue)
        print (moneyMaker.makeMoney(amountField.stringValue))
        // self.becomeFirstResponder()
        // amountField.selectText(sender)
        self.amountField.becomeFirstResponder()

    }
    
    func setDate() {
        let dateFormatter = DateFormatter()
        let shortDate = DateFormatter()
        
        _ = dateFormatter.dateFormat = "d MMMM, yyyy"
        _ = shortDate.dateFormat = "d MMM yyyy"
        
        
        let todayString = dateFormatter.string(from: today as Date);
        let shortString = shortDate.string(from: today as Date)
        dateField.stringValue = todayString;
        // registerDate = [shortDate stringFromDate:today];
        //  Just to see if the short date works...
        print (shortString)
    }
    
}


