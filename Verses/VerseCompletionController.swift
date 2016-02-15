//
//  VerseCompletionController.swift
//  Verses
//
//  Created by Isaac Williams on 2/4/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class VerseCompletionController: UIViewController {
    var practicedVerses: NSOrderedSet!

    @IBOutlet var practiceAgainButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func practiceAgain(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "practiceAgain", object: nil))
    }

    @IBAction func continueToNextPassage(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "continueToNextPassage", object: nil))
    }
}