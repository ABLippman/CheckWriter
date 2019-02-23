//
//  FileManager.swift
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

class FileManager: NSObject {
    var categories:[String] = ["1","2"]
    
    func changeAccount() {
        let dirname = NSString(string: prefs.accountDir).expandingTildeInPath
        let fullname = dirname.appending(".txt")
        let fileURL = URL(string: "file://\(fullname)")
        print ("Account Directory is:  \(fileURL)")
        
        /*
        *  Test code for files
        */
        let garbage = "This is the second test for a file\n"
        do {
            try garbage.write(to: fileURL!, atomically:true, encoding: String.Encoding.utf8)
        } catch let error as NSError{
            print ("That didn't work:  \(error)")
        }

        
        
    }

}
