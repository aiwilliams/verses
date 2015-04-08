import UIKit
import CoreData

protocol SettingsSectionViewController { // for typed Array of section models
    var isEditable: Bool { get }
    var reuseIdentifier: String { get }
    var enabledWhenRemindersOff: Bool { get }
    
    func tableView(tableView: UITableView, cellForRow row: Int) -> UITableViewCell
    func tableView(tableView: UITableView, didSelectRow row: Int)
    func numberOfRows() -> Int
    func heightForRow(index: Int) -> Int
}

protocol RemindersSwitchSectionViewDelegate {
    func remindersSwitchDidChange(on: Bool)
}

class RemindersSwitchSectionViewController: NSObject, SettingsSectionViewController {
    var delegate: RemindersSwitchSectionViewDelegate

    var remindersSwitch = UISwitch()
    var userDefaults = NSUserDefaults()
    var isEditable = false
    var reuseIdentifier = "RemindersSwitchCell"
    var enabledWhenRemindersOff = true
    
    var on : Bool {
        get { return userDefaults.boolForKey("remindersOn") }
    }
    
    init(delegate: RemindersSwitchSectionViewDelegate) {
        self.delegate = delegate

        super.init()
        
        self.remindersSwitch.on = self.on
        self.remindersSwitch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
    }
    
    func switchChanged() {
        userDefaults.setBool(remindersSwitch.on, forKey: "remindersOn")
        self.delegate.remindersSwitchDidChange(self.remindersSwitch.on)
    }
    
    func tableView(tableView: UITableView, cellForRow row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemindersSwitchCell") as UITableViewCell
        cell.accessoryView = self.remindersSwitch
        cell.selectionStyle = .None
        return cell
    }

    func tableView(tableView: UITableView, didSelectRow row: Int) {}
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func heightForRow(index: Int) -> Int {
        return 44
    }
}

class ReminderSectionViewController: SettingsSectionViewController {
    var managedObjectContext: NSManagedObjectContext
    var isEditable = true
    var enabledWhenRemindersOff = false
    var reuseIdentifier = "ReminderCell"
    var reminder: Reminder

    var timeCell: SettingsTableViewTimeCell?
    var frequencyCell: SettingsTableViewFrequencyCell?

    var selectedRow = 0

    lazy var timeFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var frequencies = [
        NSCalendarUnit.CalendarUnitDay.rawValue: "Daily",
        NSCalendarUnit.CalendarUnitWeekday.rawValue: "Weekly",
        NSCalendarUnit.CalendarUnitMonth.rawValue: "Monthly"
    ]
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter
    }()
    
    init(managedObjectContext: NSManagedObjectContext, reminder: Reminder?) {
        self.managedObjectContext = managedObjectContext
        if reminder == nil {
            self.reminder = Reminder(managedObjectContext)
        } else {
            self.reminder = reminder!
        }
    }
    
    func addReminder() -> Reminder {
        let reminder = Reminder(managedObjectContext)
        self.managedObjectContext.save(nil)
        return reminder
    }
    
    func deleteReminder() {
        self.managedObjectContext.deleteObject(reminder)
        self.managedObjectContext.save(nil)
    }
    
    func tableView(tableView: UITableView, cellForRow row: Int) -> UITableViewCell {
        if row == 0 {
            if timeCell == nil {
                timeCell = loadCellFromNib("SettingsTableViewTimeCell", owner: tableView) as? SettingsTableViewTimeCell
            }
            return timeCell!
        } else {
            if frequencyCell == nil {
                frequencyCell = loadCellFromNib("SettingsTableViewFrequencyCell", owner: tableView) as? SettingsTableViewFrequencyCell
            }
            return frequencyCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRow row: Int) {
        selectedRow = row
        if row == 0 {
            timeCell?.datePicker.hidden = false
            frequencyCell?.picker.hidden = true
        } else {
            timeCell?.datePicker.hidden = true
            frequencyCell?.picker.hidden = false
        }
    }

    func numberOfRows() -> Int {
        return 2
    }
    
    func heightForRow(row: Int) -> Int {
        return selectedRow == row ? 205 : 44
    }
    
    func loadCellFromNib(nibName: String, owner: AnyObject) -> UITableViewCell {
        let nibArray = NSBundle.mainBundle().loadNibNamed(nibName, owner: owner, options: nil)
        return nibArray[0] as UITableViewCell
    }
}

protocol RemindersAddSectionViewDelegate {
    func addReminder(section: RemindersAddSectionViewController)
}

class RemindersAddSectionViewController: NSObject, SettingsSectionViewController {
    var delegate: RemindersAddSectionViewDelegate
    var isEditable = false
    var enabledWhenRemindersOff = false
    var reuseIdentifier = "RemindersAddCell"
    
    init(delegate: RemindersAddSectionViewDelegate) {
        self.delegate = delegate
    }
    
    func tableView(tableView: UITableView, cellForRow index: Int) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("RemindersAddCell") as UITableViewCell
    }

    func numberOfRows() -> Int {
        return 1
    }
    
    func heightForRow(index: Int) -> Int {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRow row: Int) {
        self.delegate.addReminder(self)
    }
}
