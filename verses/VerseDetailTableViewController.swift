//
//  VerseDetailTableViewController.swift
//  verses
//
//  Created by Isaac Williams on 2/3/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VerseDetailTableViewController: UITableViewController {
    @IBOutlet var passageCell: UITableViewCell!
    @IBOutlet var passageTextLabel: UILabel!
    var biblePassage: BiblePassage?
    
    override func viewDidLoad() {
        self.title = self.biblePassage?.passage
        self.passageTextLabel.text = self.biblePassage?.content
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return self.biblePassage?.translation
        }
        else {
            return "PROGRESS"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = 1.0 as CGFloat
        if indexPath.section == 0 && indexPath.row == 0 {
            height += self.passageCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height
        }
        return height
    }
}

