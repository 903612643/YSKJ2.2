//
//  YSKJ_MyPerformanceView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_SalesReportView.h"


#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_SalesReportView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        saleKlineView = [[YSKJ_SaleKlineView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height -181)];
        saleKlineView.TimeLineBgColor = [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:1];   //设置时间轴颜色
        saleKlineView.moneyLineBgColor= [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:1];
        saleKlineView.backgroundColor = [UIColor whiteColor];
        saleKlineView.kLineBgColor = UIColorFromHex(0xf39800);        //设置k线的颜色
        [self addSubview:saleKlineView];
        
        
        
    }
    return self;
}

-(void)setArray:(NSArray *)array
{
    _array = array;
    
    //计算间距
    if (array.count<=31) {    //默认显示一个月,判断是否够一个月数据(实际31个点)
        
        saleKlineView.pointDistance = saleKlineView.dragScrollView.frame.size.width/array.count;
        
    }else{
        
        saleKlineView.pointDistance = saleKlineView.dragScrollView.frame.size.width/31;  //默认间距;
    }
    
    saleKlineView.klineDataArr = array;
    
}

@end
