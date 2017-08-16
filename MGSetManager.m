//
//  MGSetManager.m
//  MGSDKV2Test
//
//  Created by 张英堂 on 16/9/18.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGSetManager.h"

@implementation MGSetManager


+ (instancetype)sharedManger{
    static MGSetManager *manger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[MGSetManager alloc] init];
    });
    
    return manger;
}

@end
