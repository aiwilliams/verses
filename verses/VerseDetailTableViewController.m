//
//  VerseDetailTableViewController.m
//  verses
//
//  Created by Adam Williams on 7/6/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "VerseDetailTableViewController.h"

@interface VerseDetailTableViewController ()

@end

@implementation VerseDetailTableViewController

-(void)viewWillAppear:(BOOL)animated {
  self.navigationItem.title = self.biblePassage.passage;
}
@end
