//
//  YSKJ_OrderProDuctHeadView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/31.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderProDuctHeadView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderProDuctHeadView

-(instancetype)initWithFrame:(CGRect)frame  array1:(NSArray *)titleArray array2:(NSArray*)info
{
    if (self == [super initWithFrame:frame]) {
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, 1)];
        line.backgroundColor =  UIColorFromHex(0xd7d7d7);
        [self addSubview:line];
        
        for (int i = 0; i<titleArray.count; i++) {
            
            UILabel *lable = [[UILabel alloc] init];
            lable.text = titleArray[i];
            lable.textAlignment = NSTextAlignmentLeft;
            lable.font = [UIFont systemFontOfSize:14];
            [self addSubview:lable];
            
            UILabel *infoLable = [[UILabel alloc] init];
            infoLable.text = info[i];
            infoLable.textAlignment = NSTextAlignmentLeft;
            infoLable.font = [UIFont systemFontOfSize:14];
            [self addSubview:infoLable];
            
            if (i==1) {
                
                lable.textColor = UIColorFromHex(0x999999);
                lable.sd_layout
                .leftSpaceToView(self,20)
                .topSpaceToView(self,7+15*(i+1)+16*i)
                .widthIs(300)
                .heightIs(16);
                   
            }else{
                
                lable.textColor = UIColorFromHex(0x333333);
                
                lable.sd_layout
                .leftSpaceToView(self,20)
                .topSpaceToView(self,7+15*(i+1)+16*i)
                .widthIs(80)
                .heightIs(16);
                
                infoLable.textColor = UIColorFromHex(0x333333);
                infoLable.sd_layout
                .leftSpaceToView(self,110)
                .topSpaceToView(self,7+15*(i+1)+16*i)
                .widthIs(self.frame.size.width - 110)
                .heightIs(16);
    
            }
            if (i>=2) {
                
                lable.sd_layout
                .leftSpaceToView(self,20)
                .topSpaceToView(self,18+15*(i+1)+16*i);
                [lable updateLayout];
                
                infoLable.sd_layout
                .leftSpaceToView(self,110)
                .topSpaceToView(self,18+15*(i+1)+16*i);
                [infoLable updateLayout];
                
                
            }
            
     
        }
        
        
    }
    return self;
}

@end
