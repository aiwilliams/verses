//
//  AddVerseController.swift
//  Verses
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class AddVerseController: UIViewController {
    @IBOutlet var verseRequest: UITextField!

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
    }
}