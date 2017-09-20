//
//  VerseSelectController.swift
//  Verses
//
//  Created by Isaac Williams on 2/3/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class VerseSelectController: UITableViewController {
    var passage: UserPassage!
    var selectedVerses: Array<UserVerse> = []
    var dismissalHandler: ((Array<UserVerse>)->Void)!

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passage.verses!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verseCell") as! VerseCell
        let verse = passage.verses![indexPath.row] as! UserVerse
        cell.versePassageLabel.text = verse.reference

        if !selectedVerses.contains(verse) {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        let verse = passage.verses![indexPath.row] as! UserVerse

        if !selectedVerses.contains(verse) {
            cell!.accessoryType = .checkmark
            selectedVerses.append(verse)
        } else {
            cell!.accessoryType = .none
            let index = selectedVerses.index(of: verse)
            selectedVerses.remove(at: index!)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func cancelVerseSelect(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func continueToPractice(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            if self.dismissalHandler != nil {
                var practiceVerses: Array<UserVerse> = []
                for verse in self.passage.verses! {
                    let v = verse as! UserVerse
                    if self.selectedVerses.contains(v) { practiceVerses.append(v) }
                }
                self.dismissalHandler(practiceVerses)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! VersePracticeController
        destinationViewController.verses = NSOrderedSet(array: self.selectedVerses)
    }
}
