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

protocol AddVerseDelegate {
    func addVerseCanceled()
    func verseAdded()
}

class AddVerseViewController: UIViewController {
    @IBOutlet var passageTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorText: UILabel!

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var bibleApi: VerseSourceAPI?
    var biblePassage: BiblePassage!
    var delegate: AddVerseDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        self.passageTextField.becomeFirstResponder()
        self.errorText.hidden = true
        self.bibleApi = appDelegate.verseSourceApi
    }

    override func viewWillDisappear(animated: Bool) {
        self.passageTextField.resignFirstResponder()
    }

    @IBAction func addVerse(sender: AnyObject) {
        if count(self.passageTextField.text) > 0 {
            self.activityIndicator.startAnimating()
            var passage: NSString = self.passageTextField.text
            self.bibleApi!.loadPassage(passage as String, completion: { (returnedPassage: BiblePassage) in
                    self.activityIndicator.stopAnimating()
                    self.errorText.hidden = true
                    self.biblePassage = returnedPassage
                    self.delegate.verseAdded()
                }, failure: { (errorMessage: String) -> Void in
                    self.activityIndicator.stopAnimating()
                    self.errorText.text = errorMessage
                    self.errorText.hidden = false
                })
        }
        else {
            self.delegate.addVerseCanceled()
        }
    }

    @IBAction func cancelAddVerse(sender: AnyObject) {
        self.delegate.addVerseCanceled()
    }
}