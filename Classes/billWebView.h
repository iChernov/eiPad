//
//  billWebView.h
//  E-Iphone
//
//  Created by Ivan Chernov on 10.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface billWebView : NSObject {
	NSString *htmlPage;
	UIWebView *billView;
	UIWebView *wV;
}
@property(nonatomic, retain) NSString *htmlPage;
@property(nonatomic, retain) UIWebView *billView;
- (id)initWithBill:(NSDictionary *)billInfo;
- (void)insertValuesIn:(NSMutableDictionary *)variables from:(NSDictionary *)selfInfoDct;
- (NSString *)nullableToString:(id) object;
- (NSString *)returnHtml;
@end
