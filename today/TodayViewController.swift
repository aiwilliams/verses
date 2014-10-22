//
//  TodayViewController.swift
//  today
//
//  Created by Adam Williams on 8/10/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import UIKit
import NotificationCenter
import Foundation

class TodayViewController: UIViewController {
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var verseReference: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateVerseText()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(false)
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(NCUpdateResult.NewData)
        self.updateVerseText()
    }
    
    func updateVerseText() {
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        let verseRef: AnyObject = defaults.valueForKey("VerseReference")!
        let verse: AnyObject = defaults.valueForKey("VerseContent")!
        self.verseLabel.text = "\(verse)"
        self.verseReference.text = "\(verseRef)"
    }
}

