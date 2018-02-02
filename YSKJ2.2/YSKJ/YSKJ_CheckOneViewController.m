//
//  YSKJ_Test3ViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/4.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_CheckOneViewController.h"
#import "HttpRequestCalss.h"
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "YSKJ_FuritureInfoViewController.h"
#import "DatabaseManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh/MJRefresh.h>
#import "YSKJ_TipViewCalss.h"
#import "ToolClass.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <MJExtension/MJExtension.h>
#import "AnimatedGif.h"
#import "YSKJ_ProDuctModel.h"
#import "YSKJ_ParamModel.h"
#import "YSKJ_CheckCollectionViewCell.h"
#import "YSKJ_UpdateVersionView.h"
#import "YSKJ_NoneProductView.h"
#import "YSKJ_NetStatusNotificationView.h"
#import "WYScrollView.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器
#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地址
#define SHOPLISTURL  @"http://"API_DOMAIN@"/store/list"    //列表
#define  GETTYPE @"http://"API_DOMAIN@"/store/gettype"     //分类数据
#define GETVERSION @"http://"API_DOMAIN@"/sysconfig/getversion"  //获取版本号

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface YSKJ_CheckOneViewController ()<DatabaseManagerDelegate,UITextFieldDelegate,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UIView *searchView ;  //承载筛选的View
    
    UIImageView *imageView;  //单品图片
    
    UIView *filterView;      //筛选按钮显示View,
    
    UIView *thefilterView;     //筛选视图
    
    UIButton *theFilterCanbutton; //关闭筛选
    
    UITextField *furnitureFilterPush;   //输入框
    
    UIImageView *searchImage;          //放大镜
    
    UIView *styleViewBgm;            //风格
    UIView *spaceViewBgm;            //空间
    UIView *categoryViewBgm;         //品类
    UIView *brandViewBgm;            //品牌
    UIView *soureViewBgm;            //资源
    //上拉下拉按钮
    UIButton *styleButton;
    UIButton *spaceButton;
    UIButton *categoryButton;
    UIButton *brandButton;
    UIButton *souresButton;
    
    NSMutableArray *_styleArray;
    NSMutableArray *_spaceArray;
    NSMutableArray *_categoryArray;
    NSMutableArray *_brandArray;
    NSMutableArray *_sourceArray;

    NSMutableArray *_selectStyleArray;     //选中风格数组
    NSMutableArray *_selectSpaceArray;     //选中空间数组
    NSMutableArray *_selectCategoryArray;     //选中品类数
    NSMutableArray *_selectSouresArray;     //选中资源数组
    
    UITableView *categoryTableView;
    
    UITableView *filterTableView;
    
    NSMutableArray *categoryArray;
    
    UITableViewCell *cateCell;
    UITableViewCell *filterCell;
    
    NSArray *lableArr;
    
    YSKJ_ParamModel *paramModel;
    
    YSKJ_NoneProductView *noneProductView;
    
    HttpRequestCalss *httpRequest;
    
}

@property (nonatomic, strong) UICollectionView* collect;

@property (nonatomic,retain)NSArray *dbDataArr;  //数据库数组;

@property (nonatomic,retain)NSMutableArray *addDataArr;  //上拉下拉数组

@end

@implementation YSKJ_CheckOneViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title=@"选单品";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"_styleCount"] ;
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"_spaceCount"] ;
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"_categoryCount"] ;
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    paramModel = [[YSKJ_ParamModel alloc] init];
    
    httpRequest=[[HttpRequestCalss alloc] init];

    [self initNSMutableArray];
    
    [self initHttpParam];

    [self shopHttpData];
    
    [self setUpColletionView];
    
    [self setupSearchView];
    
    [self addFilterSubView];
    
    [self setUpMjRefresh];
    
    [self getLableHttpData];
    
    [self httpsGetVersionforService];
    
    noneProductView = [[YSKJ_NoneProductView alloc] init];
    
    NSLog(@"userId=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]);
    
    
    [httpRequest judgeNet:^(NSInteger statusIndex) {
        
        if (statusIndex == -1 || statusIndex==0) {
            
            [YSKJ_NetStatusNotificationView showNotificationViewWithText:@"当前网络不可用，请检查网络设置"];
        }
        
    }];
    
}

#pragma mark 版本更新提示

-(void)httpsGetVersionforService
{
    
    [httpRequest postHttpDataWithParam:nil url:GETVERSION success:^(NSDictionary *dict, BOOL success) {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
        if ([app_Version floatValue]<[[dict objectForKey:@"version"] floatValue]) {
            
            YSKJ_UpdateVersionView *update=[[YSKJ_UpdateVersionView alloc] initWithFrame:CGRectMake(0, 0, THEWIDTH, THEHEIGHT)];
            update.versionStr = [dict objectForKey:@"version"];
            [update.updateButton addTarget:self action:@selector(updateVersionAction) forControlEvents:UIControlEventTouchUpInside];
            [[UIApplication sharedApplication].keyWindow addSubview:update];
            
        }
        
    }fail:^(NSError *error) {
        
    }];
    
}
-(void)updateVersionAction
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/cn/app/yun-shang-kong-jian/id1220797054?mt=8"]];
}

#pragma mark 初始化数组

-(void)initNSMutableArray
{
 _selectStyleArray=[[NSMutableArray alloc] init];
 _selectSpaceArray=[[NSMutableArray alloc] init];
 _selectCategoryArray=[[NSMutableArray alloc] init];
 _selectSouresArray=[[NSMutableArray alloc] init];
 
 self.addDataArr=[[NSMutableArray alloc] init];
    
}
#pragma mark 初始化网络请求参数

-(void)initHttpParam
{
    //默认
    paramModel.cateid = @"1";
    paramModel.page = @"1";
    paramModel.order = @"view_amount";
    paramModel.ordername = @"desc";
    paramModel.keyword = @"";
    paramModel.style = @"";
    paramModel.space = @"";
    paramModel.category = @"";
    paramModel.source = @"";
    paramModel.pagenum = @"";
    
}
#pragma mark 得到商品列表
static bool ishttpData=NO;         //是否还继续预加载
static bool ishttpagain=NO;        //等上一页加载完再进行下一页

-(void)shopHttpData
{
    
    //状态栏网络监控提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    DatabaseManager *databasemang=[[DatabaseManager alloc] init];
    databasemang.delegate=self;
    [databasemang openDatabase];
    [databasemang getAllDataWithTableName:@"yskj_proDuctTable" from:@"pro"];
 
    if (furnitureFilterPush.text.length!=0) {
        paramModel.keyword=furnitureFilterPush.text;
    }else{
        paramModel.keyword=@"";
    }
    NSString *useridStr;
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]) {
        useridStr = @"";
    }else{
        useridStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    }
    NSDictionary *paramdict=@{
                              @"cateid":paramModel.cateid,
                              @"page":paramModel.page,
                              @"order":paramModel.order,
                              @"ordername":paramModel.ordername,
                              @"keyword":paramModel.keyword,
                              @"style":paramModel.style,
                              @"space":paramModel.space,
                              @"category":paramModel.category,
                              @"source":paramModel.source,
                              @"pagenum":@"20",
                              @"userid":useridStr
                              };

    NSLog(@"paramdict=%@",paramdict);
    
    [httpRequest postHttpDataWithParam:paramdict url:SHOPLISTURL success:^(NSDictionary *dict, BOOL success) {
        
        ishttpagain=YES;    //是否继续预加载
        
        NSMutableArray *lineArr=[dict objectForKey:@"data"];
        
        if (lineArr.count<20) {
            ishttpData=NO;
        }else{
            ishttpData=YES;
        }
        
      //  NSLog(@"dbDataArr.count=%@",self.dbDataArr);
        
        for (int i=0; i<lineArr.count; i++)
        {
            NSDictionary *lineDict=lineArr[i];
            
            for (int j=0; j<self.dbDataArr.count; j++)
            {
                NSDictionary *dbDict=self.dbDataArr[j];
                
                if ([[lineDict objectForKey:@"id"] integerValue] == [[dbDict objectForKey:@"product_id"] integerValue]) {
                    
                    [lineDict setValue:[dbDict objectForKey:@"thumb_file"] forKey:@"thumb_file"];        //数据替换，用数据库的覆盖请求到的字段
                    [lineDict setValue:[dbDict objectForKey:@"desc_img"] forKey:@"desc_img"];
                    
                }
                
            }
            
        }
        //结束头部刷新
        [_collect.mj_header endRefreshing];
 
        if ([paramModel.page isEqualToString:@"1"]) {
            [self.addDataArr removeAllObjects];
            self.addDataArr=lineArr;
        }else{
            [self.addDataArr addObjectsFromArray:lineArr];
        }
      //  NSLog(@"addDataArr=%@",self.addDataArr);
     
        if (self.addDataArr.count==0) {
            noneProductView.hidden = NO;
            //展示没有商品的提示
            noneProductView.frame = CGRectMake(0, 0, _collect.frame.size.width, _collect.frame.size.height);
            [_collect addSubview:noneProductView];

            NSString *textStr=furnitureFilterPush.text;
            if (furnitureFilterPush.text.length==0) {
                if ([paramModel.cateid isEqualToString:@"1"]) {
                    textStr=@"家具中心";
                }else if ([paramModel.cateid isEqualToString:@"2"])
                {
                    textStr=@"饰品中心";
                    
                }else if ([paramModel.cateid isEqualToString:@"3"])
                {
                    textStr=@"生活物件";
                }
                
            }
            noneProductView.tipStr=[NSString stringWithFormat:@"Srroy！产品汪和程序猿还没有来得及把\"%@\"的素材更新上来，客官请下次再搜搜看",textStr ];
            
            
        }else{
            noneProductView.hidden = YES;
        }
        
        [_collect reloadData];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } fail:^(NSError *error) {
        
        [httpRequest judgeNet:^(NSInteger statusIndex) {
            
            if (statusIndex == -1 || statusIndex==0) {
                
                [YSKJ_NetStatusNotificationView showNotificationViewWithText:@"当前网络不可用，请检查网络设置"];
            }
            
        }];

        //结束头部刷新
        [_collect.mj_header endRefreshing];
        
    }];
    
}
#pragma mark 获取商品筛选分类列表

-(void)getLableHttpData
{
    for (UIView *sub in thefilterView.subviews) {
        [sub removeFromSuperview];
    }
    
    NSDictionary *dict=@{
                         @"cateid":paramModel.cateid,
                         };
    
    [httpRequest postHttpDataWithParam:dict url:GETTYPE success:^(NSDictionary *dict, BOOL success) {
        //获取data字典
        NSDictionary *dataDict=[dict objectForKey:@"data"];
        
        NSArray *DataArr=[dict objectForKey:@"data"];
        
        lableArr=DataArr;
        
        if (DataArr.count!=0) {
            
            NSDictionary *styleDict=[dataDict objectForKey:@"style"];
            NSDictionary *spaceDict=[dataDict objectForKey:@"space"];
            NSDictionary *categoryDict=[dataDict objectForKey:@"category"];
            NSDictionary *souresDict=[dataDict objectForKey:@"source"];
            //风格数据
            NSArray *styleArray=[styleDict objectForKey:@"data"];
            _styleArray=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in styleArray) {
                [_styleArray addObject:[dict objectForKey:@"id"]];
            }
            //空间数据
            NSArray *spaceArray=[spaceDict objectForKey:@"data"];
            _spaceArray=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in spaceArray) {
                [_spaceArray addObject:[dict objectForKey:@"id"]];
            }
            //品类数据
            NSArray *categoryArray1=[categoryDict objectForKey:@"data"];
            _categoryArray=[[NSMutableArray alloc] init];
            categoryArray=(NSMutableArray *)categoryArray1;
            for (NSDictionary *dict in categoryArray1) {
                [_categoryArray addObject:[dict objectForKey:@"id"]];
            }
            //资源数据
            NSArray *souresArray1=[souresDict objectForKey:@"data"];
            _sourceArray=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in souresArray1) {
                [_sourceArray addObject:[dict objectForKey:@"id"]];
            }
            
            filterTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT)];
            filterTableView.backgroundColor=[UIColor clearColor];
            filterTableView.delegate=self;
            filterTableView.dataSource=self;
            [thefilterView addSubview:filterTableView];
            
            categoryTableView=[[UITableView alloc] initWithFrame:CGRectMake(thefilterView.size.width, 0, thefilterView.size.width, THEHEIGHT)];
            categoryTableView.backgroundColor=[UIColor groupTableViewBackgroundColor];
            categoryTableView.delegate=self;
            categoryTableView.dataSource=self;
            [thefilterView addSubview:categoryTableView];
            
        }
        
    } fail:^(NSError *error) {
        
    }];
}


#pragma mark 加载ColletionView

-(void)setUpColletionView
{
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    layout.itemSize = CGSizeMake((THEWIDTH-36*4)/4, 296);
    
    _collect = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 60, THEWIDTH, THEHEIGHT-160) collectionViewLayout:layout];
    
    _collect.backgroundColor=[UIColor whiteColor];
    //代理设置
    _collect.delegate=self;
    _collect.dataSource=self;
    //注册item类型 这里使用系统的类型
    [_collect registerClass:[YSKJ_CheckCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    
    [self.view addSubview:_collect];

}

#pragma mark 上拉加载下拉刷新

-(void)setUpMjRefresh
{
    //下拉刷新
    _collect.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(mj_header)];

}

static int intPage =1;

-(void)mj_header
{
    paramModel.page=@"1";
    intPage=1;
    [self shopHttpData];

}

#pragma mark  搜索栏视图

-(void)setupSearchView
{
    searchView = [UIView new];
    searchView.backgroundColor=[UIColor colorWithRed:251/255.0 green:250/255.0 blue:249/255.0 alpha:1.0];
    [self.view addSubview:searchView];
    searchView.sd_layout
    .leftEqualToView(_collect)
    .rightEqualToView(self.view)
    .topEqualToView(self.view)
    .heightIs(60);
    
    UIButton *furnitureCenter=[UIButton new];
    furnitureCenter.tag=2000;
    [furnitureCenter setTitle:@"家具中心" forState:UIControlStateNormal];
    [furnitureCenter addTarget:self action:@selector(centerAction:) forControlEvents:UIControlEventTouchUpInside];
    //默认选中
    furnitureCenter.backgroundColor=[UIColor clearColor];
    [furnitureCenter setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [searchView addSubview:furnitureCenter];
    
    UIButton *ornament=[UIButton new];
    ornament.tag=2001;
    [ornament setTitle:@"饰品中心" forState:UIControlStateNormal];
    [ornament addTarget:self action:@selector(ornamentAction:) forControlEvents:UIControlEventTouchUpInside];
    [ornament setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [searchView addSubview:ornament];
    
    UIButton *thing=[UIButton new];
    thing.tag=2002;
    [thing setTitle:@"生活物件" forState:UIControlStateNormal];
    [thing addTarget:self action:@selector(thingAction:) forControlEvents:UIControlEventTouchUpInside];
    [thing setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [searchView addSubview:thing];

    furnitureFilterPush=[UITextField new];
    furnitureFilterPush.delegate=self;
    furnitureFilterPush.returnKeyType=UIReturnKeyGoogle;
    furnitureFilterPush.clearButtonMode=UITextFieldViewModeWhileEditing;
    furnitureFilterPush.tag=3000;
    furnitureFilterPush.placeholder=@"双人沙发";
    furnitureFilterPush.borderStyle=UITextBorderStyleRoundedRect;
    furnitureFilterPush.backgroundColor=[UIColor whiteColor];
    [searchView addSubview:furnitureFilterPush];
    UIView* view1 = [[UIView alloc]initWithFrame:CGRectMake(10,0,20,0)];
    furnitureFilterPush.leftView=view1;
    searchImage=[[UIImageView alloc] initWithFrame:CGRectMake(8, 13, 14, 14)];
    searchImage.image=[UIImage imageNamed:@"search1"];
    [furnitureFilterPush addSubview:searchImage];
    furnitureFilterPush.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *orderSupView=[UIView new];
    orderSupView.tag=3001;
    orderSupView.backgroundColor=[UIColor clearColor];
    [searchView addSubview:orderSupView];
    orderSupView.sd_layout
    .leftSpaceToView(furnitureFilterPush,10)
    .rightSpaceToView(searchView,20)
    .topSpaceToView(searchView,10)
    .bottomSpaceToView(searchView,10);
    
    
    NSMutableArray *temp=[NSMutableArray new];
    NSArray *title=@[@"人气",@"销量",@"价格",@"筛选"];
    for (int i = 0; i < 4; i++) {
        UIButton *orderButton = [UIButton new];
        orderButton.backgroundColor=[UIColor clearColor];
        orderButton.tag=2003+i;
        [orderButton setTitle:title[i] forState:UIControlStateNormal];
        if (i==0) {    //默认按人气排
            [orderButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            orderButton.backgroundColor=[UIColor clearColor];
        }else{
            
            [orderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        if (i==3) {
            
            [orderButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];

        }else{
            [orderButton addTarget:self action:@selector(orderAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [orderSupView addSubview:orderButton];
        orderButton.sd_layout.autoHeightRatio(0.52);
       
        [temp addObject:orderButton];
        
       
    }

    UIView *orderButton = [orderSupView viewWithTag:2006];
    UIImageView *filteImage=[UIImageView new];
    filteImage.backgroundColor=[UIColor clearColor];
    filteImage.image=[UIImage imageNamed:@"selection"];
    [orderButton addSubview:filteImage];
    filteImage.sd_layout
    .leftSpaceToView(orderButton,0)
    .topSpaceToView(orderButton,12)
    .widthIs(15)
    .heightEqualToWidth();
    
    UIView *orderButton1 = [orderSupView viewWithTag:2005];
    UIImageView *filteImage1=[UIImageView new];
    filteImage1.tag=2007;
    filteImage1.backgroundColor=[UIColor clearColor];
    filteImage1.image=[UIImage imageNamed:@"price1"];
    [orderButton1 addSubview:filteImage1];
    filteImage1.sd_layout
    .rightSpaceToView(orderButton1,8)
    .topSpaceToView(orderButton1,10)
    .widthIs(10)
    .heightIs(18);
    
    // 关键步骤：设置类似collectionView的展示效果
    [orderSupView setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:4 verticalMargin:10 horizontalMargin:10 verticalEdgeInset:0 horizontalEdgeInset:0];
    
    furnitureCenter.sd_layout
    .leftSpaceToView(searchView,18)
    .topSpaceToView(searchView,10)
    .widthIs(80)
    .heightIs(40);
    
    ornament.sd_layout
    .leftSpaceToView(furnitureCenter,18)
    .topSpaceToView(searchView,10)
    .widthIs(80)
    .heightIs(40);
    
    thing.sd_layout
    .leftSpaceToView(ornament,18)
    .topSpaceToView(searchView,10)
    .widthIs(80)
    .heightIs(40);
    
    furnitureFilterPush.sd_layout
    .centerYEqualToView(searchView)
    .centerXEqualToView(searchView)
    .widthRatioToView(searchView,0.3)
    .heightIs(40);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:furnitureFilterPush];
    
}
-(void)textChange
{
    [self shopHttpData];
}

#pragma mark 添加筛选视图
//添加筛选视图子视图
-(void)addFilterSubView
{
    thefilterView=[[UIView alloc] initWithFrame:CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT)];
    thefilterView.backgroundColor=[UIColor colorWithRed:51/255.0 green:52/255.0 blue:51/255.0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:thefilterView];
    
    theFilterCanbutton=[[UIButton alloc] initWithFrame:CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT)];
    [theFilterCanbutton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    theFilterCanbutton.backgroundColor=[UIColor colorWithRed:51/255.0 green:52/255.0 blue:51/255.0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:theFilterCanbutton];
    
}

#pragma mark Action

//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

//确认筛选
-(void)filterSure
{
    if (self.addDataArr.count!=0) {
        [self.collect scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UICollectionViewScrollPositionNone
                                     animated:NO];
        
    }
    intPage = 1;
    [self.addDataArr removeAllObjects];
    [_collect reloadData];
    paramModel.page=@"1";
    [self shopHttpData];
    
    [UIView animateWithDuration:0.3 animations:^{
        //隐藏
        thefilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
        theFilterCanbutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
        filterCell.backgroundColor=[UIColor clearColor];
        cateCell.backgroundColor=[UIColor clearColor];
        isShowFilter=NO;
    }];

}

//搜索栏上button的选中状态
-(void)selectSubView1:(UIButton *)sendr
{
    for (UIButton *seaSubView in [searchView subviews]) {
        if (sendr.tag==seaSubView.tag) {
            [seaSubView setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            seaSubView.backgroundColor=[UIColor clearColor];
            
        }else if(seaSubView.tag!=3000  && seaSubView.tag!=3001 ){
            [seaSubView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            seaSubView.backgroundColor=[UIColor clearColor];
            
        }
        
    }

    
}
-(void)selectSubView2:(UIButton *)sender
{
    intPage=1;
    for (UIView *theorder in [searchView subviews]) {
        if (theorder.tag==3001) {
            
            UIView *theView=theorder;
            UIView *order=[searchView viewWithTag:3001];
            UIView *orderButton1 = [order viewWithTag:2005];
            UIImageView *filteImage1 = [orderButton1 viewWithTag:2007];
            
            for (UIButton *theorder in [theView subviews]) {
                
                if (self.addDataArr.count!=0) {    //colletionView存在个数的情况下才让他滚刀顶端
                    [self.collect scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                          atScrollPosition:UICollectionViewScrollPositionNone
                                                                  animated:NO];
                }
                
                if (theorder.tag==sender.tag) {
                    
                    if ([theorder.titleLabel.text isEqualToString:@"人气"]) {
                        [theorder setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                        paramModel.order=@"view_amount";
                        paramModel.page=@"1";
                        paramModel.ordername=@"desc";
                        [self shopHttpData];
                        filteImage1.image=[UIImage imageNamed:@"price1"];
                        
                    }else if ([theorder.titleLabel.text isEqualToString:@"销量"])
                    {
                        paramModel.order=@"sale_amount";
                        paramModel.page=@"1";
                        [theorder setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                        filteImage1.image=[UIImage imageNamed:@"price1"];
                        [self shopHttpData];
                        
                    }else  if (theorder.tag==2005) {  //只有价格有降序
                        
                        if (theorder.selected==NO) {
                            [theorder setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                            paramModel.order=@"price";
                            paramModel.ordername=@"asc";
                            paramModel.page=@"1";
                            filteImage1.image=[UIImage imageNamed:@"price2"];
                            [self shopHttpData];
                            theorder.selected=YES;
                            
                        }else{
                            [theorder setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                            paramModel.order=@"price";
                            paramModel.ordername=@"desc";
                            paramModel.page=@"1";
                            filteImage1.image=[UIImage imageNamed:@"price3"];
                            [self shopHttpData];
                            theorder.selected=NO;
                        }
                        
                    }else {
                        [theorder setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    }
                    
                    
                }else{
                    [theorder setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                }
            }
        }
        
    }
    
}
-(void)removeState
{
    for (UIView *theorder in [searchView subviews]) {
        if (theorder.tag==3001) {
            UIView *order=theorder;
            UIView *orderButton1 = [order viewWithTag:2005];
            UIImageView *filteImage1 = [orderButton1 viewWithTag:2007];
            filteImage1.image=[UIImage imageNamed:@"price1"];
            for (UIButton *orderbutton in [theorder subviews]) {
                if (orderbutton.tag==2003) {
                    [orderbutton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                }else{
                    [orderbutton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                }
                
            }
        }
    }
    
}

//家具中心
-(void)centerAction:(UIButton *)sendr
{
    if (self.addDataArr.count!=0) {
        [self.collect scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UICollectionViewScrollPositionNone
                                     animated:NO];
        
    }
    [self.addDataArr removeAllObjects];
    [_collect reloadData];
    [_selectStyleArray removeAllObjects];        //清空之前数据
    [_selectSpaceArray removeAllObjects];        //清空之前数据
    [_selectCategoryArray removeAllObjects];        //清空之前数据
 
    [self removeState];
    
    intPage=1;
    //默认

    paramModel.cateid = @"1";
    paramModel.page = @"1";
    paramModel.order = @"view_amount";
    paramModel.ordername = @"desc";
    paramModel.keyword = @"";
    paramModel.style = @"";
    paramModel.space = @"";
    paramModel.category = @"";
    paramModel.source = @"";
    paramModel.pagenum = @"20";
    
    [self shopHttpData];
    
    [self selectSubView1:sendr];
    
    filterTableView=nil;
    categoryTableView=nil;
    [self getLableHttpData];
    
}
-(void)ornamentAction:(UIButton *)sendr
{
    if (self.addDataArr.count!=0) {
        [self.collect scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UICollectionViewScrollPositionNone
                                     animated:NO];

    }
    [self.addDataArr removeAllObjects];
    [_collect reloadData];
    [_selectStyleArray removeAllObjects];        //清空之前数据
    [_selectSpaceArray removeAllObjects];        //清空之前数据
    [_selectCategoryArray removeAllObjects];        //清空之前数据;
    
    [self removeState];
    
    intPage=1;

    paramModel.cateid = @"2";
    paramModel.page = @"1";
    paramModel.order = @"view_amount";
    paramModel.ordername = @"desc";
    paramModel.keyword = @"";
    paramModel.style = @"";
    paramModel.space = @"";
    paramModel.category = @"";
    paramModel.source = @"";
    paramModel.pagenum = @"20";
    
    [self shopHttpData];
    
    [self selectSubView1:sendr];
    
    [self getLableHttpData];
    
}
-(void)thingAction:(UIButton *)sendr
{
    if (self.addDataArr.count!=0) {
        [self.collect scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UICollectionViewScrollPositionNone
                                     animated:NO];
        
    }
    [self.addDataArr removeAllObjects];
    [_collect reloadData];
    [_selectStyleArray removeAllObjects];        //清空之前数据
    [_selectSpaceArray removeAllObjects];        //清空之前数据
    [_selectCategoryArray removeAllObjects];        //清空之前数据
    
    [self removeState];
    
    intPage=1;

    paramModel.cateid = @"3";
    paramModel.page = @"1";
    paramModel.order = @"view_amount";
    paramModel.ordername = @"desc";
    paramModel.keyword = @"";
    paramModel.style = @"";
    paramModel.space = @"";
    paramModel.category = @"";
    paramModel.source = @"";
    paramModel.pagenum = @"20";
    
    [self shopHttpData];
    [self selectSubView1:sendr];
    [self getLableHttpData];
    
}
-(void)orderAction:(UIButton *)sender
{
    [_selectStyleArray removeAllObjects];        //清空之前数据
    [_selectSpaceArray removeAllObjects];        //清空之前数据
    [_selectCategoryArray removeAllObjects];        //清空之前数据
    
    [self selectSubView2:sender];
}

static bool styleBool=YES;
-(void)styleAction
{
    if (styleBool==YES) {
        styleViewBgm.sd_layout
        .heightIs(0.001);
        styleBool=NO;
        
        [styleButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    }else{
        // 开启动画
        [UIView animateWithDuration:0.6 animations:^{
            styleViewBgm.sd_layout
            .heightIs(styleHei);
            styleBool=YES;
        }];
        [styleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        
    }
    
    
}
static bool spaceBool=YES;
-(void)spaceAction
{
    // 开启动画
    [UIView animateWithDuration:0.6 animations:^{
        if (spaceBool==YES) {
            spaceViewBgm.sd_layout
            .heightIs(0.001);
            spaceBool=NO;
            [spaceButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }else{
            spaceViewBgm.sd_layout
            .heightIs(spaceHei);
            spaceBool=YES;
            [spaceButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            
        }
        
    }];
}
static bool souresBool=YES;
-(void)soureAction
{
    if (souresBool==YES) {
        soureViewBgm.sd_layout
        .heightIs(0.001);
        souresBool=NO;
        
        [souresButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    }else{
        // 开启动画
        [UIView animateWithDuration:0.6 animations:^{
            soureViewBgm.sd_layout
            .heightIs(souresHei);
            souresBool=YES;
        }];
        [souresButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        
    }
    
    
}

//是否展示筛选视图
static bool isShowFilter=NO;

-(void)filterAction:(UIButton*)sender
{
    if (lableArr.count==0) {
        
        YSKJ_TipViewCalss *tipView=[[YSKJ_TipViewCalss alloc] init];
        tipView.title = @"暂无分类！";
    
    }else{
        
        [self showFilterView];
        
    }
   
}

-(void)showFilterView
{
    // 开启动画
    [UIView animateWithDuration:0.3 animations:^{
        
    if (isShowFilter==NO) {
        thefilterView.frame=CGRectMake(THEWIDTH/2, 0, THEWIDTH/2, THEHEIGHT);
        theFilterCanbutton.frame=CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT);
        filterCell.backgroundColor=[UIColor whiteColor];
        cateCell.backgroundColor=[UIColor whiteColor];
        isShowFilter=YES;
    }else{
        //隐藏改变Y轴
        thefilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
        theFilterCanbutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
        isShowFilter=NO;
        filterCell.backgroundColor=[UIColor clearColor];
        cateCell.backgroundColor=[UIColor clearColor];
        
     }
   }];
}


#pragma mark DatabaseManagerDelegate

-(void)readDataBaseData:(NSArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    self.dbDataArr=array;
}

#pragma mark UITextFieldDelegate

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self shopHttpData];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if (furnitureFilterPush==textField) {
        if (string.length == 0)
            return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 80) {
            return NO;
        }
    }
    return YES;
    
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.addDataArr.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YSKJ_CheckCollectionViewCell *checkCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    YSKJ_ProDuctModel *model=[YSKJ_ProDuctModel mj_objectWithKeyValues:self.addDataArr[indexPath.row]];
    
    checkCell.url = model.thumb_file;

    checkCell.title = model.name;
    
    checkCell.price = model.price;
    
    checkCell.button.tag = 10000+indexPath.row;
    
    [checkCell.button addTarget:self action:@selector(proDuctAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.addDataArr.count-indexPath.row<8) {
        if (ishttpagain==YES) {
            if (ishttpData==YES) {
                intPage++;
                paramModel.page=[NSString stringWithFormat:@"%d",intPage];
                [self shopHttpData];
            }
            ishttpagain=NO;
        }
        
    }
    
    return checkCell;
}

-(void)proDuctAction:(UIButton *)sender
{
    for (int i=0; i<self.addDataArr.count; i++) {
        if (i==sender.tag-10000) {
            YSKJ_FuritureInfoViewController *info=[[YSKJ_FuritureInfoViewController alloc] init];
            info.hidesBottomBarWhenPushed=YES;
            info.proDuctId=[self.addDataArr[i] objectForKey:@"id"];
            [self.navigationController pushViewController:info animated:YES];
            
            for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
                
                if (subView.tag == 1000) {
                    
                    subView.hidden = YES;
                    
                }
            }
        }
    }
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {17,18,12,18};
    return top;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==filterTableView) {
        
        NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",(long)indexPath.section,(long)indexPath.row];
        filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (filterCell == nil) {
            
            filterCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            filterCell.selectionStyle=UITableViewCellSelectionStyleNone;
            tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            filterCell.backgroundColor=[UIColor clearColor];
            
            [self addSouresViewWithTableCell:filterCell souresArray:_sourceArray];
            [self addStyleViewWithTableCell:filterCell styleArray:_styleArray];
            [self addSpaceViewWithTableCell:filterCell styleArray:_spaceArray];
            [self addCategoryViewWithTableCell:filterCell styleArray:_categoryArray];
            
            
            
        }
        
        return filterCell;

    }else{
        
        NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",(long)indexPath.section,(long)indexPath.row];
        cateCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cateCell == nil) {
            cateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cateCell.selectionStyle=UITableViewCellSelectionStyleNone;
            tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            cateCell.backgroundColor=[UIColor clearColor];
            
            UIButton *sure=[UIButton new];
            sure.backgroundColor=[UIColor clearColor];
            [sure setTitle:@"返回" forState:UIControlStateNormal];
            UIColor *titleColor=UIColorFromHex(0x666666);
            [sure setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            sure.titleLabel.font=[UIFont systemFontOfSize:14];
            [sure setTitleColor:titleColor forState:UIControlStateNormal];
            [sure setImage:[UIImage imageNamed:@"direction"] forState:UIControlStateNormal];
            sure.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
            [sure addTarget:self action:@selector(returnToCate) forControlEvents:UIControlEventTouchUpInside];
            [cateCell addSubview:sure];
            sure.sd_layout
            .leftSpaceToView(cateCell,20)
            .topSpaceToView(cateCell,20)
            .widthIs(100)
            .heightIs(40);
            
            UILabel *filterLable=[UILabel new];
            filterLable.text=@"品类";
            filterLable.font=[UIFont systemFontOfSize:24];
            filterLable.textColor=UIColorFromHex(0x333333);
            filterLable.textAlignment=NSTextAlignmentCenter;
            filterLable.backgroundColor=[UIColor clearColor];
            [cateCell addSubview:filterLable];
            filterLable.sd_layout
            .centerXEqualToView(cateCell)
            .centerYEqualToView(cateCell)
            .topSpaceToView(cateCell,20)
            .widthRatioToView(cateCell,0.3)
            .heightIs(40);

            UIView *lineView=[UIView new];
            lineView.tag=1000;
            lineView.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.6];
            [cateCell addSubview:lineView];
            lineView.sd_layout
            .leftSpaceToView(cateCell,0)
            .rightSpaceToView(cateCell,0)
            .heightIs(1)
            .topSpaceToView(cateCell,61);
            
            NSMutableArray *heiArr=[[NSMutableArray alloc] init];
            for (int i=0; i<categoryArray.count; i++) {
                
                NSDictionary *cateDict=categoryArray[i];
                NSMutableArray *cateArr=[cateDict objectForKey:@"data"];
                
                NSInteger row=cateArr.count/4;
                NSInteger hasRemainder=cateArr.count%4;
                if (hasRemainder==0) {
                }else{
                    row=row+1;
                }
                float hei=row*28+(row+1)*10;
                
                [heiArr addObject:[NSString stringWithFormat:@"%f",hei]];
                
                [self addCategorySubViewTableCell:cateCell styleArray:cateDict indexPath:i heiArr:heiArr];
            }

        }
        
        return cateCell;
    }

}

#pragma  mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView==filterTableView) {
        return 1000;
    }else{
        return 1500;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark 添加资源
-(void)addSouresViewWithTableCell:(UITableViewCell *)tabCell souresArray:(NSMutableArray *)souresArr
{
    UIButton *sure=[UIButton new];
    [sure setTitleColor:[UIColor colorWithRed:243/255.0 green:42/255.0 blue:0 alpha:1] forState:UIControlStateNormal];
    sure.titleLabel.font=[UIFont systemFontOfSize:14];
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    [sure addTarget:self action:@selector(filterSure) forControlEvents:UIControlEventTouchUpInside];
    [tabCell addSubview:sure];
    sure.sd_layout
    .rightSpaceToView(tabCell,20)
    .topSpaceToView(tabCell,20)
    .widthIs(60)
    .heightIs(40);

    UILabel *filterLable=[UILabel new];
    filterLable.text=@"筛选";
    filterLable.font=[UIFont systemFontOfSize:24];
    filterLable.textColor=UIColorFromHex(0x333333);
    filterLable.textAlignment=NSTextAlignmentCenter;
    filterLable.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:filterLable];
    filterLable.sd_layout
    .centerXEqualToView(tabCell)
    .centerYEqualToView(tabCell)
    .topSpaceToView(tabCell,20)
    .widthRatioToView(tabCell,0.3)
    .heightIs(40);
    
    UIView *lineView=[UIView new];
    lineView.tag=1000;
    lineView.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.6];
    [tabCell addSubview:lineView];
    lineView.sd_layout
    .leftSpaceToView(tabCell,0)
    .rightSpaceToView(tabCell,0)
    .heightIs(1)
    .topSpaceToView(tabCell,61);
    
    UILabel *styleLable=[UILabel new];
    styleLable.text=@"类型";
    styleLable.textColor=UIColorFromHex(0x999999);
    styleLable.font=[UIFont systemFontOfSize:14];
    styleLable.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:styleLable];
    styleLable.sd_layout
    .leftSpaceToView(tabCell,30)
    .topSpaceToView(lineView,10)
    .widthIs(60)
    .heightIs(32);
    
    souresButton=[UIButton new];
    [souresButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    souresButton.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:souresButton];
    souresButton.sd_layout
    .rightSpaceToView(tabCell,16)
    .heightIs(16)
    .widthEqualToHeight()
    .topSpaceToView(lineView,15);
    
    UIButton *soures=[UIButton new];
    [tabCell addSubview: soures];
    [soures addTarget:self action:@selector(soureAction) forControlEvents:UIControlEventTouchUpInside];
    soures.sd_layout
    .rightSpaceToView(tabCell,0)
    .heightIs(50)
    .widthIs(80)
    .topSpaceToView(lineView,0);
    
    soureViewBgm=[UIView new];
    [tabCell addSubview:soureViewBgm];
    soureViewBgm.sd_layout
    .leftSpaceToView(tabCell,30)
    .rightSpaceToView(tabCell,10)
    .heightIs(500)
    .topSpaceToView(styleLable,0);

    [self addsouresScroolView:soureViewBgm withData:souresArr withTag:3];
}
static float souresHei;
-(void)addsouresScroolView:(UIView *)supView withData:(NSMutableArray *)dataArr withTag:(int)Tag
{
    NSInteger row=dataArr.count/4;
    NSInteger hasRemainder=dataArr.count%4;
    if (hasRemainder==0) {
        
    }else{
        row=row+1;
    }
    souresHei=row*28+(row+1)*10;
    supView.sd_layout
    .heightIs(row*28+(row+1)*10);
    [supView updateLayout];
    
    UIScrollView *scroll = [UIScrollView new];
    scroll.tag=7003;
    [supView addSubview:scroll];
    scroll.backgroundColor=[UIColor clearColor];
    // 设置scrollview与父view的边
    scroll.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    UIView *subVIew=[UIView new];
    subVIew.tag=3005;
    subVIew.backgroundColor=[UIColor clearColor];
    [scroll addSubview:subVIew];
    subVIew.sd_layout
    .leftEqualToView(scroll)
    .rightEqualToView(scroll)
    .topEqualToView(scroll);
    
    NSMutableArray *temp=[NSMutableArray new];
    
    if (Tag==3) {
        
        for (int i = 0; i < dataArr.count; i++) {
            
            UIView *viewbg=[UIView new];
            viewbg.tag=6000+i;
            [subVIew addSubview:viewbg];
            viewbg.sd_layout.autoHeightRatio(0.25);
            
            UIButton *filterText= [UIButton new];
            filterText.tag=6000+i;
            UIColor *titleColor=UIColorFromHex(0x333333);
            [filterText setTitleColor:titleColor forState:UIControlStateNormal];
            filterText.backgroundColor=[UIColor clearColor];
            filterText.layer.borderColor=[UIColor clearColor].CGColor;
            filterText.layer.borderWidth=1;
            [filterText setTitle:dataArr[i] forState:UIControlStateNormal];
            [filterText addTarget:self action:@selector(getSouresAction:) forControlEvents:UIControlEventTouchUpInside];
            filterText.titleLabel.font=[UIFont systemFontOfSize:14];
            [viewbg addSubview:filterText];
            
            NSDictionary *attribute = @{NSFontAttributeName: filterText.titleLabel.font};
            CGSize labelsize  = [filterText.titleLabel.text boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            filterText.layer.cornerRadius=(labelsize.height+10)/2;
            filterText.layer.masksToBounds=YES;
            
            filterText.sd_layout
            .heightIs(labelsize.height+10)
            .widthIs(labelsize.width+28)
            .topSpaceToView(viewbg,0)
            .bottomSpaceToView(viewbg,0);
            
            [temp addObject:viewbg];
            
        }
        
    }
    // 关键步骤：设置类似collectionView的展示效果
    [subVIew setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:4 verticalMargin:10 horizontalMargin:10 verticalEdgeInset:10 horizontalEdgeInset:0];
    // 设置scrollview的contentsize自适应
    [scroll setupAutoContentSizeWithBottomView:subVIew bottomMargin:0];
    
}
-(void)getSouresAction:(UIButton *)sender
{
    [_selectSouresArray removeAllObjects];        //清空之前数据
    for (UIView *styleSubView in [soureViewBgm subviews]) {
        if (styleSubView.tag==7003) {
            for (UIView *thesubView in [styleSubView subviews]) {
                if (thesubView.tag==3005) {
                    for (UIView *subView in [thesubView subviews]) {
                        
                        for (UIButton *sub in subView.subviews) {
                            
                            if (sub.tag==sender.tag) {
                                if (sub.selected==NO) {
                                    sub.selected=YES;
                                    UIColor *titleColor=UIColorFromHex(0xf39800);
                                    sub.layer.borderColor=titleColor.CGColor;
                                    [sub setTitleColor:titleColor forState:UIControlStateNormal];
                                }else{
                                    sub.selected=NO;
                                    sub.layer.borderColor=[UIColor clearColor].CGColor;
                                    UIColor *titleColor=UIColorFromHex(0x333333);
                                    [sub setTitleColor:titleColor forState:UIControlStateNormal];
                                }
                            }
                            if (sub.selected==YES) {
                                [_selectSouresArray addObject:sub.titleLabel.text];
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
    }
    
    paramModel.source=[_selectSouresArray componentsJoinedByString:@","];
    
    
}

#pragma mark 添加风格
-(void)addStyleViewWithTableCell:(UITableViewCell *)tabCell styleArray:(NSMutableArray *)styleArr
{
 
    UIView *lineView=[UIView new];
    lineView.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.3];
    [tabCell addSubview:lineView];
    lineView.sd_layout
    .leftSpaceToView(tabCell,0)
    .rightSpaceToView(tabCell,0)
    .heightIs(1)
    .topSpaceToView(soureViewBgm,10);
    
    UILabel *styleLable=[UILabel new];
    styleLable.text=@"风格";
    styleLable.textColor=UIColorFromHex(0x999999);
    styleLable.font=[UIFont systemFontOfSize:14];
    styleLable.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:styleLable];
    styleLable.sd_layout
    .leftSpaceToView(tabCell,30)
    .topSpaceToView(lineView,10)
    .widthIs(60)
    .heightIs(32);
    
    styleButton=[UIButton new];
    [styleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    styleButton.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:styleButton];
    styleButton.sd_layout
    .rightSpaceToView(tabCell,16)
    .heightIs(16)
    .widthEqualToHeight()
    .topSpaceToView(lineView,15);
    
    UIButton *style=[UIButton new];
    [tabCell addSubview: style];
    [style addTarget:self action:@selector(styleAction) forControlEvents:UIControlEventTouchUpInside];
    style.sd_layout
    .rightSpaceToView(tabCell,0)
    .heightIs(50)
    .widthIs(80)
    .topSpaceToView(lineView,0);
    
    
    styleViewBgm=[UIView new];
    [tabCell addSubview:styleViewBgm];
    styleViewBgm.sd_layout
    .leftSpaceToView(tabCell,30)
    .rightSpaceToView(tabCell,10)
    .heightIs(500)
    .topSpaceToView(styleLable,0);
    
    
    [self addScroolView1:styleViewBgm withData:styleArr withTag:1];
    
}
static float styleHei;
-(void)addScroolView1:(UIView *)supView withData:(NSMutableArray *)dataArr withTag:(int)Tag
{
    NSInteger row=dataArr.count/4;
    NSInteger hasRemainder=dataArr.count%4;
    if (hasRemainder==0) {
        
    }else{
        row=row+1;
    }
    styleHei=row*28+(row+1)*10;
    supView.sd_layout
    .heightIs(row*28+(row+1)*10);
    [supView updateLayout];

    UIScrollView *scroll = [UIScrollView new];
    scroll.tag=7001;
    [supView addSubview:scroll];
    scroll.backgroundColor=[UIColor clearColor];
    // 设置scrollview与父view的边
    scroll.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    UIView *subVIew=[UIView new];
    subVIew.tag=3003;
    subVIew.backgroundColor=[UIColor clearColor];
    [scroll addSubview:subVIew];
    subVIew.sd_layout
    .leftEqualToView(scroll)
    .rightEqualToView(scroll)
    .topEqualToView(scroll);
    
    NSMutableArray *temp=[NSMutableArray new];
    
    if (Tag==1) {
        
        for (int i = 0; i < dataArr.count; i++) {
            
            UIView *viewbg=[UIView new];
            viewbg.tag=4000+i;
            [subVIew addSubview:viewbg];
            viewbg.sd_layout.autoHeightRatio(0.25);

            UIButton *filterText= [UIButton new];
            filterText.tag=4000+i;
            UIColor *titleColor=UIColorFromHex(0x333333);
            [filterText setTitleColor:titleColor forState:UIControlStateNormal];
            filterText.backgroundColor=[UIColor clearColor];
            filterText.layer.borderColor=[UIColor clearColor].CGColor;
            filterText.layer.borderWidth=1;
            [filterText setTitle:dataArr[i] forState:UIControlStateNormal];
            [filterText addTarget:self action:@selector(getStyleAction:) forControlEvents:UIControlEventTouchUpInside];
            filterText.titleLabel.font=[UIFont systemFontOfSize:14];
            [viewbg addSubview:filterText];
            
            NSDictionary *attribute = @{NSFontAttributeName: filterText.titleLabel.font};
            CGSize labelsize  = [filterText.titleLabel.text boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            filterText.layer.cornerRadius=(labelsize.height+10)/2;
            filterText.layer.masksToBounds=YES;
            
            filterText.sd_layout
            .heightIs(labelsize.height+10)
            .widthIs(labelsize.width+28)
            .topSpaceToView(viewbg,0)
            .bottomSpaceToView(viewbg,0);
            
            [temp addObject:viewbg];

        }
        
    }
    // 关键步骤：设置类似collectionView的展示效果
    [subVIew setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:4 verticalMargin:10 horizontalMargin:10 verticalEdgeInset:10 horizontalEdgeInset:0];
    // 设置scrollview的contentsize自适应
    [scroll setupAutoContentSizeWithBottomView:subVIew bottomMargin:0];
    
}
-(void)getStyleAction:(UIButton *)sender
{
    [_selectStyleArray removeAllObjects];        //清空之前数据
    
    for (UIView *styleSubView in [styleViewBgm subviews]) {
        if (styleSubView.tag==7001) {
            for (UIView *thesubView in [styleSubView subviews]) {
                if (thesubView.tag==3003) {
                    for (UIView *subView in [thesubView subviews]) {
                            for (UIButton *sub in subView.subviews) {
                                if (sub.tag==sender.tag) {
                                    if (sub.selected==NO) {
                                        sub.selected=YES;
                                        UIColor *titleColor=UIColorFromHex(0xf39800);
                                        sub.layer.borderColor=titleColor.CGColor;
                                        [sub setTitleColor:titleColor forState:UIControlStateNormal];
                                    }else{
                                        sub.selected=NO;
                                        sub.layer.borderColor=[UIColor clearColor].CGColor;
                                        UIColor *titleColor=UIColorFromHex(0x333333);
                                        [sub setTitleColor:titleColor forState:UIControlStateNormal];
                                    }
                                }
                                if (sub.selected==YES) {
                                    [_selectStyleArray addObject:sub.titleLabel.text];
                                }
                                
                            }
                        
                }
            }
        }
        
    }
    paramModel.style=[_selectStyleArray componentsJoinedByString:@","];
    
 }
}
#pragma mark 添加空间
-(void)addSpaceViewWithTableCell:(UITableViewCell *)tabCell styleArray:(NSMutableArray *)styleArr
{
    UIView *lineView=[UIView new];
    lineView.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.3];
    [tabCell addSubview:lineView];
    lineView.sd_layout
    .leftSpaceToView(tabCell,10)
    .rightSpaceToView(tabCell,10)
    .heightIs(1)
    .topSpaceToView(styleViewBgm,10);
    
    UILabel *styleLable=[UILabel new];
    styleLable.text=@"空间";
    styleLable.textColor=UIColorFromHex(0x999999);
    styleLable.font=[UIFont systemFontOfSize:14];
    styleLable.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:styleLable];
    styleLable.sd_layout
    .leftSpaceToView(tabCell,30)
    .topSpaceToView(lineView,10)
    .widthIs(60)
    .heightIs(32);
    
    spaceButton=[UIButton new];
    [spaceButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    spaceButton.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:spaceButton];
    spaceButton.sd_layout
    .rightSpaceToView(thefilterView,16)
    .heightIs(16)
    .widthEqualToHeight()
    .topSpaceToView(lineView,15);
    
    UIButton *style=[UIButton new];
    [tabCell addSubview: style];
    [style addTarget:self action:@selector(spaceAction) forControlEvents:UIControlEventTouchUpInside];
    style.backgroundColor=[UIColor clearColor];
    style.sd_layout
    .rightSpaceToView(tabCell,0)
    .heightIs(50)
    .widthIs(80)
    .topSpaceToView(lineView,0);
    
    
    spaceViewBgm=[UIView new];
    [tabCell addSubview:spaceViewBgm];
    spaceViewBgm.sd_layout
    .leftSpaceToView(tabCell,30)
    .rightSpaceToView(tabCell,10)
    .heightIs(80)
    .topSpaceToView(styleLable,0);
    
    
    [self addScroolView2:spaceViewBgm withData:styleArr withTag:2];

}
static float spaceHei;
-(void)addScroolView2:(UIView *)supView withData:(NSMutableArray *)dataArr withTag:(int)Tag
{
    NSInteger row=dataArr.count/4;
    NSInteger hasRemainder=dataArr.count%4;
    if (hasRemainder==0) {
        
    }else{
        row=row+1;
    }
    spaceHei=row*28+(row+1)*10;
    supView.sd_layout
    .heightIs(spaceHei);
    [supView updateLayout];
    
    
    UIScrollView *scroll = [UIScrollView new];
    scroll.tag=7000+Tag;
    [supView addSubview:scroll];
    scroll.backgroundColor=[UIColor clearColor];
    // 设置scrollview与父view的边
    scroll.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    UIView *subVIew=[UIView new];
    subVIew.tag=3002+Tag;
    subVIew.backgroundColor=[UIColor clearColor];
    [scroll addSubview:subVIew];
    subVIew.sd_layout
    .leftEqualToView(scroll)
    .rightEqualToView(scroll)
    .topEqualToView(scroll);
    
    NSMutableArray *temp=[NSMutableArray new];
    
    if (Tag==2) {
        for (int i = 0; i < dataArr.count; i++) {
            UIView *viewbg=[UIView new];
            viewbg.tag=5000+i;
            [subVIew addSubview:viewbg];
            viewbg.sd_layout.autoHeightRatio(0.25);
            
            UIButton *filterText= [UIButton new];
            filterText.tag=5000+i;
            UIColor *titleColor=UIColorFromHex(0x333333);
            [filterText setTitleColor:titleColor forState:UIControlStateNormal];
            filterText.backgroundColor=[UIColor clearColor];
            filterText.layer.borderColor=[UIColor clearColor].CGColor;
            filterText.layer.borderWidth=1;
            [filterText setTitle:dataArr[i] forState:UIControlStateNormal];
            [filterText addTarget:self action:@selector(getSpaceAction:) forControlEvents:UIControlEventTouchUpInside];
            filterText.titleLabel.font=[UIFont systemFontOfSize:14];
            [viewbg addSubview:filterText];
            
            NSDictionary *attribute = @{NSFontAttributeName: filterText.titleLabel.font};
            CGSize labelsize  = [filterText.titleLabel.text boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            filterText.layer.cornerRadius=(labelsize.height+10)/2;
            filterText.layer.masksToBounds=YES;
            
            filterText.sd_layout
            .heightIs(labelsize.height+10)
            .widthIs(labelsize.width+28)
            .topSpaceToView(viewbg,0)
            .bottomSpaceToView(viewbg,0);
            
            [temp addObject:viewbg];

            
        }
        
    }
    // 关键步骤：设置类似collectionView的展示效果
    [subVIew setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:4 verticalMargin:10 horizontalMargin:10 verticalEdgeInset:10 horizontalEdgeInset:0];
    // 设置scrollview的contentsize自适应
    [scroll setupAutoContentSizeWithBottomView:subVIew bottomMargin:0];
    
}
-(void)getSpaceAction:(UIButton *)sender
{
    [_selectSpaceArray removeAllObjects];        //清空之前数据
    for (UIView *styleSubView in [spaceViewBgm subviews]) {
        if (styleSubView.tag==7002) {
            for (UIView *thesubView in [styleSubView subviews]) {
                if (thesubView.tag==3004) {
                    for (UIView *subView in [thesubView subviews]) {
                    
                            for (UIButton *sub in subView.subviews) {
       
                                if (sub.tag==sender.tag) {
                                    if (sub.selected==NO) {
                                        sub.selected=YES;
                                        UIColor *titleColor=UIColorFromHex(0xf39800);
                                        sub.layer.borderColor=titleColor.CGColor;
                                        [sub setTitleColor:titleColor forState:UIControlStateNormal];
                                    }else{
                                        sub.selected=NO;
                                        sub.layer.borderColor=[UIColor clearColor].CGColor;
                                        UIColor *titleColor=UIColorFromHex(0x333333);
                                        [sub setTitleColor:titleColor forState:UIControlStateNormal];
                                    }
                                }
                                if (sub.selected==YES) {
                                    [_selectSpaceArray addObject:sub.titleLabel.text];
                                }
                                
                            }

                    }
                }
            }
        }
        
    }
    
     paramModel.space=[_selectSpaceArray componentsJoinedByString:@","];

    
}
#pragma mark 添加品类
-(void)addCategoryViewWithTableCell:(UITableViewCell *)tabCell styleArray:(NSMutableArray *)styleArr
{
    UIView *lineView=[UIView new];
    lineView.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.3];
    [tabCell addSubview:lineView];
    lineView.sd_layout
    .leftSpaceToView(tabCell,10)
    .rightSpaceToView(tabCell,10)
    .heightIs(1)
    .topSpaceToView(spaceViewBgm,10);
    
    UIView *lineView1=[UIView new];
    lineView1.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.3];
    [tabCell addSubview:lineView1];
    lineView1.sd_layout
    .leftSpaceToView(tabCell,10)
    .rightSpaceToView(tabCell,10)
    .heightIs(1)
    .topSpaceToView(lineView,52);
    
    UILabel  *titlelable=[UILabel new];
    titlelable.tag=3000;
    UIColor *titleColor=UIColorFromHex(0x999999);
    titlelable.textColor=titleColor;
    titlelable.textAlignment=NSTextAlignmentLeft;
    titlelable.text=@"品类";
    titlelable.font=[UIFont systemFontOfSize:14];
    [tabCell addSubview:titlelable];
    titlelable.sd_layout
    .leftSpaceToView(tabCell,30)
    .topSpaceToView(lineView,0)
    .widthIs(thefilterView.size.width-12)
    .heightIs(52);
    
    UIButton *button=[[UIButton alloc] init];
    button.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:button];
    [button addTarget:self action:@selector(showSubCategory) forControlEvents:UIControlEventTouchUpInside];
    button.sd_layout
    .leftSpaceToView(tabCell,0)
    .topSpaceToView(lineView,0)
    .heightIs(52)
    .widthIs(thefilterView.size.width);
    
    categoryButton=[UIButton new];
    [categoryButton setImage:[UIImage imageNamed:@"category"] forState:UIControlStateNormal];
    categoryButton.backgroundColor=[UIColor clearColor];
    [categoryButton addTarget:self action:@selector(showSubCategory) forControlEvents:UIControlEventTouchUpInside];
    [tabCell addSubview:categoryButton];
    categoryButton.sd_layout
    .rightSpaceToView(tabCell,16)
    .heightIs(16)
    .widthEqualToHeight()
    .topSpaceToView(lineView,18);
    
}
-(void)showSubCategory
{
    // 开启动画
    [UIView animateWithDuration:0.25 animations:^{
        categoryTableView.frame=CGRectMake(0, 0, thefilterView.size.width, THEHEIGHT);
    }];
    
}
-(void)returnToCate
{
    UILabel *lable=[filterCell viewWithTag:3000];
    NSString *countStr=[NSString stringWithFormat:@"%lu",(unsigned long)_selectCategoryArray.count];
    NSString *buttonStr;
    if (_selectCategoryArray.count==0) {
        buttonStr=[NSString stringWithFormat:@"%@",@"品类"];
    }else{
        buttonStr=[NSString stringWithFormat:@"%@  已选择%@项",@"品类",countStr];
    }
    UIColor *titleColor=UIColorFromHex(0xf39800);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonStr]; // 改变特定范围颜色大小要用的
    [attributedString addAttribute:NSForegroundColorAttributeName value:titleColor range:NSMakeRange(2,buttonStr.length-2)];
    lable.attributedText=attributedString;
   
    categoryTableView.frame=CGRectMake(thefilterView.size.width, 0, thefilterView.size.width, THEHEIGHT);
}
-(void)addCategorySubViewTableCell:(UITableViewCell *)tabCell styleArray:(NSDictionary *)cateDict indexPath:(int)indexPath heiArr:(NSMutableArray*)heiArr
{
    //NSLog(@"cateDict=%@",cateDict);
    float hei=[heiArr[indexPath] floatValue];

    int addhei = 0;
    for (int i = 0; i < heiArr.count-1 ; i++)
    {
        int temp = 0;
        for (int j = 0; j <= i; j++)
        {
            NSString *index=heiArr[j];
            int tempIndex=[index intValue];
            temp = temp + tempIndex;
            addhei=temp;
        }
    }
    UIView *line=[tabCell viewWithTag:1000];

    UIView *cateViewBgm=[UIView new];
    cateViewBgm.tag=6000+indexPath;
    cateViewBgm.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:cateViewBgm];
    cateViewBgm.sd_layout
    .leftSpaceToView(tabCell,30)
    .rightSpaceToView(tabCell,10)
    .heightIs(hei)
    .topSpaceToView(line,42*(indexPath+1)+addhei);
    
    UILabel *styleLable=[UILabel new];
    styleLable.text=[cateDict objectForKey:@"display_name"];
    styleLable.textColor=UIColorFromHex(0x999999);
    styleLable.font=[UIFont systemFontOfSize:14];
    styleLable.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:styleLable];
    styleLable.sd_layout
    .leftSpaceToView(tabCell,30)
    .bottomSpaceToView(cateViewBgm,0)
    .widthIs(60)
    .heightIs(32);
    
    UIView *lineView=[UIView new];
    lineView.backgroundColor=UIColorFromHex(0xd8d8d8);
    [tabCell addSubview:lineView];
    lineView.sd_layout
    .leftSpaceToView(tabCell,12)
    .rightSpaceToView(tabCell,12)
    .heightIs(1)
    .topSpaceToView(cateViewBgm,0);
    
    [self addScroolView:cateViewBgm withData:[cateDict objectForKey:@"data"] withPath:indexPath];
    
}
-(void)addScroolView:(UIView *)supView withData:(NSMutableArray *)dataArr withPath:(int)indexPath{
    UIScrollView *scroll = [UIScrollView new];
    scroll.tag=7000+indexPath;
    [supView addSubview:scroll];
    scroll.backgroundColor=[UIColor clearColor];
    // 设置scrollview与父view的边
    scroll.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    UIView *subVIew=[UIView new];
    subVIew.tag=8000+indexPath;
    subVIew.backgroundColor=[UIColor clearColor];
    [scroll addSubview:subVIew];
    subVIew.sd_layout
    .leftEqualToView(scroll)
    .rightEqualToView(scroll)
    .topEqualToView(scroll);
    
    NSMutableArray *temp=[NSMutableArray new];
    
        for (int i = 0; i < dataArr.count; i++) {
            UIView *viewbg=[UIView new];
            [subVIew addSubview:viewbg];
            viewbg.sd_layout.autoHeightRatio(0.25);
            
            UIButton *filterText= [UIButton new];
            NSDictionary *dict=dataArr[i];
            
            UIColor *titleColor=UIColorFromHex(0x333333);
            [filterText setTitleColor:titleColor forState:UIControlStateNormal];
            filterText.backgroundColor=[UIColor clearColor];
            filterText.layer.borderColor=[UIColor clearColor].CGColor;
            filterText.layer.borderWidth=1;
            
            [filterText setTitle:[dict objectForKey:@"display_name"] forState:UIControlStateNormal];
            [filterText addTarget:self action:@selector(getCateAction:) forControlEvents:UIControlEventTouchUpInside];
            
            filterText.titleLabel.font=[UIFont systemFontOfSize:14];
            [viewbg addSubview:filterText];
            
            NSDictionary *attribute = @{NSFontAttributeName: filterText.titleLabel.font};
            CGSize labelsize  = [filterText.titleLabel.text boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            filterText.layer.cornerRadius=(labelsize.height+10)/2;
            filterText.layer.masksToBounds=YES;
        
            filterText.sd_layout
            .heightIs(labelsize.height+10)
            .widthIs(labelsize.width+28)
            .topSpaceToView(viewbg,0)
            .bottomSpaceToView(viewbg,0);
            //tag相隔100,防止出现重复，
            if (indexPath==0) {
                viewbg.tag=i+8000;
                filterText.tag=i+8000;
            }else if (indexPath==1)
            {
                viewbg.tag=i+8100;
                filterText.tag=i+8100;
            }
            else if (indexPath==2)
            {
                viewbg.tag=i+8200;
                filterText.tag=i+8200;
            }
            else if (indexPath==3)
            {
                viewbg.tag=i+8300;
                filterText.tag=i+8300;
            }
            else if (indexPath==4)
            {
                viewbg.tag=i+8400;
                filterText.tag=i+8400;
            }
            else if (indexPath==5)
            {
                viewbg.tag=i+8500;
                filterText.tag=i+8500;
            }
            else if (indexPath==6)
            {
                viewbg.tag=i+8600;
                filterText.tag=i+8600;
            }
            else if (indexPath==7)
            {
                viewbg.tag=i+8700;
                filterText.tag=i+8700;
            }
            else if (indexPath==8)
            {
                viewbg.tag=i+8800;
                filterText.tag=i+8800;
            }
            else if (indexPath==9)
            {
                viewbg.tag=i+8900;
                filterText.tag=i+8900;
            }

            [temp addObject:viewbg];

    }
    // 关键步骤：设置类似collectionView的展示效果
    [subVIew setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:4 verticalMargin:10 horizontalMargin:10 verticalEdgeInset:10 horizontalEdgeInset:0];
    // 设置scrollview的contentsize自适应
    [scroll setupAutoContentSizeWithBottomView:subVIew bottomMargin:0];
    
}
-(void)getCateAction:(UIButton *)sender
{
    [_selectCategoryArray removeAllObjects];
    for (UIView *subView in cateCell.subviews) {
        //NSLog(@"subView=%@",subView);
        if (subView.tag>=6000) {     //找到cateViewBgm
            //NSLog(@"subView=%@",subView);
            for (UIView *scroll in subView.subviews){
                if (scroll.tag>=7000) {     //找到scroll
                  //  NSLog(@"scroll=%@",scroll);
                    for (UIView *subVIew in scroll.subviews){
                        if (subVIew.tag>=8000) {
                            //NSLog(@"subVIew=%@",subVIew);
                            for (UIView *viewbg in scroll.subviews) {
                                //NSLog(@"viewbg=%@",viewbg);
                                for (UIView *filterText in viewbg.subviews) {
//                                    NSLog(@"filterText=%@",filterText);
                                    for (UIView *sub in filterText.subviews) {
                                        //NSLog(@"sub=%@",sub);
                                        UIButton *filterButton=(UIButton*)sub;
                                        if (sub.tag==sender.tag) {   //找到选中的button
                                            if (filterButton.selected==NO) {
                                                filterButton.selected=YES;
                                                UIColor *titleColor=UIColorFromHex(0xf39800);
                                                filterButton.layer.borderColor=titleColor.CGColor;
                                                [filterButton setTitleColor:titleColor forState:UIControlStateNormal];
                                            }else{
                                                filterButton.selected=NO;
                                                filterButton.layer.borderColor=[UIColor clearColor].CGColor;
                                                UIColor *titleColor=UIColorFromHex(0x333333);
                                                [filterButton setTitleColor:titleColor forState:UIControlStateNormal];
                                                
                                            }
                                        }
                                        if (filterButton.selected==YES) {
                                            [_selectCategoryArray addObject:filterButton.titleLabel.text];
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    paramModel.category=[_selectCategoryArray componentsJoinedByString:@","];
}


@end
