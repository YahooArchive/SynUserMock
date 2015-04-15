/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBScreenShotCollectionCell.h"
#import "SNBStateDataItem.h"

static CGFloat kCollectionViewHeight = 180.0f;

@interface SNBScreenShotCollectionCell ()

@property (nonatomic, strong) UIImageView *screenShot;
@property (nonatomic, strong) UIImageView *editIcon;

@end

@implementation SNBScreenShotCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.screenShot = [[UIImageView alloc] initWithFrame:frame];
        self.screenShot.contentMode = UIViewContentModeScaleAspectFill;
        self.screenShot.userInteractionEnabled = NO;
        self.userInteractionEnabled = YES;
        [self.contentView addSubview:self.screenShot];
        self.editIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SNB_EditIcon.png"]];
        [self.contentView addSubview:self.editIcon];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect editIconFrame = self.editIcon.bounds;
    editIconFrame.origin.x = CGRectGetWidth(self.contentView.bounds)/2 - CGRectGetWidth(editIconFrame)/2;
    editIconFrame.origin.y = CGRectGetHeight(self.contentView.bounds)/2 - CGRectGetHeight(editIconFrame)/2;
    self.editIcon.frame = editIconFrame;
}

- (void)updateWithData:(SNBStateDataItem *)dataItem;
{
    CGSize size = [SNBScreenShotCollectionCell defaultSizeWithData:dataItem];
    self.screenShot.image = [dataItem screenShot];
    self.screenShot.frame = (CGRect) {CGPointZero, size.width, size.height};
}

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

+ (CGSize)defaultSizeWithData:(SNBStateDataItem *)dataItem
{
    CGSize size = CGSizeZero;
    UIImage *image = [dataItem screenShot];
    
    if(image) {
        if(image.size.height > image.size.width) {
            CGFloat ratio = kCollectionViewHeight / image.size.height;
            size = CGSizeMake(ratio*image.size.width, kCollectionViewHeight);
        } else {
            CGFloat ratio = kCollectionViewHeight / image.size.height;
            size = CGSizeMake(ratio*image.size.width, kCollectionViewHeight);
        }
    } else {
        size = CGSizeZero;
    }
    
    // make sure we have a valid size
    size.height = MAX(0, size.height);
    size.width = MAX(0, size.width);
    
    return size;
}


@end
