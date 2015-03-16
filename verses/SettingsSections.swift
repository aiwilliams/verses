import UIKit
import CoreData

protocol SettingsSection { // for typed Array of section models
    func enabledWhenRemindersOff() -> Bool
    func reuseIdentifier() -> String
    func numberOfRows() -> Int
    func configureCell(cell: UITableViewCell, atIndex index: Int)
}

protocol RemindersSwitchSectionDelegate {
    func remindersSwitchSet(#on: Bool)
}

class RemindersSwitchSection: NSObject, SettingsSection {
    var delegate: RemindersSwitchSectionDelegate
    var remindersSwitch: UISwitch
    
    init(delegate: RemindersSwitchSectionDelegate, switchOn: Bool) {
        self.delegate = delegate
        remindersSwitch = UISwitch() // "switch" is an operator for bad programmers
        super.init()
        
        self.remindersSwitch.on = switchOn
        self.remindersSwitch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
    }
    
    func switchChanged() {
        self.delegate.remindersSwitchSet(on: self.remindersSwitch.on)
    }
    
    func enabledWhenRemindersOff() -> Bool {
        return true
    }
    
    func reuseIdentifier() -> String {
        return "RemindersSwitchCell"
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        cell.accessoryView = self.remindersSwitch
        cell.selectionStyle = .None
    }
}

class RemindersListSection: SettingsSection {
    var managedObjectContext: NSManagedObjectContext
    
    var reminders: [Reminder] {
        get {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = self.entity
            
            var error: NSError?
            
            var fetchData = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)! as [Reminder]
            if fetchData.count == 0 {
                return [ self.addReminder() ]
            } else {
                fetchData = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)! as [Reminder]
                return fetchData
            }
        }
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
    
    func enabledWhenRemindersOff() -> Bool {
        return false
    }
    
    func reuseIdentifier() -> String {
        return "ReminderCell"
    }
    
    func numberOfRows() -> Int {
        return reminders.count
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        let reminder = reminders[index]
        cell.textLabel!.text = dateFormatter.stringFromDate(reminder.time)
        cell.detailTextLabel!.text = frequencies[UInt(reminder.rawFrequency)]
    }
}

class RemindersAddSection: NSObject, SettingsSection {
    func enabledWhenRemindersOff() -> Bool {
        return false
    }
    
    func reuseIdentifier() -> String {
        return "RemindersAddCell"
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        cell.selectionStyle = .None
    }
}