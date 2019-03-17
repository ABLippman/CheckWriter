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
    @IBOutlet weak var batchButton: NSButton!
    @IBOutlet weak var autButton: NSButton!
    

    let today:Date = Date()
    var registerDate:String = ""
    var todayString = ""
    var categoryChosen:Bool = false
    let appDelegate = NSApplication.shared.delegate as! AppDelegate  // We now have a reference to the app delegate...
    var accountBaseData:String?
    var accountInfo:[Account]?  // Global for the array of account arrays
    var moneyMaker: MoneyMaker = MoneyMaker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setDate()  //  Set Date at launch, updated with each check
        setupPrefs()  // set initial account location and printer
    }
    
    override func viewDidAppear() { // This occurs later than the load...
        super.viewDidAppear()
        myCheckController = self
        manual.state = NSControl.StateValue.off  // We never really use manual state anymore
        setAndTestAccounts()  //  find or create base for accounts; set it up
        amountField.selectText(self)  //  programmatically define key object
        amountField.nextKeyView = toField
    }
    
    /*  WHy do we need this???
     override var representedObject: Any? {
     didSet {
     // Update the view, if already loaded.
     print ("Represented Object")  // No idea about this
     }
     }
     */
    
    func setDate() { //  Get and set date for display, print, and register
        let dateFormatter = DateFormatter()
        let shortDate = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
        shortDate.dateFormat = "d MMM yyyy"
        
        todayString = dateFormatter.string(from: today)
        registerDate = shortDate.string(from: today)
        dateField.stringValue = todayString;
    }
    
    func alertOKCancel(question: String, text: String) -> Bool {  // General panel for category and acct
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Proceed")
        alert.addButton(withTitle: "Fix")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @IBAction func openPrefWindow(_ sender: Any) {  // Programmatically open window if no account base
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"),bundle: nil)
        let controller: PrefsViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "andyPref")) as! PrefsViewController
        self.presentViewControllerAsModalWindow(controller)
    }
    
    func updateFromPrefs() {  // if account base or printer changes...
        print (prefs.printer)
        accountPulldown.removeAllItems()  // Clear the accounts you had before then...
        self.viewDidAppear()  //  Essentially restart the app
    }
    
    func setAndTestAccounts(){
        /*  Workhorse routine.  When leaving we have a valid account base (and files)
        *   Note that prefs panel has to return from whence it was called
        *   The order of setup (view did appear is do this first, then setup default acct
        */
        accountBaseData = filer.findAccounts(prefs.accountDir) // Get account base file
        if  accountBaseData != nil {  //  Check that we found one, Good ? setup : alert and fix
            accountInfo = filer.parseAccountsFileData(data: accountBaseData!)
            initializeAccount(account: accountInfo![0]) //  Use first account in accounts file
            initializeInterfaceForAccounts()  //  Set up view for that account
            return
        }
        let answer = alertOKCancel(question: "No Account files!!", text: "Pick another root or make a new one." )
        if !answer {
            // Open prefs and choose another
//            setupPrefs()  //  Maybe ****
            openPrefWindow(self)  // exit into modal prefs window, setup incomplete until done
            if filer.createAccountBase(prefs.accountDir) {print("Success! from Prefs")}
        }
        else {
          // Create account in default directory
            if filer.createAccountBase(URL.init(fileURLWithPath: "/Users/lip/Desktop")) {print("Success! from /tmp")}
            prefs.accountDir = URL.init(fileURLWithPath: "/Users/lip/Desktop")
            updateFromPrefs()
        }
    }
    
    func initializeInterfaceForAccounts() {
        //  Uses Global Accounts array of arrays, fills in accounts Pulldown
        for  i in 0..<accountInfo!.count {
            accountPulldown.addItem(withTitle: accountInfo![i].accountLabel)
        }
        accountPulldown.addItem(withTitle: "Create Account")
    }
    
    func initializeAccount (account a:Account){    //  Fill in the title, Balance, seq, and cats for an account
        self.view.window?.title = a.accountLabel
        closeBatch()  //  reset batch mode on account change
        currentAccount = a.account  //  Need this string set globally for deposits and debits
        balanceField.stringValue = filer.balance(account: a.account)!
        self.colorBalanceField()
        numberField.stringValue = filer.seq(account: a.account)
        categoryPopup.removeAllItems() //  Clear old popup
        categoryPopup.addItem(withTitle: "None") // first entry is none
        for i in 0..<filer.cat(account: a.account).count { // Now add the real ones.
            categoryPopup.addItem(withTitle: filer.cat(account: a.account)[i])
        }
    }
    
    func colorBalanceField() {
        if balanceField.floatValue < 0.0 {
            balanceField.backgroundColor = NSColor.red
        }
        else {
            balanceField.backgroundColor = NSColor.green.withAlphaComponent(0.999)
        }
    }
    
    func updateBalanceField(delta d:Float) {
        balanceField.floatValue += d
        _ = filer.balance(account: currentAccount, balance: balanceField.stringValue)  //  Result is unused
        self.colorBalanceField()
    }

    func fillCheckFromEntry (_ entry:[String]){ // Used for batch modes
        toField.stringValue = entry[0]
        amountField.floatValue =  (entry[1] as NSString).floatValue
        memoField.stringValue = entry[2]
        output.stringValue = moneyMaker.makeMoney(amountField.stringValue)
        categoryPopup.selectItem(withTitle: entry[3])
        categoryChosen = true
    }
    
    @IBAction func accountPulldownChanged(_ sender: AnyObject) {
        print("Account Changed")
        //  THis is now hard.  Have to get the array, not just the number
        //  Iterate through the accounts until the number matches the pulldown title
        if accountPulldown.titleOfSelectedItem == "Create Account" {
 //           filer.createAccountBase(prefs.accountDir)
            print ("Someday we'll do this...")
        }
        for i in 0..<accountInfo!.count {
            if accountInfo![i].accountLabel == accountPulldown.titleOfSelectedItem {
                initializeAccount(account: accountInfo![i])
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
        
        self.setDate()  //  Why not reset the date in case it runs overnight...
        if !categoryChosen {  // Interrupt if you didn't set a category!
            let answer = alertOKCancel(question: "No Category", text: "Please enter a category, proceed?")
            if !answer { return }
        }
        
        if updateChosen.state == NSControl.StateValue.on {
            check.seq = numberField.integerValue
            check.amount = amountField.floatValue
            check.date = registerDate
            check.payee = fixRegisterText(toField.stringValue)
            check.memo = fixRegisterText(memoField.stringValue)
            check.cat = (categoryPopup.selectedItem?.title)!
            filer.registerCheck(account: currentAccount, checkData:check)  //  Need to fix for accounts and lose checks!!!
            //  Finish update details:  Update seq and bal only when registering a check
            if sequenceButton != nil {
                numberField.intValue += 1
                filer.updateSeq(account: currentAccount, sequence: numberField.stringValue)  // This is correct for new FileInterface
            }
            updateBalanceField(delta: -amountField.floatValue)
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

        categoryPopup.selectItem(at: 0)  // Revert to first title == "None"
        if batchMode {
            doBatch(self)
            categoryChosen = true
        }
        else {
            categoryChosen = false
            self.amountField.becomeFirstResponder()
//            amountField.selectText(self)
        }
    }
 
    //  Batch elements:  The funcs to start, continue, and end
    //  Uses Instance global batchMode: Bool
    
    var batchMode:Bool = false  //  Mode
    var batchIndex:Int = 0    //  Instance global to iterate through batch array
    var batchChecks:[[String]] = []
    var autMode:Bool = false
    var autIndex:Int = 0
    var autChecks:[[String]] = []
    
    /*  This is logically flawed
    *  What we want is to issue a check if we hit issue, and to iterate if not
    */
    
    @IBAction func enterBatch(_ sender: Any) {
        /*  Response to Batch button:
         *  Sets mode, fetches the batch data
         */
        closeAuto()
        batchMode = true
        batchChecks = filer.eba(account: currentAccount)
        categoryChosen = true
        batchButton.title = "Batching"
    }
    
    @IBAction func doBatch(_ sender: Any) {
            //  Fill elements from each, issue check
            //  Is each the sub-array?  That would be nice.
        if !batchMode {enterBatch(self)}
        if batchIndex < batchChecks.count {
            fillCheckFromEntry(batchChecks[batchIndex])
            batchIndex += 1
        }
        else {closeBatch()}
    }
    
    func closeBatch() {
        batchMode = false
        categoryChosen = false
        batchIndex = 0
        batchButton.title = "Batch"
    }
    
    func enterAuto() {
        closeBatch()
        printChosen.state = NSControl.StateValue.off
        autMode = true
        autChecks = filer.aut(account: currentAccount)
        categoryChosen = true
        autButton.title = "Auto-ing"
    }
    
    @IBAction func doAuto(_ sender: Any) {
        if !autMode {enterAuto()}
        if autIndex < autChecks.count {
            fillCheckFromEntry(autChecks[autIndex])
            autIndex += 1
        }
        else {closeAuto()}
    }
    
    func closeAuto() {
        autMode = false
        printChosen.state = NSControl.StateValue.on   //  Might want to cache previous...
        categoryChosen = false
        autIndex = 0
        autButton.title = "Auto"
    }
    
    @IBAction func showName(_ sender: Any) {  // what's this for?
        print(masterAppName)
    }
   

}


