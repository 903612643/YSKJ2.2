//
//  YSKJ_MyPerformanceView.m
//  YSKJ
//
//  Created by YSKJ on 17/8/21.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_SaleKlineView.h"

#import "YSKJ_TipViewCalss.h"

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_SaleKlineView

#define SCROLLVIEWWEI THEWIDTH-(62+40)-263   //显示的折线图的宽度

#define SCROLLVIEWHEI 300   //显示折线图的高度

#define LEFTINVIEWPX 62     //显示折线图离左边边距

#define LOCALINVIEWTOP 70  //折线图距离self的高

#define RADIUS 3           //坐标点的半径


-(id)initWithFrame:(CGRect)frame
{
    //1：用scrollView做底层模版，一次性加载全部数据，滑动，缩放改变contentsize计算相应的显示比例，刷新数据，这样做不损耗app的性能。
    //2.缩小：缩到最小显示全部数据
    //3：放大：最多显示7天
    //4：默认显示最新一个月时间
    //5：云尚默认从20170801开始记录数据
    
    if (self == [super initWithFrame:frame]) {
        
        [self initScrollView];
        
        ylineView = [[YSKJ_YMoneyLableView alloc] initWithFrame:CGRectMake(0, LOCALINVIEWTOP -5.5 , LEFTINVIEWPX, self.dragScrollView.frame.size.height+11)];
        [self addSubview:ylineView];
        
        xlineView= [[YSKJ_XTimeLableView alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x, LOCALINVIEWTOP + self.dragScrollView.frame.size.height, self.dragScrollView.frame.size.width, 30)];
        [self addSubview:xlineView];
        
        [self initMoneyLine];
        
        [self initTimeLineView];
        
        [self initShapelayer];
        
        [self initCorssLine];
    
    }

    return self;
}

#pragma mark vertical HorizontalLine  lines

-(void)initCorssLine
{
    self.HorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x, self.dragScrollView.frame.origin.y, self.dragScrollView.frame.size.width, 1)];
    [self addSubview:self.HorizontalLine];
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    //开始点 从上左下右的点
    [aPath moveToPoint:CGPointMake(0,0)];
    [aPath addLineToPoint:CGPointMake(self.HorizontalLine.frame.size.width, 0)];
    horizontal = [[CAShapeLayer alloc] init];
    horizontal.strokeColor = [UIColor clearColor].CGColor;
    horizontal.fillColor=nil;
    horizontal.path = aPath.CGPath;
    [horizontal setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:4],
      [NSNumber numberWithInt:4],nil]];
    horizontal.lineWidth=1.0f;
    [self.HorizontalLine.layer addSublayer:horizontal];
    
    self.VerticalLine = [[UIView alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x, LOCALINVIEWTOP, 1, self.dragScrollView.frame.size.width)];
    [self addSubview:self.VerticalLine];
    UIBezierPath *aPath1 = [UIBezierPath bezierPath];
    //开始点 从上左下右的点
    [aPath1 moveToPoint:CGPointMake(0,0)];
    [aPath1 addLineToPoint:CGPointMake(0,self.dragScrollView.frame.size.height)];
    Vertical = [[CAShapeLayer alloc] init];
    Vertical.strokeColor = [UIColor clearColor].CGColor;
    Vertical.fillColor=nil;
    Vertical.path = aPath1.CGPath;
    [Vertical setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:4],
      [NSNumber numberWithInt:4],nil]];
    Vertical.lineWidth=1.0f;
    [self.VerticalLine.layer addSublayer:Vertical];
    
    self.moneyText = [[UILabel alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x - 50, LOCALINVIEWTOP, 70, 14)];
    self.moneyText.textColor = [UIColor whiteColor];
    self.moneyText.font = [UIFont systemFontOfSize:11];
    self.moneyText.textAlignment = NSTextAlignmentRight;
    self.moneyText.hidden =YES;
    self.moneyText.backgroundColor = UIColorFromHex(0x494949);
    [self addSubview:self.moneyText];
    
    self.timeText = [[UILabel alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x , LOCALINVIEWTOP+self.dragScrollView.frame.size.height + 10,70, 14)];
    self.timeText.textColor = [UIColor whiteColor];
    self.timeText.textAlignment = NSTextAlignmentCenter;
    self.timeText.font = [UIFont systemFontOfSize:11];
    self.timeText.hidden = YES;
    self.timeText.backgroundColor = UIColorFromHex(0x494949);
    [self addSubview:self.timeText];

}

#pragma mark UILongPressGestureRecognizer

- (void)handleLongProDuctImage:(UILongPressGestureRecognizer*) longPressGestureReg
{
    CGPoint location = [longPressGestureReg locationInView:longPressGestureReg.view];
 
    //得到当前偏移量的数组下标
    int count = self.dragScrollView.contentOffset.x/(int)self.pointDistance ;
    
    NSMutableArray *getPointArr = [[NSMutableArray alloc] init];
    
    //得到显示的个数
    int showCount =  self.dragScrollView.frame.size.width/self.pointDistance;
    
    for (int i=0; i< self.klineDataArr.count; i++) {
        
        if (i >= count && i<= count+showCount+1) {
            
            [getPointArr addObject:self.klineDataArr[i]];
        }
    }
    
    NSNumber *max = [[self moneyArray:getPointArr] valueForKeyPath:@"@max.floatValue"];
    NSNumber *min = [[self moneyArray:getPointArr] valueForKeyPath:@"@min.floatValue"];
    
    float moneyDistance = [max floatValue] - [min floatValue];
    
    float per = moneyDistance/self.dragScrollView.frame.size.height;   //每个像素所占的金额
    
    if (per ==0) {
        per = 1;
    }
    
    int index = (location.x -  self.dragScrollView.contentOffset.x)/self.pointDistance;
    
    float temp = 0.0;
    
    if (index == 0) {
        
        temp = (count)*self.pointDistance;
        
    }else{
        temp = (count+1)*self.pointDistance;
    }
    
    if (index < getPointArr.count && index>=0) {
        
        NSDictionary *dict = getPointArr[index];
        [self.nodePoint removeFromSuperview];
        self.nodePoint =  [[UIButton alloc] initWithFrame:CGRectMake(self.dragScrollView.contentOffset.x+(temp - self.dragScrollView.contentOffset.x) + self.pointDistance*index - RADIUS, self.dragScrollView.frame.size.height-([[dict objectForKey:@"count"] floatValue] - [min floatValue])/per - RADIUS, RADIUS*2, RADIUS*2)];
        self.nodePoint.layer.cornerRadius = RADIUS;
        self.nodePoint.layer.masksToBounds = YES;
        [self.dragScrollView addSubview:self.nodePoint];
        
        CGRect rect=[self.nodePoint.superview convertRect:self.nodePoint.frame toView:self];
        
        self.HorizontalLine.frame = CGRectMake(self.dragScrollView.frame.origin.x, rect.origin.y + RADIUS, self.dragScrollView.frame.size.width, 1);
        self.VerticalLine.frame = CGRectMake(rect.origin.x + RADIUS, LOCALINVIEWTOP, 1, self.dragScrollView.frame.size.height);
        
        if (rect.origin.x >= self.dragScrollView.frame.origin.x - 10 && location.x <= self.dragScrollView.contentSize.width ) {
        
            horizontal.strokeColor = UIColorFromHex(0x666666).CGColor;
            Vertical.strokeColor = UIColorFromHex(0x666666).CGColor;
            self.timeText.hidden = NO;
            self.moneyText.hidden = NO;
            
            self.timeText.frame = CGRectMake(rect.origin.x - 35+3, LOCALINVIEWTOP + self.dragScrollView.frame.size.height + 18, 70, 14);
            self.timeText.text = [dict objectForKey:@"time"];
            
            self.moneyText.frame = CGRectMake(self.dragScrollView.frame.origin.x - 50, rect.origin.y -5, 50, 14);
            self.moneyText.text = [NSString stringWithFormat:@"%0.2f",[[dict objectForKey:@"count"] floatValue]];
            
            
        }else{
            horizontal.strokeColor = [UIColor clearColor].CGColor;
            Vertical.strokeColor = [UIColor clearColor].CGColor;
            self.timeText.hidden = YES;
            self.moneyText.hidden = YES;
        }
        
    }
    
    if (longPressGestureReg.state == UIGestureRecognizerStateEnded || longPressGestureReg.state==UIGestureRecognizerStateCancelled) {
        horizontal.strokeColor = [UIColor clearColor].CGColor;
        Vertical.strokeColor = [UIColor clearColor].CGColor;
        self.timeText.hidden = YES;
        self.moneyText.hidden = YES;
    }
   
    
}


#pragma mark initScrollView

-(void)initScrollView
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(12, 16, 100, 18)];
    lable.textColor = UIColorFromHex(0x666666);
    lable.font = [UIFont systemFontOfSize:13];
    lable.text = @"销售额：(元)";
    [self addSubview:lable];
    
    self.dragScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(62, LOCALINVIEWTOP, SCROLLVIEWWEI, SCROLLVIEWHEI)];
    // 设置内容大小
    self.dragScrollView.contentSize = CGSizeMake(self.dragScrollView.frame.size.width, self.dragScrollView.frame.size.height);
    self.dragScrollView.delegate = self;
    self.dragScrollView.showsVerticalScrollIndicator = FALSE;
    self.dragScrollView.showsHorizontalScrollIndicator = FALSE;
    // 是否反弹
    self.dragScrollView.bounces = NO;
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.dragScrollView addGestureRecognizer:pinchGestureRecognizer];
    [self addSubview:self.dragScrollView];
    
    //长按手势
    UILongPressGestureRecognizer *panRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [panRecognizer addTarget:self action:@selector(handleLongProDuctImage:)];
    [self.dragScrollView addGestureRecognizer:panRecognizer];
    
}
// 处理缩放手势
- (void)pinchView:(UIPinchGestureRecognizer *)pinch
{
    self.pointDistance = self.pointDistance*pinch.scale;
    
    if (pinch.scale >1) {  //放大操作
  
        if (self.pointDistance >= self.dragScrollView.frame.size.width/7) {
            self.pointDistance = self.dragScrollView.frame.size.width/7;
//            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
//            tip.title = @"已经放至最大";
            
        }else{
            
            self.dragScrollView.contentOffset = CGPointMake(self.dragScrollView.contentOffset.x*pinch.scale, self.dragScrollView.frame.size.height);
        }
           
    }else{        //缩小操作
        
        if (self.pointDistance <= self.dragScrollView.frame.size.width/self.klineDataArr.count) {
            self.pointDistance = self.dragScrollView.frame.size.width/self.klineDataArr.count;
//            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
//            tip.title = @"已经缩至最小";
     
        }
        if (self.dragScrollView.contentOffset.x*pinch.scale!=0) {
            self.dragScrollView.contentOffset = CGPointMake(self.dragScrollView.contentOffset.x*pinch.scale, self.dragScrollView.frame.size.height);
        }
        
    }

    [self dorwLine:self.klineDataArr];
    
    self.dragScrollView.contentSize = CGSizeMake(self.klineDataArr.count*self.pointDistance, self.dragScrollView.frame.size.height);
    
}

#pragma mark InitShapelayer

//初始化ShapeLayer

-(void)initShapelayer
{
    self.shapelayer = [[CAShapeLayer alloc] init];
    
    //2.利用x的偏移量计算此前的数组下标，重新画线。
    self.shapelayer.strokeColor = [UIColor colorWithRed:84/255.0 green:140/255.0 blue:239/255.0 alpha:1].CGColor;
    self.shapelayer.fillColor=nil;
}

-(void)setKLineBgColor:(UIColor *)kLineBgColor
{
    _kLineBgColor = kLineBgColor;
    self.shapelayer.strokeColor = kLineBgColor.CGColor;
}

#pragma mark InitMoneyLine

//初始化金额线
-(void)initMoneyLine
{
    for (int i = 0; i<4; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x, LOCALINVIEWTOP + (self.dragScrollView.frame.size.height)/3*i, self.dragScrollView.frame.size.width, 1)];
         view.backgroundColor = [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:1];
        [self addSubview:view];
        if (i==0) {
            self.dataLine1 = view;
        }else if (i==1){
            self.dataLine2 = view;
        }else if (i==2){
            self.dataLine3 = view;
        }else{
            self.dataLine4 = view;
        }
        
    }

}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self dorwLine:self.klineDataArr];
    
}

#pragma mark drowKline

//得到点数据
-(void)setKlineDataArr:(NSArray *)klineDataArr
{
    _klineDataArr = klineDataArr;
    
    //默认显示最新数据
    self.dragScrollView.contentOffset = CGPointMake(self.pointDistance*(self.klineDataArr.count+1), self.dragScrollView.frame.size.height);
    
    self.dragScrollView.contentSize = CGSizeMake(self.pointDistance*(self.klineDataArr.count+1), self.dragScrollView.frame.size.height);
    
    [self dorwLine:klineDataArr];
    
}

//得到点间距
-(void)setPointDistance:(float)pointDistance
{
    _pointDistance = pointDistance;
    
}

-(NSArray*)moneyArray:(NSArray*)getPointArr
{
    NSMutableArray *point = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in getPointArr) {
        [point addObject:[dict objectForKey:@"count"]];
    }
    return point;
}

-(void)dorwLine:(NSArray*)array
{
    //得到当前偏移量的数组下标
    int count = self.dragScrollView.contentOffset.x/(int)self.pointDistance ;
    
    count = (count==0)?count=1:count;
    
    
//    if (self.klineDataArr.count - count<30 && count<self.klineDataArr.count) {
//        
//       count = self.klineDataArr.count - 30;
//
//    }
    
    //获得当先显示的数组
    NSMutableArray *getPointArr = [[NSMutableArray alloc] init];
    
    //得到显示的个数
    int showCount =  self.dragScrollView.frame.size.width/self.pointDistance;
    
  //  NSLog(@" index =%d   klineDataArr=%lu ",count,(unsigned long)self.klineDataArr.count);
    
    for (int i=0; i< array.count; i++) {
        
        if (i >= count && i<= count+showCount+1) {
            
            [getPointArr addObject:array[i]];
        }
    }
    
    //1.计算最大最小值，确定y轴的金额区间。
    
    NSNumber *max = [[self moneyArray:getPointArr] valueForKeyPath:@"@max.floatValue"];
    NSNumber *min = [[self moneyArray:getPointArr] valueForKeyPath:@"@min.floatValue"];
    
    float moneyDistance = [max floatValue] - [min floatValue];
    
    float per = moneyDistance/self.dragScrollView.frame.size.height;   //每个像素所占的金额
    
    per = (per<=0)?per=1.0:per;  //分母不能为0
    
    ylineView.maxLableStr  = [NSString stringWithFormat:@"%0.2f",[max floatValue]];
    
    ylineView.minLableStr = [NSString stringWithFormat:@"%0.2f",[min floatValue]];
    
    ylineView.middleLable1Str = [NSString stringWithFormat:@"%0.2f",moneyDistance/3*2 + [min floatValue]];
    
    ylineView.middleLable2Str = [NSString stringWithFormat:@"%0.2f",moneyDistance/3*1 + [min floatValue]];
    
    for (UIView *subView in self.dragScrollView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    //得到k线路径
    self.shapelayer.path =[self getKlineUiPath:getPointArr  min:[min floatValue] per:per].CGPath;
    
    [self.dragScrollView.layer addSublayer:self.shapelayer];
    
    
    [self setLineToBack];
    
}
//把分割线放在底部
-(void)setLineToBack
{
    [self.dataLine1.superview sendSubviewToBack:self.dataLine1];
    [self.dataLine2.superview sendSubviewToBack:self.dataLine2];
    [self.dataLine3.superview sendSubviewToBack:self.dataLine3];
    [self.dataLine4.superview sendSubviewToBack:self.dataLine4];
    [self.TimeLine1.superview sendSubviewToBack:self.TimeLine1];
    [self.TimeLine2.superview sendSubviewToBack:self.TimeLine2];
    [self.TimeLine3.superview sendSubviewToBack:self.TimeLine3];
    [self.TimeLine4.superview sendSubviewToBack:self.TimeLine4];
}

//GetKlineUIPath
-(UIBezierPath*)getKlineUiPath:(NSArray *)klineData  min:(float)min per:(float)per
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    //得到当前偏移量的数组下标
    int count = self.dragScrollView.contentOffset.x/(int)self.pointDistance ;
    
    for (int i=0; i<klineData.count; i++) {
        
        NSDictionary *dcit = klineData[i];
        
        if (i==0) {
            
            [aPath moveToPoint:CGPointMake(self.dragScrollView.contentOffset.x+(count*self.pointDistance - self.dragScrollView.contentOffset.x),self.dragScrollView.frame.size.height-([[dcit objectForKey:@"count"] floatValue] - min)/per)];
            
        }else{
            
            [aPath addLineToPoint:CGPointMake(self.dragScrollView.contentOffset.x+((count+1)*self.pointDistance - self.dragScrollView.contentOffset.x) + self.pointDistance*i,self.dragScrollView.frame.size.height-([[dcit objectForKey:@"count"] floatValue] - min )/per)];
            
        }
        
        [self dorwPoint:klineData index:i];
        
    }
    
    return aPath;
}

//画小圆点
-(void)dorwPoint:(NSArray *)getPointArr index:(int)index
{
    int count = self.dragScrollView.contentOffset.x/(int)self.pointDistance ;
    
    NSNumber *max = [[self moneyArray:getPointArr] valueForKeyPath:@"@max.floatValue"];
    NSNumber *min = [[self moneyArray:getPointArr] valueForKeyPath:@"@min.floatValue"];
    
    float moneyDistance = [max floatValue] - [min floatValue];
    
    float per = moneyDistance/self.dragScrollView.frame.size.height;   //每个像素所占的金额
    
    if (per ==0) {
        per = 1;
    }
    
    float temp = 0.0;
    if (index == 0) {
        temp = (count)*self.pointDistance;
    }else{
        temp = (count+1)*self.pointDistance;
    }
    
    NSDictionary *dict = getPointArr[index];
    
     UIButton *pointButton= [[UIButton alloc] initWithFrame:CGRectMake(self.dragScrollView.contentOffset.x+(temp - self.dragScrollView.contentOffset.x) + self.pointDistance*index - RADIUS, self.dragScrollView.frame.size.height-([[dict objectForKey:@"count"] floatValue] - [min floatValue])/per - RADIUS, RADIUS*2, RADIUS*2)];
    pointButton.backgroundColor = [UIColor colorWithRed:84/255.0 green:140/255.0 blue:239/255.0 alpha:1];
    pointButton.tag = 1000+index;
    pointButton.layer.cornerRadius = RADIUS;
    pointButton.layer.masksToBounds = YES;
    pointButton.hidden = YES;
    [self.dragScrollView addSubview:pointButton];
    
    CGRect rect=[pointButton.superview convertRect:pointButton.frame toView:self];
    
    if (rect.origin.x - self.dragScrollView.frame.origin.x + RADIUS>1 && index==1) {
        
        int j = getPointArr.count/4;
        
        self.timeLine1X = self.dragScrollView.frame.origin.x + (rect.origin.x - self.dragScrollView.frame.origin.x + RADIUS);
        
        self.timeLable1Xtext = [getPointArr[index] objectForKey:@"time"];
        
        self.timeLine2X =  self.timeLine1X + self.pointDistance*j;
        
        self.timeLable2Xtext = [getPointArr[index+j] objectForKey:@"time"];
        
        self.timeLine3X =  self.timeLine2X + self.pointDistance*j;
        
        self.timeLable3Xtext = [getPointArr[index+j*2] objectForKey:@"time"];
        
        self.timeLine4X =  self.timeLine3X + self.pointDistance*j;
        
        //防止数组越界
        if (getPointArr.count>index+j*3) {
            
            self.timeLable4Xtext = [getPointArr[index+j*3] objectForKey:@"time"];

        }
        
    }
    
}


#pragma mark timeLine

-(void)initTimeLineView
{
    for (int i=0; i<4; i++) {
        UIView *timeLine = [[UIView alloc] initWithFrame:CGRectMake(self.dragScrollView.frame.origin.x, self.dragScrollView.frame.origin.y, 1, self.dragScrollView.frame.size.height)];
        [self addSubview:timeLine];
        if (i==0) {
            self.TimeLine1 = timeLine;
        }else if (i==1)
        {
            self.TimeLine2 = timeLine;
        }else if (i==2)
        {
            self.TimeLine3 = timeLine;
        }else{
            self.TimeLine4 = timeLine;
        }

    }
    
}
//设置时间轴的颜色

-(void)setTimeLineBgColor:(UIColor *)TimeLineBgColor
{
    _TimeLineBgColor =TimeLineBgColor;
    self.TimeLine1.backgroundColor = TimeLineBgColor;
    self.TimeLine2.backgroundColor = TimeLineBgColor;
    self.TimeLine3.backgroundColor = TimeLineBgColor;
    self.TimeLine4.backgroundColor = TimeLineBgColor;

}

//设置横线颜色（金额线）
-(void)setMoneyLineBgColor:(UIColor *)moneyLineBgColor
{
    _moneyLineBgColor = moneyLineBgColor;
    self.dataLine1.backgroundColor = moneyLineBgColor;
    self.dataLine2.backgroundColor = moneyLineBgColor;
    self.dataLine3.backgroundColor = moneyLineBgColor;
    self.dataLine4.backgroundColor = moneyLineBgColor;
}

//改变第1条线的x轴
-(void)setTimeLine1X:(float)timeLine1X
{
    _timeLine1X = timeLine1X;
    
    self.TimeLine1.frame = CGRectMake(timeLine1X, self.dragScrollView.frame.origin.y, 1, self.dragScrollView.frame.size.height);
    
    xlineView.timeLable1X = timeLine1X - self.dragScrollView.frame.origin.x;
    
}

//改变第2条线的x轴
-(void)setTimeLine2X:(float)timeLine2X
{
    _timeLine2X = timeLine2X;
    
    self.TimeLine2.frame = CGRectMake(timeLine2X, self.dragScrollView.frame.origin.y, 1, self.dragScrollView.frame.size.height);
    
    xlineView.timeLable2X = timeLine2X - self.dragScrollView.frame.origin.x;
    
}

//改变第3条线的x轴
-(void)setTimeLine3X:(float)timeLine3X
{
    _timeLine3X = timeLine3X;
    
    self.TimeLine3.frame = CGRectMake(timeLine3X, self.dragScrollView.frame.origin.y, 1, self.dragScrollView.frame.size.height);
    
    xlineView.timeLable3X = timeLine3X - self.dragScrollView.frame.origin.x;
    
}

//改变第4条线的x轴
-(void)setTimeLine4X:(float)timeLine4X
{
    _timeLine4X = timeLine4X;
    
    self.TimeLine4.frame = CGRectMake(timeLine4X, self.dragScrollView.frame.origin.y, 1, self.dragScrollView.frame.size.height);
    
    if (timeLine4X > self.dragScrollView.frame.origin.x + self.dragScrollView.frame.size.width) {
        self.TimeLine4.hidden = YES;
    }else{
        self.TimeLine4.hidden = NO;
    }
    
    xlineView.timeLable4X = timeLine4X - self.dragScrollView.frame.origin.x;
    
}

#pragma mark set xlineViewlable text

-(void)setTimeLable1Xtext:(NSString *)timeLable1Xtext
{
    _timeLable1Xtext = timeLable1Xtext;
    xlineView.timeLable1Xtext = timeLable1Xtext;
}

-(void)setTimeLable2Xtext:(NSString *)timeLable2Xtext
{
    _timeLable2Xtext = timeLable2Xtext;
    xlineView.timeLable2Xtext = timeLable2Xtext;
}

-(void)setTimeLable3Xtext:(NSString *)timeLable3Xtext
{
    _timeLable3Xtext = timeLable3Xtext;
    xlineView.timeLable3Xtext = timeLable3Xtext;
}


-(void)setTimeLable4Xtext:(NSString *)timeLable4Xtext
{
    _timeLable4Xtext = timeLable4Xtext;
    xlineView.timeLable4Xtext = timeLable4Xtext;
}


@end
