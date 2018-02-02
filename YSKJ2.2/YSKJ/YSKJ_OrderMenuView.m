//
//  YSKJ_OrderMenuView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/4.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderMenuView.h"

#define FONT [UIFont systemFontOfSize:14]

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderMenuView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        NSArray *title = @[@"商品",@"单价",@"数量",@"总价",@"折",@"实付款"];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(150, (self.frame.size.height-14)/2, 40, 14)];
        name.text = title[0];
        name.textColor = UIColorFromHex(0x333333);
        name.font = FONT;
        [self addSubview:name];
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(369, (self.frame.size.height-14)/2, 40, 14)];
        price.text = title[1];
        price.textColor = UIColorFromHex(0x333333);
        price.font = FONT;
        [self addSubview:price];
        
        UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(485, (self.frame.size.height-14)/2, 40, 14)];
        count.text = title[2];
        count.textColor = UIColorFromHex(0x333333);
        count.font = FONT;
        [self addSubview:count];
        
        UILabel *totalPrices = [[UILabel alloc] initWithFrame:CGRectMake(588, (self.frame.size.height-14)/2, 40, 14)];
        totalPrices.text = title[3];
        totalPrices.textColor = UIColorFromHex(0x333333);
        totalPrices.font = FONT;
        [self addSubview:totalPrices];
        
        self.menuDiscount = [[UITextField alloc] initWithFrame:CGRectMake(673, (self.frame.size.height-30)/2, 40, 30)];
        self.menuDiscount.textAlignment = NSTextAlignmentCenter;
        self.menuDiscount.borderStyle = UITextBorderStyleNone;
        self.menuDiscount.keyboardType = UIKeyboardTypeNumberPad;
        self.menuDiscount.textColor = UIColorFromHex(0x333333);
        self.menuDiscount.layer.borderWidth = 1;
        self.menuDiscount.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        [self addSubview:self.menuDiscount];
        
        UILabel *disCountLable = [[UILabel alloc] initWithFrame:CGRectMake(715, (self.frame.size.height-14)/2, 20, 14)];
        disCountLable.text = title[4];
        disCountLable.textColor = UIColorFromHex(0x333333);
        disCountLable.font = FONT;
        [self addSubview:disCountLable];
        
        UILabel *actualPayment = [[UILabel alloc] initWithFrame:CGRectMake(902, (self.frame.size.height-14)/2, 60, 14)];
        actualPayment.text = title[5];
        actualPayment.textColor = UIColorFromHex(0x333333);
        actualPayment.font = FONT;
        [self addSubview:actualPayment];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, self.frame.size.width, 1)];
        line.backgroundColor = UIColorFromHex(0xd7d7d7);
        [self addSubview:line];

    }
    return self;
}


@end
