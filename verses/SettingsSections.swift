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
    func remindersSwitchSection(section: RemindersSwitchSection, setSwitchOn on: Bool)
}

class RemindersSwitchSection: NSObject, SettingsSection {
    var delegate: RemindersSwitchSectionDelegate
    var remindersSwitch: UISwitch
    var isEditable = false
    var reuseIdentifier = "RemindersSwitchCell"
    var enabledWhenRemindersOff = true
    
    init(delegate: RemindersSwitchSectionDelegate, switchOn: Bool) {
        self.delegate = delegate
        self.remindersSwitch = UISwitch()
        super.init()
        
        self.remindersSwitch.on = switchOn
        self.remindersSwitch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
    }
    
    func switchChanged() {
        self.delegate.remindersSwitchSection(self, setSwitchOn: self.remindersSwitch.on)
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
        NSCalendarUnit.DayCalendarUnit.rawValue: "Daily",
        NSCalendarUnit.WeekCalendarUnit.rawValue: "Weekly",
        NSCalendarUnit.MonthCalendarUnit.rawValue: "Monthly"
    ]
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func addReminder() -> Reminder {
        let reminder = Reminder(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
        reminder.frequency = .DayCalendarUnit
        reminder.time = NSDate()
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
        cell.textLabel!.text = dateFormatter.stringFromDate(reminder.time)
        cell.detailTextLabel!.text = frequencies[UInt(reminder.rawFrequency)]
    }
    
    func numberOfRows() -> Int {
        return reminders.count
    }
    
    func selectRow(atIndex index: Int) {}
}

protocol RemindersAddSectionDelegate {
    func remindersAddSectionShouldAddReminder(section: RemindersAddSection)
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
        self.delegate.remindersAddSectionShouldAddReminder(self)
    }
}
