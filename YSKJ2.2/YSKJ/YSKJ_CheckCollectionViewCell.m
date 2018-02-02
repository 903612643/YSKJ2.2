//
//  YSKJ_CheckCollectionViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/6/13.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CheckCollectionViewCell.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_CheckCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
    
        self.button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,(THEWIDTH-36*4)/4, (THEWIDTH-36*4)/4)];
        [self addSubview:self.button];
        
        self.titleLable=[[UILabel alloc] initWithFrame:CGRectMake(0, self.button.frame.size.height+17, self.button.frame.size.width, 20)];
        self.titleLable.font = [UIFont systemFontOfSize:14];
        self.titleLable.textColor=UIColorFromHex(0x666666);
        [self addSubview:self.titleLable];
        
        self.priceLable=[[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-32, self.frame.size.width, 20)];
        self.priceLable.textColor=UIColorFromHex(0xf32a00);
        self.priceLable.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        [self addSubview:self.priceLable];
        
        UILabel *lineLable=[[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        lineLable.backgroundColor=UIColorFromHex(0xd8d8d8);
        [self addSubview:lineLable];
        
    }
    
    return self;
    
}

-(void)setUrl:(NSString *)url{
    
    _url = url;
    
    [self.button sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
    
    if (url.length<25) {
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSArray  *picArr= [url componentsSeparatedByString:@"/"];
        
        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,picArr[1],picArr[2]];
        
        NSString *fullPath = [imagePath stringByAppendingPathComponent:picArr[3]];
        
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        
        float imageW=(THEWIDTH-36*3-36)/4;
        
        float scaleW;
        if (savedImage.size.width>=savedImage.size.height) {
            scaleW=imageW/savedImage.size.width;
        }else{
            scaleW=imageW/savedImage.size.height;
        }
        
        self.button.imageEdgeInsets=UIEdgeInsetsMake((self.button.frame.size.height-scaleW*(savedImage.size.height))/2, (self.button.frame.size.width-scaleW*(savedImage.size.width))/2, (self.button.frame.size.height-scaleW*(savedImage.size.height))/2, (self.button.frame.size.width-scaleW*(savedImage.size.width))/2);
        
        [self.button setImage:savedImage forState:UIControlStateNormal];
        
    }else{
        
        //获取网络图片的Size
        [self.button.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:url] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            float imageW=(THEWIDTH-144)/4;
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

    
}

-(void)setTitle:(NSString *)title
{
    _title=title;
    
    if (title.length>25) {
        NSString *subString=[title substringToIndex:25.5];
        self.titleLable.text=subString;
    }else{
        self.titleLable.text=title;
    }
  
}
-(void)setPrice:(NSString *)price
{
    _price=price;
    
    if ([price containsString:@"."]) {        //是否包含"."
        
        self.priceLable.text=[NSString stringWithFormat:@"¥%@",price];
        
    } else {
        
        if (price.length>3) {
            
            NSInteger inde=price.length-3;
            NSRange ranges = {inde,0};
            NSString *subStr = [price stringByReplacingCharactersInRange:ranges withString:@","];
            self.priceLable.text=[NSString stringWithFormat:@"¥%@",subStr];
            
        }else{
            
            self.priceLable.text=[NSString stringWithFormat:@"¥%@",price];
            
        }
    }

    
}



@end
