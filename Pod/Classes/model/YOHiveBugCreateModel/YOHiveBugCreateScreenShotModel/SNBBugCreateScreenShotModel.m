/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBBugCreateScreenShotModel.h"
#import "SynUserMock.h"
#import "SNBStateDataItem.h"
#import "SynUserMock_private.h"

@interface SNBBugCreateScreenShotModel()

@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation SNBBugCreateScreenShotModel

+ (NSString *)identifier
{
    return @"SNBBugCreateScreenShotCell";
}

- (instancetype)initWithContentPath:(NSString *)contentPath
{
    self = [super init];
    if(self) {
        self.contentPath = contentPath;
        self.items = [self dataItems];
    }
    return self;
}

- (void)reloadData
{
    self.items = [self dataItems];
}

- (NSArray *)filesForPath:(NSString *)path
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    NSArray *sortedFiles = [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return sortedFiles;
}

- (NSArray *)dataItems
{
    NSMutableArray *dataItems = [[NSMutableArray alloc] init];
    NSString *dataItemsPath = [self.contentPath stringByAppendingPathComponent:kItemsPathComponent];
    NSArray *files = [self filesForPath:dataItemsPath];
    
    for(NSString *aFile in files) {
        
        SNBStateDataItem *item = [[SNBStateDataItem alloc] initWithFile:[aFile stringByDeletingPathExtension] path:self.contentPath];
        [dataItems addObject:item];
    }
    
    return dataItems;
}

- (NSUInteger)screenShotCount
{
    return self.items.count;
}

- (SNBStateDataItem *)itemAtIndex:(NSUInteger)index
{
    SNBStateDataItem *item = self.items[index];
    return item;
}

- (void)didSelectIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (NSIndexPath *)selectedIndexPath
{
    return _selectedIndexPath;
}

@end
