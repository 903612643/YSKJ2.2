//
//  YSKJ_NetStatusNotificationView.m
//  YSKJ
//
//  Created by YSKJ on 17/9/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_NetStatusNotificationView.h"

#define DEFAULT_DURATION 0.3f
#define DEFAULT_ANIMATON_DURATION 1.0f
#define DEFAULT_HEIGHT 64.0f

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_NetStatusNotificationView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.lable.textAlignment = NSTextAlignmentCenter;
        self.lable.textColor = UIColorFromHex(0xffffff);
        self.lable.backgroundColor = UIColorFromHex(0xfd6b6b);
        [self addSubview:self.lable];
        
    }
    return self;
    
}

-(instancetype)initWithViewtext:(NSString *)text
{
    if ([self initWithFrame:CGRectMake(0, -DEFAULT_HEIGHT, [UIApplication sharedApplication].keyWindow.frame.size.width, DEFAULT_HEIGHT)]) {

        self.lable.text = text;
        
    }
    return self;
}

+(void)showNotificationViewWithText:(NSString *)text
{
    YSKJ_NetStatusNotificationView *view = [[YSKJ_NetStatusNotificationView alloc] initWithViewtext:text];
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
 
    [view showAnimation:YES originY:0];
    
}

-(void)dissMissAnimation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DEFAULT_ANIMATON_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self showAnimation:NO originY:-DEFAULT_HEIGHT];
        
    });
}

-(void)showAnimation:(BOOL)Yes originY:(float)originY
{
    CGRect frame = self.frame;
    
    frame.origin.y = originY;
    
    [UIView animateWithDuration:DEFAULT_DURATION animations:^{
        
        self.frame = frame;
        
    }completion:^(BOOL finished) {
        
        if (Yes == YES) {
            
            [self dissMissAnimation];
            
        }else{
            
            [self removeFromSuperview];
        }
        
    }];
}

@end
