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
@property (weak, nonatomic) IBOutlet UILabel *errorText;

@end

@implementation AddVerseViewController

- (void)viewWillAppear:(BOOL)animated {
  [self.passageTextField becomeFirstResponder];
  self.errorText.hidden = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.passageTextField resignFirstResponder];
}

- (IBAction)addVerse:(id)sender {
  if (self.passageTextField.text.length > 0) {
    [self.activityIndicator startAnimating];
    NSString *passage = self.passageTextField.text;
    [self.bibleAPI loadPassage:passage
                   completion:^(BiblePassage *biblePassage) {
                      [self.activityIndicator stopAnimating];
                      self.errorText.hidden = true;
                      self.biblePassage = biblePassage;
                      [self performSegueWithIdentifier:@"unwindAddVerse" sender:sender];
                   }
                   failure:^(NSString *errorMessage) {
                       [self.activityIndicator stopAnimating];
                       self.errorText.text = errorMessage;
                       self.errorText.hidden = false;
                   }];
  } else {
    [self performSegueWithIdentifier:@"unwindAddVerse" sender:sender];
  }
}

@end
