/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBBugCreateSummaryCell.h"
#import "SNBBugCreateSummaryModel.h"
#import "SNBBugCreateCellDelegate.h"

@interface SNBBugCreateSummaryCell()

@property (nonatomic, strong) SNBBugCreateSummaryModel *model;

@property (nonatomic, strong) IBOutlet UITextField *summaryTextField;

@end

@implementation SNBBugCreateSummaryCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.summaryTextField.text = [self.model summary];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)didEditText:(UITextField *)sender
{
    [self.model updateSummaryWithText:sender.text];
}


@end
