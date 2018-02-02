//
//  YSKJ_AdduploadProdctView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/1.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_AdduploadProdctView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_AdduploadProdctView


-(id)initWithFrame:(CGRect)frame
{
    
    if (self == [super initWithFrame:frame])
    {
        self.title=[[UILabel alloc] initWithFrame:CGRectMake(10, 33, self.frame.size.width-40, 20)];
        self.title.textColor=UIColorFromHex(0x333333);
        self.title.font=[UIFont systemFontOfSize:14];
        [self addSubview:self.title];
        
        self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 60, 60)];
        self.loadingView.hidden = YES;
        [self addSubview:self.loadingView];
        
        UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] init];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        indicatorView.transform = transform;
        indicatorView.color = [UIColor grayColor];
        [self.loadingView addSubview:indicatorView];
        [indicatorView startAnimating];
        
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 70, self.frame.size.width-40, 20)];
        self.progressView.progressTintColor=[UIColor orangeColor];
        self.progressView.trackTintColor =[UIColor colorWithRed:251/255.0 green:250/255.0 blue:249/255.0 alpha:1.0];
        self.progressView.progress=0;
        self.progressView.progressViewStyle=UIProgressViewStyleDefault;
        [self addSubview:self.progressView];
        
        self.progressLable=[[UILabel alloc] initWithFrame:CGRectMake(0, 50, 0, 20)];
        self.progressLable.font=[UIFont systemFontOfSize:14];
        self.progressLable.textColor=UIColorFromHex(0x333333);
        self.progressLable.textAlignment=NSTextAlignmentRight;
        [self addSubview:self.progressLable];
    
        self.loadData = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-72, 30, 32, 32)];
        [self.loadData setImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
        [self addSubview:self.loadData];

    }
    return self;
}

-(void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    self.title.text = titleStr;
}

-(void)setProgressValues:(float)progressValues
{
    _progressValues = progressValues;
    self.progressView.progress = progressValues;
}

-(void)setProgressTitle:(NSString *)progressTitle
{
    _progressTitle = progressTitle;
    self.progressLable.text = progressTitle;
}


@end
