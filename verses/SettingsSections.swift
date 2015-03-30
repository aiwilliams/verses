import UIKit
import CoreData

protocol SettingsSection { // for typed Array of section models
    var isEditable: Bool { get }
    var reuseIdentifier: String { get }
    var enabledWhenRemindersOff: Bool { get }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int)
    func selectRow(atIndex index: Int)
    func numberOfRows() -> Int
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
    
    func selectRow(atIndex index: Int) {}
}

class RemindersListSection: SettingsSection {
    var managedObjectContext: NSManagedObjectContext
    var isEditable = true
    var enabledWhenRemindersOff = false
    var reuseIdentifier = "ReminderCell"
    
    var reminders: [Reminder] {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entity
        
        var error: NSError?
        
        var fetchData = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)! as [Reminder]
        fetchData = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)! as [Reminder]
        return fetchData
    }
    
    lazy var entity: NSEntityDescription = {
        return NSEntityDescription.entityForName("Reminder", inManagedObjectContext: self.managedObjectContext)!
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
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func addReminder() -> Reminder {
        let reminder = Reminder(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
        self.managedObjectContext.save(nil)
        return reminder
    }
    
    func deleteReminder(index: Int) {
        let reminder: Reminder = self.reminders[index]
        self.managedObjectContext.deleteObject(reminder)
        self.managedObjectContext.save(nil)
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        let reminder = reminders[index]
        cell.textLabel!.text = dateFormatter.stringFromDate(reminder.nextFireDate)
        cell.detailTextLabel!.text = frequencies[UInt(reminder.rawRepeatInterval)]
    }
    
    func numberOfRows() -> Int {
        return reminders.count
    }
    
    func selectRow(atIndex index: Int) {}
}

protocol RemindersAddSectionDelegate {
    func addReminder(section: RemindersAddSection)
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
    
    func selectRow(atIndex index: Int) {
        self.delegate.addReminder(self)
    }
}
