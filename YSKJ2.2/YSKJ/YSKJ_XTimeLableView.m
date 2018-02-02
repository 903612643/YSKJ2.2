//
//  YSKJ_XlineView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/25.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_XTimeLableView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define WEI 100

@implementation YSKJ_XTimeLableView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        //默认显示4个时间的纵轴，当轴不在ScrollView内是，隐藏以外的轴。
        for (int i=0; i<4; i++) {
            
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - WEI*4)/5*i + WEI*(i+1), 16, WEI, 30)];
            lable.textColor = UIColorFromHex(0x666666);
            lable.textAlignment = NSTextAlignmentCenter;
            lable.font = [UIFont systemFontOfSize:11];
            [self addSubview:lable];
            if (i==0) {
                self.timeLable1 = lable;
            }else if (i==1){
                self.timeLable2 = lable;
            }else if (i==2){
                self.timeLable3 = lable;
            }else{
                self.timeLable4 = lable;
            }
            
        }
        
        
    }
    return self;
}
#pragma mark setpointX

-(void)setTimeLable1X:(float)timeLable1X
{
    _timeLable1X = timeLable1X;
    [UIView animateWithDuration:0.5 animations:^{
        self.timeLable1.frame = CGRectMake(timeLable1X - WEI/2, 18, WEI, 16);
    }];
}
-(void)setTimeLable2X:(float)timeLable2X
{
    _timeLable2X = timeLable2X;
    [UIView animateWithDuration:0.5 animations:^{
        self.timeLable2.frame = CGRectMake(timeLable2X - WEI/2, 18, WEI, 16);
    }];
}
-(void)setTimeLable3X:(float)timeLable3X
{
    _timeLable3X = timeLable3X;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.timeLable3.frame = CGRectMake(timeLable3X - WEI/2, 18, WEI, 16);
    }];
    
}
-(void)setTimeLable4X:(float)timeLable4X
{
    _timeLable4X = timeLable4X;
    [UIView animateWithDuration:0.5 animations:^{
        self.timeLable4.frame = CGRectMake(timeLable4X - WEI/2, 18, WEI, 16);
    }];
    if (self.timeLable4.frame.origin.x > self.frame.size.width - WEI/2) {
        self.timeLable4.hidden = YES;
    }else{
        self.timeLable4.hidden = NO;
    }
}
#pragma mark set text

-(void)setTimeLable1Xtext:(NSString *)timeLable1Xtext
{
    _timeLable1Xtext = timeLable1Xtext;
    self.timeLable1.text = timeLable1Xtext;
}

-(void)setTimeLable2Xtext:(NSString *)timeLable2Xtext
{
    _timeLable2Xtext = timeLable2Xtext;
    self.timeLable2.text = timeLable2Xtext;
}

-(void)setTimeLable3Xtext:(NSString *)timeLable3Xtext
{
    _timeLable3Xtext = timeLable3Xtext;
    self.timeLable3.text = timeLable3Xtext;
}


-(void)setTimeLable4Xtext:(NSString *)timeLable4Xtext
{
    _timeLable4Xtext = timeLable4Xtext;
    self.timeLable4.text = timeLable4Xtext;
}

@end
