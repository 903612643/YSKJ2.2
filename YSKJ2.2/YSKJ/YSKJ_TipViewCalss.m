//
//  YSKJ_TipView.m
//  YSKJ
//
//  Created by YSKJ on 16/12/23.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_TipViewCalss.h"
#import <SDAutoLayout/UIView+SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_TipViewCalss

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    if (self) {
        
        self.tipLable=[UILabel new];
        self.tipLable.font=[UIFont systemFontOfSize:20];
        self.tipLable.backgroundColor=UIColorFromHex(0x666666);
        self.tipLable.textColor=UIColorFromHex(0xffffff);
        [self addSubview:self.tipLable];
        self.tipLable.sd_layout
        .centerXEqualToView(self.tipLable.superview)
        .centerYEqualToView(self.tipLable.superview)
        .heightIs(1)
        .widthIs(1);
        
        self.bgLable=[UILabel new];
        self.bgLable.layer.cornerRadius=6;
        self.bgLable.layer.masksToBounds=YES;
        self.bgLable.backgroundColor=UIColorFromHex(0x666666);
        [self addSubview:_bgLable];
        self.bgLable.sd_layout
        .centerXEqualToView(self.bgLable.superview)
        .centerYEqualToView(self.bgLable.superview)
        .heightIs(1)
        .widthIs(1);
        
        [self bringSubviewToFront:self.tipLable];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.alpha=0.4;
    
            [self performSelector:@selector(dissActionremo) withObject:self afterDelay:0.2];

        });
    
    }
    return self;
}

-(void)dissActionremo
{
    [self removeFromSuperview];
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.tipLable.text=title;
    
    NSDictionary *attribute = @{NSFontAttributeName: self.tipLable.font};
    CGSize labelsize  = [title boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    self.tipLable.sd_layout
    .heightIs(labelsize.height)
    .widthIs(labelsize.width);
    [self.tipLable updateLayout];
    self.bgLable.sd_layout
    .heightIs(labelsize.height+40)
    .widthIs(labelsize.width+40);
    [self.tipLable updateLayout];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
}


@end
