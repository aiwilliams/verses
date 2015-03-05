//
//  AddVerseViewController.swift
//  verses
//
//  Created by Isaac Williams on 2/3/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddVerseViewController: UIViewController {
    @IBOutlet var passageTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorText: UILabel!
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedObjectContext: NSManagedObjectContext!
    var bibliaAPI: BibliaAPI?
    var biblePassage: BiblePassage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = self.appDelegate.managedObjectContext
        biblePassage = NSEntityDescription.insertNewObjectForEntityForName("BiblePassage", inManagedObjectContext: self.managedObjectContext) as BiblePassage
    }
    
    override func viewWillAppear(animated: Bool) {
        self.passageTextField.becomeFirstResponder()
        self.errorText.hidden = true
        
        self.managedObjectContext = appDelegate.managedObjectContext
        self.bibliaAPI = BibliaAPI(moc: self.managedObjectContext!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.passageTextField.resignFirstResponder()
    }
    
    @IBAction func addVerse(sender: AnyObject) {
        if countElements(self.passageTextField.text) > 0 {
            self.activityIndicator.startAnimating()
            var passage: NSString = self.passageTextField.text
            self.bibliaAPI!.loadPassage(passage, completion: { (returnedPassage: BiblePassage) in
                    self.activityIndicator.stopAnimating()
                    self.errorText.hidden = true
                    self.biblePassage = returnedPassage
                    self.performSegueWithIdentifier("unwindAddVerse", sender: sender)
                }, failure: { (errorMessage: String) -> Void in
                    self.activityIndicator.stopAnimating()
                    self.errorText.text = errorMessage
                    self.errorText.hidden = false
                })
        }
        else {
            self.performSegueWithIdentifier("unwindAddVerse", sender: sender)
        }
    }
    
}