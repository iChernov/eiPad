//
//  Syncronizer.h
//  E-Iphone
//
//  Created by Ivan Chernov on 15.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ElbaSyncProxyProtocol.h"
#import "BillRepositoryProtocol.h"
#import "Bill.h"
@protocol SynchronizerDelegate
- (void)changeDownloadProgress:(NSNumber *)numOfDownloadedDocs;
- (void)setDownloadProgressCount:(NSNumber *)countOfDownloadingDocs;
- (void)changeUploadProgress:(NSNumber *)numOfUploadedDocs;
//- (void)setUploadProgressCount:(NSNumber *)countOfUploadingDocs;
@end


@interface Synchronizer : NSObject {
	id <ElbaSyncProxyProtocol, NSObject> self_proxy;
	id <BillRepositoryProtocol, NSObject> self_repository;
	id<SynchronizerDelegate> _delegate;
}
- (id)init;
- (id)initWithProxy:(id <ElbaSyncProxyProtocol>)proxy andRepository:(id <BillRepositoryProtocol>)repository;
- (void)synchronize;
- (NSDictionary*)loadAllIphoneBills;
- (void)processElbaBills:(NSDictionary*) iPhoneBills;
- (long long)getMaxTimestamp:(NSDictionary*) bills;
- (void)processIPhoneBills:(NSDictionary*) bills;
- (void)processIPhoneBill:(Bill *) bill withId:(NSNumber*) iPhoneBillId;
- (NSDictionary*) createElbaIdToIPhoneIdMap:(NSDictionary*) bills;
- (void)updateIphoneBill:(Bill *)bill withId:(NSNumber *)iPhoneBillId;
- (void)uploadOnly:(int)bid;
@property (nonatomic, assign) id<SynchronizerDelegate> delegate;

@end
