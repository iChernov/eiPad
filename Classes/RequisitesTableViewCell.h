//
//  RequisitesTableViewCell.h
//  eiPad
//
//  Created by Ivan Chernov on 16.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RequisitesTableViewCell : UITableViewCell {
	UITextField* txtField;
    UIImageView *attentionButton;
    UILabel *attentionLabel;
}
@property(nonatomic,retain)UITextField* txtField;
@property(nonatomic,retain)UIImageView *attentionButton;
@property(nonatomic,retain)UILabel *attentionLabel;

@end
