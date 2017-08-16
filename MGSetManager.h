//
//  MGSetManager.h
//  MGSDKV2Test
//
//  Created by 张英堂 on 16/9/18.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGSetManager : NSObject

+ (instancetype)sharedManger;

@property (nonatomic, assign) BOOL idCardOCR;



@end
