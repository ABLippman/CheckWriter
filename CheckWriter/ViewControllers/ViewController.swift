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
import AVFoundation


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



class ViewController: NSViewController, NSWindowDelegate {
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
    @IBOutlet weak var accountPulldown: NSPopUpButton!
    @IBOutlet weak var batchButton: NSButton!
    @IBOutlet weak var autButton: NSButton!
    

    let today:Date = Date()
    var registerDate:String = ""
    var todayString = ""
    var categoryChosen:Bool = false  //  persistent variable
    //  Following line is instructional.  We don't use it here.  AppDel does little.
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var accountInfo:[Accounts]?  // Global for the array of account structures at setup
    var moneyMaker: MoneyMaker = MoneyMaker()  //  Routine to print English amount
    //  We are caching the print button state so we can restore it after batch and auto
    //  In particular, auto turns it off, the should restore it when conplete
    var printButtonCache:NSControl.StateValue = NSControl.StateValue.on //  Initially save as ON state
//    var audioPlayer : AVAudioPlayer = AVAudioPlayer()
    var audioPlayer : AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setDate()  //  Set Date at launch, updated with each check
        setupPrefs()  // set initial account location and printer
    }
    
    override func viewDidAppear() { // This occurs later than the load...
        super.viewDidAppear()
        view.window?.minSize = CGSize(width: 760, height: 380)  //  Should be done in Interface builder...
        view.window?.maxSize = CGSize(width:1000, height:380)
        myCheckController = self
        // manual.state = NSControl.StateValue.off  // We never really use manual state anymore
        setAndTestAccounts()  //  find or create base for accounts; set it up
        amountField.selectText(self)  //  programmatically define key object
        amountField.nextKeyView = toField
        self.view.window?.delegate = self as NSWindowDelegate
        let sound = Bundle.main.path(forResource: "BloatedSackOfProtoplasm", ofType: "wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: (sound!)))
            audioPlayer?.volume = prefs.volume!
            audioPlayer!.play()
        }
        catch {
            print (error)
        }
//        NSSound(named: NSSound.Name(rawValue: "BloatedSackOfProtoplasm"))?.play()  // Old method
    }
    
    func windowWillClose(_ aNotification: Notification) {
        print("Window closing")
        // appDelegate.applicationWillTerminate(willCloseNotification)  // notification to send?
    }
    
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
    
    func initializeInterfaceForAccounts() {
        //  Uses Global Accounts array of arrays, fills in accounts Pulldown
        for  i in 0..<accountInfo!.count {
            accountPulldown.addItem(withTitle: accountInfo![i].accountLabel)
        }
        accountPulldown.addItem(withTitle: "Create Account")  //  Added for future feature
    }
    
    func initializeAccount (account a:Accounts){    //  Fill in the title, Balance, seq, and cats for an account
        var categoryArray:[String] = filer.cat(account: a.account)
        self.view.window?.title = a.accountLabel
        currentAccount = a.account  //  Need this string set globally for deposits and debits
        balanceField.stringValue = filer.balance(account: a.account)!
        self.colorBalanceField()
        numberField.stringValue = filer.seq(account: a.account)
        toField.stringValue = ""
        memoField.stringValue = ""
        closeBatch()  //  reset batch mode on account change
        closeAuto()  //  Close auto mode on account change.  This and following clears form on account change
        amountField.floatValue = 0.0
        amountEntered(self)
        categoryPopup.removeAllItems() //  Clear old popup
        categoryPopup.addItem(withTitle: "None") // first entry is none
        for i in 0..<categoryArray.count {
            categoryPopup.addItem(withTitle: categoryArray[i])
        }
    }
    
    func setAndTestAccounts(){
        /*  Workhorse routine.  When leaving we have a valid account base (and files)
        *   Note that prefs panel has to return from whence it was called
        *   The order of setup (view did appear is do this first, then setup default acct
        */
        print ("Volume Setting is ",prefs.volume ?? 0.5)
        accountInfo = filer.findAccounts(prefs.accountDir) // Get account base file
        if  accountInfo != nil {  //  Check that we found one, Good ? setup : alert and fix
            initializeAccount(account: accountInfo![0]) //  Start on first account
            initializeInterfaceForAccounts()  //  Set up view for that account
            return
        }
        let answer = alertOKCancel(question: "No Account files!!", text: "Pick another root or make a new one." )
        if !answer {
            // Open prefs and choose another
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

    @IBAction func accountPulldownChanged(_ sender: AnyObject) {
        if accountPulldown.titleOfSelectedItem == "Create Account" {
 //           filer.createAccountBase(prefs.accountDir)
            print ("Someday we'll do this...")  // Meanwhile go back to account 1
            accountPulldown.selectItem(at: 0)
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
        doIt.keyEquivalent = "\r"
    }

    @IBAction func sequenceButtonChanged(_ sender: Any) {
        //  Allows for manual entry of a sequence
        if sequenceButton.state == NSControl.StateValue.off {
            numberField.intValue = 6000
        }
        else {
            numberField.stringValue = filer.seq(account: currentAccount)
        }
    }
    
    @IBAction func printButtonChanged(_ sender: Any) {  //  Cache button state
        printButtonCache = printChosen.state
    }
    
    @IBAction func issueCheck(_ sender: Any) {
        
        /*  Main routine
         *   sets printer, verifies category
         *   Prints if req'd, registers if req'd
         */
        let check = Check()
        doIt.keyEquivalent = ""

        self.setDate()  //  Why not reset the date in case it runs overnight...
        if !categoryChosen {  // Interrupt if you didn't set a category!
            let answer = alertOKCancel(question: "No Category", text: "Please enter a category, proceed?")
            if !answer { return }
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
        
        if updateChosen.state == NSControl.StateValue.on {
            check.seq = numberField.integerValue
            check.amount = amountField.floatValue
            check.date = registerDate
            check.payee = fixRegisterText(toField.stringValue)
            check.memo = fixRegisterText(memoField.stringValue)
            check.cat = (categoryPopup.selectedItem?.title)!
            
            filer.registerCheck(account: currentAccount, checkData:check)  //  Need to fix for accounts and lose checks!!!
            //  Finish update details:  Update seq and bal only when registering a check
            if sequenceButton.state == NSControl.StateValue.on  {
                numberField.intValue += 1
                filer.updateSeq(account: currentAccount, sequence: numberField.stringValue)
            }
            updateBalanceField(delta: -amountField.floatValue)
        }

        //  Finish setting up for next check...

        categoryPopup.selectItem(at: 0)  // Revert to first title == "None"
        if (batchMode || autMode) {   //  In either mode, fill out the check
            if (batchMode) {doBatch(self)}
            if (autMode) {doAuto(self)}
            categoryChosen = true
        }

        else {
            categoryChosen = false
            self.amountField.becomeFirstResponder()
//            amountField.selectText(self)
        }
        let sound = Bundle.main.path(forResource: "Ahhhhh", ofType: "wav")
        do {
            audioPlayer?.volume = prefs.volume!
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: (sound!)))
            audioPlayer!.play()
        }
        catch {
            print (error)
        }
    }
 
    //  Batch elements:  The funcs to start, continue, and end
    //  Uses Instance global batchMode: Bool
    
    var batchMode:Bool = false  //  Mode
    var batchIndex:Int = 0    //  Instance global to iterate through batch array
    var autMode:Bool = false
    var autIndex:Int = 0
    var batchChecks:[Batch] = []
    var autChecks:[Batch] = []
    
    func fillCheckFromEntry (_ entry:Batch){ // Used for batch modes
        toField.stringValue = entry.payee
        amountField.floatValue =  (entry.amount as NSString).floatValue
        memoField.stringValue = entry.memo
        output.stringValue = moneyMaker.makeMoney(amountField.stringValue)
        categoryPopup.selectItem(withTitle: entry.category)
        numberField.intValue = 6000
        if categoryPopup.selectedItem == nil {  // In case batch uses unknown category
            categoryPopup.selectItem(at: 0)  //  Presumed to be "None"
        }
        categoryChosen = true
    }
    
    @IBAction func enterBatch(_ sender: Any) {
        closeAuto()
        printButtonCache = printChosen.state  // cache the current state
        printChosen.state = NSControl.StateValue.off  // off for auto
        batchMode = true
        batchChecks = filer.eba(account: currentAccount)
        categoryChosen = true
        batchButton.title = "Batching"
        sequenceButton.state = NSControl.StateValue.off
        printButtonCache = printChosen.state  // cache the current state
        printChosen.state = NSControl.StateValue.off  // off for auto
        
    }
    
    @IBAction func doBatch(_ sender: Any) {
            //  Fill elements from each, issue check
            //  Is each the sub-array?  That would be nice.
        if !batchMode {enterBatch(self)}
        if (batchIndex < batchChecks.count) {
            fillCheckFromEntry(batchChecks[batchIndex])
            batchIndex += 1
        }
        else {closeBatch()}
    }
    
    func closeBatch() {
        batchMode = false
        printChosen.state = printButtonCache   //  Restore from cache
        categoryChosen = false
        batchIndex = 0
        batchButton.title = "Batch"
        sequenceButton.state = NSControl.StateValue.on
        numberField.stringValue = filer.seq(account: currentAccount)
        printChosen.state = printButtonCache   //  Restore from cache
    }
    
    func enterAuto() {
        closeBatch()
        autMode = true
        autChecks = filer.aut(account: currentAccount)
        categoryChosen = true
        autButton.title = "Auto-ing"
        sequenceButton.state = NSControl.StateValue.off
        printButtonCache = printChosen.state  // cache the current state
        printChosen.state = NSControl.StateValue.off  // off for auto
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
        categoryChosen = false
        autIndex = 0
        autButton.title = "Auto"
        sequenceButton.state = NSControl.StateValue.on
        numberField.stringValue = filer.seq(account: currentAccount)
        printChosen.state = printButtonCache   //  Restore from cache
    }
    
    @IBAction func showName(_ sender: Any) {  // what's this for?
        print(masterAppName)
    }
    
    
    
   
}


