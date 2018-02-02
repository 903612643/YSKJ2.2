//
//  YSKJ_OrderDetailTableViewHeadView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDetailTableViewHeadView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderDetailTableViewHeadView


-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
        imageView.image = [UIImage imageNamed:@"loading2"];
        [self addSubview:imageView];
        
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width, 56)];
        titleLable.text = @"订货单";
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.textColor = UIColorFromHex(0x333333);
        titleLable.font = [UIFont boldSystemFontOfSize:56];
        [self addSubview:titleLable];
        
        self.planName = [[UILabel alloc] initWithFrame:CGRectMake(20, 92+60, self.frame.size.width/2, 14)];
        self.planName.textAlignment = NSTextAlignmentLeft;
        self.planName.textColor = UIColorFromHex(0x333333);
        self.planName.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.planName];
        
        self.userAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, 124+60, self.frame.size.width/2, 14)];
        self.userAddress.textAlignment = NSTextAlignmentLeft;
        self.userAddress.textColor = UIColorFromHex(0x333333);
        self.userAddress.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.userAddress];
        
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2+180, 92+60, self.frame.size.width/2-150, 14)];
        self.date.textAlignment = NSTextAlignmentLeft;
        self.date.textColor = UIColorFromHex(0x333333);
        self.date.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.date];
        
        self.usernameAndPhone = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2+180, 124+60, self.frame.size.width/2-150, 14)];
        self.usernameAndPhone.textAlignment = NSTextAlignmentLeft;
        self.usernameAndPhone.textColor = UIColorFromHex(0x333333);
        self.usernameAndPhone.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.usernameAndPhone];
        
        UILabel *titlePro = [[UILabel alloc] init];
        titlePro.textColor = UIColorFromHex(0x333333);
        titlePro.font = [UIFont systemFontOfSize:18];
        titlePro.text = @"商品";
        [self addSubview:titlePro];
        titlePro.sd_layout
        .leftSpaceToView(self, 160)
        .widthIs(48)
        .heightIs(18)
        .bottomSpaceToView(self, 0);
        
        NSArray *titleArray = @[@"单价",@"数量",@"总价",@"涨价或折扣",@"实付款"];
        for (int i = 0; i<titleArray.count; i++) {
            UILabel *titleLable = [[UILabel alloc] init];
            titleLable.text = titleArray[i];
            titleLable.textAlignment = NSTextAlignmentCenter;
            titleLable.textColor = UIColorFromHex(0x333333);
            titleLable.font = [UIFont systemFontOfSize:18];
            [self addSubview:titleLable];
            titleLable.sd_layout
            .leftSpaceToView(self,340+132*i)
            .widthIs(120)
            .heightIs(18)
            .bottomSpaceToView(self, 0);
        }

        
    }
    
    return self;
    
}

-(void)setPlanNameStr:(NSString *)planNameStr
{
    _planNameStr = planNameStr;
    self.planName.text = planNameStr;
}

-(void)setUserAddressStr:(NSString *)userAddressStr
{
    _userAddressStr = userAddressStr;
    self.userAddress.text = userAddressStr;
}

-(void)setDateStr:(NSString *)dateStr
{
    _dateStr = dateStr;
    self.date.text = dateStr;
}

-(void)setUsernameAndPhoneStr:(NSString *)usernameAndPhoneStr
{
    _usernameAndPhoneStr = usernameAndPhoneStr;
    self.usernameAndPhone.text = usernameAndPhoneStr;
}


@end
