//
//  VerseDetailController.swift
//  Verses
//
//  Created by Isaac Williams on 11/15/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class VerseDetailController: UIViewController {
    var passage = String()
    var text = String()
    
    @IBOutlet var verseTextLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = passage
        verseTextLabel.text = text
    }
}