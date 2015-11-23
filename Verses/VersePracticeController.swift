//
//  ViewController.swift
//  Verses
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import UIKit
import CoreData

class VersePracticeController: UIViewController {
    @IBOutlet var basicHelpLabel: UILabel!
    @IBOutlet var advancedHelpLabel: UILabel!
    @IBOutlet var distanceFromHelpToBottomLayoutGuide: NSLayoutConstraint!
    
    var passage: NSManagedObject!
    var indexPath: NSIndexPath!
    var hintLevel: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Passage")
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            passage = results[indexPath.row] as! NSManagedObject
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        title = passage.valueForKey("reference") as? String
        basicHelpLabel.text = passage.valueForKey("text") as? String
        advancedHelpLabel.text = passage.valueForKey("text") as? String
        
        self.observeKeyboard()
    }
    
    func hideWordEndings() {
        let text = basicHelpLabel.text!
        let attributed = NSMutableAttributedString(string: text)
        var index = 0
        var secondCharIndexes = [1]
        for _ in text.characters {
            if index < 3 {
                ++index
                continue
            }
            let backTwo = text.startIndex.advancedBy(index - 2)
            if text.characters[backTwo] == " " {
                secondCharIndexes.append(index)
            }
            ++index
        }
        
        var nextIndex = 1
        for i in secondCharIndexes {
            if nextIndex == secondCharIndexes.count {
                attributed.setAttributes([NSForegroundColorAttributeName:UIColor.clearColor()], range: NSMakeRange(i, text.characters.count - i))
                break
            }
            attributed.setAttributes([NSForegroundColorAttributeName:UIColor.clearColor()], range: NSMakeRange(i, (secondCharIndexes[nextIndex] - 2) - i))
            ++nextIndex
        }
        basicHelpLabel.attributedText = attributed
    }

    @IBAction func helpButtonPressed(sender: AnyObject) {
        hintLevel++
        
        switch hintLevel {
        case 1:
            hideWordEndings()
            UIView.animateWithDuration(1, animations: { self.basicHelpLabel.alpha = 1 })
        case 2:
            UIView.animateWithDuration(1, animations: { self.advancedHelpLabel.alpha = 1})
        default:
            break
        }
    }
    
    
    
    func observeKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, forKeyPath: "keyboardWillShow:", options: .New, context: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, forKeyPath: "keyboardWillHide:", options: .New, context: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let frame = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        let keyboardFrame: CGRect = frame.CGRectValue
        let height: CGFloat = keyboardFrame.size.height
        
        print("updating constraints for opening keyboard")
        
        self.distanceFromHelpToBottomLayoutGuide.constant = self.distanceFromHelpToBottomLayoutGuide.constant + height
        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        self.distanceFromHelpToBottomLayoutGuide.constant = 20
        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

