#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class BiblePassage;

@interface VersesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) BiblePassage *biblePassage;

@end
