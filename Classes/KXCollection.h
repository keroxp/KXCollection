//
//  KXCollection.h
//  KX
//
//  Created by Yusuke Sakurai on 2014/02/14.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSOrderedSetAspect.h"

extern NSString *const KXCollectionErrorDomain;
extern NSString *const KXCollectionInvalidModelInsertionException;

typedef enum
{
    KXCollectionChangeInsert = 1,
    KXCollectionChangeDelete,
    KXCollectionChangeReplace
}KXCollectionChange;

/*
 NSMutableOrderdSetと同じインターフェースを持ち、
 特定のクラスのオブジェクトだけを格納するコレクションクラス
 */

@protocol KXCollectionObserving;

@interface KXCollection : NSObject <NSMutableOrderedSetAspect>

+ (instancetype)collectionWithClass:(Class)aClass;
+ (instancetype)collectionWithClass:(Class)aClass models:(NSArray*)models;

@property (nonatomic) Class clazz;
@property (nonatomic, readonly) NSArray *observers;

- (instancetype)initWithClass:(Class)aClass;
- (instancetype)initWithClass:(Class)aClass models:(NSArray*)models;

// オブザーバを追加する
// オブザーバは複数追加可能で、NSHashTableの弱参照で保持する
- (void)addObserver:(id <KXCollectionObserving>)observer;
- (void)removeObserver:(id <KXCollectionObserving>)observer;
- (void)removeAllObservers;


// データの実体であるNSMutableOrderedSetを返す
// 新規にallocateするのでオブジェクトとしての等価性はない
- (NSOrderedSet*)orderedSetRepresentation;

@end

@interface KXCollection (Notification)

- (void)notifyChangeOfObjectAtIndex:(NSUInteger)index forChange:(KXCollectionChange)change;
- (void)notifyMoveOfObjectsAtIndexes:(NSIndexSet*)indexses toIndex:(NSUInteger)toIndex;
- (void)validateInsertionOrRepacementOfObject:(id)object;

@end

@interface NSMutableOrderedSet (Swizzling)

- (void)kx_insertObject:(id)object atIndex:(NSUInteger)idx;
- (void)kx_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object;
- (void)kx_removeObjectAtIndex:(NSUInteger)idx;
- (void)kx_moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx;

@end

@protocol KXCollectionObserving <NSObject>

@optional
- (void)collection:(KXCollection*)collection didChangeObjectAtIndex:(NSUInteger)index forChange:(KXCollectionChange)change;
- (void)collection:(KXCollection *)collection didMoveObjectsFromIndexes:(NSIndexSet*)fromIndexes toIndex:(NSUInteger)toIndex;
- (void)collection:(KXCollection*)collection didChangeSortWithSortDescriptros:(NSArray*)sortDescriptors;

@end