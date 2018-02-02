//
//  YSKJ_OrderDoneViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/7/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDoneViewController.h"

#import "YSKJ_OrderDoneView.h"

#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径

#import <SDAutoLayout/SDAutoLayout.h>

#import "YSKJ_OrderDetaileViewController.h"

#import "YSKJ_TipViewCalss.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#import "YSKJ_OrderPopWindow.h"


@interface YSKJ_OrderDoneViewController ()<UITextFieldDelegate>
{
    
    YSKJ_OrderPopWindow *_popViewWindow;
}

@end

@implementation YSKJ_OrderDoneViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订单完成";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromHex(0xd7dee4);
    
    UIButton *buttonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [buttonItem addTarget:self action:@selector(dissmissAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:[UIImage imageNamed:@"direction"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem];
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 14;
    
    UIButton *buttontitle=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,40, 40)];
    UIColor *titlecol=UIColorFromHex(0x666666);
    [buttontitle setTitleColor:titlecol forState:UIControlStateNormal];
    [buttontitle addTarget:self action:@selector(dissmissAction) forControlEvents:UIControlEventTouchUpInside];
    [buttontitle setTitle:@"返回" forState:UIControlStateNormal];
    UIBarButtonItem *titeitem = [[UIBarButtonItem alloc]initWithCustomView:buttontitle];
    self.navigationItem.leftBarButtonItems=@[leftItem,fixedSpaceBarButtonItem,titeitem];
    
    UIButton *orderItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [orderItem addTarget:self action:@selector(showPopViewAction) forControlEvents:UIControlEventTouchUpInside];
    [orderItem setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:orderItem];
    UIButton *ordertitle=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,60, 18)];
    UIColor *ordertitlecol=UIColorFromHex(0xf32a00);
    [ordertitle setTitleColor:ordertitlecol forState:UIControlStateNormal];
    [ordertitle addTarget:self action:@selector(showPopViewAction) forControlEvents:UIControlEventTouchUpInside];
    [ordertitle setTitle:@"订货单" forState:UIControlStateNormal];
    UIBarButtonItem *rigthtitleItem = [[UIBarButtonItem alloc]initWithCustomView:ordertitle];
    self.navigationItem.rightBarButtonItems=@[rigthtitleItem,rightItem];
    
    NSArray *titleA = @[@"商品原价：",@"商品折扣：",@"优惠价格："];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    float totailePrice =0.0;
    
    for (int i=0; i<self.orderArray.count; i++) {
        
        NSString *priceStr = [NSString stringWithFormat:@"%0.2f",[self.orderArray[i] floatValue]];
        NSString *titleAStr = titleA[i];
        NSString *tempStr = [NSString stringWithFormat:@"%@%@",titleAStr,priceStr];
        [tempArray addObject:tempStr];
        
        totailePrice = totailePrice + [self.orderArray[i] floatValue];
        
    }
    [tempArray addObject:[NSString stringWithFormat:@"应付总额：%0.2f",totailePrice]];

    YSKJ_OrderDoneView *done = [[YSKJ_OrderDoneView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) priceArray:tempArray];
    done.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:done];
    
    [done.selectOrder addTarget:self action:@selector(selectOrderAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
}
-(void)popdismiss
{

    [UIView animateWithDuration:0.4 animations:^{
        
        _popViewWindow.alpha = 0.01;
        _popViewWindow.popView.alpha = 0.01;
        
    } completion:^(BOOL finished) {
        
        [_popViewWindow removeFromSuperview];
        
    }];
    
    
}
-(void)showPopViewAction
{
    
    _popViewWindow = [[YSKJ_OrderPopWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _popViewWindow.alpha = 0.1;
    _popViewWindow.popView.alpha = 0.1;
    _popViewWindow.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    _popViewWindow.urlText.text = [NSString stringWithFormat:@"  %@%@",SPACEBGURL,self.key];
    [[UIApplication sharedApplication].keyWindow addSubview:_popViewWindow];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _popViewWindow.alpha = 1;
        _popViewWindow.popView.alpha = 1;
        
    }];
    //添加手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popdismiss)];
    [_popViewWindow addGestureRecognizer:tap];
    
    
    for (UIView *subView in _popViewWindow.popView.subviews) {
        
        if ([subView isKindOfClass:[UIButton class]]) {
            
            [(UIButton*)subView addTarget:self action:@selector(copyUrlDown:) forControlEvents:UIControlEventTouchDown];

            [(UIButton*)subView addTarget:self action:@selector(copyUrlUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    
}
-(void)copyUrlDown:(UIButton *)sender
{
    sender.backgroundColor = UIColorFromHex(0xefefef);
    
}
-(void)copyUrlUpInside:(UIButton *)sender
{
    sender.backgroundColor = UIColorFromHex(0xf39800);
    
    if (sender.tag == 1000) {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@%@",SPACEBGURL,self.key];
        
        YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
        tip.title = @"复制成功！";
        
    
    }else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SPACEBGURL,self.key]]];
        NSLog(@"url=%@",[NSString stringWithFormat:@"%@%@",SPACEBGURL,self.key]);

    }
    
    [self popdismiss];
    
}

-(void)selectOrderAction
{
    YSKJ_OrderDetaileViewController *detail = [[YSKJ_OrderDetaileViewController alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
}

-(void)dissmissAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
