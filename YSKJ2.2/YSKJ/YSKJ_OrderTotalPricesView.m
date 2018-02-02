//
//  YSKJ_OrderTotalPricesView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/4.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderTotalPricesView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderTotalPricesView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.checkProduct = [[UIButton alloc] initWithFrame:CGRectMake(16, (self.frame.size.height - 30)/2, 30, 30)];
        self.checkProduct.layer.cornerRadius = 15;
        self.checkProduct.layer.masksToBounds = YES;
        self.checkProduct.layer.borderWidth = 2;
        self.checkProduct.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        [self addSubview:self.checkProduct];
        
        self.allCheckTitle = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, 60, self.frame.size.height)];
        self.allCheckTitle.text = @"全选";
        self.allCheckTitle.font = [UIFont systemFontOfSize:14];
        self.allCheckTitle.textColor = UIColorFromHex(0x333333);
        [self addSubview:self.allCheckTitle];
        
        self.produnt = [[UILabel alloc] init];
        self.produnt.textColor = UIColorFromHex(0x333333);
        self.produnt.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.produnt];
        self.produnt.sd_layout
        .leftSpaceToView(self.allCheckTitle,16)
        .heightIs(24)
        .topSpaceToView(self,15)
        .widthIs(160);
        
        UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(476, 20, 40, 14)];
        total.text = @"总计";
        total.font = [UIFont systemFontOfSize:14];
        [self addSubview:total];
        
        self.totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(524, 15, 200, 24)];
        self.totalPrice.textColor = UIColorFromHex(0xf32a00);
        self.totalPrice.font = [UIFont systemFontOfSize:24];
        [self addSubview:self.totalPrice];
        
        self.placeAnorder = [[UIButton alloc] init];
        [self.placeAnorder setTitle:@"下单" forState:UIControlStateNormal];
        UIColor *titleC = UIColorFromHex(0xefefef);
        self.placeAnorder.backgroundColor = titleC;
        self.placeAnorder.enabled = NO;
        [self.placeAnorder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.placeAnorder.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.placeAnorder];
        self.placeAnorder.sd_layout
        .widthIs(140)
        .heightIs(40)
        .topSpaceToView(self,7)
        .rightSpaceToView(self,38);
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        line.backgroundColor = UIColorFromHex(0xd7d7d7);
        [self addSubview:line];

        
    }
    
    return  self;
    
}
-(void)setProductNumber:(NSInteger)productNumber
{
    _productNumber = productNumber;
        
    NSString *text = [NSString stringWithFormat:@"已选%ld件商品",(long)productNumber
                      ];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text]; // 改变
    //种类的属性
    
    if (productNumber<10) {
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(2,1)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(2,1)];
        
    }else{
        
        if (productNumber>99) {
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(2,3)];
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:24.0]
                                     range:NSMakeRange(2,3)];

        }else{
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(2,2)];
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:24.0]
                                     range:NSMakeRange(2,2)];

        }
        
    }
    
    self.produnt.attributedText=attributedString;

}

-(void)setTotailPriceStr:(NSString *)totailPriceStr
{
    _totailPriceStr = totailPriceStr;
    self.totalPrice.text = totailPriceStr;
}

@end
