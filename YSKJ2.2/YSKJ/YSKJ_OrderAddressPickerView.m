//
//  YSKJ_OrderAddressPickerView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/7.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderAddressPickerView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderAddressPickerView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 258)];
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:self.view];
        
        //取消
        self.cancle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
        [self.cancle setTitle:@"取消" forState:UIControlStateNormal];
        UIColor *titleC = UIColorFromHex(0xf32a00);
        self.cancle.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.cancle setTitleColor:titleC forState:UIControlStateNormal];
        [self.view addSubview:self.cancle];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-150)/2, 0, 150, 40)];
        self.title.text = @"请选择地址";
        self.title.textColor = UIColorFromHex(0x333333);
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.title];
        
        //确认
        self.sure = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-70, 0, 60, 40)];
        [self.sure setTitle:@"确定" forState:UIControlStateNormal];
        self.sure.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.sure setTitleColor:titleC forState:UIControlStateNormal];
        [self.view addSubview:self.sure];
        
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 218)];
        self.pickerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.pickerView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.frame = CGRectMake(0, self.frame.size.height-258, self.frame.size.width, 258);
        }];
        
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
        
    }
    return self;
}


@end
