//
//  BillRepository.h
//  E-Iphone
//
//  Created by Ivan Chernov on 26.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BillRepositoryProtocol.h"

@interface BillRepository : NSObject <BillRepositoryProtocol> {
	NSString *pathToDocumentsFolder;
	NSString *billIdsFileName;
	NSUserDefaults *userDefs;
}

-(NSString *)fileNameBy:(int)billId;
-(int)saveIphoneBillIdToBillsFile;
-(void)saveBillIds:(NSArray*) billIds;
- (void)refreshItemsDictionary:(Bill *)bill;
-(NSString *)getActualIdsWithType:(NSString *)dtype;
- (NSDictionary *)loadDictionariedBillWithId:(int)billId;
- (NSArray *)doSearchWithKey:(NSString *)text andDtype:(NSString *)dtype;
-(NSArray *)getActualIds;
@end
