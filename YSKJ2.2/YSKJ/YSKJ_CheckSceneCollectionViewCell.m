//
//  YSKJ_CheckSceneCollectionViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/6/19.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CheckSceneCollectionViewCell.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_CheckSceneCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-70)];
        [self addSubview:self.button];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, self.button.frame.size.height+5+13, self.frame.size.width-10, 20)];
        self.titleLable.font = [UIFont systemFontOfSize:14];
        self.titleLable.textAlignment = NSTextAlignmentLeft;
        self.titleLable.textColor = UIColorFromHex(0x666666);
        [self addSubview:self.titleLable];
        
    }
    return self;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    
    [self.button sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"folderNone"]];
    
    //获取网络图片的Size
    [self.button.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:url] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        float imageW=self.button.frame.size.width;
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
-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLable.text = title;
    
}


@end
