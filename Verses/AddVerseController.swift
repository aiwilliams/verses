import Foundation
import UIKit
import CoreData

class AddVerseController: UIViewController {
  @IBOutlet var requestedVerseTextField: UITextField!
  @IBOutlet var errorLabel: UILabel!
  @IBOutlet var passagePreviewLabel: UILabel!
  @IBOutlet var translationLabel: UILabel!

  let passageParser = PassageParser()
  let API = HeartversesAPI()
  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  let userDefaults = UserDefaults.standard

  override func viewDidLoad() {
    super.viewDidLoad()

    errorLabel.alpha = 0
    passagePreviewLabel.alpha = 0

    requestedVerseTextField.becomeFirstResponder()
    requestedVerseTextField.addTarget(self, action: #selector(AddVerseController.updateVersePreview), for: .editingChanged)

    updateTranslationDisclosure()

    NotificationCenter.default.addObserver(self, selector: #selector(AddVerseController.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
  }

  /*
   There is a link to the Settings app for changing the translation selection. Update views to show the current translation selection when the application enters foreground and this controller is active.
   */
  @objc func applicationWillEnterForeground() {
    updateVersePreview()
    updateTranslationDisclosure()
  }

  @objc func updateVersePreview() {
    do {
      let passage = try self.fetchPassage()
      passagePreviewLabel.text = passage.verses.first!.text
      UIView.animate(withDuration: 0.3, animations: { self.passagePreviewLabel.alpha = 1 })
    } catch {
      UIView.animate(withDuration: 0.3, animations: { self.passagePreviewLabel.alpha = 0 })
    }
  }

  func updateTranslationDisclosure() {
    let preferredTranslation = userDefaults.string(forKey: "preferredBibleTranslation")!
    translationLabel.text = "Translation: \(preferredTranslation)"
  }

  @IBAction func cancelButtonPressed(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func doneButtonPressed(_ sender: AnyObject) {
    do {
      let passage = try self.fetchPassage()
      savePassage(passage)
      self.dismiss(animated: true, completion: nil)
    } catch HeartversesAPI.FetchError.passageDoesNotExist {
      errorLabel.text = "That passage does not exist."
      displayErrorLabel()
    } catch PassageParser.ParseError.ambiguousBookName {
      errorLabel.text = "That book name is ambiguous."
      displayErrorLabel()
    } catch PassageParser.ParseError.invalidRange {
      errorLabel.text = "That range of verses is out of bounds."
      displayErrorLabel()
    } catch {
      errorLabel.text = "Sorry, an unknown error ocurred."
      displayErrorLabel()
    }
  }

  func displayErrorLabel() {
    UIView.animate(withDuration: 0.7, animations: { self.errorLabel.alpha = 1 })
    Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(AddVerseController.hideErrorLabel), userInfo: nil, repeats: false)
  }

  @objc func hideErrorLabel() {
    UIView.animate(withDuration: 0.7, animations: { self.errorLabel.alpha = 0 })
  }

  @IBAction func launchSettings(_ sender: UIButton) {
    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
  }

  func fetchPassage() throws -> Passage {
    let parsedPassage = try passageParser.parse(requestedVerseTextField.text!)
    let preferredTranslation = userDefaults.string(forKey: "preferredBibleTranslation")!
    let passage = try API.fetchPassage(parsedPassage, translation: preferredTranslation.lowercased())
    return passage
  }

  func savePassage(_ passage: Passage) {
    // Maybe we should have a something that handles all Core Data interactions instead of always leaving it up to the controllers
    let entityDescription = NSEntityDescription.entity(forEntityName: "UserPassage", in: appDelegate.managedObjectContext)!
    let managedObject = UserPassage(entity: entityDescription, insertInto: appDelegate.managedObjectContext)
    let verseSet = NSMutableOrderedSet()
    for v in passage.verses {
      let verse = convertVerseToNSManagedObject(v)
      verseSet.add(verse)
    }
    managedObject.verses = verseSet
    managedObject.reference = passage.reference

    do {
      try appDelegate.managedObjectContext.save()
    } catch let error as NSError {
      print("Could not save \(error), \(error.userInfo)")
    }
  }

  func convertVerseToNSManagedObject(_ verse: Verse) -> NSManagedObject {
    let entity = NSEntityDescription.entity(forEntityName: "UserVerse", in: appDelegate.managedObjectContext)
    let nsmo = UserVerse(entity: entity!, insertInto: appDelegate.managedObjectContext)
    nsmo.book = verse.book
    nsmo.chapter = verse.chapter as NSNumber
    nsmo.number = verse.number as NSNumber
    nsmo.text = verse.text
    nsmo.views = 0

    return nsmo
  }
}
