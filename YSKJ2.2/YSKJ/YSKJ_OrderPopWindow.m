//
//  YSKJ_OrderPopWindow.m
//  YSKJ
//
//  Created by YSKJ on 17/7/27.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderPopWindow.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderPopWindow

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.popView = [[UIView alloc] initWithFrame:CGRectMake(584, 64, self.frame.size.width-580-10,[UIScreen mainScreen].bounds.size.height-508-80)];
        [self addSubview:self.popView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.popView.bounds];
        imageView.image = [UIImage imageNamed:@"popWindow"];
        [self.popView addSubview:imageView];
        
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, 120, 32)];
        titleLable.text = @"文件网络路径：";
        titleLable.font = [UIFont systemFontOfSize:14];
        titleLable.textColor = UIColorFromHex(0x666666);
        [self.popView addSubview:titleLable];
        
        self.urlText = [[UITextField alloc] initWithFrame:CGRectMake(124, 40, self.popView.frame.size.width - 124 -56, 32)];
        self.urlText.borderStyle = UITextBorderStyleNone;
        self.urlText.layer.borderColor = UIColorFromHex(0x969696).CGColor;
        self.urlText.layer.borderWidth = 1;
        self.urlText.textColor = UIColorFromHex(0x030303);
        self.urlText.font = [UIFont systemFontOfSize:12];
        [self.popView addSubview:self.urlText];
        
        
        NSArray *title = @[@"复制",@"用浏览器打开"];
        
        for (int i = 0 ; i<title.count; i++) {
            UIButton *button = [UIButton new];
            [button setTitle:title[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.layer.cornerRadius = 4;
            button.tag = 1000+i;
            button.layer.masksToBounds = YES;
            button.backgroundColor = UIColorFromHex(0xf39800);
            [self.popView addSubview:button];
            button.sd_layout
            .leftSpaceToView(self.popView,60*(i+1)+128*i)
            .widthIs(128)
            .heightIs(44)
            .bottomSpaceToView(self.popView,20);
            
        }
        
    }
    return self;
    
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    self.urlText.text = url;
}

@end
