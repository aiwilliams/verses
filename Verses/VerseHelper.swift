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
                index += 1
                continue
            }
            let backTwo = text.characters.index(text.startIndex, offsetBy: index - 2)
            if text.characters[backTwo] == " " {
                secondCharIndexes.append(index)
            }
            index += 1
        }
        
        var nextIndex = 1
        for i in secondCharIndexes {
            if nextIndex == secondCharIndexes.count {
              attributed.setAttributes([NSAttributedStringKey.foregroundColor:UIColor.clear], range: NSMakeRange(i, text.characters.count - i))
                break
            }
          attributed.setAttributes([NSAttributedStringKey.foregroundColor:UIColor.clear], range: NSMakeRange(i, (secondCharIndexes[nextIndex] - 2) - i))
            nextIndex += 1
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
            index += 1
        }
        
        for _ in 0..<(ranges.count / 3) {
            let randomIndex = Int(arc4random_uniform(UInt32(ranges.count)))
            ranges.remove(at: randomIndex)
        }
        
        for range in ranges {
          attributed.setAttributes([NSAttributedStringKey.foregroundColor:UIColor.clear], range: range)
        }
        
        return attributed
    }
    
    func roughlyMatches(_ userInput: String) -> Bool {
        return normalizedString(userInput.lowercased()) == removePunctuation(verse.text!.lowercased())
    }

    fileprivate func normalizedString(_ text: String) -> String {
        let spelledOut = spellOutNumbers(text)
        let final = removePunctuation(spelledOut)
        return final
    }
    
    fileprivate func removePunctuation(_ text: String) -> String {
        return text.components(separatedBy: CharacterSet.letters.inverted).joined(separator: "")
    }
    
    fileprivate func spellOutNumbers(_ text: String) -> String {
        var words: Array<String> = text.components(separatedBy: " ")
        var index = 0
        
        for word in words {
            if let numberWord: NSInteger = Int(word) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .spellOut
              let formattedNumber = formatter.string(from: NSNumber(value: numberWord))
                words.remove(at: index)
                words.insert(formattedNumber!, at: index)
            }
            index += 1
        }
        
        return words.joined(separator: " ")
    }
}
