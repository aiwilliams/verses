//
//  AddVerseViewController.m
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "AddVerseViewController.h"
#import "BiblePassage.h"
#import <AFURLRequestSerialization.h>
#import <AFHTTPRequestOperation.h>

@interface AddVerseViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passageTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation AddVerseViewController

- (void)parsePassage:(NSString *)passage completion:(void (^)(id))completion {
  NSString *URLString = @"http://api.biblia.com/v1/bible/parse";
  NSDictionary *parameters = @{@"passage": passage, @"key": @"fd37d8f28e95d3be8cb4fbc37e15e18e"};
  
  NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil];
  
  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  op.responseSerializer = [AFJSONResponseSerializer serializer];
  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
    completion(responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
    completion(nil);
  }];
  [[NSOperationQueue mainQueue] addOperation:op];
}

- (IBAction)addVerse:(id)sender {
  if (self.passageTextField.text.length > 0) {
    [self.activityIndicator startAnimating];
    NSString *passage = self.passageTextField.text;
    [self parsePassage:passage completion:^(NSDictionary *responseJSON) {
      [self.activityIndicator stopAnimating];
      if (responseJSON == nil) return;

      NSString *normalizedPassage = [responseJSON valueForKey:@"passage"];
      if ([normalizedPassage length] == 0) return;

      self.biblePassage = normalizedPassage;
      [self performSegueWithIdentifier:@"addVerseDoneSegue" sender:sender];
    }];
  } else {
    [self performSegueWithIdentifier:@"addVerseDoneSegue" sender:sender];
  }
}

@end
