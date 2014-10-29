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
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BiblePassage" inManagedObjectContext:self.userManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
    NSError *error = nil;
    NSArray *objects = [self.userManagedObjectContext executeFetchRequest:request error:&error];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    NSString *lastVerseRef = [[objects lastObject] valueForKey:@"passage"];
    NSString *lastVerseContent = [[objects lastObject] valueForKey:@"content"];

    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:29];
    [comps setMonth:10];
    [comps setYear:2014];
    [comps setHour:16];
    
    localNotification.fireDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    localNotification.repeatInterval = NSCalendarUnitDay;
    localNotification.alertBody = [NSString stringWithFormat:@"%@ \n\"%@\"", lastVerseRef, lastVerseContent];
    localNotification.hasAction = true;
    localNotification.alertAction = NSLocalizedString(@"View Details", nil);
    localNotification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BiblePassage" inManagedObjectContext:self.userManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
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
//    NSString *verseRef = url.lastPathComponent;
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BiblePassage" inManagedObjectContext:self.userManagedObjectContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    [request setResultType:NSDictionaryResultType];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"passage = %@", verseRef];
//    [request setPredicate:predicate];
//    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
//                                        initWithKey:@"passage" ascending:YES];
//    [request setSortDescriptors:@[sortDescriptor]];
//    NSError *error;
//    NSArray *array = [self.userManagedObjectContext executeFetchRequest:request error:&error];
//    //    NSExpression *expression = [NSExpression expressionForKeyPath:@"passage"];
//
//    NSArray *objects = [self.userManagedObjectContext executeFetchRequest:request error:&error];
//    
//    NSLog(@"%@", objects);

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
