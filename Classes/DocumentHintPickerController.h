//
//  DocumentTypePickerController.h
//  MathMonsters
//
//  Created by Ray Wenderlich on 5/3/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itemNameHints.h"

@protocol DocumentHintPickerDelegate
- (void)documentSelected:(NSString *)document;
- (NSString *)getNameHintedText;
@end


@interface DocumentHintPickerController : UITableViewController {
    NSMutableArray *_hints;
    id<DocumentHintPickerDelegate> _delegate;
    NSString *hintType;
    BOOL itemWasFoundInHints;
    NSUserDefaults *userDefs;

    itemNameHints *nameHints;
    BOOL nameHint;
}

@property (nonatomic, retain) NSMutableArray *hints;
@property (nonatomic, retain) NSString *hintType;
@property (nonatomic, retain) itemNameHints *nameHints;
@property (nonatomic, assign) id<DocumentHintPickerDelegate> delegate;
- (void)showHints;
- (NSArray *)calculateHints;
- (BOOL)checkAndSaveHint:(NSString *)hText;
- (id)initWithType:(NSString *)type;
@end
