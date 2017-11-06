import Foundation
import UIKit
import CoreData

class RemindersController: UITableViewController {
  var appDelegate = UIApplication.shared.delegate as! AppDelegate
  var reminders: [NSManagedObject]!

  override func viewWillAppear(_ animated: Bool) {
    let moc = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")

    do {
      let results = try moc.fetch(fetchRequest)
      reminders = results as! [NSManagedObject]
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }

    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reminders.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reminder = reminders[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell") as! ReminderCell

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    cell.timeLabel.text = dateFormatter.string(from: reminder.value(forKey: "time") as! Date)

    let toggleSwitch = UISwitch()
    toggleSwitch.isOn = reminder.value(forKey: "on") as! Bool
    toggleSwitch.addTarget(self, action: #selector(RemindersController.reminderSwitchChanged(_:)), for: .valueChanged)
    toggleSwitch.tag = indexPath.row
    cell.accessoryView = toggleSwitch

    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let reminder = reminders[indexPath.row]
      let moc = appDelegate.managedObjectContext
      moc.delete(reminder)
      try! moc.save()

      tableView.beginUpdates()

      reminders.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      rescheduleReminders()

      tableView.endUpdates()
    }
  }

  @objc func reminderSwitchChanged(_ sender: UISwitch) {
    let reminder = reminders[sender.tag]
    reminder.setValue(sender.isOn, forKey: "on")
    try! appDelegate.managedObjectContext.save()

    rescheduleReminders()
  }

  func rescheduleReminders() {
    UIApplication.shared.cancelAllLocalNotifications()
    for r in reminders {
      if r.value(forKey: "on") as! Bool {
        scheduleReminder(r)
      }
    }
  }

  func scheduleReminder(_ reminder: NSManagedObject) {
    guard let settings = UIApplication.shared.currentUserNotificationSettings else { return }

    if settings.types == UIUserNotificationType() {
      let ac = UIAlertController(title: "Can't schedule", message: "We don't have permission to schedule notifications! Please allow it in your Settings.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(ac, animated: true, completion: nil)
      return
    }

    let notif = UILocalNotification()
    notif.fireDate = reminder.value(forKey: "time") as? Date
    notif.alertBody = "It's time to memorize!"
    notif.soundName = UILocalNotificationDefaultSoundName
    notif.repeatInterval = .day
    UIApplication.shared.scheduleLocalNotification(notif)
  }
}
