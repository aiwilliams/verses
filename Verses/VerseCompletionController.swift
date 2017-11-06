import Foundation
import UIKit

class VerseCompletionController: UIViewController {
  var nextPassageExists: Bool!

  @IBOutlet var practiceAgainButton: UIButton!
  @IBOutlet var nextPassageButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    if !nextPassageExists {
      nextPassageButton.isHidden = true
    }
  }

  @IBAction func practiceAgain(_ sender: UIButton) {
    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "practiceAgain"), object: nil))
  }

  @IBAction func continueToNextPassage(_ sender: UIButton) {
    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "continueToNextPassage"), object: nil))
  }
}
