//
//  YSKJ_UpdateVersionView.m
//  YSKJ
//
//  Created by YSKJ on 17/6/15.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_UpdateVersionView.h"

@implementation YSKJ_UpdateVersionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        UIView *tipView=[[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-300)/2, (self.frame.size.height-130)/2, 300, 130)];
        tipView.backgroundColor=[UIColor whiteColor];
        tipView.layer.cornerRadius=16;
        tipView.layer.masksToBounds=YES;
        [self addSubview:tipView];
      
        UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, tipView.frame.size.width, 20)];
        title.text=@"更新提示";
        title.font=[UIFont systemFontOfSize:18 weight:1.8];
        title.textAlignment=NSTextAlignmentCenter;
        [tipView addSubview:title];
        
        self.context=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, tipView.frame.size.width, 20)];
        self.context.text=[NSString stringWithFormat:@"发现新版本，去更新版本吧！"];
        self.context.font=[UIFont systemFontOfSize:14];
        self.context.textAlignment=NSTextAlignmentCenter;
        [tipView addSubview:self.context];
        
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 80, 300, 1)];
        lineView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        [tipView addSubview:lineView];
        
        self.updateButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 80, 300, 50)];
        [self.updateButton setTitle:@"立即更新" forState:UIControlStateNormal];
        [self.updateButton setTitleColor:[UIColor colorWithRed:36/255.0 green:153/255.0 blue:241/255.0 alpha:1] forState:UIControlStateNormal];
        [tipView addSubview:self.updateButton];
    
    }
    
    return self;
}

-(void)setVersionStr:(NSString *)versionStr
{
    _versionStr = versionStr;
    
    self.context.text=[NSString stringWithFormat:@"发现新版本%@，去更新版本吧！",versionStr];
    
}

@end
