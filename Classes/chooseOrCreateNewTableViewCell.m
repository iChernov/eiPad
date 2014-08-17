//
//  chooseOrCreateNewTableViewCell.m
//  E-Iphone
//
//  Created by Ivan Chernov on 16.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "chooseOrCreateNewTableViewCell.h"
//для SearchView

@implementation chooseOrCreateNewTableViewCell
@synthesize clientNameLabel, billDetailsLabel, summaryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        clientNameLabel = [[UILabel alloc] init];
		clientNameLabel.textAlignment = UITextAlignmentLeft;
		clientNameLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
		clientNameLabel.textColor = [UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1]; /*#4a2200*/

		clientNameLabel.backgroundColor = [UIColor clearColor];
        
		billDetailsLabel = [[UILabel alloc] init];
		billDetailsLabel.textAlignment = UITextAlignmentLeft;
        billDetailsLabel.textColor = [UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1]; /*#4a2200*/
		billDetailsLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
		billDetailsLabel.backgroundColor = [UIColor clearColor];
        
		summaryLabel = [[UILabel alloc] init];
		summaryLabel.textAlignment = UITextAlignmentRight;
		summaryLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		summaryLabel.textColor = [UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1]; /*#4a2200*/
		summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.backgroundColor = [UIColor clearColor];

		[self.contentView addSubview:clientNameLabel];
		[self.contentView addSubview:billDetailsLabel];
		[self.contentView addSubview:summaryLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	//CGRect contentRect = self.contentView.bounds;
	//CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
		
	frame= CGRectMake(24 ,5, 326, 30);
	clientNameLabel.frame = frame;
	
	frame= CGRectMake(24 ,35, 326, 30);
	billDetailsLabel.frame = frame;
	
	frame= CGRectMake(355, 20, 145, 30);
	summaryLabel.frame = frame;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
