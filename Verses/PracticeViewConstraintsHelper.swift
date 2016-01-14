//
//  PracticeViewConstraintsHelper.swift
//  Verses
//
//  Created by Isaac Williams on 1/12/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

public class PracticeViewConstraintsHelper {
    var basicHelpLabelToBottomLayoutGuide = 8
    var promptLabelToBottomLayoutGuide = 8
    var verseEntryTextViewToBottomLayoutGuide = 8
    var basicHelpLabel: UILabel!
    var promptLabel: UILabel!
    
    init(helpLabel: UILabel, promptLabel: UILabel) {
        self.basicHelpLabel = helpLabel
        self.promptLabel = promptLabel
    }
    
    func showHelp() {
        verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide + Int(basicHelpLabel.intrinsicContentSize().height)
    }
    
    func showPrompt() {
        basicHelpLabelToBottomLayoutGuide = basicHelpLabelToBottomLayoutGuide + Int(promptLabel.frame.height)
        verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide + Int(promptLabel.frame.height)
    }
    
    func hidePrompt() {
        basicHelpLabelToBottomLayoutGuide = basicHelpLabelToBottomLayoutGuide - Int(promptLabel.frame.height)
        verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide - Int(promptLabel.frame.height)
    }
    
    func keyboardWillChangeFrame(keyboardHeight: CGFloat, promptVisible: Bool, hintVisible: Bool) {
        verseEntryTextViewToBottomLayoutGuide = 8 + Int(keyboardHeight)
        if hintVisible { verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide + Int(basicHelpLabel.frame.height) }
        if promptVisible { verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide + Int(promptLabel.frame.height) }

        basicHelpLabelToBottomLayoutGuide = 8 + Int(keyboardHeight)
        if promptVisible { basicHelpLabelToBottomLayoutGuide = basicHelpLabelToBottomLayoutGuide + Int(promptLabel.frame.height) }

        promptLabelToBottomLayoutGuide = 8 + Int(keyboardHeight)
    }
    
    func keyboardWillHide(promptVisible: Bool, hintVisible: Bool) {
        verseEntryTextViewToBottomLayoutGuide = 8
        if promptVisible { verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide + Int(promptLabel.frame.height) }
        if hintVisible { verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide + Int(basicHelpLabel.frame.height) }

        basicHelpLabelToBottomLayoutGuide = 8
        if promptVisible { basicHelpLabelToBottomLayoutGuide = basicHelpLabelToBottomLayoutGuide + Int(promptLabel.frame.height) }

        promptLabelToBottomLayoutGuide = 8
    }
}