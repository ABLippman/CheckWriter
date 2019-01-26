//
//  ViewController.swift
//  CheckWriter
//
//  Created by lip on 1/26/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var input: NSTextField!
    @IBOutlet weak var output: NSTextField!
    var moneyMaker: MoneyMaker = MoneyMaker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func translate(_ sender: Any) {
        output.stringValue = moneyMaker.makeMoney(input.stringValue)
        print(input.stringValue)
        print (moneyMaker.makeMoney(input.stringValue))
        
    }
    
}


