//
//  YSKJ_OrderDetailTableViewHeadView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderDetailTableViewHeadView : UIView

@property (nonatomic, strong) UILabel *planName;

@property (nonatomic, strong) UILabel *userAddress;

@property (nonatomic, strong) UILabel *date;

@property (nonatomic, strong) UILabel *usernameAndPhone;


@property (nonatomic, copy) NSString *planNameStr;

@property (nonatomic, copy) NSString *userAddressStr;

@property (nonatomic, copy) NSString *dateStr;

@property (nonatomic, copy) NSString *usernameAndPhoneStr;

@end
