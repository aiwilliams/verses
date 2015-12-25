import Foundation
import UIKit

class VerseHelper {
    let verse: UserVerse!
    
    init(verse: UserVerse) {
        self.verse = verse
    }
    
    func firstLetters() -> NSAttributedString {
        let text = verse.text!
        let attributed = NSMutableAttributedString(string: text)
        var index = 0
        var secondCharIndexes = [1]
        for _ in text.characters {
            if index < 3 {
                ++index
                continue
            }
            let backTwo = text.startIndex.advancedBy(index - 2)
            if text.characters[backTwo] == " " {
                secondCharIndexes.append(index)
            }
            ++index
        }
        
        var nextIndex = 1
        for i in secondCharIndexes {
            if nextIndex == secondCharIndexes.count {
                attributed.setAttributes([NSForegroundColorAttributeName:UIColor.clearColor()], range: NSMakeRange(i, text.characters.count - i))
                break
            }
            attributed.setAttributes([NSForegroundColorAttributeName:UIColor.clearColor()], range: NSMakeRange(i, (secondCharIndexes[nextIndex] - 2) - i))
            ++nextIndex
        }
        return attributed
    }

    func randomWords() -> NSAttributedString {
        let text = verse.text!
        let attributed = NSMutableAttributedString(string: text)
        var index = 0
        var lastSeenSpaceIndex = 0
        var ranges: Array<NSRange> = Array<NSRange>()
        for char in text.characters {
            if char == " " {
                ranges.append(NSMakeRange(lastSeenSpaceIndex, index - lastSeenSpaceIndex))
                lastSeenSpaceIndex = index
            }
            ++index
        }
        
        for _ in ranges.count / 3 {
            let randomIndex = Int(arc4random_uniform(UInt32(ranges.count)))
            ranges.removeAtIndex(randomIndex)
        }
        
        for range in ranges {
            attributed.setAttributes([NSForegroundColorAttributeName:UIColor.clearColor()], range: range)
        }
        
        return attributed
    }
    
    func roughlyMatches(userInput: String) -> Bool {
        return normalizedString(userInput.lowercaseString) == removePunctuation(verse.text!.lowercaseString)
    }

    private func normalizedString(text: String) -> String {
        let spelledOut = spellOutNumbers(text)
        let final = removePunctuation(spelledOut)
        return final
    }
    
    private func removePunctuation(text: String) -> String {
        return text.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator("")
    }
    
    private func spellOutNumbers(text: String) -> String {
        var words: Array<String> = text.componentsSeparatedByString(" ")
        var index = 0
        
        for word in words {
            if let numberWord: NSInteger = Int(word) {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .SpellOutStyle
                let formattedNumber = formatter.stringFromNumber(numberWord)
                words.removeAtIndex(index)
                words.insert(formattedNumber!, atIndex: index)
            }
            ++index
        }
        
        return words.joinWithSeparator(" ")
    }
}