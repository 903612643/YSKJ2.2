//
//  YSKJ_NoneProductView.m
//  YSKJ
//
//  Created by YSKJ on 17/6/15.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_NoneProductView.h"
#import <SDAutoLayout/UIView+SDAutoLayout.h>
#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_NoneProductView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
            self.noDataView=[UIView new];
            [self addSubview:self.noDataView];
            self.noDataView.sd_layout
            .topSpaceToView(self,43)
            .leftSpaceToView(self,309)
            .rightSpaceToView(self,309)
            .heightRatioToView(self,0.4);
        
            self.tiplable=[UILabel new];
            self.tiplable.font=[UIFont systemFontOfSize:14];
            self.tiplable.textAlignment=NSTextAlignmentCenter;
            [self.noDataView addSubview:self.tiplable];
            self.tiplable.sd_layout
            .topEqualToView(self.noDataView)
            .rightEqualToView(self.noDataView)
            .leftEqualToView(self.noDataView)
            .autoHeightRatio(0);
        
            self.noDataline=[UIView new];
            self.noDataline.backgroundColor=UIColorFromHex(0x999999);
            [self addSubview:self.noDataline];
            self.noDataline.sd_layout
            .bottomSpaceToView(self,81)
            .leftSpaceToView(self,12)
            .rightSpaceToView(self,12)
            .heightIs(1);
        
            self.noDataimage=[UIImageView new];
            self.noDataimage.image=[UIImage imageNamed:@"loading2"];
            [self addSubview:self.noDataimage];
            self.noDataimage.sd_layout
            .topSpaceToView(self.noDataline,12)
            .leftSpaceToView(self,462)
            .rightSpaceToView(self,462)
            .bottomSpaceToView(self,29);

    }
    return self;
}

-(void)setTipStr:(NSString *)tipStr{
    _tipStr = tipStr;
    self.tiplable.text = tipStr;
    UIColor *attColor=UIColorFromHex(0xf39800);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tipStr]; // 改变特定范围颜色大小要用的
    [attributedString addAttribute:NSForegroundColorAttributeName value:attColor range:NSMakeRange(21,tipStr.length-39)];
    self.tiplable.attributedText=attributedString;

}
@end
