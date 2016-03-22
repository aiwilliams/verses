//
//  IntroductionViewController.swift
//  Verses
//
//  Created by Isaac Williams on 1/25/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class IntroductionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var translationPicker: UIPickerView!
    @IBOutlet var completionButton: UIButton!
    
    var translationChoices: [String] = ["KJV", "NKJV"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        translationPicker.delegate = self
        translationPicker.dataSource = self
        
        completionButton.backgroundColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)
        completionButton.layer.cornerRadius = 10
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return translationChoices.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return translationChoices[row]
    }

    @IBAction func finishIntroduction(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setValue(translationChoices[translationPicker.selectedRowInComponent(0)], forKey: "preferredBibleTranslation")

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeTabController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeTabBarController")
        
        UIView.transitionWithView(UIApplication.sharedApplication().keyWindow!, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
            UIApplication.sharedApplication().keyWindow?.rootViewController = homeTabController
        }, completion: nil)
    }
}