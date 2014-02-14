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

@interface NSMutableOrderedSet (Swizzling)

- (void)kx_insertObject:(id)object atIndex:(NSUInteger)idx;
- (void)kx_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object;
- (void)kx_removeObjectAtIndex:(NSUInteger)idx;
- (void)kx_moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx;

@end

@protocol KXCollectionObserving <NSObject>

- (void)collectionWillChangeContent:(KXCollection*)collection;
- (void)collection:(KXCollection*)collection
   didChangeObject:(id)object
           atIndex:(NSUInteger)index
         forChange:(NSKeyValueChange)change;
- (void)collection:(KXCollection *)collection
    didMoveObjects:(NSOrderedSet*)objects
       fromIndexes:(NSIndexSet*)fromIndexes
         toIndexes:(NSIndexSet*)toIndexes;
- (void)collection:(KXCollection*)collection didChangeSortWithSortDescriptros:(NSArray*)sortDescriptors;
- (void)collectioDidChangeContent:(KXCollection*)collection;

@end