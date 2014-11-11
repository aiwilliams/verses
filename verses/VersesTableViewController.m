#import "verses-Swift.h"
#import "VersesTableViewController.h"
#import "AddVerseViewController.h"
#import "VerseDetailTableViewController.h"

@interface VersesTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *disclosingRowIndexPath;
@property (nonatomic, strong) NSManagedObjectContext *userManagedObjectContext;
@end

@implementation VersesTableViewController

@synthesize fetchedResultsController=_fetchedResultsController;

-(void)viewDidLoad {
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.userManagedObjectContext = appDelegate.managedObjectContext;
    
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
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
    case NSFetchedResultsChangeMove:
      break;
    case NSFetchedResultsChangeUpdate:
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    BiblePassage *passage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.userManagedObjectContext deleteObject:passage];

    NSError *error;
    [self.userManagedObjectContext save:&error];
  }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.disclosingRowIndexPath = indexPath;
  [self performSegueWithIdentifier:@"verseDetail" sender:self];
}

#pragma mark - Navigation

-(IBAction)unwindToList:(UIStoryboardSegue *)segue {
  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"addVerse"]) {
    AddVerseViewController *addVerseController = [segue destinationViewController];
    addVerseController.bibleAPI = [[BibliaAPI alloc] initWithMoc:self.userManagedObjectContext];
  }
  
  if ([segue.identifier isEqualToString:@"verseDetail"]) {
    VerseDetailTableViewController *detailController = [segue destinationViewController];
    detailController.biblePassage = [self.fetchedResultsController objectAtIndexPath:self.disclosingRowIndexPath];
  }
}

@end
