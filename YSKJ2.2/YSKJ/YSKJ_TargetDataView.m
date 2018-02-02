//
//  YSKJ_TargetDataView.m
//  YSKJ
//
//  Created by YSKJ on 17/9/1.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_TargetDataView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_TargetDataView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.titeleArray = @[@"本月目标",@"季度目标",@"年度目标"];
        
        for (int i=0; i<self.titeleArray.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100+(self.frame.size.width-200-60*3)/2*i + 60*i, 0, 60, 44)];
            [button setTitle:self.titeleArray[i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.tag = 100+i;
            [button addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
            UIColor *titleC =  UIColorFromHex(0x666666);
            [button setTitleColor:titleC forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:button];

            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(100+(self.frame.size.width-200-button.frame.size.width*3)/2*i + 60*i, 44, button.frame.size.width, 1)];
            line.tag = 200+i;
            [self addSubview:line];
            
            if (i==0) {
                [self choose:button];
            }
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.frame.size.width, 10)];
        view.backgroundColor = UIColorFromHex(0xefefef);
        [self addSubview:view];
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 272, self.frame.size.width, 272)];
        view1.backgroundColor = UIColorFromHex(0xefefef);
        [self addSubview:view1];
        
        self.totalePrice = [[UILabel alloc] initWithFrame:CGRectMake(20, 263, 200, 20)];
        self.totalePrice.textColor = UIColorFromHex(0x666666);
        self.totalePrice.font = [UIFont systemFontOfSize:14];
        self.totalePrice.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.totalePrice];
        
        self.finishPrice = [[UILabel alloc] initWithFrame:CGRectMake(20, 291, 200, 20)];
        self.finishPrice.textColor = UIColorFromHex(0x666666);
        self.finishPrice.font = [UIFont systemFontOfSize:14];
        self.finishPrice.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.finishPrice];
        
    }
    
    return self;
}

- (void)choose:(UIButton *)sender{
    
    for (int i = 0; i < self.titeleArray.count; i++) {
        
        UIButton *btn = (UIButton *)[[sender superview] viewWithTag:100 + i];
        UIView *line = (UIView *)[[sender superview] viewWithTag:200 + i];
        //选中当前按钮时
        if (sender.tag == btn.tag) {
            
            UIColor *titleC =  UIColorFromHex(0xf39800);
            [btn setTitleColor:titleC forState:UIControlStateNormal];
            line.backgroundColor = UIColorFromHex(0xf39800);
            line.hidden = NO;
            sender.selected = !sender.selected;

        }else{
            
            UIColor *titleC =  UIColorFromHex(0x666666);
            [btn setTitleColor:titleC forState:UIControlStateNormal];
            line.backgroundColor = UIColorFromHex(0x666666);
            line.hidden = YES;
            [btn setSelected:NO];
        }
    }
    if (self.selectBlock) {
        self.selectBlock(sender.tag - 100);
    }
    
}

-(void)setTotalePriceStr:(NSString *)totalePriceStr
{
    _totalePriceStr = totalePriceStr;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:totalePriceStr]; // 改变
    //种类的属性
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,7)];

    self.totalePrice.attributedText=attributedString;
    
}

-(void)setFinishPriceStr:(NSString *)finishPriceStr
{
    _finishPriceStr = finishPriceStr;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:finishPriceStr]; // 改变
    //种类的属性
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,7)];
    
    self.finishPrice.attributedText=attributedString;
    
}

@end
