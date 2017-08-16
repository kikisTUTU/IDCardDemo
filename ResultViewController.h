//
//  ResultViewController.h
//  MegIDCardDev
//
//  Created by 张英堂 on 16/8/30.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MegIDCard/MegIDCard.h>


/* ->证件相关字段 */
#define KCARDSIDEFRONT  @"front"
#define KCARDSIDEBACK   @"back"
#define KCARDSIDE       @"side"

#define KCARDNAME       @"name"
#define KCARDADRESS     @"address"
#define KCARDBIRTHDAY   @"birthday"
#define KCardGender     @"gender"
#define KCardIssuedBy   @"issued_by"
#define KCardIssuedDate   @"issue_date"
#define KCardValidDate  @"valid_date"
#define KCardNationality   @"nationality"

#define KDriverID   @"license_number"
#define KDriverClass   @"class"
#define KDriverValidFrom   @"valid_from"
#define KDriverValidFor   @"valid_for"

#define KIDCARDID         @"id_card_number"
#define KIDCARDRACE       @"race"



@interface ResultViewController : UIViewController

@property (nonatomic, strong) MGIDCardInfo *model;

@end
