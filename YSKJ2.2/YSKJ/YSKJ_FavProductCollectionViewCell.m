//
//  YSKJ_FavProductCollectionViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/6/28.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_FavProductCollectionViewCell.h"

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

@implementation YSKJ_FavProductCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, self.frame.size.width-8, self.frame.size.height-48)];
        self.button.adjustsImageWhenHighlighted=YES;
        [self addSubview:self.button];
        
        self.titleLable=[[UILabel alloc] initWithFrame:CGRectMake(0, self.button.frame.size.height+8, self.frame.size.width, 30)];
        self.titleLable.textColor=UIColorFromHex(0x333333);
        self.titleLable.font=[UIFont systemFontOfSize:14];
        [self addSubview:self.titleLable];
    }
    
    return self;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    
    if (url.length<25) {
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSArray  *picArr= [url componentsSeparatedByString:@"/"];
        
        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,picArr[1],picArr[2]];
        NSString *fullPath = [imagePath stringByAppendingPathComponent:picArr[3]];
        
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        
        float imageW=(THEWIDTH/2-16*4)/3-24;
        float scaleW;
        if (savedImage.size.width>=savedImage.size.height) {
            scaleW=imageW/savedImage.size.width;
        }else{
            scaleW=imageW/savedImage.size.height;
        }
        
        self.button.imageEdgeInsets=UIEdgeInsetsMake(((self.button.frame.size.height-scaleW*(savedImage.size.height))/2), ((self.button.frame.size.width-scaleW*(savedImage.size.width))/2), ((self.button.frame.size.height-scaleW*(savedImage.size.height))/2), ((self.button.frame.size.width-scaleW*(savedImage.size.width))/2));
        
        [self.button setImage:savedImage forState:UIControlStateNormal];
        
    }else{
        
        [self.button sd_setImageWithURL:[[NSURL alloc] initWithString:url]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
        
        //获取网络图片的Size
        [self.button.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:url] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            if (image.size.width>0) {
                
                float imageW=(THEWIDTH/2-16*4)/3-24;
                float scaleW;
                if (image.size.width>=image.size.height) {
                    
                    scaleW=imageW/image.size.width;
                }else{
                    scaleW=imageW/image.size.height;
                }
                
                self.button.imageEdgeInsets=UIEdgeInsetsMake(((self.button.frame.size.height-scaleW*(image.size.height))/2), ((self.button.frame.size.width-scaleW*(image.size.width))/2), ((self.button.frame.size.height-scaleW*(image.size.height))/2), ((self.button.frame.size.width-scaleW*(image.size.width))/2));
                
            }
            
        }];
        
    }

}

-(void)setText:(NSString *)text
{
    _text = text;
    
    if (text.length>20) {
        
        NSString *subString=[NSString stringWithFormat:@"%@...",[text substringToIndex:20]];
        self.titleLable.text=subString;
        
    }else{
        
        if (text.length<12) {
            self.titleLable.textAlignment=NSTextAlignmentCenter;
        }
        
        self.titleLable.text = text;
    }

    
}

@end
