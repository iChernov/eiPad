//
//  SearchViewController.h
//
#import <UIKit/UIKit.h>
#import "Bill.h"
#import "BillRepository.h"
#import "DocumentHintPickerController.h"
#import "DataViewController.h"
#import "Synchronizer.h"
#import "MBProgressHUD.h"
@protocol SearchViewDelegateProtocol <NSObject>

@end

@interface SearchViewController : UIViewController
<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, DataViewControllerDelegate, SynchronizerDelegate> {
	NSMutableArray *tableData;
	MBProgressHUD *HUD;
    UIImageView *arrowView;
    UILabel *arrowLabel;
	UIView *disableViewOverlay;
	UIActivityIndicatorView *syncIndicator;
	UITableView *theTableView;
	UISearchBar *theSearchBar;
    NSTimer *timer;
    NSString *dtype;
    BillRepository *repo;
    NSMutableArray *billiPadIds;
    NSMutableArray *billiPadClientNames;
    NSMutableDictionary *dictionaryOfDocsAndCNames;
    
    UIButton *createNewDoc;
    UIView *horizLine;
    UIProgressView *downloadBar;
    int numOfDownloadingDocs;
    int numOfUploadingDocs;
    UILabel *syncLabel;
    BOOL isLoading;
    BOOL isSharikoff;
    UIPopoverController *_DocumentTypePickerPopover;
    id<SearchViewDelegateProtocol> _delegate;
}

@property (nonatomic, assign) id<SearchViewDelegateProtocol> delegate;

@property(retain) NSMutableArray *tableData;
@property(retain) UIView *disableViewOverlay;
@property (nonatomic, retain) UIProgressView *downloadBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UIView *horizLine;

@property (nonatomic, retain) UIPopoverController *DocumentTypePickerPopover;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;
- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)theTitle andRepo:(BillRepository *)repo;
-(void)syncBillsWithServer;
- (void)setProgressCount:(NSNumber *)countOfDownloadingDocs;
- (void)changeProgress:(int)numOfDownloadedDocs;
- (void) startLoading;
- (NSArray *)getUniqueClientsNames:(NSArray *)reversedBilliPadIds;
- (BOOL)checkIfLCArray:(NSArray *)arr containsObject:(NSString *)str;
- (NSArray *)doSearchWithKey:(NSString *)text;
@end