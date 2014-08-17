//
//  RequisitesTableViewCell.m
//  eiPad
//
//  Created by Ivan Chernov on 16.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "RequisitesTableViewCell.h"


@implementation RequisitesTableViewCell
@synthesize txtField, attentionButton, attentionLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        txtField = [[UITextField alloc] init];
        txtField.adjustsFontSizeToFitWidth = YES;
        [txtField setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
        txtField.textColor = [UIColor blackColor];
        txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        txtField.returnKeyType = UIReturnKeyDefault;
        txtField.backgroundColor = [UIColor clearColor];
        txtField.autocorrectionType = UITextAutocorrectionTypeNo;
        txtField.textAlignment = UITextAlignmentLeft;
        txtField.tag = 0;

		[self.contentView addSubview:txtField];
        
        attentionButton = [[UIImageView alloc] init];
        [self.contentView addSubview:attentionButton];
        
        attentionLabel = [[UILabel alloc] init];
        attentionLabel.numberOfLines = 2;
        attentionLabel.lineBreakMode = UILineBreakModeWordWrap;
        attentionLabel.backgroundColor = [UIColor whiteColor];
        attentionLabel.textColor = [UIColor redColor];
        [attentionLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
        [self.contentView addSubview:attentionLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	//CGRect contentRect = self.contentView.bounds;
	//CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	frame= CGRectMake(8, 12, 468, 22);
	txtField.frame = frame;
    
    CGRect frame2;
	frame2 = CGRectMake(245, 10, 23, 23);
	attentionButton.frame = frame2;
    attentionButton.image = [UIImage imageNamed:@"exmark.png"];
    
    CGRect frame3;
	frame3 = CGRectMake(270, 5, 205, 34);
	attentionLabel.frame = frame3;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end
