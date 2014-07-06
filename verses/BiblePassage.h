//
//  BiblePassage.h
//  verses
//
//  Created by Adam Williams on 7/5/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

@interface BiblePassage : NSManagedObject

+ (BOOL)isValidPassage:(NSString *)passage;

@property (nonatomic, strong) NSString *passage;

//@property (readonly) NSString *bookName;
//@property (readonly) NSString *beginBookName;
//@property (readonly) NSString *endBookName;
//
//@property (readonly) NSString *verseNumber;
//@property (readonly) NSString *beginVerseNumber;
//@property (readonly) NSString *endVerseNumber;

@end
