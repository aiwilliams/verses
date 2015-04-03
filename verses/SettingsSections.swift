import UIKit
import CoreData

protocol SettingsSection { // for typed Array of section models
    var isEditable: Bool { get }
    var reuseIdentifier: String { get }
    var enabledWhenRemindersOff: Bool { get }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int)
    func selectRow(atIndex index: Int, inSection section: Int, inTableView tableView: UITableView!)
    func numberOfRows() -> Int
    func heightForRow(index: Int) -> Int
}

protocol RemindersSwitchSectionDelegate {
    func remindersSwitchSection(section: RemindersSwitchSection, toggled: Bool)
}

class RemindersSwitchSection: NSObject, SettingsSection {
    var delegate: RemindersSwitchSectionDelegate

    var remindersSwitch = UISwitch()
    var userDefaults = NSUserDefaults()
    var isEditable = false
    var reuseIdentifier = "RemindersSwitchCell"
    var enabledWhenRemindersOff = true
    
    var on : Bool {
        get { return userDefaults.boolForKey("remindersOn") }
    }
    
    init(delegate: RemindersSwitchSectionDelegate) {
        self.delegate = delegate

        super.init()
        
        self.remindersSwitch.on = self.on
        self.remindersSwitch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
    }
    
    func switchChanged() {
        userDefaults.setBool(remindersSwitch.on, forKey: "remindersOn")
        self.delegate.remindersSwitchSection(self, toggled: self.remindersSwitch.on)
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        cell.accessoryView = self.remindersSwitch
        cell.selectionStyle = .None
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func heightForRow(index: Int) -> Int {
        return 44
    }
    
    func selectRow(atIndex index: Int, inSection section: Int, inTableView tableView: UITableView!) {}
}

class ReminderSection: SettingsSection {
    var managedObjectContext: NSManagedObjectContext
    var isEditable = true
    var enabledWhenRemindersOff = false
    var reuseIdentifier = "ReminderCell"
    var selectedIndex: Int?
    var reminder: Reminder
    
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
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        switch index {
        case 0:
            cell.textLabel!.text = "Time"
            cell.detailTextLabel!.text = timeFormatter.stringFromDate(reminder.fireDate)
        default:
            cell.textLabel!.text = "Frequency"
            cell.detailTextLabel!.text = reminder.repeatIntervalDescription()
        }
    }
    
    func numberOfRows() -> Int {
        return 2
    }
    
    func heightForRow(index: Int) -> Int {
        if index == selectedIndex {
            return 300
        } else {
            return 44
        }
    }
    
    func selectRow(atIndex index: Int, inSection section: Int, inTableView tableView: UITableView!) {
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: section)], withRowAnimation: .Automatic)
    }
}

protocol RemindersAddSectionDelegate {
    func addReminder(section: RemindersAddSection, sectionIndex: Int)
}

class RemindersAddSection: NSObject, SettingsSection {
    var delegate: RemindersAddSectionDelegate
    var isEditable = false
    var enabledWhenRemindersOff = false
    var reuseIdentifier = "RemindersAddCell"
    
    init(delegate: RemindersAddSectionDelegate) {
        self.delegate = delegate
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        // don't do anything weird like change the selection style to none
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func heightForRow(index: Int) -> Int {
        return 44
    }
    
    func selectRow(atIndex index: Int, inSection section: Int, inTableView tableView: UITableView!) {
        self.delegate.addReminder(self, sectionIndex: section)
    }
}
