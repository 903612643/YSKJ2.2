//
//  YSKJ_OrderNaviBarView.m
//  YSKJ
//
//  Created by YSKJ on 17/9/11.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderNaviBarView.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderNaviBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.titeleArray = @[@"全部",@"意向确认",@"已收定金",@"成功销售"];
        
        for (int i=0; i<self.titeleArray.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-60*4)/5*(i+1) + 60*i, 0, 60, self.frame.size.height)];
            [button setTitle:self.titeleArray[i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.tag = 100+i;
            [button addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
            UIColor *titleC =  UIColorFromHex(0x666666);
            [button setTitleColor:titleC forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:button];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-button.frame.size.width*4)/5*(i+1) + 60*i, self.frame.size.height, button.frame.size.width, 1)];
            line.tag = 200+i;
            [self addSubview:line];
            
            if (i==0) {
                [self choose:button];
            }
            
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height + 1, self.frame.size.width, 1)];
        line.backgroundColor = UIColorFromHex(0xefefef);
        [self addSubview:line];

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

@end
