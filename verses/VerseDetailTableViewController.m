#import "VerseDetailTableViewController.h"
#import "verses-Swift.h"

@interface VerseDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *passageCell;
@property (weak, nonatomic) IBOutlet UILabel *passageTextLabel;
@end

@implementation VerseDetailTableViewController

-(void)viewWillAppear:(BOOL)animated {
  self.navigationItem.title = self.biblePassage.passage;
  self.passageTextLabel.text = self.biblePassage.content;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0)
    return self.biblePassage.translation;
  else
    return @"PROGRESS";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = 1.0f; // cell separator allowance
  if (indexPath.section == 0 && indexPath.row == 0) {
    height += [self.passageCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
  }
  return height;
}

@end
