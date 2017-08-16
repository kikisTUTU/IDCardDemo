//
//  ResultViewController.m
//  MegIDCardDev
//
//  Created by 张英堂 on 16/8/30.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "ResultViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

#import "MGSetManager.h"
#import "MGNetConfig.h"

@interface ResultViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *debugView;

@property (weak, nonatomic) IBOutlet UILabel *cardInfoView;
@property (nonatomic, strong) NSURLSessionDataTask *ocrDataTask;
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *debugMessage = [NSString stringWithFormat:@" is_idcard:%.3f \n in_bound:%.3f \n clear:%.3f \n",self.model.isIdcard, self.model.inBound, self.model.clear];
    
    self.debugView.text = debugMessage ;
    
    
    UIImage *sourceImage = [self drawImage:self.model];
    [self.imageView setImage:sourceImage];
    

    self.cardInfoView.text = @"上传检测中，请稍等！";
    [self getCardInfo:sourceImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.ocrDataTask.state == NSURLSessionTaskStateRunning) {
        [self.ocrDataTask cancel];
    }
}

- (UIImage *)drawImage:(MGIDCardInfo *)model{
    UIImage *image = [model cropIDCardImage];
    if (image) {
        CGSize tempSize = image.size;
        CGContextRef ctx = [self getContextRefFromImage:image];
        CGContextBeginPath(ctx);
        //身份证线框
        [self drawBox:model.cardPointArray lineWidth:3.0f lineColor:[UIColor greenColor] imageSize:tempSize context:ctx];
        //阴影框
        CGFloat sWidht = 1.5f;
        UIColor *sColor = [UIColor redColor];
        NSArray *sArray = model.shadowsArray;
        
        for (int i = 0; i < sArray.count; i++) {
            NSArray *sTempArray = [sArray objectAtIndex:i];
            [self drawBox:sTempArray lineWidth:sWidht lineColor:sColor imageSize:tempSize context:ctx];
        }
        //斑点框
        CGFloat fWidht = 1.5f;
        UIColor *fColor = [UIColor blueColor];
        NSArray *fArray = model.faculaeArray;
        for (int i = 0; i < fArray.count; i++) {
            NSArray *fTempArray = [fArray objectAtIndex:i];
            [self drawBox:fTempArray lineWidth:fWidht lineColor:fColor imageSize:tempSize context:ctx];
        }
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *sourceImage = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        
        image = sourceImage;
    }else{
        return model.image;
    }
    return image;
}

#pragma mark -
- (void)showCardInfo:(NSDictionary *)dic{
    NSDictionary *cardFrontMap = @{KCARDNAME:@"姓　　名",
                                   KCardGender:@"性　　别",
                                   KIDCARDRACE:@"民　　族",
                                   KCARDADRESS:@"地　　址",
                                   KIDCARDID:@"身份证号",
                                   KCARDBIRTHDAY:@"出生日期",
                                   KCardIssuedBy:@"签发机构",
                                   KCardValidDate:@"有效期限"};
    
    NSArray *frontArray = @[KCARDNAME, KCardGender, KIDCARDRACE, KCARDADRESS, KIDCARDID, KCARDBIRTHDAY];
    NSArray *backArray = @[KCardIssuedBy, KCardValidDate];
    
    
    NSArray *cardArray = [dic valueForKey:@"cards"];
    if (cardArray.count >= 1) {
        NSDictionary *cardDic = cardArray[0];
        
        BOOL type = [cardDic valueForKey:@"type"];
        if (1 == type) {
            
            NSMutableString *showstring = [NSMutableString stringWithFormat:@""];
            NSArray *tempArray = nil;
            NSString *side = [cardDic valueForKey:@"side"];
            if ([side isEqualToString:@"front"]) {
                tempArray = frontArray;
            }else if ([side isEqualToString:@"back"]){
                tempArray = backArray;
            }
            if (tempArray) {
                [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *tempMapString = [cardFrontMap valueForKey:obj];
                    NSString *tempValue = [cardDic valueForKey:obj];
                    
                    if (tempMapString && tempValue) {
                        [showstring appendFormat:@"%@: %@ \n", tempMapString, tempValue];
                    }
                }];
            }
            
            if (showstring.length >= 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cardInfoView.text = showstring;
                });
            }
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cardInfoView.text = @"识别失败！";
        });
    }
}

#pragma mark - ocr
- (void)getCardInfo:(UIImage *)cardImage{
    
    NSString *hostapi = MG_OCRID_API;
    NSData *imageData = UIImagePNGRepresentation(cardImage);
    
    NSDictionary *dic = @{@"api_key":MG_LICENSE_KEY,
                          @"api_secret":MG_LICENSE_SECRET};
    
   self.ocrDataTask = [[AFHTTPSessionManager manager] POST:hostapi
                              parameters:dic
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                   [formData appendPartWithFileData:imageData name:@"image_file" fileName:@"image_file" mimeType:@"image/jpeg"];
               }
                                progress:^(NSProgress * _Nonnull uploadProgress) {}
                                 success:^(NSURLSessionDataTask *operation, id responseObject) {
                                     NSLog(@"%@", responseObject);
                                     [self showCardInfo:responseObject];
                                 }
                                 failure:^(NSURLSessionDataTask *operation, NSError *error) {
                                     NSLog(@"error :%@ \n %zi", error, [(NSHTTPURLResponse*)operation.response statusCode]);
 
                                     NSData *errorData = [[error userInfo] valueForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
                                     
                                     if (errorData) {
                                         NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableContainers error:nil];
                                         NSLog(@"%@", jsonDic);
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             self.cardInfoView.text = [jsonDic description];
                                         });
                                     }
                                 }];
}

- (CGPoint)transfromPoint:(CGPoint )point imageSize:(CGSize)size{
    CGPoint tempPoint = CGPointZero;
    CGFloat height = size.height;
    CGFloat width = size.width;

    CGFloat x = point.x * width;
    CGFloat y = (height - point.y * height);
    
    tempPoint = CGPointMake(x, y);
    return tempPoint;
}

- (void)drawBox:(NSArray<NSValue *>*)array lineWidth:(CGFloat)width lineColor:(UIColor *)color imageSize:(CGSize)size context:(CGContextRef)ctx{
    
    CGContextSetLineWidth(ctx, width);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    
    CGPoint firstPoint = [self transfromPoint:[array.firstObject CGPointValue] imageSize:size];
    CGContextMoveToPoint(ctx, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < array.count; i++) {
        CGPoint point = [self transfromPoint:[array[i] CGPointValue] imageSize:size];
        CGContextAddLineToPoint(ctx, point.x, point.y);
    }
    CGContextAddLineToPoint(ctx, firstPoint.x, firstPoint.y);
    CGContextStrokePath(ctx);
    
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (CGContextRef)getContextRefFromImage:(UIImage *)image{
    
    CGImageRef imageRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             width,
                                             height,
                                             CGImageGetBitsPerComponent(imageRef),
                                             0,
                                             CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    CGContextDrawImage(ctx, CGRectMake(0,0,width,height), imageRef);
    
    return ctx;
}

-(BOOL)fd_prefersNavigationBarHidden{
    return YES;
}


@end
