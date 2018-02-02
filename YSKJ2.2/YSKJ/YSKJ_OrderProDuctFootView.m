//
//  YSKJ_OrderProDuctFootView.m
//  YSKJ
//
//  Created by YSKJ on 17/7/31.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderProDuctFootView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderProDuctFootView

-(instancetype)initWithFrame:(CGRect)frame priceArr:(NSArray *)priceArr
{
    if (self == [super initWithFrame:frame]) {
        
        NSArray *arr = @[@"商品原价",@"涨价或折扣",@"优惠价格"];
        
        for (int i = 0; i<priceArr.count; i++) {
            
            if (i!=priceArr.count -1) {
                
                UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-292, 30+28*i, 100, 14)];
                lable.text = arr[i];
                lable.textAlignment = NSTextAlignmentRight;
                lable.font = [UIFont systemFontOfSize:14];
                lable.textColor = UIColorFromHex(0x666666);
                [self addSubview:lable];
                
                UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-150, 30+28*i, 100, 14)];
                price.text = priceArr[i];
                price.textAlignment = NSTextAlignmentRight;
                price.font = [UIFont systemFontOfSize:14];
                price.textColor = UIColorFromHex(0x666666);
                [self addSubview:price];
                

            }else{
                
                self.pay = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-250, 145, 200, 14)];
                self.pay.textAlignment = NSTextAlignmentRight;
                self.pay.font = [UIFont systemFontOfSize:16];
                NSString *priStr = priceArr[i];

                UIColor *titC = UIColorFromHex(0xf32a00);

                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:priStr];
                [attributedString addAttribute:NSForegroundColorAttributeName value:titC range:NSMakeRange(4,priStr.length-4)];
                self.pay.attributedText=attributedString;
                
                [self addSubview:self.pay];
                
            }
            
            
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 130, self.frame.size.width, 1)];
        line.backgroundColor = UIColorFromHex(0xd7d7d7);
        [self addSubview:line];
       

        
    }
    
    return self;
    
}

-(void)setPayStr:(NSString *)payStr
{
    _payStr = payStr;
    self.pay.text = payStr;
}



@end
