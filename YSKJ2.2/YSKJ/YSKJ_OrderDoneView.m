//
//  YSKJ_OrderDoneView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDoneView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderDoneView

-(instancetype)initWithFrame:(CGRect)frame priceArray:(NSArray*)titleArray
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(290, 96, 120, 120)];
        imageView.image = [UIImage imageNamed:@"doneimg"];
        [self addSubview:imageView];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(466, 96, 280, 18)];
        title.font = [UIFont systemFontOfSize:18];
        title.textColor = UIColorFromHex(0x333333);
        title.textAlignment = NSTextAlignmentLeft;
        title.text = @"订单已提交，我们会尽快审核发货";
        [self addSubview:title];
        
       // NSArray *titleArray = @[@"商品原价：200000.00",@"商品折扣：10000.00",@"优惠价格：10000.00",@"应付总额：180000.00"];
        
        for (int i=0; i<titleArray.count; i++) {
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(466, 136+14*i+8*i, 160, 14)];
            title.font = [UIFont systemFontOfSize:14];
            UIColor *titC = UIColorFromHex(0xf32a00);
            NSString *textStr=[NSString stringWithFormat:@"%@",titleArray[i]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textStr];
            [attributedString addAttribute:NSForegroundColorAttributeName value:titC range:NSMakeRange(5,textStr.length-5)];
            title.attributedText=attributedString;
            [self addSubview:title];
            
        }
        self.selectOrder = [[UIButton alloc] initWithFrame:CGRectMake(466, 256, 208, 38)];
        [self.selectOrder setTitle:@"查看订货单" forState:UIControlStateNormal];
        self.selectOrder.layer.borderColor = UIColorFromHex(0xf95f3e).CGColor;
        self.selectOrder.layer.borderWidth = 1;
        UIColor *titleColor = UIColorFromHex(0xf95f3e);
        [self.selectOrder setTitleColor:titleColor forState:UIControlStateNormal];
        self.selectOrder.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.selectOrder];
        
    }
    return self;
}


@end
