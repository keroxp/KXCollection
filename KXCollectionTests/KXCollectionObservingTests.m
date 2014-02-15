//
//  KXCollectionObservingTests.m
//  KXCollection
//
//  Created by 桜井雄介 on 2014/02/15.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KXCollection.h"
#import "KXCollectionObserverMock.h"

@interface KXCollectionObservingTests : XCTestCase
<KXCollectionObserving>

@end

@implementation KXCollectionObservingTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testBasic
{
    KXCollection *c = [KXCollection collectionWithClass:[NSString class]];
    KXCollectionObserverMock *mock = [[KXCollectionObserverMock alloc] init];
    [c addObserver:self];
    [c addObserver:mock];
    XCTAssert(c.observers.count == 2, );
    [c addObjectsFromArray:@[@"a",@"b",@"c",@"d"]];
    [c addObject:@"e"];
    XCTAssert(c.count == 5, );
    XCTAssert([[c lastObject] isEqualToString:@"e"], );
    [c removeObjectAtIndex:0];
    XCTAssert(c.count == 4, );
    XCTAssert([[c firstObject] isEqualToString:@"b"], );
    XCTAssert([mock delegateMethodDidCall:@selector(collection:didChangeObjectAtIndex:forChange:)], );
}

- (void)testMoveOrderedSet
{
    NSMutableOrderedSet *os = [NSMutableOrderedSet orderedSetWithArray:@[@"a",@"b",@"c",@"d"]];
    NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
    [is addIndex:0];
    [is addIndex:2];
    // a,b,c,d -> b,d,a,c
    XCTAssertThrows([os moveObjectsAtIndexes:is toIndex:4], ); // この時点でosのlengthが0..1になっているのでクラッシュする
    XCTAssertNoThrow([os moveObjectsAtIndexes:is toIndex:2], ); // b,dが一度削除された後にあらためて追加が起こる
}

- (void)testMove
{
    KXCollection *c = [KXCollection collectionWithClass:[NSString class] models:@[@"a",@"b",@"c",@"d"]];
    XCTAssert(c.count == 4, );
    KXCollectionObserverMock *mock = [[KXCollectionObserverMock alloc] init];
    [c addObserver:self];
    [c addObserver:mock];
    NSMutableIndexSet *is = [NSMutableIndexSet new];
    [is addIndex:0];
    [is addIndex:2];
    // a,b,c,d -> b,d,a,d
    [c moveObjectsAtIndexes:is toIndex:2];
    XCTAssert([[c firstObject] isEqualToString:@"b"], );
    XCTAssert([[c lastObject] isEqualToString:@"c"], );
    XCTAssert([mock delegateMethodDidCall:@selector(collection:didMoveObjectsFromIndexes:toIndex:)], );
    XCTAssert([mock delegateMethodDidCall:@selector(collection:didChangeObjectAtIndex:forChange:)], @"moveだけどremove/insertが呼ばれている");
}

- (void)collection:(KXCollection *)collection didChangeObjectAtIndex:(NSUInteger)index forChange:(KXCollectionChange)change
{
    NSLog(@"%@, index : %ul",collection, index); // 呼ばれる
}
- (void)collection:(KXCollection *)collection didMoveObjectsFromIndexes:(NSIndexSet *)fromIndexes toIndex:(NSUInteger)toIndex
{
    NSLog(@"%@, index : %ul",collection, toIndex); // 呼ばれる
}

@end
