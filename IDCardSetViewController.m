//
//  IDCardSetViewController.m
//  MGSDKV2Test
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "IDCardSetViewController.h"
#import "ResultViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "NSDate+MGDate.h"

#import <MegIDCard/MegIDCard.h>

#import "MGSetManager.h"
#import "MGLicenseHandle.h"

@interface IDCardSetViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *screenView;

@property (weak, nonatomic) IBOutlet UISwitch *debugView;
@property (weak, nonatomic) IBOutlet UITextField *inbundleView;
@property (weak, nonatomic) IBOutlet UITextField *iscardView;
@property (weak, nonatomic) IBOutlet UITextField *clearView;
@property (weak, nonatomic) IBOutlet UISwitch *gettextView;

@property (weak, nonatomic) IBOutlet UILabel *versionView;

@end

@implementation IDCardSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* 联网授权 */
    [MGLicenseHandle licenseForNetWokrFinish:^(bool License, NSDate *sdkDate) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *card_Version = [MGIDCardManager IDCardVersion];
            
            NSString *showString = [NSString stringWithFormat:@"%@ ; %@",card_Version, [sdkDate chageShortString]];
            [self.versionView setText:showString];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDetect:(id)sender {
    
    /* 设置身份证信息识别 */
    MGSetManager *setmanager = [MGSetManager sharedManger];
    [setmanager setIdCardOCR:self.gettextView.on];
    
    /* 设置检测中的参数 */
    MGIDCardScreenOrientation screenOrientation = self.screenView.selectedSegmentIndex == 0? MGIDCardScreenOrientationLandscapeLeft:MGIDCardScreenOrientationPortrait;

    MGIDCardManager *manager = [[MGIDCardManager alloc] init];
    manager.screenOrientation = screenOrientation;
    manager.debug = self.debugView.on;
    
    manager.isCard = [self.iscardView.text floatValue];
    manager.inBound = [self.inbundleView.text floatValue];
    manager.clear = [self.clearView.text floatValue];
    
    manager.flareType = YES;
    
    [manager IDCardStartDetection:self finish:^(MGIDCardInfo *model) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            ResultViewController *viewController = [[ResultViewController alloc] initWithNibName:nil bundle:nil];
            [viewController setModel:model];
            
            [self.navigationController pushViewController:viewController animated:YES];
        });
    } errr:^(MGIDCardCancelType errorType) {
        
    }];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)fd_prefersNavigationBarHidden{
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}


@end
