//
//  YSKJ_PicCollectionViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/9/14.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_PicCollectionViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import <SDWebImage/UIButton+WebCache.h>

#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地址

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_PicCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        self.layer.borderWidth=1;
        
        self.layer.borderColor=UIColorFromHex(0x999999).CGColor;

        [self addSubview:self.imageView];
        
        
    }
    return self;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",PICURL,url]] placeholderImage:[UIImage imageNamed:@"loading1"]];

    //获取网络图片的Size
    [self.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@",PICURL,url]] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        float imageW=44;
        float scaleW;
        if (image.size.width>=image.size.height) {
            scaleW=imageW/image.size.width;
        }else{
            scaleW=imageW/image.size.height;
        }
        
        if (image.size.width>0 && image.size.height>0) {
            
            self.imageView.frame =  CGRectMake((self.frame.size.width - (scaleW*(image.size.width)-5))/2, (self.frame.size.height - (scaleW*(image.size.height)-5))/2, scaleW*(image.size.width) - 5, (scaleW*(image.size.height)-5));
        }
        
    }];
    
    
}


@end
