//
//  VerseDetailTableViewController.m
//  verses
//
//  Created by Adam Williams on 7/6/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "VerseDetailTableViewController.h"

#import "verses-Swift.h"

@interface VerseDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *passageCell;
@property (weak, nonatomic) IBOutlet UILabel *passageTextLabel;
@end

@implementation VerseDetailTableViewController

-(void)viewWillAppear:(BOOL)animated {
  self.navigationItem.title = self.biblePassage.passage;
  self.passageTextLabel.text = @"There was a man of the Pharisees named Nicodemus, a ruler of the Jews.  2 This man came to Jesus by night and said to Him, “Rabbi, we know that You are a teacher come from God; for no one can do these signs that You do unless God is with him.” John 3:3   Jesus answered and said to him, “Most assuredly, I say to you, unless one is born again, he cannot see the kingdom of God.”";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = 1.0f; // cell separator allowance
  if (indexPath.row == 0) {
    height += [self.passageCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  }
  return height;
}

@end
