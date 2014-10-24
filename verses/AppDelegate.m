//
//  AppDelegate.m
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "AppDelegate.h"
#import "VersesTableViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong, readonly) NSManagedObjectContext *userManagedObjectContext;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
  VersesTableViewController *rootViewController = (VersesTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
  rootViewController.userManagedObjectContext = self.userManagedObjectContext;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BiblePassage" inManagedObjectContext:self.userManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
//    NSExpression *expression = [NSExpression expressionForKeyPath:@"passage"];
    NSError *error = nil;
    NSArray *objects = [self.userManagedObjectContext executeFetchRequest:request error:&error];
    if (objects == nil) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.thewilliams.verses"];
        [sharedDefaults setValue:@"" forKeyPath:@"VerseReference"];
        [sharedDefaults setValue:@"You don't have any verses!" forKey:@"VerseContent"];
        [sharedDefaults synchronize];
    }
    else {
        if ([objects count] > 0) {
            NSString *lastVerseRef = [[objects lastObject] valueForKey:@"passage"];
            NSString *lastVerseContent = [[objects lastObject] valueForKey:@"content"];
            
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.thewilliams.verses"];
            [sharedDefaults setValue:lastVerseRef forKeyPath:@"VerseReference"];
            [sharedDefaults setValue:lastVerseContent forKey:@"VerseContent"];
            [sharedDefaults synchronize];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}

#pragma mark - Core Data stack

@synthesize userManagedObjectContext = _userManagedObjectContext;

- (NSManagedObjectContext *)userManagedObjectContext
{
  if (_userManagedObjectContext) return _userManagedObjectContext;
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UserData" withExtension:@"momd"];
  NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *libraryURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
  NSURL *url = [libraryURL URLByAppendingPathComponent:@"Example.storedata"];
  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
  NSAssert(coordinator, @"Failed to initialize coordinator");
  
  NSError *error;
  NSAssert1([coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error], @"Error: %@", error);
  
  _userManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  [_userManagedObjectContext setPersistentStoreCoordinator:coordinator];
  
  return _userManagedObjectContext;
}

@end
