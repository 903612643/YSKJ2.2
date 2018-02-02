//
//  YSKJ_OrderProDuctTableViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/7/28.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderProDuctTableViewCell.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地址

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderProDuctTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.proImage = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 80, 80)];
        self.proImage.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        
        self.proImage.layer.borderWidth = 1;
        
        [self addSubview:self.proImage];
        
        self.proName = [[UILabel alloc] init];
        self.proName.textColor = UIColorFromHex(0x333333);
        self.proName.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.proName];
        self.proName.sd_layout
        .leftSpaceToView(self, 120)
        .widthIs(250)
        .heightIs(14)
        .topSpaceToView(self, 10);
        
        self.standardLable = [[UILabel alloc] init];
        self.standardLable .textColor = UIColorFromHex(0x999999);
        self.standardLable .font = [UIFont systemFontOfSize:12];
        [self addSubview:self.standardLable];
        self.standardLable.sd_layout
        .leftSpaceToView(self, 120)
        .widthIs(250)
        .heightIs(14)
        .topSpaceToView(self.proName, 10);
        
        self.desc = [[UILabel alloc] init];
        self.desc.textColor = UIColorFromHex(0x999999);
        self.desc.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.desc];
        self.desc.sd_layout
        .leftSpaceToView(self, 120)
        .widthIs(250)
        .heightIs(14)
        .topSpaceToView(self.standardLable, 10);

        self.price = [[UILabel alloc] init];
        self.price.textColor = UIColorFromHex(0x666666);
        self.price.textAlignment = NSTextAlignmentCenter;
        self.price.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.price];
        self.price.sd_layout
        .leftSpaceToView(self, 455)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self, 49);
        
        self.count = [[UILabel alloc] init];
        self.count.textColor = UIColorFromHex(0x666666);
        self.count.font = [UIFont systemFontOfSize:14];
        self.count.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.count];
        self.count.sd_layout
        .leftSpaceToView(self, 455+60+54)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self, 49);
        
        self.totailPrice = [[UILabel alloc] init];
        self.totailPrice.textColor = UIColorFromHex(0x666666);
        self.totailPrice.textAlignment = NSTextAlignmentCenter;
        self.totailPrice.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.totailPrice];
        self.totailPrice.sd_layout
        .leftSpaceToView(self, 455+(60+54)*2)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self, 49);
        
        self.updatePrice = [[UILabel alloc] init];
        self.updatePrice.textColor = UIColorFromHex(0x666666);
        self.updatePrice.textAlignment = NSTextAlignmentCenter;
        self.updatePrice.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.updatePrice];
        self.updatePrice.sd_layout
        .leftSpaceToView(self, 455+(60+54)*3)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self, 49);
        
        self.payPrice = [[UILabel alloc] init];
        self.payPrice.textColor = UIColorFromHex(0x666666);
        self.payPrice.textAlignment = NSTextAlignmentCenter;
        self.payPrice.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.payPrice];
        self.payPrice.sd_layout
        .leftSpaceToView(self, 455+(60+54)*4)
        .widthIs(100)
        .heightIs(14)
        .topSpaceToView(self, 49);
        
    }
    
    return self;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    
    [self.proImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",PICURL,url]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
    
    //获取网络图片的Size
    [self.proImage.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@",PICURL,url]] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        float imageW=80;
        float scaleW;
        if (image.size.width>=image.size.height) {
            scaleW=imageW/image.size.width;
        }else{
            scaleW=imageW/image.size.height;
        }
        
        if (image.size.width>0 && image.size.height>0) {
            
            self.proImage.imageEdgeInsets=UIEdgeInsetsMake((self.proImage.frame.size.height-scaleW*(image.size.height))/2+2, (self.proImage.frame.size.width-scaleW*(image.size.width))/2+2, (self.proImage.frame.size.height-scaleW*(image.size.height))/2+2, (self.proImage.frame.size.width-scaleW*(image.size.width))/2+2);
        }
        
    }];
    
}

-(void)setProNameStr:(NSString *)proNameStr
{
    _proNameStr = proNameStr;
    self.proName.text = proNameStr;
}

-(void)setStandardLableStr:(NSString *)standardLableStr
{
    _standardLableStr = standardLableStr;
    
    if (standardLableStr.length!=0) {
        
        self.standardLable.text = [NSString stringWithFormat:@"规格：%@",standardLableStr];
    }
    
}

-(void)setDescStr:(NSString *)descStr
{
    _descStr = descStr;
    if (descStr.length!=0) {
        _desc.text = [NSString stringWithFormat:@"备注：%@",descStr];

    }
}

-(void)setPriceStr:(NSString *)priceStr
{
    _priceStr = priceStr;
    self.price.text = priceStr;
    
}

-(void)setCountStr:(NSString *)countStr
{
    _countStr = countStr;
    self.count.text = countStr;
}

-(void)setTotailPriceStr:(NSString *)totailPriceStr
{
    _totailPriceStr = totailPriceStr;
    self.totailPrice.text = totailPriceStr;
}

-(void)setUpdatePriceStr:(NSString *)updatePriceStr
{
    _updatePriceStr = updatePriceStr;
    self.updatePrice.text = updatePriceStr;
}

-(void)setPayPriceStr:(NSString *)payPriceStr
{
    _payPriceStr = payPriceStr;
    self.payPrice.text = payPriceStr;
}


@end
