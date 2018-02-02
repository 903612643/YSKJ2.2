//
//  YSKJ_MyPerformanceView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/21.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_YMoneyLableView.h"

#import "YSKJ_XTimeLableView.h"

@interface YSKJ_SaleKlineView : UIView<UIScrollViewDelegate>
{
    YSKJ_YMoneyLableView *ylineView ;
    YSKJ_XTimeLableView  *xlineView;
    CAShapeLayer *horizontal;
    CAShapeLayer *Vertical;
    
}
@property (nonatomic, strong)CAShapeLayer *shapelayer;

@property (nonatomic, strong)UIScrollView *dragScrollView;

@property (nonatomic, strong)UIButton *nodePoint;

//十字架
@property (nonatomic, strong)UIView *HorizontalLine;
@property (nonatomic, strong)UIView *VerticalLine;
@property (nonatomic, strong)UILabel *moneyText;
@property (nonatomic, strong)UILabel *timeText;

@property (nonatomic, strong)UIView *dataLine1;
@property (nonatomic, strong)UIView *dataLine2;
@property (nonatomic, strong)UIView *dataLine3;
@property (nonatomic, strong)UIView *dataLine4;

@property (nonatomic, strong)UIView *TimeLine1;
@property (nonatomic, strong)UIView *TimeLine2;
@property (nonatomic, strong)UIView *TimeLine3;
@property (nonatomic, strong)UIView *TimeLine4;

@property (nonatomic,assign) float timeLine1X;
@property (nonatomic,assign) float timeLine2X;
@property (nonatomic,assign) float timeLine3X;
@property (nonatomic,assign) float timeLine4X;

@property (nonatomic,copy) NSString* timeLable1Xtext;
@property (nonatomic,copy) NSString* timeLable2Xtext;
@property (nonatomic,copy) NSString* timeLable3Xtext;
@property (nonatomic,copy) NSString* timeLable4Xtext;

@property (nonatomic,copy) NSArray* klineDataArr;    //K线数据

@property (nonatomic,assign) float pointDistance;   //点的间距

@property (nonatomic, copy)UIColor *TimeLineBgColor;  //时间轴线颜色

@property (nonatomic, copy)UIColor *moneyLineBgColor; //日期轴线颜色

@property (nonatomic, copy)UIColor *kLineBgColor; //k线的颜色


@end
