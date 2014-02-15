//
//  KXCollectionObserverMock.h
//  KXCollection
//
//  Created by 桜井雄介 on 2014/02/15.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KXCollection.h"

@interface KXCollectionObserverMock : NSObject
<KXCollectionObserving>

- (BOOL)delegateMethodDidCall:(SEL)selector;

@end
