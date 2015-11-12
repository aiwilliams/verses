//
//  ViewController.swift
//  Verses
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var helpLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        helpLabel.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func helpButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { self.helpLabel.alpha = 1 })
    }
}

