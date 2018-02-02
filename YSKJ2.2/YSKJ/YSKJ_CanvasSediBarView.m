//
//  YSKJ_CanvasSediBarView.m
//  YSKJ
//
//  Created by YSKJ on 17/6/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CanvasSediBarView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_CanvasSediBarView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        NSArray *title=@[@"复制",@"变形",@"镜像",@"删除",@"锁定",@"置顶",@"上移",@"下移",@"置底"];
        
        NSArray *normalImage=@[@"copy",@"reform",@"mirrom",@"dele",@"lockpro",@"top",@"topmov",@"bottommov",@"bottom"];
        
        NSArray *heightImage=@[@"copy1",@"reform1",@"mirrom1",@"dele1",@"lockpro1",@"top1",@"topmov1",@"bottommov1",@"bottom1"];
        
        for (int i=0; i<title.count; i++) {
            
            UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(7, 22*(i+1)+48*i, 44, 48)];
            button.tag=2001+i;
            button.titleLabel.font=[UIFont systemFontOfSize:14];
            UIColor *titleCol=UIColorFromHex(0x999999);
            UIColor *HtitleCol=UIColorFromHex(0xf39800);
            [button setTitleColor:titleCol forState:UIControlStateNormal];
            [button setTitleColor:HtitleCol forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageNamed:normalImage[i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:heightImage[i]] forState:UIControlStateHighlighted];
            [button setTitle:title[i] forState:UIControlStateNormal];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [button setTitleEdgeInsets:UIEdgeInsetsMake(30 ,-30, 0.0,0.0)];
            [button setImageEdgeInsets:UIEdgeInsetsMake(-18,0.0,0.0, -11)];
            [self addSubview:button];
            
        }
        self.line=[[UIView alloc] initWithFrame:CGRectMake(1, 0, 1, [UIScreen mainScreen].bounds.size.width-63)];
        self.line.backgroundColor=[UIColor clearColor];
        [self addSubview:self.line];
        
    }
    
    return self;
}



@end
