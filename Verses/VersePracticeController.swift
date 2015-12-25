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
    @IBOutlet var distanceFromSubmissionButtonToTextView: NSLayoutConstraint!
    @IBOutlet var distanceFromHelpToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var verseEntryTextView: UITextView!
    @IBOutlet var submissionButton: UIButton!
    @IBOutlet var helpButton: UIBarButtonItem!
    @IBOutlet var passageProgressView: UIProgressView!
    
    var passage: UserPassage!
    var verses: NSOrderedSet!
    
    var activeVerse: UserVerse!
    var verseHelper: VerseHelper!
    var activeVerseIndex: Int!

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
        
        exposeFreeHints()
        
        self.observeKeyboard()
        verseEntryTextView.becomeFirstResponder()
        submissionButton.layer.cornerRadius = 5
    }
    
    func activateVerse(verse: UserVerse) {
        activeVerse = verse
        verseHelper = VerseHelper(verse: verse)
    }
    
    func exposeFreeHints() {
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
    
    func textViewDidChange(textView: UITextView) {
        if verseHelper.roughlyMatches(textView.text) {
            displayVerseSuccessAndTransition()
        }
    }
    

    @IBAction func helpButtonPressed(sender: AnyObject) {
        hintLevel++
        
        switch hintLevel {
        case 1:
            distanceFromSubmissionButtonToTextView.constant = distanceFromSubmissionButtonToTextView.constant + basicHelpLabel.frame.height
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

    @IBAction func checkUserVerse(sender: UIButton) {
        if verseHelper.roughlyMatches(verseEntryTextView.text) {
            displayVerseSuccessAndTransition()
        } else {
            displayVerseFailure()
        }
    }
    
    func displayVerseSuccessAndTransition() {
        verseEntryTextView.editable = false

        UIView.animateWithDuration(0.1, animations: {
            self.submissionButton.backgroundColor = self.successSubmissionColor
            self.submissionButton.setTitle("Great job!", forState: .Normal)
            self.submissionButton.layer.addAnimation(self.bounceAnimation(), forKey: "position")
        })
        
        if activeVerseIndex != (verses.count - 1) {
            activeVerseIndex = activeVerseIndex + 1
            activateVerse(verses[activeVerseIndex] as! UserVerse)
            incrementActiveVerseViewCounter()
            
            let delay = 0.7 * Double(NSEC_PER_SEC)
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.transitionToNextVerse()
            })
        } else {
            self.displayCompletion()
        }
    }
    
    func displayVerseFailure() {
        UIView.animateWithDuration(0.1, animations: {
            self.submissionButton.backgroundColor = self.failureSubmissionColor
            self.submissionButton.setTitle("Try again!", forState: .Normal)
            self.submissionButton.layer.addAnimation(self.shakeAnimation(), forKey: "position")
        })
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.1, animations: {
                self.submissionButton.backgroundColor = self.neutralSubmissionColor
                self.submissionButton.setTitle("Check it!", forState: .Normal)
            })
        })
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
    
    func transitionToNextVerse() {
        title = activeVerse.reference
        verseEntryTextView.editable = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.basicHelpLabel.alpha = 0
            self.intermediateHelpLabel.alpha = 0
            self.advancedHelpLabel.alpha = 0
            
            self.basicHelpLabel.text = self.activeVerse.text
            self.intermediateHelpLabel.text = self.activeVerse.text
            self.advancedHelpLabel.text = self.activeVerse.text
            
            self.exposeFreeHints()
            
            self.submissionButton.backgroundColor = self.neutralSubmissionColor
            self.submissionButton.setTitle("Check it!", forState: .Normal)
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
    }
    
    func displayCompletion() {
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("completionSegue", sender: self)
        })
    }
    
    func incrementActiveVerseViewCounter() {
        activeVerse.views = Int(activeVerse.views!) + 1
        try! appDelegate.managedObjectContext.save()
    }
}

