//
//  UpdateNotifier.h
//  E-Iphone
//
//  Created by Ivan Chernov on 03.03.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UpdateNotifier : NSObject {
	NSString* criticalMessage;
	NSString *updateMessage;
}
@property(nonatomic, retain) NSString *criticalMessage;
@property(nonatomic, retain) NSString *updateMessage;
-(NSData *)receiveUpdateDataFromServer;
-(void)receiveCriticalAndUpgradeMeassages;
-(BOOL)updateIsCritical;
-(NSString *)updateMessage;
@end
