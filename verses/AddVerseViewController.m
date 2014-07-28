//
//  AddVerseViewController.m
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "AddVerseViewController.h"

#import "verses-Swift.h"

@interface AddVerseViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passageTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation AddVerseViewController

- (void)viewWillAppear:(BOOL)animated {
  [self.passageTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.passageTextField resignFirstResponder];
}

- (IBAction)addVerse:(id)sender {
  if (self.passageTextField.text.length > 0) {
    [self.activityIndicator startAnimating];
    NSString *passage = self.passageTextField.text;
    [self.bibleAPI loadPassage:passage completion:^(BiblePassage *biblePassage) {
      [self.activityIndicator stopAnimating];
      if (biblePassage == nil) return;

      self.biblePassage = biblePassage;
      [self performSegueWithIdentifier:@"unwindAddVerse" sender:sender];
    }];
  } else {
    [self performSegueWithIdentifier:@"unwindAddVerse" sender:sender];
  }
}

@end
