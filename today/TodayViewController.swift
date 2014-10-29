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
    @IBOutlet var verseLabel: UILabel!
    @IBOutlet var verseReference: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateVerseText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.updateVerseText()
    }
    
    func updateVerseText() {
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        let verseRef: AnyObject = defaults.valueForKey("VerseReference")!
        let verse: AnyObject = defaults.valueForKey("VerseContent")!
        self.verseLabel.text = "\(verse)"
        self.verseReference.text = "\(verseRef)"
    }
    
    @IBAction func openContainingApp(sender: AnyObject) {
        let appUrl: NSURL = NSURL(string: "verses://index")!
        self.extensionContext?.openURL(appUrl, completionHandler: nil)
    }
}

