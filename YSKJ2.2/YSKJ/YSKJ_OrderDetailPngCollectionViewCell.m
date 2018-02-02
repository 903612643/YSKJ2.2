//
//  YSKJ_OrderDetailPngCollectionViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/8/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDetailPngCollectionViewCell.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderDetailPngCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.price = [[UILabel alloc] initWithFrame:self.bounds];
        
        self.price.textAlignment = NSTextAlignmentCenter;
        
        self.price.textColor = UIColorFromHex(0x666666);
        
        self.price.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:self.price];
        
    }
    return self;
}

-(void)setPriceStr:(NSString *)priceStr
{
    _priceStr = priceStr;
    self.price.text = priceStr;
}

@end
