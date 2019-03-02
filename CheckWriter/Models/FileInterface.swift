//
//  FileInterface.swift
//  CheckWriter
//
//  Created by lip on 2/2/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//
/*  File manager opens, closes, reads, writes and appends to the file system
 *
 *  Uses prefs.acountDir as the root dir for all files
 *  files include:  .bal for balance, .seq for check number
 *  .cat for categories (for each account)
 *  .eba for auto pay list.
 *
 *  Main operation is changeAccount, called on start and from ViewController.
 *  This class stores the data such as bal and data
 *
 */

import Cocoa
    /*  First question:  Is this brain dead?  Should we instantiate a different FileInterface
    *   for each account, or should this one be used for each account?
    *   For now it is simpler to have only one.  Then it can close the register and open a new one
    */
    /*
    *  File Interface is initialized on launch with a preferences base directory
    *  It is called to open an account and fetch the sequence, balance, categories, auto-pay lists
    *  Close account closes the register.  Others need no close
    *  Change account closes the register and opens a new account
    *
    *  Presumably the view that called this will then fill in the category popups and
    *  dothe right thing with the auto pay stuff
    *
    *  File Interface also registers the checks if view controllers asks to do so
    *
    *  Note:   view controller only calls us with the account number.
    *  We handle the base account directory here on launch and if it is
    *  changed via the preference panel
    *
    *  We also handle requesting a new account to be set up from
    *  Preferences
    *  NOTE:  This app is sandboxed!!!  That means we must use OpenPanel to choose a
    *  directory for the checkbook data if it is not in the sandbox.
    *  That requires modifying preferences
    *
    *  At some future time, we may add the ability to add categories...
    *
    */

class FileInterface: NSObject {
    var accounts:String = ""
    let fm = FileManager.default    // Create a file manager for all this work
    var account = ""                //  This is the global account number string
    var categories:[String] = ["1","2"]
    var register = "/tmp/dummyRegister"  //String.  Used to close old register then open a new one on change
    
    override init() {   //  Set up the account root directory
        /*
        *  Code to creat account directory if it doesn't exist  NO NO
        */
        if !fm.fileExists(atPath: prefs.accountDir.path) {     //  If the specified account root doesn't exists make it
            //  Check via alert that there is no account, create one?
            
        }
        super.init()
    }
    
    func stripComments(_ s:[String]) -> [String]{  // Takes \n-separated arrays, removes elements starting with # or empty
        var answer :[String] = []
        for each in s {
            if (each.first != "#") && (each.first != nil) {
                answer.append(each)
            }
        }
        return answer
    }
    
    func allowFolder() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        if openPanel.runModal() == .OK {
            print("OK clicked...")
            return openPanel.url != nil ? openPanel.url :  URL.init(string: "/Users/lip/Desktop")
        }
        print ("Nothing selected")
        return URL.init(string: "/Users/lip/Desktop")
    }

    func findAccounts() -> [[String]] {  // Tests that root is  accessible and finds all accounts, returns array for each acct
        var accountsFile = ""           //  This is the file of account base info
        var accountsAll:[String] = []

        print ("finding and testing accounts")
        do {
            accountsFile = try NSString(contentsOfFile: prefs.accountDir.appendingPathComponent("Accounts").path,
                                        encoding: String.Encoding.utf8.rawValue) as String
        }
        catch let error {
            print ("****  Finding accounts:  Failed!\n \(error)")
            //  Code to open Preference Panel...
            var myWindow: NSWindow? = nil
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"),bundle: nil)
            let controller: PrefsViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "andyPref")) as! PrefsViewController
            myWindow = NSWindow(contentViewController: controller)
            myWindow?.makeKeyAndOrderFront(self)
            let vc = NSWindowController(window: myWindow)
            vc.showWindow(self)
/*
             let url = allowFolder()
            print("Found one: \(url!.path)")
          prefs.accountDir = url!.path  */

        }
        let accountEach:[String] = accountsFile.components(separatedBy: "\n")
        var f:[[String]] = []
        let accountFix = stripComments(accountEach)
        for each in accountFix[...2] { // ****  up to three accounts
            f.append(each.components(separatedBy: ":"))
        }
        return f  //  Returns the array of accounts with elements as an array
    }
    
    func openAccount(account a:String) -> (categories:[String],   //  Takes account number string
        auto:[String],
        eba:[String],
        seq:String,
        bal:String) {
            var bal: String = "", seq: String = ""
            var categories: [String] = [], auto: [String] = [], eba: [String] = []
            /*
            *  takes a complete path to the account
            *  i.e., the account base + the account number
            *  Returns all the information needed to write checks
            */
            let pathURL =  prefs.accountDir.appendingPathComponent(a)
            let balURL = pathURL.appendingPathExtension("bal")
            let seqURL = pathURL.appendingPathExtension("seq")
            let catURL = pathURL.appendingPathExtension("cat")
            let ebaURL = pathURL.appendingPathExtension("eba")
            let autURL = pathURL.appendingPathExtension("aut")
            
            do {
                bal = try NSString(contentsOfFile: balURL.path,
                                              encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
                seq = try NSString(contentsOfFile: seqURL.path,
                                   encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
            } catch let error {
                print ("File didn't open \(error)")
            }
            do { // add in the eba and aut setters
                let tmp = try NSString(contentsOfFile: catURL.path,
                                       encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
                categories = tmp.components(separatedBy: "\n")
                let tmp2 = try NSString(contentsOfFile: autURL.path,
                                       encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
                auto = tmp2.components(separatedBy: "\n")
                let tmp3 = try NSString(contentsOfFile: ebaURL.path,
                                        encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
                eba = tmp3.components(separatedBy: "\n")
                
            } catch let error {
                print ("File didn't open \(error)")
            }

            return (categories, auto, eba, seq, bal)
        }
    
    func registerCheck(account a:String, checkData d:Check) {
        let serialNumber: NSDate = NSDate() // new serialization date each time MOVE to File Interface
        let amountString = String(format: "%7.2f", d.amount)
//        let r = ("\(d.date):\(Int (serialNumber.timeIntervalSince1970)):\(d.amount):\(d.payee):\(d.cat):\(d.memo):Out:\n")
        let r = ("\(d.date):\(Int (serialNumber.timeIntervalSince1970)):\(amountString):\(d.payee):\(d.cat):\(d.memo):Out:\n")

        let rData = (r as NSString).data(using: String.Encoding.utf8.rawValue)
        
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("reg")
        do { let handleWrite2 = try FileHandle(forWritingTo:pathURL) as FileHandle?
            handleWrite2!.seekToEndOfFile()  // This is for appending
            handleWrite2!.write(rData!)   //  This should append the data.
            handleWrite2!.closeFile()
        } catch let error {
            print("Register Error: \(error)")
            
        }
        
    }
    
    func registerBalance (_ b:Float) {
        do { print ("Have to update the balance here!!!") }
    }

    func changeAccount() {   // *****  THis is all test code to test file interface.  Is this used?
        let dirname = prefs.accountDir.path
        let fullname = dirname.appending(".txt")
        let fileURL = URL(string: "file://\(fullname)")
        print ("Account is:  \(String(describing: fileURL))")

        /*   The following is code in progress for file access in general  May not all belong here
        *
        *    Sets up filenames from dummy account base and account number, which
        *    should be supplied elsewhere in the real app
        */
        let bal = ".bal"
        let seq = ".seq"
        let register = ".reg"
        let aut = ".aut"
        let eba = ".eba"
        let cat = ".cat"
        //  Following is to be filled in by app.  These are tests
        let currentAccount = "16641301"
        var balance = 123.45
        var balanceString = String(format: "%10.2f", balance)
        print (balanceString)
        
        let balFile = currentAccount.appending(bal)
        let seqFile = currentAccount.appending(seq)
        let registerFile = currentAccount.appending(register)
        let autFile = currentAccount.appending(aut)
        let ebaFile = currentAccount.appending(eba)
        let catFile = currentAccount.appending(cat)
        
        let balPath = dirname.appending("/\(balFile)")
        let balURL = URL(fileURLWithPath: balPath)
        let seqURL = dirname.appending(seqFile)
        let registerURL = NSURL(fileURLWithPath: dirname.appending("/\(registerFile)"))
        
        print (balURL)
        print (registerURL)
        // balanceString.write(balURL)
        do { try balanceString.write(to: fileURL!, atomically: false, encoding: .utf8) }
        catch { print("Write failed!!")}
    }

}
