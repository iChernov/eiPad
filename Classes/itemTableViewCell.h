//
//  itemTableViewCell.h
//  eiPad
//
//  Created by Ivan Chernov on 07.09.11.
//  Copyright (c) 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface itemTableViewCell : UITableViewCell
{
    UILabel* clientNameLabel;
	UILabel* billDetailsLabel;
	UILabel* summaryLabel;
}
@property(nonatomic,retain)UILabel *clientNameLabel;
@property(nonatomic,retain)UILabel *billDetailsLabel;
@property(nonatomic,retain)UILabel *summaryLabel;

@end
