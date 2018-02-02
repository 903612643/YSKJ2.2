//
//  YSKJ_CanvasLoading.m
//  YSKJ
//
//  Created by YSKJ on 17/9/21.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CanvasLoading.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import "AnimatedGif.h"

#define DEFAULT_DURATION 0.3f
#define DEFAULT_ANIMATON_DURATION 1.0f
#define DEFAULT_HEIGHT 64.0f

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_CanvasLoading

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.bgView = [[UILabel alloc] init];
        self.bgView.backgroundColor = [UIColor colorWithRed:47.013/255.0 green:47.013/255.0 blue:47.013/255.0 alpha:0.6];
        self.bgView.layer.cornerRadius = 6;
        self.bgView.layer.masksToBounds = YES;
        [self addSubview:self.bgView];
        self.bgView.sd_layout
        .leftSpaceToView(self,(self.frame.size.width-180)/2)
        .topSpaceToView(self,(self.frame.size.height-60)/2)
        .heightIs(60)
        .widthIs(180);
        
        UIImageView *loadimage = [[UIImageView alloc] init];
        NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]];
        loadimage= [AnimatedGif getAnimationForGifAtUrl:localUrl];
        [self.bgView addSubview:loadimage];
        loadimage.sd_layout
        .leftSpaceToView(self.bgView,20)
        .topSpaceToView(self.bgView,10)
        .widthIs(40)
        .heightEqualToWidth();
    
        
        self.lable = [[UILabel alloc] init];
        self.lable.textAlignment = NSTextAlignmentLeft;
        self.lable.textColor = UIColorFromHex(0xffffff);
        [self.bgView addSubview:self.lable];
        
        self.lable.sd_layout
        .rightSpaceToView(self.bgView,20)
        .topSpaceToView(self.bgView,16)
        .bottomSpaceToView(self.bgView,16)
        .leftSpaceToView(loadimage,10);
        
        self.onlyGifImageView = [[UIImageView alloc] init];
        NSURL *localUrl1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]];
        self.onlyGifImageView= [AnimatedGif getAnimationForGifAtUrl:localUrl1];
        self.onlyGifImageView.hidden = YES;
        [self addSubview:self.onlyGifImageView];
        self.onlyGifImageView.sd_layout
        .centerXEqualToView(self)
        .centerYEqualToView(self)
        .widthIs(48)
        .heightEqualToWidth();
        
        
        
    }
    return self;
    
}

-(instancetype)initWithViewtext:(NSString *)text loadType:(LoadingStatus)type
{
    if (type == isBack) {
        
        float weight = [UIApplication sharedApplication].keyWindow.frame.size.width - 60;
        
        float height = [UIApplication sharedApplication].keyWindow.frame.size.height;
        
        CGRect selfBounds = CGRectMake(60, 0, weight, height);
        
        if ([self initWithFrame:selfBounds]) {
            
            self.lable.text = text;
            
            self.bgView.sd_layout
            .leftSpaceToView(self,(self.frame.size.width-250-60)/2)
            .widthIs(250);
            [self.bgView updateLayout];
            
        }
 
    }else{
        
        if ([self initWithFrame:[UIApplication sharedApplication].keyWindow.bounds]) {
            
            self.lable.text = text;
            if (type == onlyGif) {
                self.bgView.hidden =YES;
                self.onlyGifImageView.hidden = NO;
            }
        }
   
    }
    
    return self;
    
}

+(void)showNotificationViewWithText:(NSString *)text loadType:(LoadingStatus)type;
{
    
    YSKJ_CanvasLoading *view = [[YSKJ_CanvasLoading alloc] initWithViewtext:text loadType:type];
    view.tag = 2017;
   // view.backgroundColor = [[UIColor greenColor]colorWithAlphaComponent:0.3];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
}


@end
