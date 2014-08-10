//
//  TodayViewController.swift
//  today
//
//  Created by Adam Williams on 8/10/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController {
  @IBOutlet weak var verseLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
      verseLabel.text = "John 3:16 - For God so loved the world, He gave His only begotten Son..."
        // Perform any setup necessary in order to update the view.

        // If an error is encoutered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
  
}
