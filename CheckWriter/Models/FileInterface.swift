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
    let fm = FileManager.default    // Create a file manager for all this work
    var accountBase:URL                 //  Global for base of account files
    var account = ""                //  This is the global account number string
    var categories:[String] = ["1","2"]
    var register = "/tmp/dummyRegister"  //String.  Used to close old register then open a new one on change
    
    override init() {   //  Set up the account root directory
        accountBase = FileManager.default.homeDirectoryForCurrentUser  // Start with User Home
        /*
        *  Code to creat account directory if it doesn't exist  NO NO
        */
        if !fm.fileExists(atPath: prefs.accountDir) {     //  If the specified account root doesn't exists make it
            //  Check via alert that there is no account, create one?
        }
        super.init()
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
            let pathURL =  accountBase.appendingPathComponent(prefs.accountDir).appendingPathComponent(a)
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
    
    func registerCheck
    

    func changeAccount() {   // *****  THis is all test code to test file interface.  Does not do real work!!!
        let dirname = NSString(string: prefs.accountDir).expandingTildeInPath
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
        let accountBase = "~lip/tmp"
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
