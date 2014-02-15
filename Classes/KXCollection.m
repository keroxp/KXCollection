//
//  KXCollection.m
//  KX
//
//  Created by Yusuke Sakurai on 2014/02/14.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const KXCollectionErrorDomain = @"me.keroxp.app.KX:KXCollectionErrorDomain";
NSString *const KXCollectionInvalidModelInsertionException = @"me.keroxp.app.KX:KXCollectionInvalidModelInsertionException";
static const char * KXCollectionInsertionValidationKey = "me.keroxp.app.KX:KXCollectionInsertionValidationKey";

@implementation NSMutableOrderedSet (Swizzling)

- (KXCollection*)owner
{
    return objc_getAssociatedObject(self, KXCollectionInsertionValidationKey);
}

- (void)kx_insertObject:(id)object atIndex:(NSUInteger)idx
{
    [[self owner] validateInsertionOrRepacementOfObject:object];
    [self kx_insertObject:object atIndex:idx];
    [[self owner] notifyChangeOfObjectAtIndex:idx forChange:KXCollectionChangeInsert];
}

- (void)kx_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    [[self owner] validateInsertionOrRepacementOfObject:object];
    [self kx_replaceObjectAtIndex:idx withObject:object];
    [[self owner] notifyChangeOfObjectAtIndex:idx forChange:KXCollectionChangeReplace];
}

- (void)kx_removeObjectAtIndex:(NSUInteger)idx
{
    [self kx_removeObjectAtIndex:idx];
    [[self owner] notifyChangeOfObjectAtIndex:idx forChange:KXCollectionChangeDelete];
}

- (void)kx_moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx
{
    [self kx_moveObjectsAtIndexes:indexes toIndex:idx];
    [[self owner] notifyMoveOfObjectsAtIndexes:indexes toIndex:idx];
}

@end

@interface KXCollection ()
{
    NSMutableOrderedSet *_actualData;
    NSHashTable *_observers;
}

@end

@implementation KXCollection

+ (instancetype)collectionWithClass:(Class)aClass
{
    return [self collectionWithClass:aClass models:nil];
}

+ (instancetype)collectionWithClass:(Class)aClass models:(NSArray *)models
{
    return [[self alloc] initWithClass:aClass models:models];
}

- (id)init
{
    self = [super init];
    _actualData = [NSMutableOrderedSet new];
    _observers = [NSHashTable weakObjectsHashTable];
    // _actualDataにselfの弱参照を持たせる
    objc_setAssociatedObject(_actualData, KXCollectionInsertionValidationKey , self, OBJC_ASSOCIATION_ASSIGN);
    // 黒魔術
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethods:@selector(insertObject:atIndex:) to:@selector(kx_insertObject:atIndex:)];
        [self swizzleMethods:@selector(replaceObjectAtIndex:withObject:) to:@selector(kx_replaceObjectAtIndex:withObject:)];
        [self swizzleMethods:@selector(moveObjectsAtIndexes:toIndex:) to:@selector(kx_moveObjectsAtIndexes:toIndex:)];
        [self swizzleMethods:@selector(removeObjectAtIndex:) to:@selector(kx_removeObjectAtIndex:)];
    });
    return self ?: nil;
}

- (instancetype)initWithClass:(Class)aClass
{
    return [self initWithClass:aClass];
}

- (instancetype)initWithClass:(Class)aClass models:(NSArray *)models
{
    self = [self init];
    NSParameterAssert(aClass);
    _clazz = aClass;
    if (models) {
        // 与えられたモデルがすべて対象のクラスを継承しているかをチェックする
        for (id obj in models) {
            [self validateInsertionOrRepacementOfObject:obj];
        }
        [self addObjectsFromArray:models];
    }
    return self ?: nil;;
}

- (NSOrderedSet *)orderedSetRepresentation
{
    return [NSOrderedSet orderedSetWithOrderedSet:_actualData];
}

- (NSArray *)observers
{
    return [_observers allObjects];
}

- (NSString *)description
{
    return [_actualData description];
}

#pragma mark - Observer

- (void)addObserver:(id<KXCollectionObserving>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<KXCollectionObserving>)observer
{
    [_observers removeObject:observer];
    // 弱参照の保持の挙動が気になるので定期的にhash tableをリニューアルする
    NSHashTable *renew = [NSHashTable weakObjectsHashTable];
    for (id obj in _observers) {
        [renew addObject:obj];
    }
    _observers = renew;
}

- (void)removeAllObservers
{
    [_observers removeAllObjects];
    _observers = [NSHashTable weakObjectsHashTable];
}

- (void)notifyChangeOfObjectAtIndex:(NSUInteger)index forChange:(KXCollectionChange)change
{
    for (id<KXCollectionObserving> obs in _observers) {
        if ([obs respondsToSelector:@selector(collection:didChangeObjectAtIndex:forChange:)]) {
            [obs collection:self didChangeObjectAtIndex:index forChange:change];
        }
    }
}

- (void)notifyMoveOfObjectsAtIndexes:(NSIndexSet *)indexses toIndex:(NSUInteger)toIndex
{
    for (id<KXCollectionObserving> obs in _observers) {
        if ([obs respondsToSelector:@selector(collection:didMoveObjectsFromIndexes:toIndex:)]) {
            [obs collection:self didMoveObjectsFromIndexes:indexses toIndex:toIndex];
        }
    }
}


#pragma mark - Method Forwarding

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_actualData respondsToSelector:anInvocation.selector]) {
        [anInvocation setTarget:_actualData];
        [anInvocation invoke];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([_actualData respondsToSelector:aSelector]) {
        return [_actualData methodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}

#pragma mark - NSMutableOrderedSet

- (void)swizzleMethods:(SEL)from to:(SEL)to
{
    Method from_m = class_getInstanceMethod([_actualData class], from);
    Method to_m = class_getInstanceMethod([_actualData class], to);
    method_exchangeImplementations(from_m, to_m);
}

- (void)validateInsertionOrRepacementOfObject:(id)object
{
    // 登録されいるクラスでないオブジェクトの挿入を防ぐ
    if (![object isKindOfClass:_clazz]) {
        NSString *r = [NSString stringWithFormat:@"invalid classs %@ for class %@", NSStringFromClass([object class]), NSStringFromClass(_clazz)];
        @throw [NSException exceptionWithName:@"KXCollectionInvalidModelInsertionException" reason:r userInfo:nil];
    }
}

#pragma mark - NSSrcureCoding

+ (BOOL)supportsSecureCoding
{
    return [NSOrderedSet supportsSecureCoding];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    NSString *classtr = [aDecoder decodeObjectForKey:@"class"];
    _clazz = NSClassFromString(classtr);
    _actualData = [aDecoder decodeObjectForKey:@"actualData"];
    return self ?: nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:NSStringFromClass(_clazz) forKey:@"class"];
    [aCoder encodeObject:_actualData forKey:@"actualData"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    KXCollection *__self = [[[self class] alloc] init];
    __self->_actualData = _actualData.mutableCopy;
    __self->_clazz = NSClassFromString(NSStringFromClass(_clazz));
    return __self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return [_actualData countByEnumeratingWithState:state objects:buffer count:len];
}



@end
