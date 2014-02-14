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

@interface KXCollection : NSObject <NSMutableOrderedSetAspect>

+ (instancetype)collectionWithClass:(Class)aClass;
+ (instancetype)collectionWithClass:(Class)aClass models:(NSArray*)models;

@property (nonatomic) Class clazz;

- (instancetype)initWithClass:(Class)aClass;
- (instancetype)initWithClass:(Class)aClass models:(NSArray*)models;

// データの実体であるNSMutableOrderedSetを返す
// 新規にallocateするのでオブジェクトとしての等価性はない
- (NSOrderedSet*)orderedSetRepresentation;

@end

@interface NSMutableOrderedSet (Validation)

- (void)kx_insertObject:(id)object atIndex:(NSUInteger)idx;
- (void)kx_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object;

@end