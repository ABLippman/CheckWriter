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
    *  No need to close accounts.  All file I/O closes when done
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

    
    func allowFolder() -> URL? {  // get URL of account root via OpenPanel
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
    
    func createAccountBase() -> Bool {
        //  Appends an account description to the accounts file
        //  or creates one
        let base = prefs.accountDir.appendingPathComponent("Accounts")
        if findAccounts() == nil {
            do {try "# Default created\n".write(to: base, atomically: false, encoding: .utf8)}
            catch let error {
                print("Failed to creat an account base\(error)")
                return false
            }
        }
        do { let handleWrite2 = try FileHandle(forWritingTo:base) as FileHandle?
            let rData = ("100001:none:bat:Account 100001" as NSString).data(using: String.Encoding.utf8.rawValue)
            handleWrite2!.seekToEndOfFile()  // This is for appending
            handleWrite2!.write(rData!)   //  This should append an initial \n.
            handleWrite2!.closeFile()
        } catch let error {
            print("Register Error: \(error)")
            return false
        }
        //  Now we have a prototype random account added to the Accounts file
        //  Need to set up a register, a sequence, and a balance file.
        //  Then we essentially return and restart the app
        do { try "001".write(to: prefs.accountDir.appendingPathComponent("100001").appendingPathExtension("seq"), atomically: false, encoding: .utf8)
        try "001".write(to: prefs.accountDir.appendingPathComponent("100001").appendingPathExtension("reg"), atomically: false, encoding: .utf8)
        try "001".write(to: prefs.accountDir.appendingPathComponent("100001").appendingPathExtension("bal"), atomically: false, encoding: .utf8)
        }
        catch let error {
            print("Failed to set up auxiliary files \(error)")
            return false
        }
        return true
    }

    func parseAccountsFileData(data d:String) -> [[String]] {
        let accountEach:[String] = d.components(separatedBy: "\n")
        var f:[[String]] = []
        let accountFix = stripComments(accountEach)
        print ("Number of Accounts is: \(accountFix.count)")
        for each in accountFix[0..<accountFix.count] {
            f.append(each.components(separatedBy: ":"))
        }
        return f  //  Returns the array of accounts with elements as an array
    }
    
    
    
    func findAccounts() -> String? {  // Tests that root is  accessible and finds all accounts,
        // returns array for each acct or nil if non found
        var accountsFile = ""           //  This is the file of account base info
        print ("finding and testing accounts")
        do {  //  "Accounts"  has the list of accounts and names for them
            accountsFile = try NSString(contentsOfFile: prefs.accountDir.appendingPathComponent("Accounts").path,
                                        encoding: String.Encoding.utf8.rawValue) as String
            return accountsFile
        }
        catch let error {
            print ("****  Finding accounts:  Failed!\n \(error)")
            return nil // just exit to view controller on account missing
        }
    }
    
    /*  New funcs to separate bal, seq, cat, eba, and aut.  A call for each
    *   with an account number.  Global root should be set.
    */
    

    func balance(account a:String, balance b:String? = nil) -> String? {   //  Uses optional second argument
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("bal")
        if b != nil{  //  unwrap with optional...
            do { try b!.write(to: pathURL, atomically: false, encoding: .utf8) }
            catch let error { print ("File didn't open \(error)") }
            return nil
        }
        var bal = ""
        do {
            bal = try NSString(contentsOfFile: pathURL.path,
                               encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
        } catch let error {
            print ("File didn't open \(error)")
            bal = "00.00"
        }
        return bal
    }
    
    func seq(account a:String) -> String {   //Fetch Sequence
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("seq")
        var seq = ""
        do {
            seq = try NSString(contentsOfFile: pathURL.path,
                               encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
        } catch let error {
            print ("File didn't open \(error)")
            seq = "0000"
        }
        return seq
    }
    
    func updateSeq(account a:String, sequence b:String) {
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("seq")
        do { try b.write(to: pathURL, atomically: false, encoding: .utf8) }
        catch let error {
            print ("File didn't open \(error)")
        }
    }

    func cat(account a:String) -> [String] {
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("cat")
        var cats: [String] = []
        do {
            let tmp = try NSString(contentsOfFile: pathURL.path,
                                   encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
            cats = tmp.components(separatedBy: "\n")
            cats = stripComments(cats)
        } catch let error {
            print ("File didn't open \(error)")
        }
        return cats
    }
    
    func eba(account a:String) -> [[String]] {
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("eba")
        var tmp: String = ""
        var ebas: [String] = []
        var ebasArray:[[String]] = []
        do {
            tmp = try NSString(contentsOfFile: pathURL.path,
                                   encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
            ebas = stripComments(tmp.components(separatedBy: "\n"))  //  ****Check strip first or after
//            ebas = stripComments(ebas)
        } catch let error {
            print ("File didn't open \(error)")
        }
        for each in ebas {
        ebasArray.append(each.components(separatedBy: ":"))
        }
        return ebasArray
    }
    
    func aut(account a:String) -> [[String]] {
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("aut")
        var tmp: String = ""
        var auts: [String] = []
        var autsArray:[[String]] = []
        do {
            tmp = try NSString(contentsOfFile: pathURL.path,
                               encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
            auts = stripComments(tmp.components(separatedBy: "\n"))  //  ****Check strip first or after
        } catch let error {
            print ("File didn't open \(error)")
        }
        for each in auts {
            autsArray.append(each.components(separatedBy: ":"))
        }
        return autsArray
    }
    
    func registerCheck(account a:String, checkData d:Check) {
        let serialNumber: NSDate = NSDate() // new serialization date each time
        let amountString = String(format: "%7.2f", d.amount)
        let seqString = String(format: "%04i", d.seq)
        let r = ("\(seqString):\(d.date):\(Int (serialNumber.timeIntervalSince1970)):\(amountString):\(d.payee):\(d.cat):\(d.memo):Out:\n")
        
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
    
/*    This function is not needed.  Register Check works for deps and checks
 func registerDeposit(account a:String, checkData d:Check) {
        let serialNumber: NSDate = NSDate() // new serialization date each time MOVE to File Interface
        let amountString = String(format: "%7.2f", d.amount)
        let seqString = String(format: "%04i", d.seq)

        let r = ("\(seqString):\(d.date):\(Int (serialNumber.timeIntervalSince1970)):\(amountString):\(d.payee):\(d.cat):\(d.memo):Out:\n")
        
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
 */
  /*  This is obsolete and not used
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
 */
 /*  These are obsolete, not used or needed
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
 */

}
