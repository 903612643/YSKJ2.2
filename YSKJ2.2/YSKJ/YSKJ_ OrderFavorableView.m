//
//  YSKJ_ OrderFavorableView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/4.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_ OrderFavorableView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define FONT [UIFont systemFontOfSize:14]

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ__OrderFavorableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UILabel *title = [[UILabel alloc] init];
        title.text = @"优惠价格";
        title.textColor = UIColorFromHex(0x333333);
        title.font = FONT;
        [self addSubview:title];
        title.sd_layout
        .leftSpaceToView(self,80)
        .widthIs(80)
        .heightIs(14)
        .topSpaceToView(self,28);
        
        NSArray *titleArray = @[@"商品原价",@"涨价或折扣",@"优惠价格",@"应付金额"];
        
        NSArray *lableArray = @[@"＋",@"＋",@"＝"];
        
        for (int i=0; i<titleArray.count; i++) {
            
            UILabel *title = [[UILabel alloc] init];
            title.text = titleArray[i];
            title.textAlignment = NSTextAlignmentRight;
            title.textColor = UIColorFromHex(0x333333);
            title.font = FONT;
            [self addSubview:title];
            title.sd_layout
            .leftSpaceToView(self,526+(56+72)*i)
            .topSpaceToView(self,16)
            .widthIs(80)
            .heightIs(14);
            
            if (i!=titleArray.count-1) {
                UILabel *lable = [[UILabel alloc] init];
                lable.text = lableArray[i];
                lable.textColor = UIColorFromHex(0x999999);
                lable.font = FONT;
                [self addSubview:lable];
                lable.sd_layout
                .leftSpaceToView(title,20)
                .widthIs(14)
                .heightIs(14)
                .topSpaceToView(self,40);
            }

        }
        
        self.naturePrice = [[UILabel alloc] init];
        self.naturePrice.textAlignment = NSTextAlignmentRight;
        self.naturePrice.textColor = UIColorFromHex(0x999999);
        self.naturePrice.font = FONT;
        [self addSubview:self.naturePrice];
        self.naturePrice.sd_layout
        .leftSpaceToView(self,504)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self,40);
        
        self.disCountPrice = [[UILabel alloc] init];
        self.disCountPrice.textAlignment = NSTextAlignmentRight;
        self.disCountPrice.textColor = UIColorFromHex(0x999999);
        self.disCountPrice.font = FONT;
        [self addSubview:self.disCountPrice];
        self.disCountPrice.sd_layout
        .leftSpaceToView(self,504+(56+72)*1)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self,40);
        
        self.favorablePrice = [[UILabel alloc] init];
        self.favorablePrice.textAlignment = NSTextAlignmentRight;
        self.favorablePrice.text = @"0.00";
        self.favorablePrice.textColor = UIColorFromHex(0x999999);
        self.favorablePrice.font = FONT;
        [self addSubview:self.favorablePrice];
        self.favorablePrice.sd_layout
        .leftSpaceToView(self,504+(56+72)*2)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self,40);
        
        self.payPrice = [[UILabel alloc] init];
        self.payPrice.textAlignment = NSTextAlignmentRight;
        self.payPrice.text = @"0.00";
        self.payPrice.textColor = UIColorFromHex(0x999999);
        self.payPrice.font = FONT;
        [self addSubview:self.payPrice];
        self.payPrice.sd_layout
        .leftSpaceToView(self,504+(56+72)*3)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self,40);
        
        UILabel *jian = [[UILabel alloc] init];
        jian.text = @"减";
        jian.textColor = UIColorFromHex(0x333333);
        jian.font = FONT;
        [self addSubview:jian];
        jian.sd_layout
        .leftSpaceToView(self,179)
        .widthIs(14)
        .heightEqualToWidth()
        .topSpaceToView(self,28);
        
        self.discount = [[UITextField alloc] init];
        self.discount.borderStyle = UITextBorderStyleNone;
        self.discount.textAlignment = NSTextAlignmentCenter;
        self.discount.textColor = UIColorFromHex(0x333333);
        self.discount.layer.borderWidth = 1;
        self.discount.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        [self addSubview:self.discount];
        self.discount.sd_layout
        .leftSpaceToView(jian,2)
        .widthIs(90)
        .heightIs(30)
        .topSpaceToView(self,20);
        
        UILabel *yuan = [[UILabel alloc] init];
        yuan.text = @"元";
        yuan.textColor = UIColorFromHex(0x333333);
        yuan.font = FONT;
        [self addSubview:yuan];
        yuan.sd_layout
        .leftSpaceToView(self.discount,2)
        .widthIs(14)
        .heightEqualToWidth()
        .topSpaceToView(self,28);

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        line.backgroundColor = UIColorFromHex(0xd7d7d7);
        [self addSubview:line];
        
    }
    return self;
}

-(void)setNaturePriceStr:(NSString *)naturePriceStr
{
    _naturePriceStr = naturePriceStr;
    self.naturePrice.text = [NSString stringWithFormat:@"%0.2f",[naturePriceStr floatValue]];
}

-(void)setDisCountPriceStr:(NSString *)disCountPriceStr
{
    _disCountPriceStr = disCountPriceStr;
    self.disCountPrice.text = [NSString stringWithFormat:@"%0.2f",[disCountPriceStr floatValue]];
}

-(void)setFavorablePriceStr:(NSString *)favorablePriceStr
{
    _favorablePriceStr = favorablePriceStr;
    self.favorablePrice.text = [NSString stringWithFormat:@"%0.2f",[favorablePriceStr floatValue]];
}

-(void)setPayPriceStr:(NSString *)payPriceStr
{
    _payPriceStr = payPriceStr;
    self.payPrice.text = [NSString stringWithFormat:@"%0.2f",[payPriceStr floatValue]];
}


@end
