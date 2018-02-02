//
//  YSKJ_OrderDetailTableViewFootView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDetailTableViewFootView.h"

#import <SDAutoLayout/SDAutoLayout.h>

@implementation YSKJ_OrderDetailTableViewFootView

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

-(instancetype)initWithFrame:(CGRect)frame withDict:(NSDictionary *)dict
{
    if (self == [super initWithFrame:frame]) {
        
        NSArray *titleA = @[@"商品原价",@"涨价或折扣",@"优惠价格"];
        
        NSArray *orderArray = [dict objectForKey:@"priceArr"];
        
        for (int i=0; i<titleA.count; i++) {
            
            UILabel *titleLable = [[UILabel alloc] init];
            titleLable.text = titleA[i];
            titleLable.textAlignment = NSTextAlignmentRight;
            titleLable.textColor = UIColorFromHex(0x666666);
            titleLable.font = [UIFont systemFontOfSize:14];
            [self addSubview:titleLable];
            titleLable.sd_layout
            .rightSpaceToView(self,186)
            .widthIs(200)
            .heightIs(14)
            .topSpaceToView(self,35+28*i);
            
            UILabel *money = [[UILabel alloc] init];
            float moneyF = [orderArray[i] floatValue];
            if (moneyF >=0) {
                money.text = [NSString stringWithFormat:@"¥%0.2f",moneyF];
            }else{
                money.text = [NSString stringWithFormat:@"-¥%0.2f",[[orderArray[i] substringFromIndex:1] floatValue]];
            }
            money.textAlignment = NSTextAlignmentRight;
            money.textColor = UIColorFromHex(0x666666);
            money.font = [UIFont systemFontOfSize:14];
            [self addSubview:money];
            money.sd_layout
            .rightSpaceToView(self,64)
            .widthIs(100)
            .heightIs(14)
            .topSpaceToView(self,35+28*i);
    
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 125, self.frame.size.width-60, 1)];
        line.backgroundColor = UIColorFromHex(0xd7d7d7);
        [self addSubview:line];
        
        UILabel *number = [[UILabel alloc] init];
        number.textColor = UIColorFromHex(0x333333);
        number.text = [NSString stringWithFormat:@"已选%@件商品    总计：",[dict objectForKey:@"proNumber"]];
        number.textAlignment = NSTextAlignmentLeft;
        number.font = [UIFont systemFontOfSize:24];
        [self addSubview:number];
        number.sd_layout
        .leftSpaceToView(self,580)
        .topSpaceToView(self,140)
        .heightIs(24)
        .rightSpaceToView(self,190);
        
        UILabel *totail = [[UILabel alloc] init];
        totail.textColor = UIColorFromHex(0xf32a00);
        totail.textAlignment = NSTextAlignmentLeft;
        totail.text = [NSString stringWithFormat:@"¥%0.2f",[[dict objectForKey:@"totailePrice"] floatValue]];
        totail.font = [UIFont systemFontOfSize:24];
        [self addSubview:totail];
        totail.sd_layout
        .leftSpaceToView(number,10)
        .topSpaceToView(self,140)
        .heightIs(24)
        .rightSpaceToView(self,0);
        
        UILabel *principal = [[UILabel alloc] init];
        principal.textColor = UIColorFromHex(0x333333);
        principal.textAlignment = NSTextAlignmentLeft;
        principal.text = [NSString stringWithFormat:@"客户负责人：%@     电话：%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"username"],[[NSUserDefaults standardUserDefaults]objectForKey:@"phone"]];
        principal.font = [UIFont systemFontOfSize:12];
        [self addSubview:principal];
        principal.sd_layout
        .leftSpaceToView(self,580)
        .topSpaceToView(self,185)
        .heightIs(24)
        .rightSpaceToView(self,0);
        
        UILabel *compay = [[UILabel alloc] init];
        compay.textColor = UIColorFromHex(0x333333);
        compay.textAlignment = NSTextAlignmentLeft;
        compay.text = [NSString stringWithFormat:@"公司地址：深圳市福田区车公庙本元大厦   电话：13476897254"];
        compay.font = [UIFont systemFontOfSize:12];
        [self addSubview:compay];
        compay.sd_layout
        .leftSpaceToView(self,580)
        .topSpaceToView(self,210)
        .heightIs(24)
        .rightSpaceToView(self,40);
        
        UILabel *signature = [[UILabel alloc] init];
        signature.textColor = UIColorFromHex(0x333333);
        signature.textAlignment = NSTextAlignmentLeft;
        signature.text = [NSString stringWithFormat:@"客户签字："];
        signature.font = [UIFont systemFontOfSize:18];
        [self addSubview:signature];
        signature.sd_layout
        .leftSpaceToView(self,580)
        .topSpaceToView(self,273)
        .heightIs(24)
        .rightSpaceToView(self,0);


    }
    
    return self;
}


@end
