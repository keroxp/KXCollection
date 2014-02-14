//
//  KXCollectionTests.m
//  KXCollectionTests
//
//  Created by Yusuke Sakurai on 2014/02/14.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KXCollection.h"

@interface KXCollectionTests : XCTestCase

@end

@implementation KXCollectionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    KXCollection *c = [[KXCollection alloc] init];
    XCTAssert([c conformsToProtocol:@protocol(NSOrderedSetAspect)], );
    XCTAssert([c isKindOfClass:[NSObject class]], );
}


- (void)testClass
{
    KXCollection *c = [KXCollection collectionWithClass:[NSString class]];
    XCTAssert(c.clazz == [NSString class], );
    XCTAssertNoThrow([c addObject:@"str1"], @"文字列は追加できる");
    XCTAssertNoThrow([c addObject:[NSMutableString stringWithString:@"mutablestr1"]], @"サブクラスもOK");
    XCTAssertThrows([c addObject:@[]], @"NSarrayは追加できない");
}

- (void)testClassWithModels
{
    KXCollection *c = [KXCollection collectionWithClass:[NSString class] models:@[@"a",@"b",@"c",[NSMutableString stringWithFormat:@"d"]]];
    XCTAssert(c.count == 4, );
    XCTAssert(![c isEqual:[c orderedSetRepresentation]], @"repは違うオブジェクト");
    XCTAssert([c isEqualToOrderedSet:[c orderedSetRepresentation]], @"でも中身は同じ");
}

- (void)testSortCall
{
    KXCollection *c = [KXCollection collectionWithClass:[NSString class] models:@[@"a",@"b",@"c",[NSMutableString stringWithFormat:@"d"]]];
    [c sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return NSOrderedDescending;
    }];
}

@end
