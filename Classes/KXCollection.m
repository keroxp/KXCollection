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

@implementation NSMutableOrderedSet (Validation)

- (void)validateInertion:(id)object
{
    // owner -> KXCollection
    id owner = objc_getAssociatedObject(self, KXCollectionInsertionValidationKey);
    if (owner) {
        SEL sel = NSSelectorFromString(@"validateInsertion:");
        objc_msgSend(owner, sel, object);
    }
}

- (void)kx_insertObject:(id)object atIndex:(NSUInteger)idx
{
    [self validateInertion:object];
    // call original
    [self kx_insertObject:object atIndex:idx];
}

- (void)kx_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    [self validateInertion:object];
    // call oriignal
    [self kx_replaceObjectAtIndex:idx withObject:object];
}

@end

@interface KXCollection ()
{
    NSMutableOrderedSet *_actualData;
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
    // 黒魔術
    [self darkMagic];
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
            [self validateInsertion:obj];
        }
        [self addObjectsFromArray:models];
    }
    return self ?: nil;;
}

- (NSOrderedSet *)orderedSetRepresentation
{
    return [NSOrderedSet orderedSetWithOrderedSet:_actualData];
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

- (void)darkMagic
{
    /*
     自身のクラスが保持すべきモデルオブジェクト以外の挿入を防ぐために
     NSMutableOrderedSetのプリミティブアクセッサである
     insertObject:atIndex, replaceObject:atIndex:
     にvalidation処理を差し込む
    */
    // selfに弱参照を持たせる
    objc_setAssociatedObject(_actualData, KXCollectionInsertionValidationKey , self, OBJC_ASSOCIATION_ASSIGN);
    // カテゴリに追加したwrap methodに入れ替える
    Method insert = class_getInstanceMethod([_actualData class], @selector(insertObject:atIndex:));
    Method _insert = class_getInstanceMethod([_actualData class], @selector(kx_insertObject:atIndex:));
    Method replace = class_getInstanceMethod([_actualData class], @selector(replaceObjectAtIndex:withObject:));
    Method _replace = class_getInstanceMethod([_actualData class], @selector(kx_replaceObjectAtIndex:withObject:));
    method_exchangeImplementations(insert, _insert);
    method_exchangeImplementations(replace, _replace);
}

- (void)validateInsertion:(id)object
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
