/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateDataItem.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

@interface SNBStateDataItem()

@property (nonatomic, strong) NSValue *touchValue;
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, strong) NSDate *createDate;

@end

@implementation SNBStateDataItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withTouchPoint:(CGPoint)touchPoint
{
    self = [super init];
    if(self) {
        self.dictionary = [dictionary mutableCopy];
        self.touchValue = [NSValue valueWithCGPoint:touchPoint];
        self.createDate = [NSDate date];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SNBStateDataItem *item = [[[self class] allocWithZone:zone] initWithDictionary:self.dictionary withTouchPoint:CGPointZero];
    if(item) {
        item.touchValue = nil;
        item.createDate = [self.createDate dateByAddingTimeInterval:1];
    }
    return item;
}

- (NSDictionary *)data
{
    return self.dictionary;
}

- (CGPoint)touchPoint
{
    return [self.touchValue CGPointValue];
}

- (void)updateValue:(id)value forKey:(NSString *)key
{
    if(value && key) {
        [self.dictionary setValue:value forKey:key];
    }
}

- (NSString *)viewControllerName
{
    return [self.dictionary valueForKey:kSNBKeyClass];
}

- (void)writeToFile:(NSString *)file path:(NSString *)path
{
    if(!self.dictionary) {
        self.dictionary = [[NSMutableDictionary alloc] init];
    }
    
    [self.dictionary setValue:self.createDate forKey:kSNBCreateDateClass];
 
    NSString *itemPath = [path stringByAppendingPathComponent:kItemsPathComponent];
    NSString *itemFile = [NSString stringWithFormat:@"%@.item", file];
    [self.dictionary writeToFile:[itemPath stringByAppendingPathComponent:itemFile] atomically:YES];
}

- (instancetype)initWithFile:(NSString *)file path:(NSString *)path
{
    self = [super init];
    if(self) {
        self.filename = file;
        self.contentPath = path;
        NSString *itemPath = [path stringByAppendingPathComponent:kItemsPathComponent];
        NSString *itemFile = [NSString stringWithFormat:@"%@.item", file];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[itemPath stringByAppendingPathComponent:itemFile]];
        self.dictionary = dictionary;
        self.createDate = dictionary[kSNBCreateDateClass];
    }
    return self;
}

- (UIImage *)screenShot
{
    UIImage *screenShot = nil;
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", self.filename];
    NSString *screenShotPath = [[self.contentPath stringByAppendingPathComponent:kScreenShotPathComponent] stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:screenShotPath isDirectory:NULL]) {
        screenShot = [[UIImage alloc] initWithContentsOfFile:screenShotPath];
    }
    
    return screenShot;
}

@end
