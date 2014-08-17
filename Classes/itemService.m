//
//  itemService.m
//  E-Iphone
//
//  Created by Ivan Chernov on 20.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "itemService.h"
#import "itemContainer.h"
#import "itemRepository.h"
#import "itemNameHints.h"
#import "DocumentHintPickerController.h"
@implementation itemService
- (void)saveItemsFromBill:(Bill *)bill
{
    itemRepository *itemRepo = [[itemRepository alloc] init];
    NSArray *items = bill.Items;
    for(itemContainer *item in items)
    {
        [itemRepo saveItemWithName:item.itemsName andEdizm:item.itemsEdIzm andCost:item.itemsCost];
    }
    [self refreshNeededHintsWithItems:items];
    [itemRepo release];
}

- (void)saveClientFromBill:(Bill *)bill
{
    //DocumentHintPickerController *tempClientHint = [[[DocumentHintPickerController alloc] initWithType:@"client"] autorelease];
    //[tempClientHint checkAndSaveHint:clientTextField.text];
}


- (void)refreshNeededHintsWithItems:(NSArray *)items
{
    itemNameHints *nameHints = [[itemNameHints alloc] initWithNameType];
    itemNameHints *edIzmHints = [[itemNameHints alloc] initWithEdIzmType];
    for (itemContainer *item in items) {
        [nameHints tryToAddNeededHint: item.itemsName];
        [edIzmHints tryToAddNeededHint: item.itemsEdIzm];
    }
    [nameHints saveHints];
    [edIzmHints saveHints];
    [nameHints release];
    [edIzmHints release];
}

- (void)refreshHintsWithItems:(NSArray *)items
{
    itemNameHints *nameHints = [[itemNameHints alloc] initWithNameType];
    itemNameHints *edIzmHints = [[itemNameHints alloc] initWithEdIzmType];
    for (itemContainer *item in items) {
        [nameHints tryToAddHint: [item.itemsName lowercaseString]];
        [edIzmHints tryToAddHint: [item.itemsEdIzm lowercaseString]];
    }
    [nameHints saveHints];
    [edIzmHints saveHints];
    [nameHints release];
    [edIzmHints release];
}
@end
