//
//  YSKJ_leftMenuView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/1.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_leftMenuView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_leftMenuView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.head = [UIButton new];
        [self addSubview:self.head];
        self.head.sd_layout
        .leftSpaceToView(self,100)
        .topSpaceToView(self,36)
        .widthIs(64)
        .heightEqualToWidth();
        self.head.sd_cornerRadiusFromHeightRatio = @(0.5);   //设置圆角
        
        self.name=[UILabel new];
        self.name.textAlignment=NSTextAlignmentCenter;
        self.name.textColor = UIColorFromHex(0x666666);
        self.name.font=[UIFont systemFontOfSize:14];
        [self addSubview:self.name];
        self.name.sd_layout
        .leftSpaceToView(self,81)
        .topSpaceToView(self.head,12)
        .widthIs(100)
        .heightIs(14);
        
        self.loginButton=[UIButton new];
        [self addSubview:self.loginButton];
        self.loginButton.sd_layout
        .leftSpaceToView(self,90)
        .topSpaceToView(self,30)
        .widthIs(84)
        .heightIs(120);
        
        self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 211, 262, 42*5+2)];
        self.tableView.scrollEnabled=NO;
        [self addSubview:self.tableView];
        
        self.line=[[UIView alloc] initWithFrame:CGRectMake(0, 211+170, 262, 1)];
        self.line.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self addSubview:self.line];
        
        self.exit=[UIButton new];
        self.exit.backgroundColor=UIColorFromHex(0xf32a00);
        self.exit.titleLabel.font=[UIFont systemFontOfSize:14];
        self.exit.sd_cornerRadius=@(4);
        [self.exit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.exit.titleLabel.font=[UIFont systemFontOfSize:14];
        [self.exit setTitle:@"退出" forState:UIControlStateNormal];
        [self addSubview:self.exit];
        self.exit.sd_layout
        .leftSpaceToView(self,10)
        .bottomSpaceToView(self,85+64)
        .widthIs(243)
        .heightIs(28);
        
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(262, 0, 1, self.frame.size.height)];
        line.backgroundColor=UIColorFromHex(0xd7d7d7);
        [self addSubview:line];
    
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    [self.head setImage:image forState:UIControlStateNormal];
    
}

-(void)setNameStr:(NSString *)nameStr
{
    _nameStr = nameStr;
    self.name.text = nameStr;
    
}




@end
