//
//  BiblePassage.m
//  verses
//
//  Created by Adam Williams on 7/5/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import <AFURLRequestSerialization.h>
#import <AFHTTPRequestOperation.h>
#import "BiblePassage.h"

@implementation BiblePassage

+ (BOOL)isValidPassage:(NSString *)passage {
  NSString *URLString = @"http://api.biblia.com/v1/bible/parse";
  NSDictionary *parameters = @{@"passage": passage, @"key": @"fd37d8f28e95d3be8cb4fbc37e15e18e"};

  NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil];
  
  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  op.responseSerializer = [AFJSONResponseSerializer serializer];
  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
  }];
  [[NSOperationQueue mainQueue] addOperation:op];
  
  return YES;
}

@dynamic passage;

@end
