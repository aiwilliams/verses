//
//  AddVerseViewController.m
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "AddVerseViewController.h"
#import "BiblePassage.h"

@interface AddVerseViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passageTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation AddVerseViewController

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if (sender != self.doneButton) return;
  
  if (self.passageTextField.text.length > 0) {
    NSString *passage = self.passageTextField.text;
    if ([BiblePassage isValidPassage:passage])
      self.biblePassage = passage;
  }
}
@end
