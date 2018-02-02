//
//  YSKJ_CanvasnavigationView.m
//  YSKJ
//
//  Created by YSKJ on 17/6/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CanvasnavigationView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_CanvasnavigationView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpItem];
        
        self.line=[UIView new];
        self.line.backgroundColor=UIColorFromHex(0xd8d8d8);
        [self addSubview:self.line];
        self.line.sd_layout.spaceToSuperView(UIEdgeInsetsMake(62, 0, 0, 0));
        
        self.backgroundColor = UIColorFromHex(0xffffff);
        
    }
    return self;
    
}
-(void)setUpItem
{
    self.close = [UIButton new];
    self.close.tag=1002;
    [self.close setImage:[UIImage imageNamed:@"direction"] forState:UIControlStateNormal];
    [self.close setImageEdgeInsets:UIEdgeInsetsMake(10, 4, 2, 8)];
    [self addSubview:self.close];
    self.close.sd_layout
    .bottomSpaceToView(self,6)
    .leftSpaceToView(self,8)
    .widthIs(44)
    .heightEqualToWidth();
    
    self.details=[UIButton new];
    [self.details setImage:[UIImage imageNamed:@"detaile"] forState:UIControlStateNormal];
    self.details.tag=1009;
    [self.details setImage:[UIImage imageNamed:@"detaile1"] forState:UIControlStateHighlighted];
    self.details.backgroundColor=[UIColor clearColor];
    self.details.titleLabel.font=[UIFont systemFontOfSize:14];
    [self.details setTitle:@"方案清单" forState:UIControlStateNormal];
    [self.details setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 48)];
    [self.details setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 10)];
    UIColor *titleCo=UIColorFromHex(0x666666);
    UIColor *htitleCo=UIColorFromHex(0xf39800);
    [self.details setTitleColor:titleCo forState:UIControlStateNormal];
    [self.details setTitleColor:htitleCo forState:UIControlStateHighlighted];
    [self addSubview:self.details];
    self.details.sd_layout
    .bottomSpaceToView(self,6)
    .leftSpaceToView(self,750)
    .widthIs(120)
    .heightIs(44);
    
    self.add=[UIButton new];
    [self.add setImage:[UIImage imageNamed:@"addProduct"] forState:UIControlStateNormal];
    [self.add setImage:[UIImage imageNamed:@"addProduct1"] forState:UIControlStateHighlighted];
    [self.add setTitleColor:titleCo forState:UIControlStateNormal];
    [self.add setTitleColor:htitleCo forState:UIControlStateHighlighted];
    [self.add setTitle:@"添加商品" forState:UIControlStateNormal];
    [self.add setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 48)];
    [self.add setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 10)];
    self.add.titleLabel.font=[UIFont systemFontOfSize:14];
    [self addSubview:self.add];
    self.add.sd_layout
    .bottomSpaceToView(self,6)
    .leftSpaceToView(self,876)
    .widthIs(120)
    .heightIs(44);
    
    NSArray *titleArray=@[@"save",@"recall",@"next",@"del",@"spacebg",@"collection"];
    NSArray *titleArray1=@[@"save1",@"recall1",@"next1",@"del1",@"spacebg1",@"collection1"];
    NSArray *title=@[@"保存",@"撤销",@"前进",@"清空",@"空间背景",@"收藏夹"];
    
    for (int i=0; i<titleArray.count; i++) {
        
        UIButton *button=[UIButton new];
        button.tag = 1003+i;
        button.titleLabel.font=[UIFont systemFontOfSize:14];
        [button setTitle:title[i] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 48)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 10)];
        UIColor *titleCo=UIColorFromHex(0x666666);
        UIColor *htitleCo=UIColorFromHex(0xf39800);
        [button setTitleColor:titleCo forState:UIControlStateNormal];
        [button setTitleColor:htitleCo forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:titleArray[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:titleArray1[i]] forState:UIControlStateHighlighted];
        [self addSubview:button];
        button.sd_layout
        .bottomSpaceToView(self,6)
        .leftSpaceToView(self,107+100*i)
        .widthIs(80)
        .heightIs(44);
        
        if (i==4) {
            button.sd_layout
            .widthIs(130);
            [button updateLayout];
        }
        if (i==5) {
            [button setTitleEdgeInsets:UIEdgeInsetsMake(12, 10, 0, 5)];
            button.sd_layout
            .leftSpaceToView(self,107+100*i+29)
            .widthIs(94);
            [button updateLayout];
        }
        
    }

}



@end
