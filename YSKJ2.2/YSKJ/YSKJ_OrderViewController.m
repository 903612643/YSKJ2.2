//
//  YSKJ_OrderViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/7/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderViewController.h"

#import "YSKJ_OrderMenuView.h"

#import "YSKJ_OrderTotalPricesView.h"

#import "YSKJ_ OrderFavorableView.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import "YSKJ_OrderInfoViewController.h"

#import "YSKJ_LoginViewController.h"

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "ToolClass.h"

#import "YSKJ_TipViewCalss.h"

#import "YSKJ_OrderDoneViewController.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@interface YSKJ_OrderViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    YSKJ__OrderFavorableView *favorable;
    YSKJ_OrderMenuView *menu;
    YSKJ_OrderTotalPricesView *totalPrices;
    
    UITableView *_tableView;
    
    UITableViewCell *cell;
    
    UITextField *reboundField;  //cell，里的textField键盘回弹;
    
    NSMutableArray *_dataSource;
    
    NSMutableArray *_checkProductData;
    
    NSMutableArray *_array;
    
}


@end

@implementation YSKJ_OrderViewController


-(void)viewWillAppear:(BOOL)animated{

    
    [super viewWillAppear:animated];
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
    
   if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {

        _dataSource = [[NSMutableArray alloc] init];
        
        _tableView.hidden = NO;
        
        self.draggingView.hidden = NO;
        
        UIImageView *none = [self.view viewWithTag:2000];
        none.hidden = YES;
        UILabel *titleLable = [self.view viewWithTag:2001];
        titleLable.hidden = YES;
        
        //得到方案本地数组
        NSMutableArray *array1 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]];
        
        //得到单品本地数组
        NSMutableArray *array2 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]];

        for (NSDictionary *dict in array1) {
            
            NSString *titleStr = [dict objectForKey:@"title"];
            
            NSString *fanan = @"  方案";
            
            if([[dict objectForKey:@"title"] rangeOfString:fanan].location !=NSNotFound)
            {
                titleStr = [titleStr substringToIndex:titleStr.length - fanan.length];
            }
            
                NSDictionary *obj = @{
                                      @"plan_id":[dict objectForKey:@"plan_id"],
                                      @"title":[NSString stringWithFormat:@"%@  方案",titleStr],
                                      @"check":[dict objectForKey:@"check"],
                                      @"data": [dict objectForKey:@"data"]
                                      };

                [_dataSource addObject:obj];
            
        }
       
       for (NSDictionary *dict1 in array2) {
           
           NSDictionary *obj1 = @{
                                 @"plan_id":[dict1 objectForKey:@"plan_id"],
                                 @"title":[dict1 objectForKey:@"title"],
                                 @"check":[dict1 objectForKey:@"check"],
                                 @"data": [dict1 objectForKey:@"data"]
                                 };
           
           [_dataSource addObject:obj1];
           
       }
       
       for (int i=0;i<_dataSource.count;i++) {
           
           NSDictionary *dict = _dataSource[i];
           
           NSArray *arr = [dict objectForKey:@"data"];
           
           if (arr.count == 0) {
               
               [_dataSource removeObjectAtIndex:i];
               
           }
       }
       
    
    if (_dataSource.count == 0) {
        
        _tableView.hidden = YES;
        self.draggingView.hidden = YES;

        UIImageView *none = [self.view viewWithTag:2000];
        none.hidden = NO;
        UILabel *titleLable = [self.view viewWithTag:2001];
        titleLable.hidden = NO;
        
        self.navigationItem.rightBarButtonItems = nil;

    
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
        
    }else{
        
        UIButton *buttonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [buttonItem addTarget:self action:@selector(deleteProAction) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonItem setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem];
        self.navigationItem.rightBarButtonItems=@[leftItem];
    }
       
    _dataSource = (NSMutableArray *)[self replaceCheckByDataIn:_dataSource];
       
    [_tableView reloadData];
    
    [self updatePriceData];
       
    [self checkProductDataAction];
       
   }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromHex(0xd7dee4);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActionSuccess:) name:@"notificationToProDuctCtr" object:nil];
    
    
    if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {
        
        [self orderView];
        
    }else{
        
        [self setUpLoginTipView];
        
    }
    
    //下订单成功接受通知，移除已经下单的商品
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderSuccessAction:) name:@"orderSuccess" object:nil];
    
}

-(void)orderSuccessAction:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
}

#pragma mark 登录成功后得到通知

-(void)loginActionSuccess:(NSNotification*)sender
{

    if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {
        
        for (UIView *subView in [self.view subviews]) {
            if (subView.tag==1000) {
                [subView removeFromSuperview];
            }
        }
        
        [self orderView];
        
    }else{
        
        [self setUpLoginTipView];
        
        [_tableView removeFromSuperview];
        [self.draggingView removeFromSuperview];
        
    }
    
}
#pragma mark deleteProAction

-(void)deleteProAction
{
    
    int count = 0;
    for (int i=0; i<_dataSource.count; i++) {
        NSDictionary *dict = _dataSource[i];
        for (NSDictionary *dataDict in [dict objectForKey:@"data"]) {
            if ([[dataDict objectForKey:@"check"] integerValue] == 1) {
                
                count += [[dataDict objectForKey:@"count"] integerValue];
            }
        }
        
    }
    
    UIAlertController *alert;
    
    if (count ==0) {
        
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请先选择商品"] preferredStyle:UIAlertControllerStyleAlert];
        
    }else{
        
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除已选%d件商品",count] preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (int i=0; i<_dataSource.count; i++) {
            
            NSDictionary *dict = _dataSource[i];
            
            NSMutableArray *arr = [dict objectForKey:@"data"];
            
            for (int j=0; j<arr.count;j++) {
                
                NSDictionary *dataDict = arr[j];
                
                if ([[dataDict objectForKey:@"check"] integerValue] == 1) {
                    
                    [arr removeObject:dataDict];
                    
                    j--;
                   
                }
            }
            
        }
        
        for (int i=0;i<_dataSource.count;i++) {
            
            NSDictionary *dict = _dataSource[i];
            
            NSArray *arr = [dict objectForKey:@"data"];
            
            if (arr.count == 0) {
                
                [_dataSource removeObjectAtIndex:i];
                
                i--;
                
            }
        }
        
        [_tableView reloadData];
        
        [self updateLocalDatas];
        
        [self updatePriceData];
        
        if (_dataSource.count == 0) {
            
            _tableView.hidden = YES;
            self.draggingView.hidden = YES;
            
            UIImageView *none = [self.view viewWithTag:2000];
            none.hidden = NO;
            UILabel *titleLable = [self.view viewWithTag:2001];
            titleLable.hidden = NO;
            
            self.navigationItem.rightBarButtonItems = nil;
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
    
}

-(void)orderView
{
    
    UIButton *buttonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [buttonItem addTarget:self action:@selector(deleteProAction) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonItem setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem];
    self.navigationItem.rightBarButtonItems=@[leftItem];
    

    self.draggingView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(54+70+63+44+5), self.view.frame.size.width, 54+70)];
    [self.view addSubview:self.draggingView];

    menu =[[YSKJ_OrderMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 55)];
    menu.backgroundColor = UIColorFromHex(0xffffff);
    [self.view addSubview:menu];
    
    totalPrices = [[YSKJ_OrderTotalPricesView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 54)];
    [totalPrices.checkProduct addTarget:self action:@selector(checkAllAction:) forControlEvents:UIControlEventTouchUpInside];
    totalPrices.categoryNumber = self.categoryNumber;
    totalPrices.productNumber = self.productNumber;
    totalPrices.totailPriceStr = self.totailsPrice;
    totalPrices.backgroundColor = UIColorFromHex(0xffffff);
    [self.draggingView addSubview:totalPrices];
    
    favorable = [[YSKJ__OrderFavorableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    favorable.backgroundColor = UIColorFromHex(0xffffff);
    [self.draggingView addSubview:favorable];
    
    [totalPrices.placeAnorder addTarget:self action:@selector(placeAnorderAction) forControlEvents:UIControlEventTouchUpInside];
    
    favorable.discount.delegate = self;
    menu.menuDiscount.delegate = self;
    favorable.discount.keyboardType = UIKeyboardTypeNumberPad;
    
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.sd_layout
    .topSpaceToView(menu,0)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .bottomSpaceToView(self.draggingView,0);
    
    //监听软键盘事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDiscountTextChange) name:UITextFieldTextDidChangeNotification object:menu.menuDiscount];
    
    UIImageView *none = [UIImageView new];
    none.image = [UIImage imageNamed:@"buyerNone"];
    none.tag = 2000;
    none.hidden = YES;
    [self.view addSubview:none];
    none.sd_layout
    .leftSpaceToView(self.view,351)
    .topSpaceToView(self.view,180)
    .rightSpaceToView(self.view,563)
    .bottomSpaceToView(self.view,370);
    
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.text = @"订货单还是空的";
    titleLable.tag = 2001;
    titleLable.hidden = YES;
    titleLable.font = [UIFont systemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLable];
    titleLable.sd_layout
    .leftSpaceToView(none,38)
    .topSpaceToView(self.view,220)
    .widthIs(160)
    .heightIs(28);
    
    //添加手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    
    [self discountData];
    
}
-(void)checkAllAction:(UIButton *)sender
{
    if (sender.selected == NO) {
        
        sender.selected = YES;
        
        [sender setImage:[UIImage imageNamed:@"tranformSure"] forState:UIControlStateNormal];
        sender.layer.borderColor = UIColorFromHex(0x7abd54).CGColor;
        
        for (NSDictionary *dict in _dataSource) {
            [dict setValue:@"1" forKey:@"check"];
            for (NSDictionary *dataDict in [dict objectForKey:@"data"]) {
                
                [dataDict setValue:@"1" forKey:@"check"];
            }
        }
        
        
        
    }else{
        
        sender.selected = NO;
        
        [sender setImage:nil forState:UIControlStateNormal];
        sender.layer.cornerRadius = 15;
        sender.layer.masksToBounds = YES;
        sender.layer.borderWidth = 2;
        sender.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        
        for (NSDictionary *dict in _dataSource) {
            [dict setValue:@"0" forKey:@"check"];
            for (NSDictionary *dataDict in [dict objectForKey:@"data"]) {
                
                [dataDict setValue:@"0" forKey:@"check"];
            }
        }
        
    }
    
    [self updateLocalDatas];
    
    [self updatePriceData];
    
    [_tableView reloadData];

}

-(void)menuDiscountTextChange
{
     for (UIView *subView in _tableView.subviews) {
        
          for (UIView *sub in subView.subviews) {
            
            for (UIView *subs in sub.subviews) {
                
                if (subs.tag >=8000 && subs.tag<9000) {
                    
                    UITextField *textf = (UITextField*)subs;
                    textf.text = menu.menuDiscount.text;
                    
                    for (int i=0;i<_dataSource.count;i++) {
                        
                        NSDictionary *dict = _dataSource[i];
                        
                        NSArray *arr = [dict objectForKey:@"data"];

                        for (NSDictionary *dictj in arr) {
                            
                            if ([textf.text floatValue]>=1 && [textf.text floatValue]<10) {
                                
                                [dictj setValue:textf.text forKey:@"disCount"];
                            }else{
                                
                                [dictj setValue:@"10" forKey:@"disCount"];
                            }
     
                        }
                    }
                    
                    [_tableView reloadData];
                    
                    //修改本地数据
                    [self updateLocalDatas];
                    
                }
            }
            
        }
     }
    
    [self updatePriceData];
   
}

#pragma mark 未登录提示View

-(void)setUpLoginTipView
{
    UIView *unloginhomeView=[UIView new];
    unloginhomeView.tag=1000;
    unloginhomeView.backgroundColor=UIColorFromHex(0xEFEFEF);
    [self.view addSubview:unloginhomeView];
    unloginhomeView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    UIView *tiploginView=[UIView new];
    tiploginView.layer.cornerRadius=4;
    tiploginView.layer.masksToBounds=YES;
    tiploginView.backgroundColor=UIColorFromHex(0xffffff);
    [unloginhomeView addSubview:tiploginView];
    tiploginView.sd_layout
    .leftSpaceToView(unloginhomeView,272)
    .rightSpaceToView(unloginhomeView,272)
    .topSpaceToView(unloginhomeView,103)
    .heightIs(258);
    
    UILabel *tipLable=[UILabel new];
    tipLable.text=@"您尚未登录，无法操纵该板块内容，请登录";
    tipLable.textColor=UIColorFromHex(0x333333);
    tipLable.font=[UIFont systemFontOfSize:20];
    [tiploginView addSubview:tipLable];
    tipLable.sd_layout
    .leftSpaceToView(tiploginView,45)
    .rightSpaceToView(tiploginView,45)
    .topSpaceToView(tiploginView,27)
    .heightIs(28);
    
    UIImageView *tipImage=[UIImageView new];
    tipImage.image=[UIImage imageNamed:@"unlogin"];
    [tiploginView addSubview:tipImage];
    tipImage.sd_layout
    .leftSpaceToView(tiploginView,187)
    .rightSpaceToView(tiploginView,186)
    .topSpaceToView(tipLable,12)
    .heightIs(100);
    
    UIButton *tipLogin=[UIButton new];
    [tipLogin setTitle:@"前往登录" forState:UIControlStateNormal];
    [tipLogin addTarget:self action:@selector(toLoginCtrAction) forControlEvents:UIControlEventTouchUpInside];
    tipLogin.titleLabel.font=[UIFont systemFontOfSize:14];
    tipLogin.backgroundColor=UIColorFromHex(0xf39800);
    tipLogin.layer.cornerRadius=4;
    tipLogin.layer.masksToBounds=YES;
    [tiploginView addSubview:tipLogin];
    tipLogin.sd_layout
    .leftSpaceToView(tiploginView,176)
    .rightSpaceToView(tiploginView,176)
    .topSpaceToView(tipImage,19)
    .heightIs(44);
    
}

#pragma mark 登录

-(void)toLoginCtrAction
{
    YSKJ_LoginViewController *log=[[YSKJ_LoginViewController alloc] init];
    log.fromProductListVC=@"1";
    [self presentViewController:log animated:YES completion:nil];
}

-(void)placeAnorderAction
{
  
//    YSKJ_OrderDoneViewController *doneVC = [[YSKJ_OrderDoneViewController alloc] init];
//    [self.navigationController pushViewController:doneVC animated:YES];
    
    YSKJ_OrderInfoViewController *info = [[YSKJ_OrderInfoViewController alloc] init];
    info.title = @"订货单";
    info.proNumber = [NSString stringWithFormat:@"%ld",(long)totalPrices.productNumber];
    info.totailePrice = totalPrices.totailPriceStr;
    info.discount = [NSString stringWithFormat:@"%0.2f",[favorable.discount.text floatValue]];
    info.orderList = [self checkProductDataAction];
    info.orderArray = _array;
    info.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:info animated:YES];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return _dataSource.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    NSDictionary *dict=[_dataSource objectAtIndex:section];
    
    NSArray *arr=[dict objectForKey:@"data"];
    
    return arr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    static NSString *cellIder = @"cell";
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIder];
        
        cell.backgroundColor=[UIColor whiteColor];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.checkProduct = [[UIButton alloc] initWithFrame:CGRectMake(14, 50, 30, 30)];
        [self.checkProduct addTarget:self action:@selector(checkProductAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:self.checkProduct];
        
        self.productImage = [[UIButton alloc] initWithFrame:CGRectMake(58, 25, 80, 80)];
        [cell addSubview:self.productImage];
        
        self.productName = [[UILabel alloc] initWithFrame:CGRectMake(150, 25, 200, 14)];
        self.productName.textColor = UIColorFromHex(0x333333);
        self.productName.font = [UIFont systemFontOfSize:14];
        [cell addSubview:self.productName];
        
        self.standardLable = [[UILabel alloc] initWithFrame:CGRectMake(150, 59, 200, 12)];
        self.standardLable .textColor = UIColorFromHex(0x999999);
        self.standardLable .font = [UIFont systemFontOfSize:12];
        [cell addSubview:self.standardLable ];
        
        self.colorLable = [[UILabel alloc] initWithFrame:CGRectMake(150, 85, 200, 12)];
        self.colorLable.textColor = UIColorFromHex(0x999999);
        self.colorLable.font = [UIFont systemFontOfSize:12];
        [cell addSubview:self.colorLable];
        
        self.price = [[UILabel alloc] initWithFrame:CGRectMake(369, 58, 200, 12)];
        self.price.textColor = UIColorFromHex(0x333333);
        self.price.font = [UIFont systemFontOfSize:14];
        [cell addSubview:self.price];
        
        self.borLable = [[UILabel alloc] initWithFrame:CGRectMake(450, 50, 100, 30)];
        self.borLable.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        self.borLable.layer.borderWidth = 1;
        self.borLable.font = [UIFont systemFontOfSize:14];
        self.borLable.textAlignment = NSTextAlignmentCenter;
        self.borLable.textColor = UIColorFromHex(0x333333);
        [cell addSubview:self.borLable];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(30, 0, 1, 30)];
        line1.backgroundColor = UIColorFromHex(0xd8d8d8);
        [self.borLable addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(68, 0, 1, 30)];
        line2.backgroundColor = UIColorFromHex(0xd8d8d8);
        [self.borLable addSubview:line2];
        
        self.subtract=[UIButton new];
        [cell addSubview:self.subtract];
        self.subtract.sd_layout
        .leftSpaceToView(cell,443)
        .widthIs(44)
        .heightEqualToWidth()
        .topSpaceToView(cell,42);
        self.subtract.enabled = NO;
        [self.subtract setTitle:@"—" forState:UIControlStateNormal];
        [self.subtract addTarget:self action:@selector(subtractAction:) forControlEvents:UIControlEventTouchUpInside];
        UIColor *titlec=UIColorFromHex(0xd8d8d8);
        self.subtract.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.subtract setTitleColor:titlec forState:UIControlStateNormal];
        
        self.addProduct=[UIButton new];
        [cell addSubview:self.addProduct];
        self.addProduct.sd_layout
        .leftSpaceToView(cell,443+70)
        .widthIs(44)
        .heightEqualToWidth()
        .topSpaceToView(cell,42);
        [self.addProduct setTitle:@"+" forState:UIControlStateNormal];
        [self.addProduct addTarget:self action:@selector(addCount:) forControlEvents:UIControlEventTouchUpInside];
        UIColor *addtitlec=UIColorFromHex(0x333333);
        self.addProduct.titleEdgeInsets = UIEdgeInsetsMake(3, 3, 5, 5);
        self.addProduct.titleLabel.font = [UIFont systemFontOfSize:26];
        [self.addProduct setTitleColor:addtitlec forState:UIControlStateNormal];

        self.countPrice = [[UILabel alloc] initWithFrame:CGRectMake(588, 58, 200, 12)];
        self.countPrice.textColor = UIColorFromHex(0x333333);
        self.countPrice.font = [UIFont systemFontOfSize:14];
        [cell addSubview:self.countPrice];
        
        self.discount = [[UITextField alloc] initWithFrame:CGRectMake(673, 50, 40, 30)];
        self.discount.keyboardType = UIKeyboardTypeNumberPad;
        self.discount.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        self.discount.layer.borderWidth = 1;
        self.discount.textAlignment = NSTextAlignmentCenter;
        self.discount.delegate = self;
        [cell addSubview:self.discount];
        
        UILabel *discountLable = [[UILabel alloc] initWithFrame:CGRectMake(715, 58, 14, 14)];
        discountLable.text = @"折";
        discountLable.textColor = UIColorFromHex(0x333333);
        discountLable.font = [UIFont systemFontOfSize:14];
        [cell addSubview:discountLable];
        
        UILabel *equel = [[UILabel alloc] initWithFrame:CGRectMake(745, 58, 9, 14)];
        equel.text = @"=";
        equel.textColor = UIColorFromHex(0x333333);
        equel.font = [UIFont systemFontOfSize:14];
        [cell addSubview:equel];
        
        self.discountMoney = [[UITextField alloc] initWithFrame:CGRectMake(760, 50, 76, 30)];
        self.discountMoney.textAlignment = NSTextAlignmentCenter;
        self.discountMoney.keyboardType = UIKeyboardTypeNumberPad;
        self.discountMoney.textColor = UIColorFromHex(0x333333);
        self.discountMoney.font = [UIFont systemFontOfSize:13];
        self.discountMoney.delegate = self;
        self.discountMoney.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        self.discountMoney.layer.borderWidth = 1;
        [cell addSubview:self.discountMoney];
        
        UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(840, 58, 14, 14)];
        yuan.text = @"元";
        yuan.textColor = UIColorFromHex(0x333333);
        yuan.font = [UIFont systemFontOfSize:14];
        [cell addSubview:yuan];
        
        self.payPrice = [[UILabel alloc] initWithFrame:CGRectMake(902, 58, 120, 14)];
        self.payPrice.textColor = UIColorFromHex(0xf32a00);
        self.payPrice.font = [UIFont systemFontOfSize:14];
        [cell addSubview:self.payPrice];
        
        //备注
        self.editButton=[UIButton new];
        [cell addSubview:self.editButton];
        self.editButton.hidden = YES;
        self.editButton.sd_layout
        .leftSpaceToView(cell,142)
        .widthIs(44)
        .heightEqualToWidth()
        .bottomSpaceToView(cell,18);
        [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.editButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [self.editButton setImage:[UIImage imageNamed:@"editButton"] forState:UIControlStateNormal];
        
        self.editText=[UILabel new];
        self.editText.textColor = UIColorFromHex(0x999999);
        self.editText.hidden = YES;
        self.editText.textAlignment = NSTextAlignmentLeft;
        self.editText.font = [UIFont systemFontOfSize:12];
        [cell addSubview:self.editText];
        self.editText.sd_layout
        .leftSpaceToView(self.editButton,-8)
        .widthIs(370)
        .heightIs(18)
        .bottomSpaceToView(cell,30);
        
        self.editTextField = [[UITextField alloc] initWithFrame:CGRectMake(150, 86, 100, 18)];
        self.editTextField.hidden = YES;
        self.editTextField.placeholder = @"请输入备注";
        self.editTextField.textColor = UIColorFromHex(0x333333);
        self.editTextField.font = [UIFont systemFontOfSize:12];
        self.editTextField.delegate = self;
        self.editTextField.borderStyle = UITextBorderStyleRoundedRect;
        [cell addSubview:self.editTextField];

        
        self.editSure=[UIButton new];
        self.editSure.hidden = YES;
        [cell addSubview:self.editSure];
        self.editSure.sd_layout
        .leftSpaceToView(self.editTextField,3.5)
        .widthIs(44)
        .heightEqualToWidth()
        .bottomSpaceToView(cell,12.5);
        [self.editSure addTarget:self action:@selector(editSureAction:) forControlEvents:UIControlEventTouchUpInside];
        self.editSure.imageEdgeInsets = UIEdgeInsetsMake(8, 3.5, 8, 3.5);
        [self.editSure setImage:[UIImage imageNamed:@"editSure"] forState:UIControlStateNormal];
        
        self.editCancle=[UIButton new];
        self.editCancle.hidden = YES;
        [cell addSubview:self.editCancle];
        self.editCancle.sd_layout
        .leftSpaceToView(self.editSure,3.5)
        .widthIs(44)
        .heightEqualToWidth()
        .bottomSpaceToView(cell,12.5);
        [self.editCancle addTarget:self action:@selector(editCancleAction:) forControlEvents:UIControlEventTouchUpInside];
        self.editCancle.imageEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 7);
        [self.editCancle setImage:[UIImage imageNamed:@"editCancle"] forState:UIControlStateNormal];
        
        self.editUpdateText=[UIButton new];
        [cell addSubview:self.editUpdateText];
        self.editUpdateText.hidden = YES;
        self.editUpdateText.sd_layout
        .leftSpaceToView(cell,142)
        .widthIs(44)
        .heightEqualToWidth()
        .bottomSpaceToView(cell,18);
        [self.editUpdateText addTarget:self action:@selector(editUpdateTextAction:) forControlEvents:UIControlEventTouchUpInside];
        self.editUpdateText.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [self.editUpdateText setImage:[UIImage imageNamed:@"editButton"] forState:UIControlStateNormal];
        
    }

    self.subtract.tag = [[NSString stringWithFormat:@"30%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.addProduct.tag = [[NSString stringWithFormat:@"40%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.borLable.tag = [[NSString stringWithFormat:@"50%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.countPrice.tag = [[NSString stringWithFormat:@"60%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.price.tag = [[NSString stringWithFormat:@"70%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.discount.tag = [[NSString stringWithFormat:@"80%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.payPrice.tag = [[NSString stringWithFormat:@"90%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.discountMoney.tag = [[NSString stringWithFormat:@"100%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.checkProduct.tag = [[NSString stringWithFormat:@"110%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.editTextField.tag = [[NSString stringWithFormat:@"120%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.editSure.tag = [[NSString stringWithFormat:@"130%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    self.editCancle.tag = [[NSString stringWithFormat:@"140%ld%ld",(long)indexPath.section,(long)indexPath.row]integerValue];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    
    NSArray *arr=[dict objectForKey:@"data"];
    
    NSDictionary *obj = arr[indexPath.row];
    
    if (indexPath.section == 0) {
        
       // NSLog(@"obj=%@",arr[0]);
    }
    if ([[obj objectForKey:@"check"] integerValue] == 0) {
        
        self.checkProduct.layer.cornerRadius = 15;
        self.checkProduct.layer.masksToBounds = YES;
        self.checkProduct.layer.borderWidth = 2;
        self.checkProduct.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        
    }else{
        
        [self.checkProduct setImage:[UIImage imageNamed:@"tranformSure"] forState:UIControlStateNormal];
        self.checkProduct.layer.borderColor = UIColorFromHex(0x7abd54).CGColor;

    }
    
    if ([obj objectForKey:@"thumb_file"]) {
        
        [self.productImage sd_setImageWithURL:[[NSURL alloc] initWithString:[obj objectForKey:@"thumb_file"]] forState:UIControlStateNormal];
        
        [self.productImage.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:[obj objectForKey:@"thumb_file"]] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            float scaleW;
            if (image.size.width>=image.size.height) {
                scaleW=80/image.size.width;
            }else{
                scaleW=80/image.size.height;
            }
            
            if (image.size.width>0 && image.size.height>0) {
                
                self.productImage.imageEdgeInsets=UIEdgeInsetsMake((self.productImage.frame.size.height-scaleW*(image.size.height))/2, (self.productImage.frame.size.width-scaleW*(image.size.width))/2, (self.productImage.frame.size.height-scaleW*(image.size.height))/2, (self.productImage.frame.size.width-scaleW*(image.size.width))/2);
            }
        }];

    }else{
        
        [self.productImage setImage:[UIImage imageNamed:@"loading1"] forState:UIControlStateNormal];
    }
    
    
    self.productName.text = [obj objectForKey:@"name"];
    
    NSDictionary *arrdict=[ToolClass dictionaryWithJsonString:[obj objectForKey:@"attributes"]];
    
    NSArray *allkeys=[arrdict allKeys];
    
    for (NSString *key in allkeys) {
        if ([key isEqualToString:@"规格"]) {
            NSDictionary *guigeDict=[arrdict valueForKey:key];
            NSMutableArray *tempArr=[NSMutableArray new];
            [guigeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [tempArr addObject:[NSString stringWithFormat:@"%@%@",key,obj]];
            }];
            if (tempArr.count==2) {
                [tempArr exchangeObjectAtIndex:0 withObjectAtIndex:1];
            }else if (tempArr.count==3)
            {
                [tempArr exchangeObjectAtIndex:0 withObjectAtIndex:2];
                [tempArr exchangeObjectAtIndex:1 withObjectAtIndex:2];
            }
            self.standardLable .text= [NSString stringWithFormat:@"规格：%@mm",[tempArr componentsJoinedByString:@"*"]]; //为分隔符
        }
        if ([key isEqualToString:@"颜色"]) {
            self.colorLable.text = [NSString stringWithFormat:@"颜色：%@",[arrdict valueForKey:key]];
        }
    }
    
    self.price.text = [NSString stringWithFormat:@"¥%0.2f",[[obj objectForKey:@"price"] floatValue]];
    
    float money = [[obj objectForKey:@"price"] floatValue]*[[obj objectForKey:@"count"] floatValue];
    
    self.countPrice.text = [NSString stringWithFormat:@"¥%0.2f",money];
    
    self.borLable.text = [obj objectForKey:@"count"];
    
    if ([[obj objectForKey:@"count"] integerValue]>1) {
        
        UIColor *titleC = UIColorFromHex(0x333333);
        [self.subtract setTitleColor:titleC forState:UIControlStateNormal];
        self.subtract.enabled = YES;
        
    }
    
    NSInteger disCountInt = [[obj objectForKey:@"disCount"] integerValue];

    float pay = 0.0;
    
    if (disCountInt != 10 && disCountInt !=0) {
        
        self.discount.text = [obj objectForKey:@"disCount"];
        
        //[obj setValue:@"0" forKey:@"payMoney"];
        
        pay = [[obj objectForKey:@"price"] floatValue] * [[obj objectForKey:@"disCount"] floatValue]/10 * [[obj objectForKey:@"count"] integerValue];
        
        self.discountMoney.text = [NSString stringWithFormat:@"%0.2f",-([[obj objectForKey:@"price"] floatValue] * (1-[[obj objectForKey:@"disCount"] floatValue]/10) * [[obj objectForKey:@"count"] integerValue])];
        
        self.payPrice.text = [NSString stringWithFormat:@"¥%0.2f",pay];
        
    }else{
        
        pay = [[obj objectForKey:@"price"] floatValue] * [[obj objectForKey:@"count"] integerValue];
        
         self.payPrice.text = [NSString stringWithFormat:@"¥%0.2f",pay + [[obj objectForKey:@"payMoney"] floatValue]];
        
        if ([[obj objectForKey:@"payMoney"] integerValue] !=0) {
            
            self.discountMoney.text = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"payMoney"] integerValue]];
        }
        
    }
    
    //0不显示编辑框，否则显示
    if ([[obj objectForKey:@"edit"] integerValue] == 0) {
        
        NSString *textStr = [obj objectForKey:@"editText"];
        
        if (textStr.length!=0) {
            
            self.editButton.hidden = YES;
            self.editText.hidden = NO;
            self.editTextField.hidden = YES;
            self.editSure.hidden =YES ;
            self.editCancle.hidden = YES;
            self.editUpdateText.hidden = NO;

            
        }else{
            self.editButton.hidden = NO;
            self.editText.hidden = YES;
            self.editTextField.hidden = YES;
            self.editSure.hidden =YES ;
            self.editCancle.hidden = YES;
            self.editUpdateText.hidden = YES;

        }
        
    }else if ([[obj objectForKey:@"edit"] integerValue] == 1){
        
        self.editButton.hidden = YES;
        self.editText.hidden = YES;
        self.editTextField.hidden = NO;
        self.editSure.hidden =NO ;
        self.editCancle.hidden = NO;
        self.editUpdateText.hidden = YES;
        
    }
    
    NSString *textStr = [obj objectForKey:@"editText"];
    
   // NSLog(@"textStr=%@",textStr);
    
    if (textStr.length!=0) {
        
        if ([[obj objectForKey:@"edit"] integerValue] == 1) {
            
            self.editButton.hidden = YES;
            self.editText.hidden = YES;
            self.editTextField.hidden = NO;
            self.editSure.hidden =NO ;
            self.editCancle.hidden = NO;
            self.editUpdateText.hidden = YES;
            self.editTextField.text = [obj objectForKey:@"editText"];
            
            
        }else
        {
            self.editButton.hidden = YES;
            self.editText.hidden = NO;
            self.editTextField.hidden = YES;
            self.editSure.hidden =YES ;
            self.editCancle.hidden = YES;
            self.editUpdateText.hidden = NO;
            self.editText.text = [obj objectForKey:@"editText"];
        }
        
        
    }
    
    return cell;
    
}

-(void)editUpdateTextAction:(UIButton *)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    [proDcit setValue:@"1" forKey:@"edit"];
    
    [self updateLocalDatas];
    
    [_tableView reloadData];
}

-(void)editCancleAction:(UIButton *)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    for (UIView *subView in tableViewCell.subviews) {
        
        if (subView.tag == sender.tag - 2000) {
            UITextField *textf = (UITextField *)subView;
            [proDcit setValue:textf.text forKey:@"editText"];
        }
    }
    [proDcit setValue:@"0" forKey:@"edit"];
    
    [self updateLocalDatas];
    
    [_tableView reloadData];
}

-(void)editSureAction:(UIButton *)sender
{
    
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    
    NSInteger editTag = [[NSString stringWithFormat:@"120%ld%ld",(long)indexPath.section,(long)indexPath.row] integerValue];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    for (UIView *subView in tableViewCell.subviews) {
        
        if (subView.tag == editTag) {

            UITextField *textf = (UITextField *)subView;
            
            [proDcit setValue:textf.text forKey:@"editText"];
            
        }
    }
    
    [proDcit setValue:@"0" forKey:@"edit"];
    
    [self updateLocalDatas];
    
    [_tableView reloadData];
}

-(void)editButtonAction:(UIButton*)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    [proDcit setValue:@"1" forKey:@"edit"];
    
    [self updateLocalDatas];
    
    [_tableView reloadData];
    
    
}

-(void)headAction:(UIButton *)sender
{
    
    for (int i = 0; i<_dataSource.count ; i++) {
        
        NSMutableDictionary *obj = [[NSMutableDictionary alloc] initWithDictionary:_dataSource[i]];
        
        if (i == sender.tag - 1000) {
            
            NSMutableArray *arr=[obj objectForKey:@"data"];
            
            if ([[obj objectForKey:@"check"] integerValue] == 0) {
                
                [obj setValue:@"1" forKey:@"check"];
                
                [_dataSource replaceObjectAtIndex:i withObject:obj];
                
                sender.layer.borderColor = UIColorFromHex(0x7abd54).CGColor;
                [sender setImage:[UIImage imageNamed:@"tranformSure"] forState:UIControlStateNormal];
                
                for (NSDictionary *dicta in arr) {
                    
                    [dicta setValue:@"1" forKey:@"check"];
                }
                
            }else{
                
                [obj setValue:@"0" forKey:@"check"];
                
                [_dataSource replaceObjectAtIndex:i withObject:obj];
                
                sender.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
                [sender setImage:nil forState:UIControlStateNormal];
                
                for (NSDictionary *dicta in arr) {
                    
                    [dicta setValue:@"0" forKey:@"check"];
                    
                }
                
            }
            
        }
        
    }
    
    [_tableView reloadData];
    
    [self updatePriceData];
    
    [self updateLocalDatas];
    
    [self checkProductDataAction];
    
}

-(void)checkProductAction:(UIButton *)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    for (UIView *subs in tableViewCell.subviews) {
        
        if (subs.tag == sender.tag) {
            
            UIButton *checkB = (UIButton *)sender;
            
            if ([[proDcit objectForKey:@"check"] integerValue] == 0) {
                
                [proDcit setObject:@"1" forKey:@"check"];
                [checkB setImage:[UIImage imageNamed:@"tranformSure"] forState:UIControlStateNormal];
                checkB.layer.borderColor = UIColorFromHex(0x7abd54).CGColor;
                
            }else{
                
                [proDcit setObject:@"0" forKey:@"check"];
                [checkB setImage:nil forState:UIControlStateNormal];
                checkB.layer.cornerRadius = 15;
                checkB.layer.masksToBounds = YES;
                checkB.layer.borderWidth = 2;
                checkB.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
            }
        
        }
    }
    
    _dataSource = (NSMutableArray *)[self replaceCheckByDataIn:_dataSource];
    
    [self updatePriceData];
    
    [self updateLocalDatas];
    
    [self checkProductDataAction];
    
    [_tableView reloadData];
    
}

- (NSArray *)replaceCheckByDataIn:(NSArray *)arr
{
    NSMutableArray *mutArr = [arr mutableCopy];
    for (int i = 0; i < mutArr.count; i++)
    {
        NSArray *itemArray = [mutArr[i] objectForKey:@"data"];
        //        只要data里面的check都是1外部为check为1，data 有一个为 check为0外部为 0
        BOOL allOne = YES;
        NSMutableDictionary *mutItem = [mutArr[i] mutableCopy];
        
        for (NSDictionary *dict in itemArray)
        {
            int check = [[dict objectForKey:@"check"] intValue];
            if(check == 0)
            {
                allOne = NO;
                [mutItem setObject:@"0" forKey:@"check"];
                break;
            }
            else if(check == 1)
            {
                continue;
            }
        }
        if(allOne)
        {
            [mutItem setObject:@"1" forKey:@"check"];
        }
        mutArr[i] = mutItem;
    }
    
    return  mutArr;
    
}

-(void)subtractAction:(UIButton*)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];

    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    //修改商品数量
    [proDcit setObject:[NSString stringWithFormat:@"%d",[[proDcit objectForKey:@"count"] intValue] -1] forKey:@"count"];

    //修改本地数据
    [self updateLocalDatas];
    
    [_tableView reloadData];
    
    if ([[proDcit objectForKey:@"check"] integerValue] == 1) {
        
        [self updatePriceData];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
    
}

-(void)addCount:(UIButton*)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
    
    NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
    
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    NSMutableDictionary *proDcit = arr[indexPath.row];
    
    //修改商品数量
    [proDcit setObject:[NSString stringWithFormat:@"%d",[[proDcit objectForKey:@"count"] intValue] +1] forKey:@"count"];
    
    //修改本地数据
    [self updateLocalDatas];
    
    [_tableView reloadData];
    
    if ([[proDcit objectForKey:@"check"] integerValue] == 1) {
        
        [self updatePriceData];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
}

#pragma mark UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    //修改数据源
    NSDictionary *dict=[_dataSource objectAtIndex:section];
    
    NSMutableArray *arr=[dict objectForKey:@"data"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    view.backgroundColor = UIColorFromHex(0xd7dee4);
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 54)];
    subView.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, self.view.frame.size.width, 1)];
    line.backgroundColor = UIColorFromHex(0xd7d7d7);
    [subView addSubview:line];
    [view addSubview:subView];
    UIButton  *headCheckProduct = [[UIButton alloc] initWithFrame:CGRectMake(14, 12, 30, 30)];
    headCheckProduct.layer.cornerRadius = 15;
    headCheckProduct.layer.masksToBounds = YES;
    [headCheckProduct addTarget:self action:@selector(headAction:) forControlEvents:UIControlEventTouchUpInside];
    headCheckProduct.tag = 1000+section;
    [subView addSubview:headCheckProduct];
    
    if ([[dict objectForKey:@"check"] integerValue] == 1) {
    
        
        [headCheckProduct setImage:[UIImage imageNamed:@"tranformSure"] forState:UIControlStateNormal];
        
    }else{
        
        headCheckProduct.layer.borderWidth = 2;
        headCheckProduct.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
        
    }
    
    if ([self getAllcheckStatus] == YES) {
        
        totalPrices.checkProduct.selected = YES;
        [totalPrices.checkProduct setImage:[UIImage imageNamed:@"tranformSure"] forState:UIControlStateNormal];
        totalPrices.checkProduct.layer.borderColor = UIColorFromHex(0x7abd54).CGColor;
        
    }else{
        
        totalPrices.checkProduct.selected = NO;
        [totalPrices.checkProduct setImage:nil forState:UIControlStateNormal];
        totalPrices.checkProduct.layer.cornerRadius = 15;
        totalPrices.checkProduct.layer.masksToBounds = YES;
        totalPrices.checkProduct.layer.borderWidth = 2;
        totalPrices.checkProduct.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
    }

    
    if (section!=_dataSource.count-1) {
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(58, 20, self.view.frame.size.width-58, 14)];
        title.textAlignment = NSTextAlignmentLeft;
        title.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = UIColorFromHex(0x333333);
        [subView addSubview:title];
        
        
    }else {
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(58, 20, self.view.frame.size.width-58, 14)];
        title.textAlignment = NSTextAlignmentLeft;
        title.text = [dict objectForKey:@"title"];
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = UIColorFromHex(0x333333);
        [subView addSubview:title];
    }
    
    return view;
    
}
#pragma mark getBoolAllcheckProductStatus

-(BOOL)getAllcheckStatus
{
    BOOL res = '\0';
    
    for (int i =0 ; i<_dataSource.count ; i++) {
        
        NSDictionary *dcita = _dataSource[i];
        
        if ([[dcita objectForKey:@"check"] integerValue] == 0) {
        
            res = NO;
            break;
            
        }else{
            res = YES;
        }
    }
    
    return res;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 130;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 64;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 1;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return   UITableViewCellEditingStyleDelete;
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"    删除    ";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
        
        NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
        
        NSMutableArray *arr=[dict objectForKey:@"data"];
        
        [arr removeObjectAtIndex:indexPath.row];

       [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        //当组的个数为0时，移除headView
        for (int i=0;i<_dataSource.count;i++) {
            
            NSDictionary *dict = _dataSource[i];
            
            NSArray *arr = [dict objectForKey:@"data"];
            
            if (arr.count == 0) {
                
                [_dataSource removeObjectAtIndex:i];
                
                 i--;
                
            }
        }
        
        if (_dataSource.count == 0) {
            
            _tableView.hidden = YES;
            self.draggingView.hidden = YES;
            
            UIImageView *none = [self.view viewWithTag:2000];
            none.hidden = NO;
            UILabel *titleLable = [self.view viewWithTag:2001];
            titleLable.hidden = NO;
            
        }
        
        [self updatePriceData];
        
        //修改本地数据
        [self updateLocalDatas];
        
        [self performSelector:@selector(afterAction) withObject:self afterDelay:0.3];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
    }
    
}
#pragma mark updatePriceData
static float ProTotalPrice = 0.0;
static float ProDisCountPrice = 0.0;
static float ProfavorablePrice = 0.00;
static float ProNumber = 0.0;
-(void)updatePriceData
{
    ProTotalPrice = 0.0;
    ProDisCountPrice = 0.0;
    ProNumber = 0.0;
    
    for (int i=0 ; i<_dataSource.count; i++) {
        
        NSDictionary *dict = _dataSource[i];
        
        NSArray *dataArr = [dict objectForKey:@"data"];
        
        for (NSDictionary *dataDict in dataArr) {
            
            if ([[dataDict objectForKey:@"check"] integerValue] == 1) {
        
                ProNumber=ProNumber+[[dataDict objectForKey:@"count"] floatValue];
                
                float fprice = [[dataDict objectForKey:@"price"] floatValue];
                NSInteger Count = [[dataDict objectForKey:@"count"] integerValue];
    
                float totalPrice = fprice * Count;
                ProTotalPrice=ProTotalPrice+totalPrice;

                
                if ([[dataDict objectForKey:@"disCount"] floatValue]>0 && [[dataDict objectForKey:@"disCount"] floatValue]<10) {
                    
                    float disCountMoneyStr=-[[dataDict objectForKey:@"price"] floatValue] * [[dataDict objectForKey:@"count"] floatValue] * (1-[[dataDict objectForKey:@"disCount"] floatValue]/10) ;
                    
                        ProDisCountPrice=ProDisCountPrice+disCountMoneyStr;

                }else{
                         
                        ProDisCountPrice = ProDisCountPrice + [[dataDict objectForKey:@"payMoney"] floatValue];

                }
                
                
            }
            
        }
    }
    
    favorable.naturePriceStr = [NSString stringWithFormat:@"%0.2f",ProTotalPrice];
    favorable.disCountPriceStr = [NSString stringWithFormat:@"%0.2f",ProDisCountPrice];
    favorable.payPriceStr = [NSString stringWithFormat:@"%0.2f",ProTotalPrice + ProDisCountPrice + ProfavorablePrice];
    totalPrices.totailPriceStr = favorable.payPriceStr;
    totalPrices.productNumber = (NSInteger)ProNumber;
    
    if ([favorable.payPriceStr integerValue] <= 0) {
        
        if (_tableView.hidden !=YES && [favorable.payPriceStr integerValue] < 0
            ) {
            
            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
            tip.title = @"优惠价格过低";
            
        }
        favorable.favorablePriceStr = [NSString stringWithFormat:@"%0.2f",0.00];
        favorable.payPriceStr = [NSString stringWithFormat:@"%0.2f",ProTotalPrice +ProDisCountPrice ];
        totalPrices.totailPriceStr = favorable.payPriceStr;
        totalPrices.placeAnorder.enabled = NO;
        totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xefefef);

    }else{
        
        totalPrices.placeAnorder.enabled = YES;
        totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xf95f3e);
        _array = [[NSMutableArray alloc] init];
        
        [_array addObject:favorable.naturePrice.text];
        [_array addObject:favorable.disCountPriceStr];
        [_array addObject:favorable.favorablePrice.text];
        
    }
 
}

#pragma mark getCheckProDuctData

-(NSMutableArray*)checkProductDataAction
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    //用户信息
    NSDictionary *obj = @{
                          @"plan_id":@"0",
                          @"title":@"插入一个空的行",
                          @"check":@"0",
                          @"data": @[]
                          };
    [temp addObject:obj];
        
    NSMutableArray *proArr = [[NSMutableArray alloc] initWithArray:_dataSource];
    
    for (int i=0 ; i<proArr.count; i++) {
        
        NSDictionary *dict = proArr[i];
        
        if ([[dict objectForKey:@"check"] integerValue] == 1) {
            
            [temp addObject:dict];
            
        }else
        {
            NSArray *checkProArr = [dict objectForKey:@"data"];
            
            NSMutableArray *data = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dictC in checkProArr) {
                
                if ([[dictC objectForKey:@"check"] integerValue] == 1) {
                    
                    [data addObject:dictC];
                }
            }
            if (data.count != 0) {
                
                NSDictionary *obj = @{
                                      @"plan_id":[dict objectForKey:@"plan_id"],
                                      @"title":[dict objectForKey:@"title"],
                                      @"check":[dict objectForKey:@"check"],
                                      @"data": data
                                      };
                [temp addObject:obj];

            }
            
        }
        
    }
    if (temp.count!=0 && [totalPrices.totailPriceStr floatValue]>0) {
        totalPrices.placeAnorder.enabled = YES;
        totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xf95f3e);
    }else{
        totalPrices.placeAnorder.enabled = NO;
        totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xefefef);
    }
    
    return temp;
}

#pragma mark updateLocalDatas

-(void)updateLocalDatas
{
    
    NSMutableArray *planArr = [[NSMutableArray alloc] init];
    
    NSMutableArray *proArr = [[NSMutableArray alloc] init];
    
    for (int i=0 ; i<_dataSource.count; i++) {
        
        NSDictionary *dict = _dataSource[i];
        
        if ([[dict objectForKey:@"title"] isEqualToString:@"选单品"]) {
            
            [proArr addObject:dict];
            
            
        }
        if (![[dict objectForKey:@"title"] isEqualToString:@"选单品"]) {
            
            [planArr addObject:dict];
            
        }
        
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if (proArr.count>0) {
        
        [def setObject:[NSKeyedArchiver archivedDataWithRootObject:proArr] forKey:[NSString stringWithFormat:@"%@_proCar",[def objectForKey:@"userId"]]];
        
        [def synchronize];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
    }
    
    if (planArr.count>0) {
        
        [def setObject:[NSKeyedArchiver archivedDataWithRootObject:planArr] forKey:[NSString stringWithFormat:@"%@_planCar",[def objectForKey:@"userId"]]];
        
        [def synchronize];
        
    }else{
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
        
    }
    

}

-(void)afterAction
{
    [_tableView reloadData];
}

#pragma mark - 键盘弹出时界面上移及还原

static bool show = NO;

-(void)keyboardWillShow:(NSNotification *) notification{
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyBoardHeight = keyboardRect.size.height;
    
    if (show == YES){
        
        //使视图上移
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = -keyBoardHeight+(54+63+54);
        self.view.frame = viewFrame;
    }
    
    
}
-(void)keyboardWillHide
{
    //   [textfield resignFirstResponder];
    [favorable.discount resignFirstResponder];
    
    //使视图还原
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 63;
    self.view.frame = viewFrame;
    
    
}
-(void)tapAction
{
    if ([favorable.discount isFirstResponder]&&UIKeyboardDidShowNotification)
    {
        [favorable.discount resignFirstResponder];
        [reboundField resignFirstResponder];

        //使视图还原
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = 63;
        self.view.frame = viewFrame;
        
    }else{
        
        [menu.menuDiscount resignFirstResponder];
        
    }
}

#pragma mark UITextFieldDelegate

//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [favorable.discount resignFirstResponder];
    [menu.menuDiscount resignFirstResponder];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    CGPoint point = textField.frame.origin;
    CGPoint realLocation = [textField convertPoint:point toView:self.view];
    
    if (realLocation.y>350) {
        show = YES;
    }else{
        show = NO;
    }
}

static NSString *stempStr = nil;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{

    if (textField != menu.menuDiscount && textField!=favorable.discount) {
        
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)textField.tag];
        NSString *tagSub = [tagStr substringToIndex:2];
        
        NSLog(@"textField.tag=%ld",(long)textField.tag);
        
        if ([tagSub integerValue] == 80) {
        
            UITableViewCell *tableViewCell = (UITableViewCell*)[textField superview];
            NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
            
            //修改数据源
            NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
            
            NSMutableArray *arr=[dict objectForKey:@"data"];
            
            NSMutableDictionary *proDcit = arr[indexPath.row];
            
            [proDcit setObject:string forKey:@"disCount"];
            
            //修改实付金额  实付金额 ＝ 单价 * 折扣 * 数量
            
            float fdisCount = [[proDcit objectForKey:@"disCount"] floatValue]/10;
            float fprice = [[proDcit objectForKey:@"price"] floatValue];
            NSInteger Count = [[proDcit objectForKey:@"count"] integerValue];
            
            float pay = 0.0;
            float disCountMoney = 0.0;

            if (string.length != 0) {
                
                pay = fprice * fdisCount * Count;
                disCountMoney = fprice * (1-fdisCount) * Count;
                
            }else{
                
                pay = fprice * Count;
                
            }
            
            NSInteger subViewtag1 = [[NSString stringWithFormat:@"90%ld%ld",(long)indexPath.section,(long)indexPath.row] integerValue];
            NSInteger subViewtag2 = [[NSString stringWithFormat:@"100%ld%ld",(long)indexPath.section,(long)indexPath.row] integerValue];
            
            for (UILabel *view in tableViewCell.subviews) {
                
                if (view.tag == subViewtag1) {

                    UILabel *lable = (UILabel*)view;
                    lable.text = [NSString stringWithFormat:@"¥%0.2f",pay];
     
                }
                
                if (view.tag == subViewtag2) {
                    
                    UITextField *money = (UITextField *)view;
                    
                    if (string.length != 0) {
                        
                        money.text = [NSString stringWithFormat:@"-%0.2f",disCountMoney];
                        
                    }else{
                        
                        money.text = nil;
                    }
                }
            }
            
            [self discountData];
    
            [self updateLocalDatas];
  
        }
        
        if ([tagSub integerValue] == 10) {
            
            UITableViewCell *tableViewCell = (UITableViewCell*)[textField superview];
            NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
            
            //修改数据源
            NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
            
            NSMutableArray *arr=[dict objectForKey:@"data"];
            
            NSMutableDictionary *proDcit = arr[indexPath.row];
            
            NSInteger subViewtag1 = [[NSString stringWithFormat:@"80%ld%ld",(long)indexPath.section,(long)indexPath.row] integerValue];
            NSInteger subViewtag2 = [[NSString stringWithFormat:@"90%ld%ld",(long)indexPath.section,(long)indexPath.row] integerValue];
            
            for (UILabel *view in tableViewCell.subviews) {
                
                if (view.tag == subViewtag1) {
                    
                    UITextField *textf = (UITextField *)view;
                    
                    textf.text = nil;
                    
                    menu.menuDiscount.text = nil;
                    
                    [proDcit setObject:@"10" forKey:@"disCount"];
                    
                    [self updateLocalDatas];
                    
                    for (UILabel *view in tableViewCell.subviews) {
                        
                        if (view.tag == subViewtag2) {
                            
                            //修改数据源
                            NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
                            
                            NSMutableArray *arr=[dict objectForKey:@"data"];
                            
                            NSMutableDictionary *proDcit = arr[indexPath.row];
                            
                            [proDcit setObject:string forKey:@"disCount"];
                            
                            float fprice = [[proDcit objectForKey:@"price"] floatValue];
                            NSInteger Count = [[proDcit objectForKey:@"count"] integerValue];
                            
                            float pay = fprice * Count;
                            
                            UITextField *textf1 = (UITextField *)view;
                            textf1.text = [NSString stringWithFormat:@"¥%0.2f",pay];
                            
                        }
                        
                    }
                }
                
            }

        }
        
    }
    
    if (textField == favorable.discount) {
        
        if ([textField.text containsString:@"-"]) {        //是否包含"－"
            
            favorable.favorablePrice.text = [NSString stringWithFormat:@"%0.2f",[textField.text floatValue]];
            [self updatePriceData];
            
        }else{
            favorable.favorablePrice.text = [NSString stringWithFormat:@"-%0.2f",[textField.text  floatValue]];
          
        }
        
    }
    
    return YES;
    
}

- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex = @"[1-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    
    ProfavorablePrice = 0.0;
    
    if (textField == menu.menuDiscount) {
        
        for (int i=0;i<_dataSource.count;i++) {
            
            NSDictionary *dict = _dataSource[i];
            
            NSArray *arr = [dict objectForKey:@"data"];
            
            for (NSDictionary *dictj in arr) {
                
                if ([self deptNumInputShouldNumber:textField.text] == YES) {
                    
                    if ([textField.text floatValue]>0 && [textField.text floatValue]<10) {
                        float fdisCount = [textField.text floatValue]/10;
                        float fprice = [[dictj objectForKey:@"price"] floatValue];
                        NSInteger Count = [[dictj objectForKey:@"count"] integerValue];
                        
                        float disCountMStr = -fprice * (1-fdisCount) * Count;
                        [dictj setValue:[NSString stringWithFormat:@"%f",disCountMStr] forKey:@"payMoney"];
                        
                    }else{
                        [dictj setValue:@"0" forKey:@"payMoney"];
                    }
        
                }else{
                    [dictj setValue:@"0" forKey:@"payMoney"];
                }
                if (textField.text.length == 0) {
                    
                    [dictj setValue:@"0" forKey:@"payMoney"];

                }
 
            }
        }
        [self updateLocalDatas];
        
    }
    
    if (textField!=menu.menuDiscount && textField!=favorable.discount) {
        
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)textField.tag];
        NSString *tagSub = [tagStr substringToIndex:2];
        
        if ([tagSub integerValue] == 80) {
            
            UITableViewCell *tableViewCell = (UITableViewCell*)[textField superview];
            NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
            
            //修改数据源
            NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
            
            NSMutableArray *arr=[dict objectForKey:@"data"];
            
            NSMutableDictionary *proDcit = arr[indexPath.row];
            
            if ([textField.text floatValue]>=1 && [textField.text floatValue]<10) {
                
                [proDcit setValue:textField.text forKey:@"disCount"];
                
            }else{
                
                [proDcit setValue:@"10" forKey:@"disCount"];
                [proDcit setValue:@"0" forKey:@"payMoney"];
            }
            
            if ([favorable.discount.text containsString:@"-"]) {        //是否包含"."
                
                ProfavorablePrice = [favorable.discount.text floatValue];
                
            }else{
                
                ProfavorablePrice = -[favorable.discount.text floatValue];
            }
            
            [self discountData];
            [self updateLocalDatas];
            [self updatePriceData];
            
        }
        
        if ([tagSub integerValue] == 10) {
            
            UITableViewCell *tableViewCell = (UITableViewCell*)[textField superview];
            NSIndexPath *indexPath = [_tableView indexPathForCell:tableViewCell];
            
            //修改数据源
            NSDictionary *dict=[_dataSource objectAtIndex:indexPath.section];
            
            NSMutableArray *arr=[dict objectForKey:@"data"];
            
            NSMutableDictionary *proDcit = arr[indexPath.row];
            
            [proDcit setObject:textField.text forKey:@"payMoney"];
            
             NSInteger subViewtag = [[NSString stringWithFormat:@"80%ld%ld",(long)indexPath.section,(long)indexPath.row] integerValue];
            
            for (UIView *view in tableViewCell.subviews) {
                
                if (view.tag == subViewtag) {
                    
                    UITextField *textf = (UITextField *)view;
                    textf.text = nil;
                    [proDcit setValue:@"0" forKey:@"disCount"];
                    menu.menuDiscount.text = nil;
                    
                }
                
            }

            if ([favorable.discount.text containsString:@"-"]) {        //是否包含"."
                
                ProfavorablePrice = [favorable.discount.text floatValue];
                
            }else{
                
                ProfavorablePrice = -[favorable.discount.text floatValue];
            }
            
            [self updateLocalDatas];
            [self updatePriceData];
            
        }

    }
    
    if (textField == favorable.discount) {
        
        if ([textField.text containsString:@"-"]) {        //是否包含"."
            
            ProfavorablePrice = [textField.text floatValue];
            favorable.favorablePrice.text = [NSString stringWithFormat:@"%0.2f",[textField.text floatValue]];
        
            
        }else{
            
            ProfavorablePrice = -[textField.text floatValue];
            favorable.favorablePrice.text = [NSString stringWithFormat:@"-%0.2f",[textField.text floatValue]];
            
        }
        [self updatePriceData];
 
    }
    
    [_tableView reloadData];

}

#pragma mark disCount delegate

-(void)discountData
{
    BOOL menuDisCountHaveData = YES;
    
    for (int i=0;i<_dataSource.count;i++) {
        
        NSDictionary *dict = _dataSource[i];
        
        NSArray *arr = [dict objectForKey:@"data"];
        
        for (int j=0; j<arr.count ; j++) {
            
            NSDictionary *dictj = arr[j];
            
            if (j>0) {
                
                NSDictionary *beforeDict = arr[j-1];
                if (![[dictj objectForKey:@"disCount"] isEqualToString:[beforeDict objectForKey:@"disCount"]]) {
                    
                    menu.menuDiscount.text = nil;
                    
                    menuDisCountHaveData = NO;
                    
                }else{
                    
                    if (menuDisCountHaveData == YES) {
                        
                        if ([[dictj objectForKey:@"disCount"] floatValue]>0 && [[dictj objectForKey:@"disCount"] floatValue]<10) {
                            menu.menuDiscount.text = [dictj objectForKey:@"disCount"];
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
}

@end
