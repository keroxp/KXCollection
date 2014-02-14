//
//  FANCollectionTests.m
//  fan
//
//  Created by 桜井雄介 on 2014/02/14.
//  Copyright (c) 2014年 LoiLo Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FANCollection.h"

@interface FANCollectionTests : XCTestCase

@end

@implementation FANCollectionTests

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

- (void)testExample
{
    FANCollection *c = [[FANCollection alloc] init];
    XCTAssert([c conformsToProtocol:@protocol(NSOrderedSetAspect)], );
    XCTAssert([c isKindOfClass:[NSObject class]], );
}


- (void)testClass
{
    FANCollection *c = [FANCollection collectionWithClass:[NSString class]];
    XCTAssert(c.class == [NSString class], );
    XCTAssertNoThrow([c addObject:@"str1"], @"文字列は追加できる");
    XCTAssertNoThrow([c addObject:[NSMutableString stringWithString:@"mutablestr1"]], @"サブクラスもOK");
    XCTAssertThrows([c addObject:@[]], @"NSarrayは追加できない");
}

- (void)testClassWithModels
{
    FANCollection *c = [FANCollection collectionWithClass:[NSString class] models:@[@"a",@"b",@"c",[NSMutableString stringWithFormat:@"d"]]];
    XCTAssert(c.count == 4, );
    XCTAssert(![c isEqual:[c orderedSetRepresentation]], @"repは違うオブジェクト");
    XCTAssert([c isEqualToOrderedSet:[c orderedSetRepresentation]], @"でも中身は同じ");
}

@end
