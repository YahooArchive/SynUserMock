/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBBugCreateScreenShotCell.h"
#import "SNBBugCreateScreenShotModel.h"
#import "SNBScreenShotCollectionCell.h"
#import "SNBBugCreateCellDelegate.h"

@interface SNBBugCreateScreenShotCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) SNBBugCreateScreenShotModel *model;

@end

@implementation SNBBugCreateScreenShotCell

- (void)awakeFromNib
{
    [self.collectionView registerClass:[SNBScreenShotCollectionCell class] forCellWithReuseIdentifier:[SNBScreenShotCollectionCell identifier]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if([self.model selectedIndexPath]) {
        [self.collectionView scrollToItemAtIndexPath:[self.model selectedIndexPath] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [self.model didSelectIndexPath:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [self.model screenShotCount];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SNBScreenShotCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SNBScreenShotCollectionCell identifier] forIndexPath:indexPath];
    SNBStateDataItem *item = [self.model itemAtIndex:indexPath.row];
    [cell updateWithData:item];
    
    return cell;
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

#pragma mark - UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = [SNBScreenShotCollectionCell defaultSizeWithData:[self.model itemAtIndex:indexPath.row]];
    return cellSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.model didSelectIndexPath:indexPath];
    SNBStateDataItem *item = [self.model itemAtIndex:indexPath.row];
    [self.delegate didSelectScreenShotWithDataItem:item];
}

@end
