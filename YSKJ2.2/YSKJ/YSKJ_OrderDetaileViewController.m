//
//  YSKJ_OrderDetaileViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/7/27.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDetaileViewController.h"

#import "YSKJ_OrderDetailTableViewCell.h"

#import "HttpRequestCalss.h"

#import "ToolClass.h"

#import "YSKJ_OrderDetailModel.h"

#import <MJExtension/MJExtension.h>

#import "YSKJ_OrderProjectDetailViewController.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define ORDERLIST @"http://"API_DOMAIN@"/project/list" //订单详情列表

#define CELLID @"cellid" // tableViewCellid

#define HIGHT 178    //tableViewCellHight

@interface YSKJ_OrderDetaileViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate>
{
    YSKJ_OrderDetailTableViewCell *_cell;
    
    UITableView *_tableView;
    
    NSMutableArray *_orderList;
}

@end

@implementation YSKJ_OrderDetaileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"订货单详情";
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

    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self getListOrderDetailList];
    
    // 注册某个标识对应的cell类型
    [_tableView registerClass:[YSKJ_OrderDetailTableViewCell class] forCellReuseIdentifier:CELLID];
    
}

-(void)getListOrderDetailList
{
    
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]

      };
    
    [requset postHttpDataWithParam:param url:ORDERLIST  success:^(NSDictionary *dict, BOOL success) {
        
     //   NSLog(@"dict=%@",dict);
        
        _orderList = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"data"]];
        
        [_tableView reloadData];
        
    }fail:^(NSError *error) {
        
    }];
    
}

-(void)dissmissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _orderList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    _cell = [tableView dequeueReusableCellWithIdentifier:CELLID];
    
    _cell.selectionStyle=UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    NSDictionary *dict = _orderList[indexPath.row];
    
    YSKJ_OrderDetailModel *model = [YSKJ_OrderDetailModel mj_objectWithKeyValues:dict];

    NSDictionary *dataInfo = model.data_info;
    
    NSArray *pdata = [dataInfo objectForKey:@"pdata"];
    
    NSInteger proCount = 0;
    
    for (NSDictionary *dict in pdata) {
        
        NSArray *data = [dict objectForKey:@"data"];
        
        for (NSDictionary *dict in data) {
            
            proCount += [[dict objectForKey:@"num"] integerValue];
            
        }
    }
    
    _cell.line.hidden = YES;
    
    _cell.nameStr = model.name;

    _cell.dateStr = [ToolClass utcToDateString:[model.create_time integerValue] dateFormat:@"yyyy-MM-dd"];
    
    _cell.numberStr = [NSString stringWithFormat:@"%lu",(unsigned long)proCount];
    
    _cell.totailePriceStr = [NSString stringWithFormat:@"实付款：%0.2f",[[dict objectForKey:@"price"] floatValue]];
    
    _cell.waitPassStr = model.status;
    
    _cell.obj = dict;
    
    _cell.button.tag = indexPath.row + 1000;
    
    _cell.width = self.view.frame.size.width;
    
    [_cell.button addTarget:self action:@selector(orderProductAciton:) forControlEvents:UIControlEventTouchUpInside];
    
    return _cell;
}

-(void)orderProductAciton:(UIButton *)sender
{
    
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    YSKJ_OrderProjectDetailViewController *detail = [[YSKJ_OrderProjectDetailViewController alloc] init];
    detail.objProduct = _orderList[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];

}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return HIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 1;
}

@end
