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
    @IBOutlet var promptLabel: UILabel!
    @IBOutlet var verseEntryTextView: UITextView!
    @IBOutlet var helpButton: UIBarButtonItem!
    @IBOutlet var passageProgressView: UIProgressView!

    @IBOutlet var basicHelpLabelToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var promptLabelToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var verseEntryTextViewToBottomLayoutGuide: NSLayoutConstraint!

    var passage: UserPassage!
    var verses: NSOrderedSet!
    
    var activeVerse: UserVerse!
    var verseHelper: VerseHelper!
    var activeVerseIndex: Int!
    
    var constraintsHelper: PracticeViewConstraintsHelper!

    var promptTimer: NSTimer!
    
    var verseEntryTextViewEnabled = true
    var keyboardHeight: CGFloat = 0
    var verseCompleted = false

    var helpLevel: Int = 0
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let neutralPromptColor = UIColor(red:0.40, green:0.60, blue:1.00, alpha:1.0)
    let successPromptColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        verseEntryTextView.delegate = self
        
        if passage != nil {
            verses = passage.valueForKey("verses") as! NSOrderedSet
        }

        activateVerse(verses.firstObject as! UserVerse)
        activeVerseIndex = 0
        incrementActiveVerseViewCounter()

        title = activeVerse.reference
        
        basicHelpLabel.text = activeVerse.text
        intermediateHelpLabel.text = activeVerse.text
        advancedHelpLabel.text = activeVerse.text
        
        self.observeKeyboard()
        verseEntryTextView.becomeFirstResponder()
        
        constraintsHelper = PracticeViewConstraintsHelper(helpLabel: basicHelpLabel, promptLabel: promptLabel, basicHelpLabelToBottomLayoutGuide: basicHelpLabelToBottomLayoutGuide, promptLabelToBottomLayoutGuide: promptLabelToBottomLayoutGuide, verseEntryTextViewToBottomLayoutGuide: verseEntryTextViewToBottomLayoutGuide, keyboardHeight: self.keyboardHeight)

        self.view.layoutIfNeeded()
        if Int(activeVerse.views!) <= 10 {
            exposeFreeHelp()
        }

        resetPromptTimer()

        if verses.count == 1 {
            passageProgressView.hidden = true
        }
    }
    
    func userTimedOut() {
        if promptLabel.alpha == 0 {
            constraintsHelper.showPrompt()
            UIView.animateWithDuration(0.5, animations: {
                self.promptLabel.text = "Still there?"
                self.promptLabel.textColor = self.neutralPromptColor
                self.promptLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        } else if promptLabel.alpha == 1 {
            promptTimer.invalidate()

            let fadeAnimation = CATransition()
            fadeAnimation.type = kCATransitionFade
            fadeAnimation.duration = 0.5
            promptLabel.layer.addAnimation(fadeAnimation, forKey: "kCATransitionFade")
            self.promptLabel.text = "Try a hint!"

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "helpButtonPressed:")
            self.promptLabel.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func activateVerse(verse: UserVerse) {
        activeVerse = verse
        verseHelper = VerseHelper(verse: verse)
    }
    
    func exposeFreeHelp() {
        if Int(activeVerse.views!) <= 2 {
            constraintsHelper.showHelp()
            helpButton.enabled = false
            advancedHelpLabel.alpha = 1
        } else if Int(activeVerse.views!) > 2 && Int(activeVerse.views!) <= 5 {
            constraintsHelper.showHelp()
            helpButton.enabled = true
            helpLevel = 2
            basicHelpLabel.attributedText = verseHelper.firstLetters()
            intermediateHelpLabel.attributedText = verseHelper.randomWords()
            basicHelpLabel.alpha = 1
            intermediateHelpLabel.alpha = 1
        } else if Int(activeVerse.views!) > 5 && Int(activeVerse.views!) <= 10 {
            constraintsHelper.showHelp()
            helpButton.enabled = true
            helpLevel = 1
            basicHelpLabel.attributedText = verseHelper.firstLetters()
            basicHelpLabel.alpha = 1
        }
    }
    
    func resetPromptTimer() {
        if let t = promptTimer { t.invalidate() }
        promptTimer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "userTimedOut", userInfo: nil, repeats: true)
    }
    
    func hidePrompt() {
        if promptLabel.alpha == 1 {
            constraintsHelper.hidePrompt()
            UIView.animateWithDuration(0.5, animations: { self.promptLabel.alpha = 0; self.view.layoutIfNeeded() })
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if verseCompleted {
            if self.verseHelper.roughlyMatches("\(textView.text)\(text)") {
                return true
            }
        }

        return verseEntryTextViewEnabled
    }
    
    func textViewDidChange(textView: UITextView) {
        resetPromptTimer()
        hidePrompt()

        if !verseCompleted {
            if self.verseHelper.roughlyMatches(textView.text) {
                verseEntryTextViewEnabled = false
                verseCompleted = true
                let delay = 0.7 * Double(NSEC_PER_SEC)
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.promptTimer.invalidate()
                    self.displayVerseSuccessAndTransition()
                })
            }
        }
    }

    @IBAction func helpButtonPressed(sender: AnyObject) {
        resetPromptTimer()
        hidePrompt()
        helpLevel++

        if basicHelpLabel.alpha == 0 {
            constraintsHelper.showHelp()
        }
        
        switch helpLevel {
        case 1:
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let frame = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!
        let keyboardFrame: CGRect = frame.CGRectValue
        let height: CGFloat = keyboardFrame.size.height
        
        keyboardHeight = height
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let frame = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        let keyboardFrame: CGRect = frame.CGRectValue
        let height: CGFloat = keyboardFrame.size.height

        constraintsHelper.keyboardWillChangeFrame(height, promptVisible: promptLabel.alpha == 1, hintVisible: basicHelpLabel.alpha == 1 || advancedHelpLabel.alpha == 1)

        UIView.animateWithDuration(animationDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let animationDuration = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue

        constraintsHelper.keyboardWillHide(promptLabel.alpha == 1, hintVisible: basicHelpLabel.alpha == 1 || advancedHelpLabel.alpha == 1)

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
                self.promptLabel.alpha = 1
                self.promptLabel.textColor = self.successPromptColor
                self.promptLabel.text = "Great job!"
                self.promptLabel.layer.addAnimation(self.bounceAnimation(), forKey: "position")
            })
            
            if self.activeVerseIndex != (self.verses.count - 1) {
                self.activeVerseIndex = self.activeVerseIndex + 1
                self.activateVerse(self.verses[self.activeVerseIndex] as! UserVerse)
                self.incrementActiveVerseViewCounter()
                self.passageProgressView.setProgress(Float(self.verses.indexOfObject(self.activeVerse)) / Float(self.verses.count), animated: true)
                
                let delay = 0.7 * Double(NSEC_PER_SEC)
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.transitionToNextVerse()
                })
            } else {
                self.passageProgressView.setProgress(1, animated: true)
                self.displayCompletion()
            }
        })
    }

    func displayCompletion() {
        let delay = 1.0 * Double(NSEC_PER_SEC)
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

            self.constraintsHelper = PracticeViewConstraintsHelper(helpLabel: self.basicHelpLabel, promptLabel: self.promptLabel, basicHelpLabelToBottomLayoutGuide: self.basicHelpLabelToBottomLayoutGuide, promptLabelToBottomLayoutGuide: self.promptLabelToBottomLayoutGuide, verseEntryTextViewToBottomLayoutGuide: self.verseEntryTextViewToBottomLayoutGuide, keyboardHeight: self.keyboardHeight)
            self.exposeFreeHelp()
            
            self.verseEntryTextViewEnabled = true
        })
        
        let transitionVerseEntryTextViewAnimation = CATransition()
        transitionVerseEntryTextViewAnimation.duration = 0.5
        transitionVerseEntryTextViewAnimation.type = kCATransitionFade
        self.verseEntryTextView.layer.addAnimation(transitionVerseEntryTextViewAnimation, forKey: "pushTransition")
        UIView.animateWithDuration(0.5, animations: { self.promptLabel.alpha = 0 })

        verseEntryTextView.text = ""
        verseEntryTextView.becomeFirstResponder()
        resetPromptTimer()
        verseCompleted = false
    }

    func bounceAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.11
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.promptLabel.center.x, self.promptLabel.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.promptLabel.center.x, self.promptLabel.center.y - 10))
        return animation
    }
    
    func incrementActiveVerseViewCounter() {
        activeVerse.views = Int(activeVerse.views!) + 1
        try! appDelegate.managedObjectContext.save()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "completionSegue" {
            let destinationViewController = segue.destinationViewController as! VerseCompletionController
            destinationViewController.practicedPassage = self.passage
        }
    }
}

