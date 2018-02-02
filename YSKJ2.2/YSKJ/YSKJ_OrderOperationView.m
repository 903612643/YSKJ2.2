//
//  YSKJ_OrderOperationView.m
//  YSKJ
//
//  Created by YSKJ on 17/9/12.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderOperationView.h"

#import "HttpRequestCalss.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define UPDATEORDER  @"http://"API_DOMAIN@"/project/editproject"  //离线商品数据

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderOperationView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        
        
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 480)/2, 224, 480, 200)];
        centerView.backgroundColor = [UIColor whiteColor];
        centerView.layer.cornerRadius = 4;
        centerView.layer.masksToBounds = YES;
        [self addSubview:centerView];
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, centerView.frame.size.width, 28)];
        self.titleLab.textAlignment =NSTextAlignmentCenter;
        self.titleLab.font = [UIFont systemFontOfSize:20];
        self.titleLab.textColor = [UIColor blackColor];
        [centerView addSubview:self.titleLab];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(80, 74, centerView.frame.size.width - 160, 44)];
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.layer.borderColor = UIColorFromHex(0x969696).CGColor;
        self.textField.layer.borderWidth = 1;
        [centerView addSubview:self.textField];
        
        self.cancleBut = [[UIButton alloc] initWithFrame:CGRectMake(42, 128, 128, 44)];
        [self.cancleBut setTitle:@"取消" forState:UIControlStateNormal];
        self.cancleBut.titleLabel.font = [UIFont systemFontOfSize:14];
        UIColor *titlCol = UIColorFromHex(0x999999);
        [self.cancleBut addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [self.cancleBut setTitleColor:titlCol forState:UIControlStateNormal];
        [centerView addSubview:self.cancleBut];
        
        self.sureBut = [[UIButton alloc] initWithFrame:CGRectMake(centerView.frame.size.width - (128+42), 128, 128, 44)];
        [self.sureBut setTitle:@"确定" forState:UIControlStateNormal];
        self.sureBut.titleLabel.font = [UIFont systemFontOfSize:14];
        UIColor *titlCol1 = UIColorFromHex(0xf39800);
        self.sureBut.layer.cornerRadius = 4;
        self.sureBut.layer.masksToBounds = YES;
        [self.sureBut addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        self.sureBut.backgroundColor = titlCol1;
        [self.sureBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [centerView addSubview:self.sureBut];
        
        
    }
    
    return self;
}

-(instancetype)initWithText:(NSString*)text
{
    
    if ([self initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height)]) {
        
        self.titleLab.text = text;
        
    }
    return self;
}

+(void)operationOrderWithText:(NSString*)text type:(orderType)type projectId:(NSString*)projectId filishBlock:(filishBlock)block;
{
    YSKJ_OrderOperationView *order = [[YSKJ_OrderOperationView alloc] initWithText:text];
    order.titleLab.text = text;

    order.status = type;
    
    order.projectId = projectId;
    
    order.block = block;
    
    [[UIApplication sharedApplication].keyWindow addSubview:order];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        order.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
        
    }];
    
}

-(void)cancleAction
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
}

-(void)sureAction
{
    NSDictionary *param;
    
    if (self.status == CustomerLoss) {
        
       param=@{
                @"id":self.projectId,
                @"status":@"客户流失"
                };
        
    }else if (self.status == StageOfSuccess){
        
        param=@{
                @"id":self.projectId,
                @"status":@"成功销售"
                };
    }else if (self.status == PayInAdvance)
    {
        param=@{
                @"id":self.projectId,
                @"status":@"已收定金",
                @"price":self.textField.text
                };
    }else if (self.status == PayTheFirst)
    {
        param=@{
                @"id":self.projectId,
                @"status":@"已收首款",
                @"price":self.textField.text
                };
    }else if (self.status == PayTheBalancePayment)
    {
        param=@{
                @"id":self.projectId,
                @"status":@"已收尾款",
                @"price":self.textField.text
                };
    }
    NSLog(@"param=%@",param);
    
    //请求后台数据
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    [httpRequest postHttpDataWithParam:param url:UPDATEORDER  success:^(NSDictionary *dict, BOOL success) {
        
        NSLog(@"dict=%@",dict);
        
        if (self.block) {
            self.block();
        }
        
        [self cancleAction];
        
    } fail:^(NSError *error) {
        
    }];

    
}

-(void)setStatus:(orderType)status
{
    _status = status;
    if (status == CustomerLoss || status == StageOfSuccess) {
        self.textField.hidden = YES;
    }else{
        self.textField.hidden = NO;
    }
}

@end
