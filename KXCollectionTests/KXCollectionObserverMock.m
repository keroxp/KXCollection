//
//  KXCollectionObserverMock.m
//  KXCollection
//
//  Created by 桜井雄介 on 2014/02/15.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXCollectionObserverMock.h"

@implementation KXCollectionObserverMock
{
    NSMutableDictionary *_called;
}

- (id)init
{
    self = [super init];
    _called = [NSMutableDictionary new];
    return  self ?: nil;
}

- (void)collection:(KXCollection *)collection didChangeObjectAtIndex:(NSUInteger)index forChange:(KXCollectionChange)change
{
    [_called setObject:@(YES) forKey:NSStringFromSelector(_cmd)];
}

- (void)collection:(KXCollection *)collection didChangeSortWithSortDescriptros:(NSArray *)sortDescriptors
{
    [_called setObject:@(YES) forKey:NSStringFromSelector(_cmd)];
}

- (void)collection:(KXCollection *)collection didMoveObjectsFromIndexes:(NSIndexSet *)fromIndexes toIndex:(NSUInteger)toIndex
{
    [_called setObject:@(YES) forKey:NSStringFromSelector(_cmd)];
}

- (BOOL)delegateMethodDidCall:(SEL)selector
{
    return [[_called objectForKey:NSStringFromSelector(selector)] boolValue];
}

@end
