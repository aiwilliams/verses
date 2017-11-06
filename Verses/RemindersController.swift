import Foundation
import UIKit
import CoreData
import UserNotifications

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
      removeReminderNotification(reminder)
      let moc = appDelegate.managedObjectContext
      moc.delete(reminder)
      try! moc.save()

      tableView.beginUpdates()

      reminders.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)

      tableView.endUpdates()
    }
  }

  @objc func reminderSwitchChanged(_ sender: UISwitch) {
    let reminder = reminders[sender.tag]
    reminder.setValue(sender.isOn, forKey: "on")
    try! appDelegate.managedObjectContext.save()

    if reminder.value(forKey: "on") as! Bool == false {
      removeReminderNotification(reminder)
    }
  }

  func removeReminderNotification(_ reminder: NSManagedObject) {
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.getPendingNotificationRequests { (requests) in
      for request in requests {
        if request.identifier == reminder.value(forKey: "notificationIdentifier") as! String {
          notificationCenter.removePendingNotificationRequests(withIdentifiers: [request.identifier])
        }
      }
    }
  }
}
