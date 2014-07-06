//
//  VersesTableViewController.m
//  verses
//
//  Created by Adam Williams on 7/3/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

#import "VersesTableViewController.h"
#import "AddVerseViewController.h"
#import "BiblePassage.h"

@interface VersesTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation VersesTableViewController

@synthesize fetchedResultsController=_fetchedResultsController;

-(void)viewDidLoad {
  NSError *error;
  if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"BiblePassage" inManagedObjectContext:self.userManagedObjectContext];
  [fetchRequest setEntity:entity];
  
  NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"passage" ascending:YES];
  NSArray *sortDescriptors = @[numberDescriptor];
  [fetchRequest setSortDescriptors:sortDescriptors];

  _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.userManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
  _fetchedResultsController.delegate = self;
  
  return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  
  UITableView *tableView = self.tableView;
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type) {
      
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BiblePassage *passage = [self.fetchedResultsController objectAtIndexPath:indexPath];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"verseCell" forIndexPath:indexPath];
  UILabel *titleLabel = (UILabel *)[cell viewWithTag:0];
  titleLabel.text = passage.passage;
  return cell;
}

#pragma mark - Navigation

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
  AddVerseViewController *addController = [segue sourceViewController];
  if (addController.biblePassage != nil) {
    BiblePassage *passage = (BiblePassage *)[NSEntityDescription insertNewObjectForEntityForName:@"BiblePassage" inManagedObjectContext:self.userManagedObjectContext];
    [passage setValue:addController.biblePassage forKey:@"passage"];
    
    NSError *error;
    [self.userManagedObjectContext save:&error];
  }
}

@end