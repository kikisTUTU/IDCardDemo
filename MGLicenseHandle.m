//
//  MGLicenseHandle.m
//  MGSDKV2Test
//
//  Created by 张英堂 on 16/9/7.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGLicenseHandle.h"

#import <MGBaseKit/MGBaseKit.h>
#import <MegIDCard/MegIDCard.h>

@implementation MGLicenseHandle

+ (BOOL)getLicense{
    
    NSDate *sdkDate = [self getLicenseDate];
    
    double result = [self licenseTimeDifference:sdkDate];
    
    if (result <= 0) {
        return NO;
    }
    return YES;
}


+ (void)licenseForNetWokrFinish:(void(^)(bool License, NSDate *sdkDate))finish{
    
    NSDate *licenSDKDate = [self getLicenseDate];
    
    if ([self compareSDKDate:licenSDKDate] == NO) {
        if (finish) {
            finish(YES, [self getLicenseDate]);
        }
        return;
    }
    
    NSNumber *cardlicenSDK = [NSNumber numberWithUnsignedInteger:[MGIDCard getAPIName]];
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [MGLicenseManager takeLicenseFromNetwokrUUID:uuid
                                       candidate:cardlicenSDK
                                         sdkType:MG_SDK_TYPE_IDCARD
                                          apiKey:MG_LICENSE_KEY
                                       apiSecret:MG_LICENSE_SECRET
                                         isChina:YES
                                          finish:^(bool License, NSError *error) {
                                              
                                              NSLog(@"%@", error);
                                              
                                              if (License) {
                                                  NSDate  *nowSDKDate = [self getLicenseDate];
                                                  
                                                  if (finish) {
                                                      finish(License, nowSDKDate);
                                                  }
                                              }else{
                                                  if (finish) {
                                                      finish(License, licenSDKDate);
                                                  }
                                              }
                                          }];
    
}

+ (BOOL)compareSDKDate:(NSDate *)sdkDate{
    
    NSDate *nowDate = [NSDate date];
    double result = [sdkDate timeIntervalSinceDate:nowDate];
    
    if (result >= 1*1*60*60.0) {
        return NO;
    }
    return YES;
}

+ (NSDate *)getLicenseDate{
    NSDate *date = [MGIDCard getApiExpiration];
    return date;
}

+ (BOOL)needLicenseForNet{
    NSDate *sdkDate = [self getLicenseDate];
    double result = [self licenseTimeDifference:sdkDate];
    
    if (result >= 1*1*60*60.0) {
        return NO;
    }
    return YES;
}

+ (double)licenseTimeDifference:(NSDate *)SDKDate{
    NSDate *nowDate = [NSDate date];
    
    double result = [SDKDate timeIntervalSinceDate:nowDate];
    
    return result;
}

+ (void)setMGLicenseData:(NSString *)string{
    if (string) {
        [MGLicenseManager setLicense:string];
    }
}

+ (NSString *)percentEscapeString:(NSString *)string {
    NSCharacterSet *allowedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/?"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
