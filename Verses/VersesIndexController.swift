import Foundation
import UIKit
import CoreData

class VersesIndexController: UITableViewController {
  var passages = [UserPassage]()
  var selectedPassage: UserPassage!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(VersesIndexController.practiceAgain), name: NSNotification.Name(rawValue: "practiceAgain"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(VersesIndexController.continueToNextPassage), name: NSNotification.Name(rawValue: "continueToNextPassage"), object: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let moc = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserPassage")

    do {
      let results = try moc.fetch(fetchRequest)
      passages = results as! [UserPassage]
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }

    self.tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return passages.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "passageCell") as! PassageCell
    let passage = passages[indexPath.row]
    cell.titleLabel.text = passage.reference

    if passage.memorized!.boolValue == true {
      cell.flagLabel.text = "⚑"
    } else {
      cell.flagLabel.text = "⚐"
    }

    if passage.selectedVerses.count == 0 {
      cell.selectionLabel.isHidden = true
      cell.distanceFromFlagToTitle.constant = 10
    } else {
      cell.selectionLabel.isHidden = false
      cell.distanceFromFlagToTitle.constant = 40
    }

    return cell
  }

  /**
   When manually triggering the passagePracticeSegue or the verseSelectSegue, pass a UITableViewCell as the sender.
   Both destination controllers require the passage associated with the sender.
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "passagePracticeSegue" {
      let destinationViewController = segue.destination as! VersePracticeController
      var ip = tableView.indexPath(for: sender as! UITableViewCell)!

      self.selectedPassage = self.passages[ip.row]
      if selectedPassage.selectedVerses.count == 0 {
        destinationViewController.verses = self.selectedPassage.verses!
      } else {
        destinationViewController.verses = NSOrderedSet(array: selectedPassage.selectedVerses)
      }

      if ip.row + 1 >= (self.passages.count) {
        destinationViewController.nextPassageExists = false
      } else {
        destinationViewController.nextPassageExists = true
      }

      destinationViewController.hidesBottomBarWhenPushed = true
    } else if segue.identifier == "verseSelectSegue" {
      var ip = tableView.indexPath(for: sender as! UITableViewCell)!

      let destinationNavController = segue.destination as! UINavigationController
      let destinationViewController = destinationNavController.topViewController as! VerseSelectController
      let passage: UserPassage = self.passages[ip.row]
      destinationViewController.selectedVerses = passage.selectedVerses
      destinationViewController.passage = passage
      destinationViewController.dismissalHandler = { (verses) in
        for verse in verses { verse.selected = true }
        try! self.appDelegate.managedObjectContext.save()
        self.performSegue(withIdentifier: "passagePracticeSegue", sender: sender)
      }
    }
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let cell = tableView.cellForRow(at: indexPath) as! PassageCell
    let passage = self.passages[indexPath.row]

    let moreAction = UITableViewRowAction(style: .normal, title: "More", handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) in
      self.displayMoreOptions(indexPath)
    })

    var memorizeAction: UITableViewRowAction!
    if passage.memorized!.boolValue {
      memorizeAction = UITableViewRowAction(style: .normal, title: "⚐", handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) in
        passage.memorized = false
        try! self.appDelegate.managedObjectContext.save()
        cell.flagLabel.text = "⚐"
        tableView.setEditing(false, animated: true)
      })
    } else {
      memorizeAction = UITableViewRowAction(style: .normal, title: "⚑", handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) in
        passage.memorized = true
        try! self.appDelegate.managedObjectContext.save()
        cell.flagLabel.text = "⚑"
        tableView.setEditing(false, animated: true)
      })
    }
    memorizeAction.backgroundColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)

    let deleteAction = UITableViewRowAction(style: .normal, title: "✕", handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) in
      self.confirmDeletionOf(passageAt: indexPath)
    })
    deleteAction.backgroundColor = UIColor(red:1.00, green:0.35, blue:0.31, alpha:1.0)

    if passage.verses!.count != 1 {
      return [memorizeAction, deleteAction, moreAction]
    } else {
      return [memorizeAction, deleteAction]
    }
  }

  func displayMoreOptions(_ indexPath: IndexPath) {
    let passage = self.passages[indexPath.row]

    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    let selectAction = UIAlertAction(title: "Select Verses", style: .default, handler: { (alertAction: UIAlertAction) in
      self.performSegue(withIdentifier: "verseSelectSegue", sender: self.tableView.cellForRow(at: indexPath))
    })

    let clearAction = UIAlertAction(title: "Clear Selection", style: .destructive, handler: { (alertAction: UIAlertAction) in
      for verse in self.passages[indexPath.row].selectedVerses { verse.selected = false }
      try! self.appDelegate.managedObjectContext.save()
      CATransaction.begin()
      CATransaction.setCompletionBlock({
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
      })
      self.tableView.setEditing(false, animated: true)
      CATransaction.commit()
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction: UIAlertAction) in
      self.tableView.setEditing(false, animated: true)
    })

    alert.addAction(selectAction)
    if passage.selectedVerses.count != 0 { alert.addAction(clearAction) }
    alert.addAction(cancelAction)

    self.present(alert, animated: true, completion: nil)
  }

  func confirmDeletionOf(passageAt passageIndexPath: IndexPath) {
    let passageToDelete = passages[passageIndexPath.row]
    let alert = UIAlertController(title: "Delete Passage", message: "Are you sure you want to delete \(passageToDelete.reference!)? This will permanently destroy any practice data!", preferredStyle: .actionSheet)

    let deleteAction = UIAlertAction(title: "Delete, and I mean it!", style: .destructive, handler: { (alertAction) in
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.managedObjectContext.delete(passageToDelete)

      do {
        try appDelegate.managedObjectContext.save()
      } catch let err as NSError {
        print("Couldn't delete a passage. Error: \(err), \(err.userInfo)")
      }

      self.tableView.beginUpdates()

      self.passages.remove(at: passageIndexPath.row)
      self.tableView.deleteRows(at: [passageIndexPath], with: .automatic)

      self.tableView.endUpdates()
    })
    let cancelAction = UIAlertAction(title: "Nevermind", style: .cancel, handler: nil)

    alert.addAction(deleteAction)
    alert.addAction(cancelAction)

    self.present(alert, animated: true, completion: nil)
  }

  @objc func practiceAgain() {
    let pvc = self.storyboard!.instantiateViewController(withIdentifier: "versePracticeController")
    var controllerStack = self.navigationController!.viewControllers
    controllerStack.insert(pvc, at: 1)
    self.navigationController!.setViewControllers(controllerStack, animated: true)

    for controller in self.navigationController!.viewControllers {
      if controller.isKind(of: VersePracticeController.self) {
        let destination = controller as! VersePracticeController
        let index = self.passages.index(of: self.selectedPassage)
        let passage = self.passages[index!]

        if passage.selectedVerses.count == 0 {
          destination.verses = selectedPassage.verses!
        } else {
          destination.verses = NSOrderedSet(array: passage.selectedVerses)
        }

        if index! + 2 >= (self.passages.count) {
          destination.nextPassageExists = false
        } else {
          destination.nextPassageExists = true
        }

        self.navigationController!.popToViewController(destination, animated: true)
        break
      }
    }
  }

  @objc func continueToNextPassage() {
    let pvc = self.storyboard!.instantiateViewController(withIdentifier: "versePracticeController")
    var controllerStack = self.navigationController!.viewControllers
    controllerStack.insert(pvc, at: 1)
    self.navigationController!.setViewControllers(controllerStack, animated: true)

    for controller in self.navigationController!.viewControllers {
      if controller.isKind(of: VersePracticeController.self) {
        let destination = controller as! VersePracticeController
        let index = self.passages.index(of: self.selectedPassage)

        if index! + 1 >= (self.passages.count) {
          self.navigationController!.popToRootViewController(animated: true)
          break
        }

        if index! + 2 >= (self.passages.count) {
          destination.nextPassageExists = false
        } else {
          destination.nextPassageExists = true
        }

        let passage = self.passages[index! + 1]
        self.selectedPassage = passage
        destination.verses = passage.verses

        self.navigationController!.popToViewController(destination, animated: true)
        break
      }
    }
  }
}
