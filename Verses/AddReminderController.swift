import Foundation
import UIKit
import CoreData
import UserNotifications

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
    let notificationIdentifier = UUID().uuidString
    saveReminder(withIdentifier: notificationIdentifier)
    scheduleReminder(withIdentifier: notificationIdentifier)
    self.dismiss(animated: true, completion: nil)
  }

  private func roundToNearestFive(number: Int) -> Int {
    return (number % 5) >= 3 ? number - (number % 5) + 5 : number - (number % 5)
  }

  private func saveReminder(withIdentifier notificationIdentifier: String) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let entityDescription = NSEntityDescription.entity(forEntityName: "Reminder", in: appDelegate.managedObjectContext)!
    let managedObject = NSManagedObject(entity: entityDescription, insertInto: appDelegate.managedObjectContext)
    managedObject.setValue(reminderTimePicker.date, forKey: "time")
    managedObject.setValue(notificationIdentifier, forKey: "notificationIdentifier")

    do {
      try appDelegate.managedObjectContext.save()
    } catch let error as NSError {
      print("Could not save \(error), \(error.userInfo)")
    }
  }

  private func scheduleReminder(withIdentifier notificationIdentifier: String) {
    let notificationCenter = UNUserNotificationCenter.current()

    notificationCenter.getNotificationSettings { (settings) in
      if settings.authorizationStatus != .authorized {
        let ac = UIAlertController(title: "Can't schedule", message: "We don't have permission to schedule notifications! Please allow it in your Settings.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
        return
      }
    }

    let content = UNMutableNotificationContent()
    content.title = "It's time to memorize!"
    content.sound = UNNotificationSound.default()
    let trigger = UNCalendarNotificationTrigger(dateMatching: NSCalendar.current.dateComponents([.hour, .minute], from: reminderTimePicker.date), repeats: true)
    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
    notificationCenter.add(request) { (error) in
      if let err = error {
        print(err.localizedDescription)
      }
    }
  }
}
