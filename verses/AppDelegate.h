//
//  AppDelegate.h
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly) NSManagedObjectContext *userManagedObjectContext;

@end
