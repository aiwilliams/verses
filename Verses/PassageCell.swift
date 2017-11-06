import Foundation
import UIKit

class PassageCell: UITableViewCell {
  @IBOutlet var flagLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var selectionLabel: UILabel!
  @IBOutlet var distanceFromFlagToTitle: NSLayoutConstraint!
}
