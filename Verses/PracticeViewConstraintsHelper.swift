//
//  PracticeViewConstraintsHelper.swift
//  Verses
//
//  Created by Isaac Williams on 1/12/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

open class PracticeViewConstraintsHelper {
    var basicHelpLabelToBottomLayoutGuide: NSLayoutConstraint!
    var promptLabelToBottomLayoutGuide: NSLayoutConstraint!
    var verseEntryTextViewToBottomLayoutGuide: NSLayoutConstraint!

    var basicHelpLabel: UILabel!
    var promptLabel: UILabel!

    init(helpLabel: UILabel, promptLabel: UILabel, basicHelpLabelToBottomLayoutGuide: NSLayoutConstraint, promptLabelToBottomLayoutGuide: NSLayoutConstraint, verseEntryTextViewToBottomLayoutGuide: NSLayoutConstraint, keyboardHeight: CGFloat) {
        self.basicHelpLabel = helpLabel
        self.promptLabel = promptLabel
        self.basicHelpLabelToBottomLayoutGuide = basicHelpLabelToBottomLayoutGuide
        self.promptLabelToBottomLayoutGuide = promptLabelToBottomLayoutGuide
        self.verseEntryTextViewToBottomLayoutGuide = verseEntryTextViewToBottomLayoutGuide
        
        self.basicHelpLabelToBottomLayoutGuide.constant = 8 + keyboardHeight
        self.promptLabelToBottomLayoutGuide.constant = 8 + keyboardHeight
        self.verseEntryTextViewToBottomLayoutGuide.constant = 8 + keyboardHeight
    }
    
    func showHelp() {
        verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant + basicHelpLabel.intrinsicContentSize.height
    }
    
    func showPrompt() {
        basicHelpLabelToBottomLayoutGuide.constant = basicHelpLabelToBottomLayoutGuide.constant + promptLabel.frame.height
        verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant + promptLabel.frame.height
    }
    
    func hidePrompt() {
        basicHelpLabelToBottomLayoutGuide.constant = basicHelpLabelToBottomLayoutGuide.constant - promptLabel.frame.height
        verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant - promptLabel.frame.height
    }
    
    func keyboardWillChangeFrame(_ keyboardHeight: CGFloat, promptVisible: Bool, hintVisible: Bool) {
        verseEntryTextViewToBottomLayoutGuide.constant = 8 + keyboardHeight
        if hintVisible { verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant + basicHelpLabel.frame.height }
        if promptVisible { verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant + promptLabel.frame.height }

        basicHelpLabelToBottomLayoutGuide.constant = 8 + keyboardHeight
        if promptVisible { basicHelpLabelToBottomLayoutGuide.constant = basicHelpLabelToBottomLayoutGuide.constant + promptLabel.frame.height }

        promptLabelToBottomLayoutGuide.constant = 8 + keyboardHeight
    }
    
    func keyboardWillHide(_ promptVisible: Bool, hintVisible: Bool) {
        verseEntryTextViewToBottomLayoutGuide.constant = 8
        if promptVisible { verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant + promptLabel.frame.height }
        if hintVisible { verseEntryTextViewToBottomLayoutGuide.constant = verseEntryTextViewToBottomLayoutGuide.constant + basicHelpLabel.frame.height }

        basicHelpLabelToBottomLayoutGuide.constant = 8
        if promptVisible { basicHelpLabelToBottomLayoutGuide.constant = basicHelpLabelToBottomLayoutGuide.constant + promptLabel.frame.height }

        promptLabelToBottomLayoutGuide.constant = 8
    }
}
