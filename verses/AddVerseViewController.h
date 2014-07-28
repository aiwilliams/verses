//
//  AddVerseViewController.h
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

@class BibliaAPI;
@class BiblePassage;

@interface AddVerseViewController : UIViewController

@property (nonatomic, retain) BibliaAPI *bibleAPI;
@property (nonatomic, retain) BiblePassage *biblePassage;

@end
