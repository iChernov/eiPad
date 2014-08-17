//
//  addItemViewController.h
//  eiPad
//
//  Created by Ivan Chernov on 18.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itemContainer.h"
#import "DocumentHintPickerController.h"
#import "itemRepository.h"

@protocol AddItemViewControllerDelegate <NSObject, DocumentHintPickerDelegate>

- (void)didDismissAddItemViewWithItemContainer:(itemContainer *)itemCont;
- (void)dismissAddItemView;
- (void)deleteItem;
- (void)rotatedDetected:(NSNumber *)num;

@end

@interface addItemViewController : UIViewController {
    IBOutlet UITextField *nameTF, *qtyTF, *edizmTF, *costTF;
	IBOutlet UILabel* summaryLabel;
    IBOutlet UIButton* saveBttn;
    IBOutlet UIButton* deleteBttn;
    
    DocumentHintPickerController *dnamehint;
    DocumentHintPickerController *dedizmhint;
    
    UIView *contentView;
    BOOL shouldHideDeleteButton;

    BOOL editingNameNotEnded;
    BOOL editingEdizmNotEnded;
    
    itemRepository *iSaver;
    DocumentHintPickerController *_documentNameHintPicker;
    DocumentHintPickerController *_documentEdizmHintPicker;
    UIPopoverController *hintNamePickerPopover;
    UIPopoverController *hintEdizmPickerPopover;
    id<AddItemViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UIPopoverController *hintNamePickerPopover, *hintEdizmPickerPopover;
@property(nonatomic,retain) UILabel *summaryLabel;
@property(nonatomic,retain) UITextField *nameTF, *qtyTF, *edizmTF, *costTF;
@property(nonatomic,retain) UIButton* saveBttn, *deleteBttn;
@property (nonatomic, assign) id<AddItemViewControllerDelegate> delegate;
@property(nonatomic, retain) DocumentHintPickerController *documentNameHintPicker, *documentEdizmHintPicker;

- (IBAction)deleteItem:(id)sender;
- (IBAction)saveItem:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)putFocusToQty:(id)sender;
- (IBAction)putFocusToEdizm:(id)sender;
- (IBAction)putFocusToCost:(id)sender;
- (IBAction)recalculateSummary:(id)sender;
- (IBAction)itemNameIsFilling;
- (IBAction)itemEdizmIsFilling;
- (IBAction)tryFillItem;
- (void)hideNamePopover;
- (void)hideEdizmPopover;
- (void)tryFillItemWithName:(NSString *)name;
- (NSString *)clearStr:(NSString *)str;
@end
