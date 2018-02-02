//
//  YSKJ_OrderProjectDetailViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/7/28.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderProjectDetailViewController.h"

#import "YSKJ_OrderProDuctTableViewCell.h"

#import "YSKJ_OrderProDuctHeadView.h"

#import "YSKJ_OrderProDuctFootView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import "YSKJ_OrderPopWindow.h"

#import "YSKJ_OrderDataModel.h"

#import <MJExtension/MJExtension.h>

#import "YSKJ_TipViewCalss.h"

#define CELLID @"cellid"

#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //七牛图片绝对路径

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define FIRSTROWHEGHT 160  //第一行行高

#define LASTROWHEGHT 177    //最后一行行高

#define NONMALROWHEGHT 64    //商品行高

@interface YSKJ_OrderProjectDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataSource;
    UITableView *_tableView;
    YSKJ_OrderProDuctTableViewCell *_cell;
    
    YSKJ_OrderPopWindow *_popViewWindow;
}

@end

@implementation YSKJ_OrderProjectDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
   // NSLog(@"self.objProduct=%@",self.objProduct);
    
    self.title = [self.objProduct objectForKey:@"name"];
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromHex(0xd7dee4);
    
    
    UIButton *buttonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [buttonItem addTarget:self action:@selector(poptoRootAction) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonItem setImage:[UIImage imageNamed:@"direction"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem];
    self.navigationItem.leftBarButtonItems=@[leftItem];
    
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
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_tableView];
    
    [self getDataSoure];
    
    [_tableView registerClass:[YSKJ_OrderProDuctTableViewCell class] forCellReuseIdentifier:CELLID];

}

-(void)poptoRootAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getDataSoure
{
    NSDictionary *dataInfo = [self.objProduct objectForKey:@"data_info"];
    
    NSArray *pdata = [dataInfo objectForKey:@"pdata"];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    NSDictionary *fristDict = @{
                           @"name":@"",
                           @"data":@[]
                           };
    [_dataSource addObject:fristDict];
    
    for (NSDictionary *pdict in pdata) {
        
        NSDictionary *dict = @{
                               @"name":[pdict objectForKey:@"name"],
                               @"data":[pdict objectForKey:@"data"]
                               };
        
        [_dataSource addObject:dict];
        
    }
    
    NSDictionary *lastDict = @{
                               @"name":@"",
                               @"data":@[]
                               };
    [_dataSource addObject:lastDict];
    
    [_dataSource exchangeObjectAtIndex:_dataSource.count-1 withObjectAtIndex:0];
    
    [_tableView reloadData];
    
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
    _popViewWindow.urlText.text = [NSString stringWithFormat:@"  %@%@",SPACEBGURL,[[self.objProduct objectForKey:@"data_info"] objectForKey:@"pdfurl"]];
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
        pasteboard.string = [NSString stringWithFormat:@"%@%@",SPACEBGURL,[[self.objProduct objectForKey:@"data_info"] objectForKey:@"pdfurl"]];
        
        YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
        tip.title = @"复制成功！";
        
    }else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SPACEBGURL,[[self.objProduct objectForKey:@"data_info"] objectForKey:@"pdfurl"]]]];
    }
    
    [self popdismiss];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDictionary *dict = _dataSource[section];
    NSArray *data = [dict objectForKey:@"data"];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    _cell = [tableView dequeueReusableCellWithIdentifier:CELLID];
    
    _cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    NSArray *objArray = [_dataSource[indexPath.section] objectForKey:@"data"];
    
    YSKJ_OrderDataModel *dataModel = [YSKJ_OrderDataModel mj_objectWithKeyValues:objArray[indexPath.row]];
    
    _cell.url = dataModel.thumb_file;
    
    _cell.proNameStr = dataModel.name;
    
    _cell.standardLableStr = dataModel.size;
    
    _cell.descStr = dataModel.desc;
    
    _cell.priceStr = [NSString stringWithFormat:@"¥%0.2f",[dataModel.price floatValue]];
    
    _cell.countStr = [NSString stringWithFormat:@"x%@",dataModel.num];
    
    _cell.totailPriceStr = [NSString stringWithFormat:@"¥%0.2f",[dataModel.price floatValue]*[dataModel.num integerValue]];
    
    float updata = 0.0;
    
    updata = [dataModel.real_price floatValue] - ([dataModel.price floatValue]*[dataModel.num integerValue]);
    
    NSString *updateStr = [NSString stringWithFormat:@"%0.2f",updata];
    
    if (updata<0) {
        
        _cell.updatePriceStr = [NSString stringWithFormat:@"-¥%@",[updateStr substringFromIndex:1]];
        
    }else{
        
        _cell.updatePriceStr = [NSString stringWithFormat:@"¥%0.2f",updata];

    }
    
    _cell.payPriceStr = [NSString stringWithFormat:@"¥%0.2f",[dataModel.real_price floatValue]];

    
    return _cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section==0) {
        
        return FIRSTROWHEGHT;
        
    }else if (section==_dataSource.count-1)
    {
        return LASTROWHEGHT;
        
    }else{
        
        return NONMALROWHEGHT;
    }

}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 120, NONMALROWHEGHT)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 54)];
    lable.textColor = UIColorFromHex(0x333333);
    lable.font = [UIFont systemFontOfSize:14];
    NSDictionary *dict = _dataSource[section];
    if ([[dict objectForKey:@"name"] isEqualToString:@"选单品"]) {
        
        lable.text = [dict objectForKey:@"name"];

    }else if(![[dict objectForKey:@"name"] isEqualToString:@""]){
        
        lable.text = [NSString stringWithFormat:@"%@   方案",[dict objectForKey:@"name"]];

    }
    
    [view addSubview:lable];
    
    UIView *subView = [[UIView alloc] init];
    subView.backgroundColor = UIColorFromHex(0xd7d7d7);
    [view addSubview:subView];
    subView.sd_layout
    .leftSpaceToView(view,0)
    .rightSpaceToView(view,0)
    .topSpaceToView(view,0)
    .heightIs(10);
    
    if (section !=0 && section!=_dataSource.count - 1) {
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = UIColorFromHex(0xd7d7d7);
        [view addSubview:line];
        
        line.sd_layout
        .leftSpaceToView(view,0)
        .rightSpaceToView(view,0)
        .topSpaceToView(view,63)
        .bottomSpaceToView(view,0);
        

    }else if (section == 0)
    {
        NSDictionary *dataInfo = [self.objProduct objectForKey:@"data_info"];
        
        NSArray *titleArray = @[[dataInfo objectForKey:@"cname"],[NSString stringWithFormat:@"地址：%@%@%@%@",[dataInfo objectForKey:@"province"],[dataInfo objectForKey:@"city"],[dataInfo objectForKey:@"district"],[dataInfo objectForKey:@"address"]],@"客流归属",@"备注"];
        
        NSArray *info = @[[dataInfo objectForKey:@"cphone"],@"",[dataInfo objectForKey:@"ctype"],[dataInfo objectForKey:@"cdesc"]];
        
        YSKJ_OrderProDuctHeadView *head = [[YSKJ_OrderProDuctHeadView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FIRSTROWHEGHT) array1:titleArray array2:info];
        [view addSubview:head];
        
        
    }else{
        
        
        float natruePrice = 0.0, dicCountPrice = 0.0 ,updataPrice = 0.0 ,pay = 0.0;
        
        for (int i=0 ; i<_dataSource.count ;i++) {
    
            NSDictionary *dict = _dataSource[i];
            
            if (i!=0 && i!=_dataSource.count-1) {
                
                NSArray *arr = [dict objectForKey:@"data"];
                
                for (NSDictionary *dictdata in arr) {
                    
                    
                    natruePrice += [[dictdata objectForKey:@"price"] floatValue] * [[dictdata objectForKey:@"num"] integerValue];

                    
                    updataPrice = updataPrice + ([[dictdata objectForKey:@"real_price"] floatValue] - [[dictdata objectForKey:@"price"] floatValue]*[[dictdata objectForKey:@"num"] integerValue]);
                    
                }

            }
            
        }
        
        NSString *updateStr = [NSString stringWithFormat:@"%0.2f",updataPrice];
        
        //原价
        NSString *natrueStr = [NSString stringWithFormat:@"¥%0.2f",natruePrice];
        
        NSString *updataPriceStr;
        //涨价或折扣
        if (updataPrice<0) {
            
            updataPriceStr = [NSString stringWithFormat:@"-¥%@",[updateStr substringFromIndex:1]];
            
        }else{
            updataPriceStr = [NSString stringWithFormat:@"¥%@",updateStr];
        }
        
        
        //实付款
        pay = [[self.objProduct objectForKey:@"price"] floatValue];
        
        //优惠价格
        dicCountPrice = natruePrice + updataPrice - pay;
        
        NSArray *price = @[natrueStr,updataPriceStr,[NSString stringWithFormat:@"-¥%0.2f",dicCountPrice],[NSString stringWithFormat:@"实付款：¥%0.2f",pay]];
        
        YSKJ_OrderProDuctFootView *foot = [[YSKJ_OrderProDuctFootView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, LASTROWHEGHT) priceArr:price];
        [view addSubview:foot];
        
    }
    
    
    return view;
    
}



@end
