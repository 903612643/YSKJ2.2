//
//  YSKJ_TitleView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_TitleView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]


@implementation YSKJ_TitleView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        NSArray *items=@[@"销售日报",@"目标数据"];
        UISegmentedControl *seg=[[UISegmentedControl alloc] initWithItems:items];
        seg.selectedSegmentIndex = 0;
        [seg addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
        seg.tintColor=UIColorFromHex(0xf39800);
        [self addSubview:seg];
        seg.sd_layout
        .leftSpaceToView(self,(self.size.width-200)/2)
        .widthIs(200)
        .heightIs(34)
        .topSpaceToView(self,(self.frame.size.height-34)/2);
        
    }
    
    return self;
    
}

-(void)segmentedChanged:(UISegmentedControl *)seg
{

    if (self.indexBlock) {
        self.indexBlock(seg.selectedSegmentIndex);
    }
  
    self.selectIndex = seg.selectedSegmentIndex;
    
}


@end
