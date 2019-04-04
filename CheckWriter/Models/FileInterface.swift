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
 *
 */

import Cocoa

    /*
    *  File Interface is used by viewcontroller with a preferences base directory URL
    *  It is called to open an account and fetch the sequence, balance, categories, auto-pay lists
    *
    *  The view that calls this will then fill in the category popups array,and
    *  dothe right thing with the auto pay stuff
    *
    *  File Interface also registers the checks if view controllers asks to do so
    *
    *  On startup, call findAccounts with the base directory
    *  If there is no account, call CreateAccountBase with base directory
    *
    *  View controller usually only calls routines with the account number.
    *
    *  NOTE:  This app is not sandboxed!!!  Sandox code to be added later
    *
    *  At some future time, we may add the ability to add categories...
    *
    *
    */

class FileInterface: NSObject {
    var accounts:String = ""
    let fm = FileManager.default    // Create a file manager for all this work
    var account = ""                //  This is the global account number string
//    var register = "/tmp/dummyRegister"  //String.  Used to close old register then open a new one on change
    
    override init() {   //  Does nothing
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
    
/*  This is not used, I thnk
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
 */
    func parseAccountsFileData(data d:String) -> [Accounts] {
        // Called by view controller as part of normal sequence.  Here because file format dependent
        let accountEach:[String] = d.components(separatedBy: "\n")
        var f:[Accounts] = []
        var elements:[String] = []
        let accountFix = stripComments(accountEach)
        print ("Number of Accounts is: \(accountFix.count)")
        for each in accountFix[0..<accountFix.count] {
            elements = (each.components(separatedBy: ":"))
            f.append(Accounts(account:elements[0], printFile: "none", batchName:"none", accountLabel:elements[3]) )
        }
        return f  //  Returns the array of accounts with elements as an array
    }
    
    func findAccounts(_ baseDir:URL) -> [Accounts]? {  // Tests that root is accessible and finds all accounts,
        // returns array for each acct or nil if non found
        var accountsFile = ""           //  This is the file of account base info
        print ("finding and testing accounts")
        do {  //  "Accounts"  has the list of accounts and names for them
            accountsFile = try NSString(contentsOfFile: baseDir.appendingPathComponent("Accounts").path,
                                        encoding: String.Encoding.utf8.rawValue) as String
            return parseAccountsFileData(data: accountsFile)
        }
        catch let error {
            print ("****  Finding accounts:  Failed!\n \(error)")
            return nil // just exit to view controller on account missing
        }
    }
    
    func createAccountBase(_ baseDir:URL) -> Bool {
        //  Appends an account description to the accounts file
        //  or creates an Accounts file if there is none.
        let base = baseDir.appendingPathComponent("Accounts")
        if findAccounts(baseDir) == nil {
            do {try "# Default created\n".write(to: base, atomically: false, encoding: .utf8)}
            catch let error {
                print("Failed to creat an account base\(error)")
                return false
            }
        }
        do { let handleWrite2 = try FileHandle(forWritingTo:base) as FileHandle?
            let rData = ("100001:none:bat:Dummy Account 100001\n" as NSString).data(using: String.Encoding.utf8.rawValue)
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
        do { try "001".write(to: baseDir.appendingPathComponent("100001").appendingPathExtension("seq"), atomically: false, encoding: .utf8)
        try "001".write(to: baseDir.appendingPathComponent("100001").appendingPathExtension("reg"), atomically: false, encoding: .utf8)
        try "001".write(to: baseDir.appendingPathComponent("100001").appendingPathExtension("bal"), atomically: false, encoding: .utf8)
        }
        catch let error {
            print("Failed to set up auxiliary files \(error)")
            return false
        }
        return true
    }



    /*  New funcs to separate bal, seq, cat, eba, and aut.  A call for each
    *   with an account number.  Global root taken from Prefs
    */
    

    func balance(account a:String, balance b:String? = nil) -> String? {   //  Uses optional second argument
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("bal")
        if b != nil{  //  unwrap with optional...
            do { try b!.write(to: pathURL, atomically: false, encoding: .utf8) }
            catch let error { print ("balance file didn't open \(error)") }
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
            print ("seq file not found \(error)")
            seq = "0000"
        }
        return seq
    }
    
    func updateSeq(account a:String, sequence b:String) {
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("seq")
        do { try b.write(to: pathURL, atomically: false, encoding: .utf8) }
        catch let error {
            print ("seq file didn't open \(error)")
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
        } catch {
            print ("cat file didn't open...")
            cats = ["Home", "Work"]  //  Arbitrary default set when no cat file
        }
        return cats
    }
    
    func unpackBatchItems(pathURL:URL) -> [Batch] {
        //  Opens the eba or aut file and
        //  unpacks the batch or auto-pay file into an array
        //  of structs:Batch
        var tmp: String = ""
        var aBatchEntry: [String] = []
        var f:[Batch] = []
        var elements:[String] = []
        do {
            tmp = try NSString(contentsOfFile: pathURL.path,
                               encoding: String.Encoding.utf8.rawValue) as String //  Uses NSString and string path, not URL
            aBatchEntry = stripComments(tmp.components(separatedBy: "\n"))  //  ****Check strip first or after
        } catch let error {
            print ("eba file didn't open \(error)")
        }
        for each in aBatchEntry {
            elements = each.components(separatedBy: ":")
            f.append(Batch(payee:elements[0], amount:elements[1], memo:elements[2], category:elements[3]) )
        }
        return f
    }
    
    func eba(account a:String) -> [Batch] {  //  Builds filename:URL
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("eba")
        return unpackBatchItems(pathURL: pathURL)
    }
    
    func aut(account a:String) -> [Batch] {  //  Build filename:URL = [].aut
        let pathURL =  prefs.accountDir.appendingPathComponent(a).appendingPathExtension("aut")
        return unpackBatchItems(pathURL: pathURL)
    }
    
    
    func registerCheck(account a:String, checkData d:Check) {
        let serialNumber: NSDate = NSDate() // new serialization date each time
        let amountString = String(format: "%7.2f", d.amount)
        let seqString = String(format: "%04i", d.seq)
        let r = ("\(seqString):\(Int (serialNumber.timeIntervalSince1970)):\(d.date):\(amountString):\(d.payee):\(d.cat):\(d.memo):Out:\n")
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


}
