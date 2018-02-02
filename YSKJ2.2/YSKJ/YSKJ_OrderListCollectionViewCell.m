//
//  YSKJ_OrderListCollectionViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/7/28.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderListCollectionViewCell.h"

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地址

@implementation YSKJ_OrderListCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.button = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:self.button];
    }
    
    return self;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    
    [self.button sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",PICURL,url]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
  
    //获取网络图片的Size
    [self.button.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@",PICURL,url]] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        float imageW=80;
        float scaleW;
        if (image.size.width>=image.size.height) {
            scaleW=imageW/image.size.width;
        }else{
            scaleW=imageW/image.size.height;
        }
        
        if (image.size.width>0 && image.size.height>0) {
            
            self.button.imageEdgeInsets=UIEdgeInsetsMake((self.button.frame.size.height-scaleW*(image.size.height))/2, (self.button.frame.size.width-scaleW*(image.size.width))/2, (self.button.frame.size.height-scaleW*(image.size.height))/2, (self.button.frame.size.width-scaleW*(image.size.width))/2);
        }
        
    }];


}

@end
