//
//  YSKJ_CheckSceneViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/6/19.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_ScenePlanViewController.h"
#import "YSKJ_ScenePlanCollectionViewCell.h"
#import "HttpRequestCalss.h"
#import "YSKJ_CheckSceneModel.h"
#import <MJExtension/MJExtension.h>
#import "ToolClass.h"
#import "YSKJ_CanvasViewController.h"
#import "YSKJ_LoginViewController.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器
#define GETFORMATLIST @"http://"API_DOMAIN@"/solution/getformatlist"   //场景列表
#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径

#define SPACEBG @"http://"API_DOMAIN@"/solution/getbglist"

@interface YSKJ_ScenePlanViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *spaceArray;
    
}

@property (nonatomic, strong) UICollectionView* collect;

@property (nonatomic, strong) UIView *corssView;

@end

@implementation YSKJ_ScenePlanViewController

-(void)viewWillAppear:(BOOL)animated
{
    
    [self.corssView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    UIButton *buttonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [buttonItem addTarget:self action:@selector(dissmissAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:[UIImage imageNamed:@"direction"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem];
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 14;
    
    self.navigationItem.leftBarButtonItems=@[leftItem,fixedSpaceBarButtonItem];

    [self setUpCollectionView];
    
    spaceArray = [[NSMutableArray alloc] init];
    
   // [self httpGetSpacebgList];
    
}

-(void)dissmissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setUpCollectionView
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    layout.itemSize = CGSizeMake(240, 240);
    
    _collect = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, THEWIDTH, THEHEIGHT-110) collectionViewLayout:layout];
    _collect.backgroundColor=[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    //代理设置
    _collect.delegate=self;
    _collect.dataSource=self;
    //注册item类型 这里使用系统的类型
    [_collect registerClass:[YSKJ_ScenePlanCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    
    [self.view addSubview:_collect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YSKJ_ScenePlanCollectionViewCell *checkCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    checkCell.layer.cornerRadius = 4;
    checkCell.layer.masksToBounds = YES;
    
    checkCell.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    
    if (self.dataSource.count!=0) {
        
        NSDictionary *dict_info=[ToolClass dictionaryWithJsonString:[dict objectForKey:@"data_info"]];
        
        checkCell.url = [NSString stringWithFormat:@"%@/%@",SPACEBGURL,[dict_info objectForKey:@"url"]];
        
        [checkCell.button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }else{
        
        checkCell.url = @"";
        
    }
    
    checkCell.title = [dict objectForKey:@"name"];
    
    checkCell.button.tag = 1000+indexPath.row;
    
    
    return checkCell;
}
-(void)action:(UIButton *)sender
{
    for (int i=0; i<self.dataSource.count; i++) {
        
        if (i==sender.tag-1000) {
            
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]!=nil) {
                
                YSKJ_CanvasViewController *newPlan=[[YSKJ_CanvasViewController alloc] init];
                
                NSDictionary *planData=@{
                                        @"data_value":[self.dataSource[i] objectForKey:@"data_value"],
                                        @"type":@"create",
                                        @"planId":@"",
                                        @"projectName":@"",
                                        @"planName":[self.dataSource[i] objectForKey:@"name"]
                                        };
    
                [[NSUserDefaults standardUserDefaults] setObject:planData forKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                

                self.corssView = [[UIView alloc] initWithFrame:_collect.bounds];
                self.corssView.backgroundColor = [UIColor whiteColor];
                [_collect addSubview:self.corssView];
                
                [self presentViewController:newPlan animated:YES completion:nil];
                
                
            }else{
                
                YSKJ_LoginViewController *log=[[YSKJ_LoginViewController alloc] init];
                [self presentViewController:log animated:YES completion:nil];
            }
 
        }
    }
}


-(void)httpGetSpacebgList
{
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *param=@{
                          
                          @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                          @"type":@"",
                          @"style":@""
                          };
    
    [httpRequest postHttpDataWithParam:param url:SPACEBG success:^(NSDictionary *dict, BOOL success) {
        
        if ([[dict objectForKey:@"success"]boolValue]!=0) {
            
            spaceArray = [dict objectForKey:@"data"];
            
        }
        
    } fail:^(NSError *error) {
        
    }];
    
}


//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {16,8,16,8};
    return top;
}


@end
