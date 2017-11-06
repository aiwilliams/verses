import UIKit
import CoreData

class passageCompletionSegue: UIStoryboardSegue {
  override func perform() {
    let navigationController = source.navigationController!
    var controllerStack = navigationController.viewControllers
    let index = controllerStack.index(of: source)!
    controllerStack.replaceSubrange(index...index, with: [destination])
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

  var verses: NSOrderedSet!

  var nextPassageExists: Bool!

  var activeVerse: UserVerse!
  var verseHelper: VerseHelper!
  var activeVerseIndex: Int!

  var constraintsHelper: PracticeViewConstraintsHelper!

  var verseEntryTextViewEnabled = true
  var keyboardHeight: CGFloat = 0
  var verseCompleted = false

  var helpLevel: Int = 0

  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  let neutralPromptColor = UIColor(red:0.40, green:0.60, blue:1.00, alpha:1.0)
  let successPromptColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)

  override func viewDidLoad() {
    super.viewDidLoad()

    self.automaticallyAdjustsScrollViewInsets = false
    verseEntryTextView.delegate = self

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
    if Int(truncating: activeVerse.views!) <= 10 {
      exposeFreeHelp()
    }

    if verses.count == 1 {
      passageProgressView.isHidden = true
    }
  }

  func activateVerse(_ verse: UserVerse) {
    activeVerse = verse
    verseHelper = VerseHelper(verse: verse)
  }

  func exposeFreeHelp() {
    if Int(truncating: activeVerse.views!) <= 2 {
      constraintsHelper.showHelp()
      helpButton.isEnabled = false
      advancedHelpLabel.alpha = 1
    } else if Int(truncating: activeVerse.views!) > 2 && Int(truncating: activeVerse.views!) <= 5 {
      constraintsHelper.showHelp()
      helpButton.isEnabled = true
      helpLevel = 2
      basicHelpLabel.attributedText = verseHelper.firstLetters()
      intermediateHelpLabel.attributedText = verseHelper.randomWords()
      basicHelpLabel.alpha = 1
      intermediateHelpLabel.alpha = 1
    } else if Int(truncating: activeVerse.views!) > 5 && Int(truncating: activeVerse.views!) <= 10 {
      constraintsHelper.showHelp()
      helpButton.isEnabled = true
      helpLevel = 1
      basicHelpLabel.attributedText = verseHelper.firstLetters()
      basicHelpLabel.alpha = 1
    }
  }

  func hidePrompt() {
    if promptLabel.alpha == 1 {
      constraintsHelper.hidePrompt()
      UIView.animate(withDuration: 0.5, animations: { self.promptLabel.alpha = 0; self.view.layoutIfNeeded() })
    }
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if verseCompleted {
      if self.verseHelper.roughlyMatches("\(textView.text)\(text)") {
        return true
      }
    }

    return verseEntryTextViewEnabled
  }

  func textViewDidChange(_ textView: UITextView) {
    if !verseCompleted {
      if self.verseHelper.roughlyMatches(textView.text) {
        verseEntryTextViewEnabled = false
        verseCompleted = true
        let delay = 0.7 * Double(NSEC_PER_SEC)
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
          self.displayVerseSuccessAndTransition()
        })
      }
    }
  }

  @IBAction func helpButtonPressed(_ sender: AnyObject) {
    helpLevel += 1

    if basicHelpLabel.alpha == 0 {
      constraintsHelper.showHelp()
    }

    switch helpLevel {
    case 1:
      basicHelpLabel.attributedText = verseHelper.firstLetters()
      UIView.animate(withDuration: 1, animations: { self.basicHelpLabel.alpha = 1 })
    case 2:
      intermediateHelpLabel.attributedText = verseHelper.randomWords()
      UIView.animate(withDuration: 1, animations: { self.intermediateHelpLabel.alpha = 1 })
    case 3:
      UIView.animate(withDuration: 1, animations: { self.advancedHelpLabel.alpha = 1})
      helpButton.isEnabled = false
    default:
      break
    }
  }

  func observeKeyboard() {
    NotificationCenter.default.addObserver(self, selector: #selector(VersePracticeController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(VersePracticeController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(VersePracticeController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }

  @objc func keyboardWillShow(_ notification: Notification) {
    let info: NSDictionary = notification.userInfo! as NSDictionary
    let frame = info.object(forKey: UIKeyboardFrameEndUserInfoKey)!
    let keyboardFrame: CGRect = (frame as AnyObject).cgRectValue
    let height: CGFloat = keyboardFrame.size.height

    keyboardHeight = height
  }

  @objc func keyboardWillChangeFrame(_ notification: Notification) {
    let info: NSDictionary = notification.userInfo! as NSDictionary
    let frame = info.object(forKey: UIKeyboardFrameEndUserInfoKey)!
    let animationDuration = (info.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as AnyObject).doubleValue
    let keyboardFrame: CGRect = (frame as AnyObject).cgRectValue
    let height: CGFloat = keyboardFrame.size.height

    constraintsHelper.keyboardWillChangeFrame(height, promptVisible: promptLabel.alpha == 1, hintVisible: basicHelpLabel.alpha == 1 || advancedHelpLabel.alpha == 1)

    UIView.animate(withDuration: animationDuration!, animations: {
      self.view.layoutIfNeeded()
    })
  }

  @objc func keyboardWillHide(_ notification: Notification) {
    let info: NSDictionary = notification.userInfo! as NSDictionary
    let animationDuration = (info.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as AnyObject).doubleValue

    constraintsHelper.keyboardWillHide(promptLabel.alpha == 1, hintVisible: basicHelpLabel.alpha == 1 || advancedHelpLabel.alpha == 1)

    UIView.animate(withDuration: animationDuration!, animations: {
      self.view.layoutIfNeeded()
    })
  }

  func displayVerseSuccessAndTransition() {
    UIView.animate(withDuration: 0.1, animations: {
      self.basicHelpLabel.alpha = 0
      self.intermediateHelpLabel.alpha = 0
      self.advancedHelpLabel.alpha = 0
    }, completion: { (animated: Bool) -> Void in
      UIView.animate(withDuration: 0.1, animations: {
        self.promptLabel.alpha = 1
        self.promptLabel.textColor = self.successPromptColor
        self.promptLabel.text = "Great job!"
        self.promptLabel.layer.add(self.bounceAnimation(), forKey: "position")
      })

      if self.activeVerseIndex != (self.verses.count - 1) {
        self.activeVerseIndex = self.activeVerseIndex + 1
        self.activateVerse(self.verses[self.activeVerseIndex] as! UserVerse)
        self.incrementActiveVerseViewCounter()
        self.passageProgressView.setProgress(Float(self.verses.index(of: self.activeVerse)) / Float(self.verses.count), animated: true)

        let delay = 0.7 * Double(NSEC_PER_SEC)
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
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
    let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
      self.performSegue(withIdentifier: "completionSegue", sender: self)
    })
  }

  func transitionToNextVerse() {
    title = activeVerse.reference
    verseEntryTextView.isEditable = true

    UIView.animate(withDuration: 0.5, animations: {
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
    self.verseEntryTextView.layer.add(transitionVerseEntryTextViewAnimation, forKey: "pushTransition")
    UIView.animate(withDuration: 0.5, animations: { self.promptLabel.alpha = 0 })

    verseEntryTextView.text = ""
    verseEntryTextView.becomeFirstResponder()
    verseCompleted = false
  }

  func bounceAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.11
    animation.repeatCount = 1
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: self.promptLabel.center.x, y: self.promptLabel.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: self.promptLabel.center.x, y: self.promptLabel.center.y - 10))
    return animation
  }

  func incrementActiveVerseViewCounter() {
    activeVerse.views = Int(truncating: activeVerse.views!) + 1 as NSNumber
    try! appDelegate.managedObjectContext.save()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "completionSegue" {
      let destinationViewController = segue.destination as! VerseCompletionController

      if !nextPassageExists {
        destinationViewController.nextPassageExists = false
      } else {
        destinationViewController.nextPassageExists = true
      }
    }
  }
}

