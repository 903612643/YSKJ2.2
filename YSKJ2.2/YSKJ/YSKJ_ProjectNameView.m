//
//  YSKJ_ProjectNameView.m
//  YSKJ
//
//  Created by YSKJ on 17/6/21.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_ProjectNameView.h"
#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_ProjectNameView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.projectView=[[UIView alloc] init];
        self.projectView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.projectView];
        self.projectView.layer.cornerRadius = 4;
        self.projectView.layer.masksToBounds = YES;
        self.projectView.sd_layout
        .topSpaceToView(self,224)
        .leftSpaceToView(self,272)
        .rightSpaceToView(self,272)
        .bottomSpaceToView(self,344);
        
        self.cancle = [[UIButton alloc] init];
        [self.cancle setTitle:@"取消" forState:UIControlStateNormal];
        self.cancle.titleLabel.font = [UIFont systemFontOfSize:14];
        UIColor *titleC = UIColorFromHex(0x999999);
        [self.cancle setTitleColor:titleC forState:UIControlStateNormal];
        [self.projectView addSubview:self.cancle];
        self.cancle.sd_cornerRadius = @(4);
        self.cancle.sd_layout.spaceToSuperView(UIEdgeInsetsMake(128, 23, 28, 331));
        
        self.sure = [[UIButton alloc] init];
        [self.sure setTitle:@"确定" forState:UIControlStateNormal];
        self.sure.titleLabel.font = [UIFont systemFontOfSize:14];
        self.sure.backgroundColor=UIColorFromHex(0xefefef);
        self.sure.enabled = NO;
        [self.projectView addSubview:self.sure];
        self.sure.sd_cornerRadius = @(4);
        self.sure.sd_layout.spaceToSuperView(UIEdgeInsetsMake(128, 329, 28, 23));
        
        self.textfield= [[UITextField alloc] init];
        self.textfield.clearButtonMode=UITextFieldViewModeWhileEditing;
        self.textfield.borderStyle=UITextBorderStyleRoundedRect;
        self.textfield.backgroundColor=[UIColor whiteColor];
        [self.projectView addSubview:self.textfield];
        self.textfield.sd_layout.spaceToSuperView(UIEdgeInsetsMake(49, 87, 119, 23));
        
        UILabel *title =[[UILabel alloc] init];
        title.text = @"项目名称";
        title.textAlignment = NSTextAlignmentRight;
        title.textColor = UIColorFromHex(0x666666);
        title.font = [UIFont systemFontOfSize:14];
        [self.projectView addSubview:title];
        title.sd_layout.spaceToSuperView(UIEdgeInsetsMake(54, 0, 122, 401));
 
    }
    return self;
}


@end
