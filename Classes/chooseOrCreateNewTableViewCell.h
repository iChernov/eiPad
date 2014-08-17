//
//  chooseOrCreateNewTableViewCell.h
//  E-Iphone
//
//  Created by Ivan Chernov on 16.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface chooseOrCreateNewTableViewCell : UITableViewCell {
	UILabel* clientNameLabel;
	UILabel* billDetailsLabel;
	UILabel* summaryLabel;
}
@property(nonatomic,retain)UILabel *clientNameLabel;
@property(nonatomic,retain)UILabel *billDetailsLabel;
@property(nonatomic,retain)UILabel *summaryLabel;

@end
