//
//  YSKJ_YlineView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/25.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_YMoneyLableView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_YMoneyLableView

-(id)initWithFrame:(CGRect)frame
{
    
    if (self == [super initWithFrame:frame]) {
        
        for (int i=0; i<4; i++) {
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-11*4)/3*i + 11*i , self.frame.size.width, 11)];
            lable.textColor = UIColorFromHex(0x666666);
            lable.font = [UIFont systemFontOfSize:11];
            lable.textAlignment = NSTextAlignmentRight;
            [self addSubview:lable];
            
            if (i==0) {
                self.maxLable = lable;
            }else if (i==1){
                self.middleLable1 = lable;
            }else if (i==2){
                self.middleLable2 = lable;
            }else{
                self.minLable = lable;
            }
        }
    }
    
    return self;
}

-(void)setMaxLableStr:(NSString *)maxLableStr
{
    _maxLableStr = maxLableStr;
    self.maxLable.text = maxLableStr;
}

-(void)setMinLableStr:(NSString *)minLableStr
{
    _minLableStr = minLableStr;
    self.minLable.text = minLableStr;
}

-(void)setMiddleLable1Str:(NSString *)middleLable1Str
{
    _middleLable1Str = middleLable1Str;
    self.middleLable1.text = middleLable1Str;
}

-(void)setMiddleLable2Str:(NSString *)middleLable2Str
{
    _middleLable2Str = middleLable2Str;
    self.middleLable2.text = middleLable2Str;
}

@end
