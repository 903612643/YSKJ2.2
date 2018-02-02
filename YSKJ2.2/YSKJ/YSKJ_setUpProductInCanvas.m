//
//  YSKJ_setUpProductInCanvas.m
//  YSKJ
//
//  Created by YSKJ on 17/6/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_setUpProductInCanvas.h"

#import "YSKJ_CanvasParamModel.h"

#import <MJExtension/MJExtension.h>

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

@implementation YSKJ_setUpProductInCanvas

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame withDict:(NSDictionary *)dict
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        YSKJ_CanvasParamModel *model = [YSKJ_CanvasParamModel mj_objectWithKeyValues:dict];
        
        self.frame = CGRectMake([model.x floatValue], [model.y floatValue], [model.w floatValue], [model.h floatValue]);
        
        self.adjustsImageWhenHighlighted = NO;
        
        if (![model.rotate isEqualToString:@"nan"]) {
            
            self.transform = CGAffineTransformRotate(self.transform, [model.rotate floatValue]);
            
        }
        //是否镜像
        if ([model.mirror isEqualToString:@"1"]) {
            
            self.imageView.transform = CGAffineTransformMakeScale(-1, 1);
            
        }
        
        
        if ([model.lockState isEqualToString:@"YES"]) {
            self.gestureRecognizers=nil;
        }


    }
    
    return self;
    
}


@end
