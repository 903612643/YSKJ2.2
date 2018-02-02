//
//  YSKJ_NetStatusNotificationView.h
//  YSKJ
//
//  Created by YSKJ on 17/9/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_NetStatusNotificationView : UIView

@property (nonatomic, strong) UILabel *lable;

+(void)showNotificationViewWithText:(NSString *)text;


@end
