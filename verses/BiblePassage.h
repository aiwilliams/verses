//
//  BiblePassage.h
//  verses
//
//  Created by Adam Williams on 7/5/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

@interface BiblePassage : NSManagedObject

+ (BOOL)isValidPassage:(NSString *)passage;

// https://api.biblia.com will be a source
@property (nonatomic, strong) NSString *passage;

@end
