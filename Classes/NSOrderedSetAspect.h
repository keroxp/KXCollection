//
//  NSOrderedSet.h
//  KX
//
//  Created by Yusuke Sakurai on 2014/02/14.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * NSOrderedSetをアスペクト化したプロトコル
 * NSOrderedSet.hからコピペ
 */


NS_AVAILABLE(10_7, 5_0)

@protocol
NSOrderedSetAspect,
NSExtendedOrderedSetAspect,
NSOrderedSetCreation,
NSMutableOrderedSetAspect,
NSExtendedMutableOrderedSet,
NSMutableOrderedSetCreation;

@protocol NSOrderedSetAspect
<NSObject,NSFastEnumeration,NSCopying,NSMutableCopying,NSSecureCoding,NSExtendedOrderedSetAspect,NSOrderedSetCreation>

@optional
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)idx;
- (NSUInteger)indexOfObject:(id)object;

@end

@protocol NSExtendedOrderedSetAspect

@optional
- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes;
- (id)firstObject;
- (id)lastObject;

- (BOOL)isEqualToOrderedSet:(NSOrderedSet *)other;

- (BOOL)containsObject:(id)object;
- (BOOL)intersectsOrderedSet:(NSOrderedSet *)other;
- (BOOL)intersectsSet:(NSSet *)set;

- (BOOL)isSubsetOfOrderedSet:(NSOrderedSet *)other;
- (BOOL)isSubsetOfSet:(NSSet *)set;

- (id)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;

- (NSOrderedSet *)reversedOrderedSet;

- (NSArray *)array;
- (NSSet *)set;

#if NS_BLOCKS_AVAILABLE

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSUInteger)indexOfObject:(id)object inSortedRange:(NSRange)range options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp; // binary search

- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr;
- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;

#endif

- (NSString *)description;
- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;

@end

@protocol NSOrderedSetCreation

@optional
+ (instancetype)orderedSet;
+ (instancetype)orderedSetWithObject:(id)object;
+ (instancetype)orderedSetWithObjects:(const id [])objects count:(NSUInteger)cnt;
+ (instancetype)orderedSetWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)orderedSetWithOrderedSet:(NSOrderedSet *)set;
+ (instancetype)orderedSetWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(BOOL)flag;
+ (instancetype)orderedSetWithArray:(NSArray *)array;
+ (instancetype)orderedSetWithArray:(NSArray *)array range:(NSRange)range copyItems:(BOOL)flag;
+ (instancetype)orderedSetWithSet:(NSSet *)set;
+ (instancetype)orderedSetWithSet:(NSSet *)set copyItems:(BOOL)flag;

- (instancetype)init;	/* designated initializer */
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt;	/* designated initializer */

- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithOrderedSet:(NSOrderedSet *)set;
- (instancetype)initWithOrderedSet:(NSOrderedSet *)set copyItems:(BOOL)flag;
- (instancetype)initWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)set copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray *)set range:(NSRange)range copyItems:(BOOL)flag;
- (instancetype)initWithSet:(NSSet *)set;
- (instancetype)initWithSet:(NSSet *)set copyItems:(BOOL)flag;

@end

/****************       Mutable Ordered Set     ****************/

NS_AVAILABLE(10_7, 5_0)

@protocol NSMutableOrderedSetAspect <NSOrderedSetAspect, NSExtendedMutableOrderedSet, NSMutableOrderedSetCreation>

@optional
- (void)insertObject:(id)object atIndex:(NSUInteger)idx;
- (void)removeObjectAtIndex:(NSUInteger)idx;
- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object;

@end

@protocol NSExtendedMutableOrderedSet

@optional
- (void)addObject:(id)object;
- (void)addObjects:(const id [])objects count:(NSUInteger)count;
- (void)addObjectsFromArray:(NSArray *)array;

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx;

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;

- (void)setObject:(id)obj atIndex:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (void)replaceObjectsInRange:(NSRange)range withObjects:(const id [])objects count:(NSUInteger)count;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;

- (void)removeObjectsInRange:(NSRange)range;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)removeAllObjects;

- (void)removeObject:(id)object;
- (void)removeObjectsInArray:(NSArray *)array;

- (void)intersectOrderedSet:(NSOrderedSet *)other;
- (void)minusOrderedSet:(NSOrderedSet *)other;
- (void)unionOrderedSet:(NSOrderedSet *)other;

- (void)intersectSet:(NSSet *)other;
- (void)minusSet:(NSSet *)other;
- (void)unionSet:(NSSet *)other;

#if NS_BLOCKS_AVAILABLE
- (void)sortUsingComparator:(NSComparator)cmptr;
- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
- (void)sortRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
#endif

@end

@protocol NSMutableOrderedSetCreation

@optional
+ (instancetype)orderedSetWithCapacity:(NSUInteger)numItems;

- (instancetype)init;	/* designated initializer */
- (instancetype)initWithCapacity:(NSUInteger)numItems;	/* designated initializer */

@end