import UIKit
import CoreData

extension Int : SequenceType {
    public func generate() -> RangeGenerator<Int> {
        return (0..<self).generate()
    }
}

class passageCompletionSegue: UIStoryboardSegue {
    override func perform() {
        let navigationController = sourceViewController.navigationController!
        var controllerStack = navigationController.viewControllers
        let index = controllerStack.indexOf(sourceViewController)!
        controllerStack.replaceRange(index...index, with: [destinationViewController])
        navigationController.setViewControllers(controllerStack, animated: true)
    }
}

class VersePracticeController: UIViewController, UITextViewDelegate {
    @IBOutlet var basicHelpLabel: UILabel!
    @IBOutlet var intermediateHelpLabel: UILabel!
    @IBOutlet var advancedHelpLabel: UILabel!
    @IBOutlet var submissionLabel: UILabel!
    @IBOutlet var distanceFromSubmissionLabelToTextView: NSLayoutConstraint!
    @IBOutlet var distanceFromSubmissionLabelToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var distanceFromHelpToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var distanceFromSubmissionLabelToHelpLabel: NSLayoutConstraint!
    @IBOutlet var verseEntryTextView: UITextView!
    @IBOutlet var helpButton: UIBarButtonItem!
    @IBOutlet var passageProgressView: UIProgressView!
    
    var passage: UserPassage!
    var verses: NSOrderedSet!
    
    var activeVerse: UserVerse!
    var verseHelper: VerseHelper!
    var activeVerseIndex: Int!

    var submissionTimer: NSTimer!
    var submissionTextVisible = false

    var indexPath: NSIndexPath!
    var hintLevel: Int = 0
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let neutralSubmissionColor = UIColor(red:0.40, green:0.60, blue:1.00, alpha:1.0)
    let successSubmissionColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)
    let failureSubmissionColor = UIColor(red:1.00, green:0.35, blue:0.31, alpha:1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        verseEntryTextView.delegate = self
        
        verses = passage.valueForKey("verses") as! NSOrderedSet
        
        activateVerse(verses.firstObject as! UserVerse)
        activeVerseIndex = 0
        incrementActiveVerseViewCounter()

        title = activeVerse.reference
        
        basicHelpLabel.text = activeVerse.text
        intermediateHelpLabel.text = activeVerse.text
        advancedHelpLabel.text = activeVerse.text
        
        self.observeKeyboard()
        verseEntryTextView.becomeFirstResponder()
        
        if Int(activeVerse.views!) <= 10 {
            exposeFreeHints()
        }

        submissionTimer = NSTimer.scheduledTimerWithTimeInterval(4.5, target: self, selector: "userTimedOut", userInfo: nil, repeats: true)
    }
    
    func userTimedOut() {
        if submissionTextVisible == false {
            distanceFromSubmissionLabelToHelpLabel.constant = distanceFromSubmissionLabelToHelpLabel.constant + submissionLabel.frame.height + 8
            distanceFromHelpToBottomLayoutGuide.constant = distanceFromHelpToBottomLayoutGuide.constant + submissionLabel.frame.height + 8
            UIView.animateWithDuration(0.5, animations: {
                self.submissionLabel.text = "Still there?"
                self.submissionLabel.textColor = self.neutralSubmissionColor
                self.submissionLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
            submissionTextVisible = true
        }
    }
    
    func activateVerse(verse: UserVerse) {
        activeVerse = verse
        verseHelper = VerseHelper(verse: verse)
    }
    
    func exposeFreeHints() {
        print(advancedHelpLabel)
        print(advancedHelpLabel.frame.height)
        distanceFromSubmissionLabelToTextView.constant = distanceFromSubmissionLabelToTextView.constant + advancedHelpLabel.frame.height

        if Int(activeVerse.views!) <= 2 {
            helpButton.enabled = false
            advancedHelpLabel.alpha = 1
        } else if Int(activeVerse.views!) > 2 && Int(activeVerse.views!) <= 5 {
            hintLevel = 2
            basicHelpLabel.attributedText = verseHelper.firstLetters()
            intermediateHelpLabel.attributedText = verseHelper.randomWords()
            basicHelpLabel.alpha = 1
            intermediateHelpLabel.alpha = 1
        } else if Int(activeVerse.views!) > 5 && Int(activeVerse.views!) <= 10 {
            hintLevel = 1
            basicHelpLabel.attributedText = verseHelper.firstLetters()
            basicHelpLabel.alpha = 1
        }
    }
    
    func resetSubmissionTimer() {
        submissionTimer.invalidate()
        submissionTimer = NSTimer.scheduledTimerWithTimeInterval(4.5, target: self, selector: "userTimedOut", userInfo: nil, repeats: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        resetSubmissionTimer()

        if submissionTextVisible == true {
            distanceFromSubmissionLabelToHelpLabel.constant = distanceFromSubmissionLabelToHelpLabel.constant - submissionLabel.frame.height - 8
            distanceFromHelpToBottomLayoutGuide.constant = distanceFromHelpToBottomLayoutGuide.constant - submissionLabel.frame.height - 8
            UIView.animateWithDuration(0.5, animations: { self.submissionLabel.alpha = 0; self.view.layoutIfNeeded() })
            submissionTextVisible = false
        }

        if verseHelper.roughlyMatches(textView.text) {
            submissionTimer.invalidate()
            let delay = 0.7 * Double(NSEC_PER_SEC)
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.displayVerseSuccessAndTransition()
            })
        }
    }

    @IBAction func helpButtonPressed(sender: AnyObject) {
        resetSubmissionTimer()
        hintLevel++
        
        switch hintLevel {
        case 1:
            print(advancedHelpLabel)
            print(advancedHelpLabel.frame.height)
            distanceFromSubmissionLabelToTextView.constant = distanceFromSubmissionLabelToTextView.constant + basicHelpLabel.frame.height
            basicHelpLabel.attributedText = verseHelper.firstLetters()
            UIView.animateWithDuration(1, animations: { self.basicHelpLabel.alpha = 1 })
        case 2:
            intermediateHelpLabel.attributedText = verseHelper.randomWords()
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
        
        self.distanceFromHelpToBottomLayoutGuide.constant = height + 20
        self.distanceFromSubmissionLabelToBottomLayoutGuide.constant = height + 20
        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        if submissionTextVisible {
            distanceFromHelpToBottomLayoutGuide.constant = submissionLabel.frame.height + 8
        } else {
            self.distanceFromHelpToBottomLayoutGuide.constant = 8
        }

        self.distanceFromSubmissionLabelToBottomLayoutGuide.constant = 8
        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func displayVerseSuccessAndTransition() {
        UIView.animateWithDuration(0.1, animations: {
            self.basicHelpLabel.alpha = 0
            self.intermediateHelpLabel.alpha = 0
            self.advancedHelpLabel.alpha = 0
        }, completion: { (animated: Bool) -> Void in
            UIView.animateWithDuration(0.1, animations: {
                self.submissionLabel.alpha = 1
                self.submissionLabel.textColor = self.successSubmissionColor
                self.submissionLabel.text = "Great job!"
                self.submissionLabel.layer.addAnimation(self.bounceAnimation(), forKey: "position")
            })
            
            if self.activeVerseIndex != (self.verses.count - 1) {
                self.activeVerseIndex = self.activeVerseIndex + 1
                self.activateVerse(self.verses[self.activeVerseIndex] as! UserVerse)
                self.incrementActiveVerseViewCounter()
                
                let delay = 0.7 * Double(NSEC_PER_SEC)
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.transitionToNextVerse()
                })
            } else {
                self.displayCompletion()
            }
        })
    }
    
    func displayCompletion() {
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("completionSegue", sender: self)
        })
    }
    
    func transitionToNextVerse() {
        title = activeVerse.reference
        verseEntryTextView.editable = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.basicHelpLabel.text = self.activeVerse.text
            self.intermediateHelpLabel.text = self.activeVerse.text
            self.advancedHelpLabel.text = self.activeVerse.text
            
            self.exposeFreeHints()
        })
        
        self.passageProgressView.setProgress(Float(self.verses.indexOfObject(self.activeVerse)) / Float(self.verses.count), animated: true)
        
        hintLevel = 0
        helpButton.enabled = true
        
        let transitionVerseEntryTextViewAnimation = CATransition()
        transitionVerseEntryTextViewAnimation.duration = 0.5
        transitionVerseEntryTextViewAnimation.type = kCATransitionPush
        transitionVerseEntryTextViewAnimation.subtype = kCATransitionFromRight
        self.verseEntryTextView.layer.addAnimation(transitionVerseEntryTextViewAnimation, forKey: "pushTransition")
        self.verseEntryTextView.text = ""
        self.verseEntryTextView.becomeFirstResponder()
        
        let delay = 0.7 * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.resetSubmissionTimer()
            UIView.animateWithDuration(0.5, animations: { self.submissionLabel.alpha = 0 })
        })
    }
    
    func displayVerseFailure() {
        UIView.animateWithDuration(0.1, animations: {
            self.submissionLabel.alpha = 1
            self.submissionLabel.textColor = self.failureSubmissionColor
            self.submissionLabel.text = "Try again!"
            self.submissionLabel.layer.addAnimation(self.shakeAnimation(), forKey: "position")
        })
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.1, animations: {
                self.submissionLabel.alpha = 0
            })
        })
    }
        
    func shakeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.submissionLabel.center.x - 10, self.submissionLabel.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.submissionLabel.center.x + 10, self.submissionLabel.center.y))
        return animation
    }
    
    func bounceAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.11
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.submissionLabel.center.x, self.submissionLabel.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.submissionLabel.center.x, self.submissionLabel.center.y - 10))
        return animation
    }
    
    func incrementActiveVerseViewCounter() {
        activeVerse.views = Int(activeVerse.views!) + 1
        try! appDelegate.managedObjectContext.save()
    }
}

