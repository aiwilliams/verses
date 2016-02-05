//
//  VerseCompletionController.swift
//  Verses
//
//  Created by Isaac Williams on 2/4/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class VerseCompletionController: UIViewController {
    var practicedVerses: NSOrderedSet!

    @IBOutlet var practiceAgainButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        practiceAgainButton.layer.cornerRadius = 10
        practiceAgainButton.backgroundColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)
    }
    
    @IBAction func practiceAgain(sender: UIButton) {
        let pvc = self.storyboard!.instantiateViewControllerWithIdentifier("versePracticeController")
        var controllerStack = self.navigationController!.viewControllers
        controllerStack.insert(pvc, atIndex: 1)
        self.navigationController!.setViewControllers(controllerStack, animated: true)

        for controller in self.navigationController!.viewControllers {
            if controller.isKindOfClass(VersePracticeController) {
                let destination = controller as! VersePracticeController
                destination.verses = practicedVerses

                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}