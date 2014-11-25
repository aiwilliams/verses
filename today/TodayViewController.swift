import UIKit
import NotificationCenter
import Foundation

class TodayViewController: UIViewController {
    @IBOutlet var verseLabel: UILabel!
    @IBOutlet var verseReference: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateVerseText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.updateVerseText()
    }
    
    func updateVerseText() {
        let defaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        if let verseRef = defaults.valueForKey("VerseReference") as? String {
            let verse = defaults.valueForKey("VerseContent")! as String
            self.verseLabel.text = verse
            self.verseReference.text = verseRef
        } else {
            self.verseLabel.text = "You have no verses. Touch to add one!"
        }
    }
    
    @IBAction func openContainingApp(sender: AnyObject) {
        let defaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        var appUrl = NSURL(string: "verses://verse")
        if let verseRef = defaults.valueForKey("VerseReference") as? String {
            appUrl = appUrl?.URLByAppendingPathComponent(verseRef)
        }
        self.extensionContext?.openURL(appUrl!, completionHandler: nil)
    }
}

