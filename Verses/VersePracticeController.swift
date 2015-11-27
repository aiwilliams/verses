//
//  ViewController.swift
//  Verses
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import UIKit
import CoreData

extension Int : SequenceType {
    public func generate() -> RangeGenerator<Int> {
        return (0..<self).generate()
    }
}

class VersePracticeController: UIViewController {
    @IBOutlet var basicHelpLabel: UILabel!
    @IBOutlet var intermediateHelpLabel: UILabel!
    @IBOutlet var advancedHelpLabel: UILabel!
    @IBOutlet var distanceFromSubmissionButtonToTextView: NSLayoutConstraint!
    @IBOutlet var distanceFromHelpToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var verseEntryTextView: UITextView!
    @IBOutlet var submissionButton: UIButton!
    @IBOutlet var helpButton: UIBarButtonItem!
    
    var passageText: String!
    var passageReference: String!
    var indexPath: NSIndexPath!
    var hintLevel: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        title = passageReference
        basicHelpLabel.text = passageText
        intermediateHelpLabel.text = passageText
        advancedHelpLabel.text = passageText
        
        self.observeKeyboard()
        verseEntryTextView.becomeFirstResponder()
        submissionButton.layer.cornerRadius = 5
    }
    
    func hideWordEndings(label: UILabel) {
        let text = label.text!
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
        label.attributedText = attributed
    }
    
    func hideRandomWords(label: UILabel) {
        let text = label.text!
        let attributed = NSMutableAttributedString(string: text)
        var index = 0
        var lastSeenSpaceIndex = 0
        var ranges: Array<NSRange> = Array<NSRange>()
        for char in text.characters {
            if char == " " {
                ranges.append(NSMakeRange(lastSeenSpaceIndex, index - lastSeenSpaceIndex))
                lastSeenSpaceIndex = index
            }
            ++index
        }
        
        for _ in ranges.count / 3 {
            let randomIndex = Int(arc4random_uniform(UInt32(ranges.count)))
            ranges.removeAtIndex(randomIndex)
        }

        for range in ranges {
            attributed.setAttributes([NSForegroundColorAttributeName:UIColor.clearColor()], range: range)
        }
        
        label.attributedText = attributed
    }

    @IBAction func helpButtonPressed(sender: AnyObject) {
        hintLevel++
        
        switch hintLevel {
        case 1:
            distanceFromSubmissionButtonToTextView.constant = distanceFromSubmissionButtonToTextView.constant + basicHelpLabel.frame.height
            hideWordEndings(basicHelpLabel)
            UIView.animateWithDuration(1, animations: { self.basicHelpLabel.alpha = 1 })
        case 2:
            hideRandomWords(intermediateHelpLabel)
            UIView.animateWithDuration(1, animations: { self.intermediateHelpLabel.alpha = 1 })
        case 3:
            UIView.animateWithDuration(1, animations: { self.advancedHelpLabel.alpha = 1})
            helpButton.enabled = false
        default:
            break
        }
    }
    
    func observeKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let frame = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        let keyboardFrame: CGRect = frame.CGRectValue
        let height: CGFloat = keyboardFrame.size.height
        
        self.distanceFromHelpToBottomLayoutGuide.constant = height + submissionButton.frame.size.height + 20
        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        self.distanceFromHelpToBottomLayoutGuide.constant = submissionButton.frame.size.height + 20
        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func endEditingOnTapOutside(sender: UITapGestureRecognizer) {
        verseEntryTextView.endEditing(true)
    }

    @IBAction func checkUserVerse(sender: UIButton) {
        if normalizedString(verseEntryTextView.text.lowercaseString) == removePunctuation(passageText.lowercaseString) {
            UIView.animateWithDuration(0.1, animations: {
                self.submissionButton.backgroundColor = UIColor(red: 0.16, green: 0.75, blue: 0.09, alpha: 1)
                self.submissionButton.setTitle("Great job!", forState: .Normal)
                self.submissionButton.layer.addAnimation(self.bounceAnimation(), forKey: "position")
            })
        } else {
            UIView.animateWithDuration(0.1, animations: {
                self.submissionButton.backgroundColor = UIColor(red: 0.59, green: 0.23, blue: 0.18, alpha: 1)
                self.submissionButton.setTitle("Try again!", forState: .Normal)
                self.submissionButton.layer.addAnimation(self.shakeAnimation(), forKey: "position")
            })
            let delay = 3.0 * Double(NSEC_PER_SEC)
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.1, animations: {
                    self.submissionButton.backgroundColor = UIColor(red:0.67, green:0.69, blue:0.08, alpha:1.0)
                    self.submissionButton.setTitle("Check it!", forState: .Normal)
                })
            })
        }
    }
    
    func normalizedString(text: String) -> String {
        let spelledOut = spellOutNumbers(text)
        let final = removePunctuation(spelledOut)
        return final
    }
    
    func removePunctuation(text: String) -> String {
        return text.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator("")
    }
    
    func spellOutNumbers(text: String) -> String {
        var words: Array<String> = text.componentsSeparatedByString(" ")
        var index = 0

        for word in words {
            if let numberWord: NSInteger = Int(word) {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .SpellOutStyle
                let formattedNumber = formatter.stringFromNumber(numberWord)
                words.removeAtIndex(index)
                words.insert(formattedNumber!, atIndex: index)
            }
            ++index
        }

        return words.joinWithSeparator(" ")
    }
    
    func shakeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.submissionButton.center.x - 10, self.submissionButton.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.submissionButton.center.x + 10, self.submissionButton.center.y))
        return animation
    }
    
    func bounceAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.11
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.submissionButton.center.x, self.submissionButton.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.submissionButton.center.x, self.submissionButton.center.y - 10))
        return animation
    }
}

