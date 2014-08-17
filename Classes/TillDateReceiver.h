//
//  TillDateReceiver.h
//  E-Iphone
//
//  Created by Ivan Chernov on 27.05.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CabinetControllerDelegate;
@interface TillDateReceiver : NSObject {
    NSString* tillDateString;
}
- (NSString *)getTillDate;
@property (nonatomic, assign) id <CabinetControllerDelegate> delegate;
@end
@protocol CabinetControllerDelegate
- (void)showTillDateLabel:(NSString *)tillDateString;
@end

