import Foundation
import UIKit
import CoreData

class AddReminderController: UIViewController {
  @IBOutlet var reminderTimePicker: UIDatePicker!

  override func viewDidLoad() {
    super.viewDidLoad()

    var time = NSCalendar.current.dateComponents([.hour, .minute], from: Date())
    time.setValue(roundToNearestFive(number: time.minute!), for: .minute)
    let date = NSCalendar.current.date(from: time)!

    reminderTimePicker.setDate(date, animated: false)
  }

  @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
    saveReminder()
    scheduleReminder()
    self.dismiss(animated: true, completion: nil)
  }

  private func roundToNearestFive(number: Int) -> Int {
    return (number % 5) >= 3 ? number - (number % 5) + 5 : number - (number % 5)
  }

  private func saveReminder() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let entityDescription = NSEntityDescription.entity(forEntityName: "Reminder", in: appDelegate.managedObjectContext)!
    let managedObject = NSManagedObject(entity: entityDescription, insertInto: appDelegate.managedObjectContext)
    managedObject.setValue(reminderTimePicker.date, forKey: "time")

    do {
      try appDelegate.managedObjectContext.save()
    } catch let error as NSError {
      print("Could not save \(error), \(error.userInfo)")
    }
  }

  private func scheduleReminder() {
    guard let settings = UIApplication.shared.currentUserNotificationSettings else { return }

    if settings.types == UIUserNotificationType() {
      let ac = UIAlertController(title: "Can't schedule", message: "We don't have permission to schedule notifications! Please allow it in your Settings.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(ac, animated: true, completion: nil)
      return
    }

    let notif = UILocalNotification()
    notif.fireDate = reminderTimePicker.date
    notif.alertBody = "It's time to memorize!"
    notif.soundName = UILocalNotificationDefaultSoundName
    notif.repeatInterval = .day
    UIApplication.shared.scheduleLocalNotification(notif)
  }
}
