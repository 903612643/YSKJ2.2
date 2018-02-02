//
//  YSKJ_CanvasTransfromView.m
//  YSKJ
//
//  Created by YSKJ on 17/6/30.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CanvasTransfromView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_CanvasTransfromView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
            NSArray *title1=@[@"确认",@"取消"];
        
            NSArray *normalImage1=@[@"tranformSure",@"tranformDiss"];
        
            for (int i=0; i<title1.count; i++) {
                
                UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(7, 63+(48*3+22*4)+48*i+22*i, 44, 48)];
                button.titleLabel.font=[UIFont systemFontOfSize:14];
                button.tag=2010+i;
                button.backgroundColor=[UIColor clearColor];
                UIColor *titleCol=UIColorFromHex(0x999999);
                UIColor *HtitleCol=UIColorFromHex(0xf39800);
                [button setTitleColor:titleCol forState:UIControlStateNormal];
                [button setTitleColor:HtitleCol forState:UIControlStateHighlighted];
                [button setImage:[UIImage imageNamed:normalImage1[i]] forState:UIControlStateNormal];
                [button setTitle:title1[i] forState:UIControlStateNormal];
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [button setTitleEdgeInsets:UIEdgeInsetsMake(30 ,-30, 0.0,0.0)];
                [button setImageEdgeInsets:UIEdgeInsetsMake(-18,0.0,0.0, -11)];
                
                [self addSubview:button];
                
            }
        self.transformViewLine=[[UIView alloc] initWithFrame:CGRectMake(1, 0, 1, [UIScreen mainScreen].bounds.size.height)];
        self.transformViewLine.backgroundColor=[UIColor clearColor];
        [self addSubview:self.transformViewLine];

    }
    
    return self;
    
}
@end
