//
//  YSKJ_PersonCenterViewController.m
//  YSKJ
//
//  Created by 羊德元 on 2016/11/14.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_PersonCenterViewController.h"
#import "UIView+SDAutoLayout.h"
#import "HttpRequestCalss.h"
#import "YSKJ_LoginViewController.h"
#import "DatabaseManager.h"
#import "AnimatedGif.h"
#import "ToolClass.h"
#import "YSKJ_ForGetPasswordViewController.h"
#import <Qiniu/QiniuSDK.h>
#import "NSString+MD5.h"
#import "YSKJ_SaveWebImageClass.h"
#import "YSKJ_OrderDetailTableViewCell.h"

#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "YSKJ_OrderDetailModel.h"

#import "YSKJ_OrderProjectDetailViewController.h"

#import <MJExtension/MJExtension.h>

#import "YSKJ_leftMenuView.h"

#import "YSKJ_AdduploadProdctView.h"

#import "YSKJ_AdduploadSpaceView.h"

#import "YSKJ_SaleKlineView.h"

#import "YSKJ_SalesReportView.h"

#import "YSKJ_TargetDataView.h"

#import "YSKJ_TitleView.h"

#import "QLCycleProgressView.h"

#import "YSKJ_OrderNaviBarView.h"

#import "YSKJ_OrderOperationView.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define PICURL @"http://odso4rdyy.qnssl.com/"                    //图片固定地址

#define LINEOFFURL  @"http://"API_DOMAIN@"/user/productoffonline"  //离线商品数据

#define LINEOFFSPACE  @"http://"API_DOMAIN@"/user/bgoffonline"  //离线商品数据

#define GETTOKEN @"http://"API_DOMAIN@"/sysconfig/gettoken" //得到token

#define UPDATEHEAD @"http://"API_DOMAIN@"/user/editface" //修改头像

#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径

#define ORDERLIST @"http://"API_DOMAIN@"/project/list" //订单详情列表

#define KLINEDATA  @"http://"API_DOMAIN@"/user/getalltime"  //K线数据

#define SALEMAP @"http://"API_DOMAIN@"/user/getmonths"    //比例图

#define ORIGINAL_MAX_WIDTH 640.0f

#define CELLID @"cellid" // tableViewCellid

#define HIGHT 242    //tableViewCellHight

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface YSKJ_PersonCenterViewController ()<DatabaseManagerDelegate,HttpRequestClassDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *arrowImage; //离线箭头
    
    NSMutableArray *dbDataArr;       //商品数据库数组
    NSMutableArray *spaceDbDataArr;       //空间数据库数组
    
    NSMutableArray *desc_imgArr;
    NSMutableArray *thumb_fileArr;
    NSMutableArray *desc_modArr;
    
    DatabaseManager *databasemang;
    
    UIButton *updatePassword;
    
    NSString *_dataString;
    
    NSArray *dataSoure;
    
    UITableViewCell *tabCell;
    
    NSMutableArray *thumbSpace_fileArr;
    
    YSKJ_OrderDetailTableViewCell *_cell;
    
    UITableView *_OrederTableView;
    
    NSMutableArray *_orderList;
    
    YSKJ_leftMenuView *menu;
    
    YSKJ_AdduploadProdctView *upLoadPro;
    
    YSKJ_AdduploadSpaceView *upLoadSpa;
    
    YSKJ_SaleKlineView *saleKlineView;
    
    QLCycleProgressView *_progressView;
    
    NSArray *_klineData;
    
    UIImageView *_noneOrderImage;
    
    UILabel *_tipTitle;
    
}
@property (nonatomic ,strong)YSKJ_TargetDataView *targetData;
@property (nonatomic ,strong)YSKJ_TitleView *titleView;
@property (nonatomic ,strong)YSKJ_SalesReportView *salesReport;
@property (nonatomic,retain)NSMutableArray *lineArr;  //在线数组;
@property (nonatomic,retain)NSMutableArray *lineSpaceArr;  //在线数组;

@property (nonatomic, assign)NSInteger orderStatusIndex;

@end

@implementation YSKJ_PersonCenterViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]) {
        
        [self getListOrderDetailList];
        
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title=@"个人中心";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    
    
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    self.view.backgroundColor=UIColorFromHex(0xefefef);
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    databasemang=[[DatabaseManager alloc] init];
    databasemang.delegate=self;
    [databasemang openDatabase];
    
    [self setUpleftMenuView];
    
    //添加我的订货单
    UIView *orderlistView=[[UIView alloc] initWithFrame:CGRectMake(263, 0, self.view.size.width-263, THEHEIGHT - 114)];
    orderlistView.tag=2000;
    orderlistView.hidden = YES;
    orderlistView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    [self.view addSubview:orderlistView];
    _OrederTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, orderlistView.frame.size.width, orderlistView.frame.size.height-40)];
    _OrederTableView.dataSource = self;
    _OrederTableView.delegate = self;
    [orderlistView addSubview:_OrederTableView];
    [_OrederTableView registerClass:[YSKJ_OrderDetailTableViewCell class] forCellReuseIdentifier:CELLID];
    YSKJ_OrderNaviBarView *naviView = [[YSKJ_OrderNaviBarView alloc] initWithFrame:CGRectMake(0, 0, orderlistView.frame.size.width, 40)];
    [orderlistView addSubview:naviView];
    
    
    _noneOrderImage = [[UIImageView alloc] initWithFrame:CGRectMake((_OrederTableView.frame.size.width - 150)/2 - 15, 193, 150, 150)];
    _noneOrderImage.image = [UIImage imageNamed:@"noneOrder"];
    _noneOrderImage.hidden = YES;
    [_OrederTableView addSubview:_noneOrderImage];
    
    _tipTitle = [[UILabel alloc] initWithFrame:CGRectMake((_OrederTableView.frame.size.width - 160)/2 + 10, 375, 160, 28)];
    _tipTitle.text = @"您还没有订单哦！";
    _tipTitle.hidden = YES;
    _tipTitle.textColor = UIColorFromHex(0x666666);
    _tipTitle.font = [UIFont systemFontOfSize:20];
    [_OrederTableView addSubview:_tipTitle];
    
    //添加下载空间背景
    upLoadSpa=[[YSKJ_AdduploadSpaceView alloc] initWithFrame:CGRectMake(263, 0, self.view.size.width-263, THEHEIGHT)];
    upLoadSpa.hidden = YES;
    upLoadSpa.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:upLoadSpa];
    [upLoadSpa.loadData addTarget:self action:@selector(downloadSpace) forControlEvents:UIControlEventTouchUpInside];
    
    //添加下载商品
    upLoadPro=[[YSKJ_AdduploadProdctView alloc] initWithFrame:CGRectMake(263, 0, self.view.size.width-263, THEHEIGHT)];
    upLoadPro.hidden = YES;
    upLoadPro.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:upLoadPro];
    [upLoadPro.loadData addTarget:self action:@selector(downloadProduct) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleView = [[YSKJ_TitleView alloc] initWithFrame:CGRectMake(263, 0, self.view.size.width-263, 54)];
    self.titleView.hidden =YES;
    [self.view addSubview:self.titleView];
    
    self.salesReport  = [[YSKJ_SalesReportView alloc] initWithFrame:CGRectMake(263, 54, self.view.size.width-263, THEHEIGHT-54-110)];
    self.salesReport.hidden = YES;
    self.salesReport.backgroundColor = UIColorFromHex(0xefefef);
    [self.view addSubview:self.salesReport];
    
    self.targetData = [[YSKJ_TargetDataView alloc] initWithFrame:CGRectMake(263, 54, self.view.size.width-263, THEHEIGHT-54-110)];
    self.targetData.hidden = YES;
    [self.view addSubview:self.targetData];
    
    _progressView = [[QLCycleProgressView alloc]initWithFrame:CGRectMake((self.view.size.width-263 - 200)/2, 95, 200, 200)];
    [self.targetData addSubview:_progressView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((200-200*0.85)/2 + 1 , 15, 200*0.85, 187*0.80)];
    imageView.image = [UIImage imageNamed:@"turntable"];
    [_progressView addSubview:imageView];
    _progressView.animationDuration = 3;
    _progressView.line_width = 5;
    _progressView.mainColor = UIColorFromHex(0xd63232);
    
    __weak typeof(self) weakSelf = self;
    
    self.orderStatusIndex = 0;  //默认显示全部
    
    naviView.selectBlock = ^(NSInteger selectIndex)
    {
        weakSelf.orderStatusIndex = selectIndex;
        
        [weakSelf getListOrderDetailList];
    };
    
    self.targetData.selectBlock = ^(NSInteger selectIndex)
    {
        [weakSelf getSaleMapData:selectIndex];
    };
    
    self.titleView.indexBlock = ^(NSInteger selectIndex)
    {
        if (selectIndex==0) {
            
            [weakSelf.salesReport.superview bringSubviewToFront:weakSelf.salesReport];
            weakSelf.salesReport.hidden = NO;
            [weakSelf.titleView.superview bringSubviewToFront:weakSelf.titleView];
            weakSelf.titleView.hidden = NO;
            
        }else{
            
            [weakSelf.targetData.superview bringSubviewToFront:weakSelf.targetData];
            weakSelf.targetData.hidden = NO;
            [weakSelf.titleView.superview bringSubviewToFront:weakSelf.titleView];
            weakSelf.titleView.hidden = NO;
        }
        
    };
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        [self getSaleMapData:0];
        [self getKlineData];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:@"loginNotification" object:nil];
    
}

-(void)getSaleMapData:(NSInteger)selectIndex
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *stime,*etime;
    
    if (selectIndex==0) {
        
        stime = [NSString stringWithFormat:@"%@%@",[dateString substringToIndex:7],@"-01"];
        
        etime = dateString;

    }else if(selectIndex==1){
        
        NSRange range;range.location  = 5,range.length = 2;
        
        NSString *dateMonthStrng = [dateString substringWithRange:range];
    
        NSRange range1;range1.location  = 0,range1.length = 1;
        
        int last = [[dateMonthStrng substringWithRange:range1] integerValue];
        
        if (last == 0) {
            
            if ([[dateMonthStrng substringFromIndex:1] integerValue] <=3) {
                
                stime = [NSString stringWithFormat:@"%@%@",[dateString substringToIndex:4],@"-01-01"];
                
            }else if ([[dateMonthStrng substringFromIndex:1] integerValue]>3 && [[dateMonthStrng substringFromIndex:1] integerValue]<=6){
                
                stime = [NSString stringWithFormat:@"%@%@",[dateString substringToIndex:4],@"-03-01"];
                
            }else {
                
                stime = [NSString stringWithFormat:@"%@%@",[dateString substringToIndex:4],@"-07-01"];
            }
            
        }else{
            
            stime = [NSString stringWithFormat:@"%@%@",[dateString substringToIndex:4],@"-10-01"];
        }
        
        etime = dateString;

        
    }else{
        
        stime = [NSString stringWithFormat:@"%@%@",[dateString substringToIndex:4],@"-01-01"];
        
        etime = dateString;
    }
    
    NSDictionary *param=@{
                          @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
                          @"stime":stime,
                          @"etime":etime
                          };
    //请求后台数据
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    [httpRequest postHttpDataWithParam:param url:SALEMAP  success:^(NSDictionary *dict, BOOL success) {
        
        if ([[dict objectForKey:@"success"] boolValue] == 1) {
            
            self.targetData.totalePriceStr = [NSString stringWithFormat:@"总目标（元）：%@",[[dict objectForKey:@"data"] objectForKey:@"target"]];
            
            self.targetData.finishPriceStr = [NSString stringWithFormat:@"已完成（元）：%@",[[dict objectForKey:@"data"] objectForKey:@"achievement"]];
            
            if ([[[dict objectForKey:@"data"] objectForKey:@"achievement"] floatValue] > [[[dict objectForKey:@"data"] objectForKey:@"target"] floatValue]) {
                
                _progressView.progress = .999;
                _progressView.mainColor = UIColorFromHex(0x20bb65);
                
            }else{
                
                float per = [[[dict objectForKey:@"data"] objectForKey:@"achievement"] floatValue];
                
                CGFloat percent = per/100.0;
                
                if (per<=50.0) {
                    
                    _progressView.mainColor = UIColorFromHex(0xd63232);
                    
                }else if (per>50.0 && per<=90.0)
                {
                    _progressView.mainColor = UIColorFromHex(0xfa8844);

                }else{
                    _progressView.mainColor = UIColorFromHex(0x20bb65);
                }
                
                _progressView.progress = percent;
                
            }
            
        }
        
        
    } fail:^(NSError *error) {

    }];
    
}

-(void)getKlineData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSDictionary *param=@{
                          @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
                          @"stime":@"2017-01-01",
                          @"etime":dateString
                          };
    //请求后台数据
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    [httpRequest postHttpDataWithParam:param url:KLINEDATA  success:^(NSDictionary *dict, BOOL success) {
        
        self.salesReport.array = [[dict objectForKey:@"data"]  objectForKey:@"data"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.salesReport.array] forKey:@"lastData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } fail:^(NSError *error) {
        
        //请求失败，显示上一次数据
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastData"]];
        self.salesReport.array = array;
        
    }];
    
}

#pragma mark LoginSuccessNotification
//得到通知
-(void)loginSuccessNotification
{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
        
        updatePassword.hidden=NO;
        
        dataSoure=@[@"离线商品资源至本地",@"离线空间背景资源至本地",@"修改密码",@"我的订货单"];
        [menu.tableView reloadData];
        
        menu.line.frame=CGRectMake(0, 211+42*dataSoure.count, 262, 1);
        
        NSURL *logoUrl=[[NSURL alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userlogo"]]
        ;
        NSData *logoData=[NSData dataWithContentsOfURL:logoUrl];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userlogo"] isEqualToString:@""]) {
            
            menu.image = [UIImage imageNamed:@"user"];
            
        }else{
            
            menu.image = [UIImage imageWithData:logoData];
            
        }
        
        menu.nameStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        
        menu.exit.hidden=NO;
        
        [self getSaleMapData:0];
        [self getKlineData];
        
    }
    
}

-(void)setUpleftMenuView
{
    
    menu = [[YSKJ_leftMenuView alloc] initWithFrame:CGRectMake(0, 0, 263, self.view.frame.size.height)];
    [self.view addSubview:menu];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userlogo"]) {
        
        NSURL *logoUrl=[[NSURL alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userlogo"]]
        ;
        NSData *logoData=[NSData dataWithContentsOfURL:logoUrl];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userlogo"] isEqualToString:@""]) {
            
            menu.image = [UIImage imageNamed:@"user"];

        }else{
     
            menu.image = [UIImage imageWithData:logoData];
        }
        
       }else{
           
           menu.image = [UIImage imageNamed:@"default_user"];
           
    }
  
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]) {
        
        menu.nameStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        
    }else{
        
        menu.nameStr = @"请登录";
    }
    
    [menu.loginButton addTarget:self action:@selector(isLoginAciton:) forControlEvents:UIControlEventTouchUpInside];
  
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
        menu.exit.hidden=NO;
    }else{
        menu.exit.hidden=YES;
    }
    
   [menu.exit addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];

    menu.tableView.delegate=self;
    menu.tableView.dataSource=self;

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        
         dataSoure=@[@"离线商品资源至本地",@"离线空间背景资源至本地",@"修改密码",@"我的订货单"];
        menu.line.frame = CGRectMake(0, 211+42*dataSoure.count, 262, 1);
        
    }else{
        
        dataSoure=@[@"离线商品资源至本地"];
        menu.line.frame = CGRectMake(0, 211+42, 262, 1);
        
    }
    

}

#pragma mark Login

-(void)isLoginAciton:(UIButton*)sender  //没登录去登录
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
        
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        
        UIPopoverController *popover = [[UIPopoverController alloc]initWithContentViewController:controller];
        popover.popoverContentSize = CGSizeMake(600, 800);//弹出视图的大小
        [popover presentPopoverFromRect:CGRectMake(100, 90, 60, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else{
        
        YSKJ_LoginViewController *log=[[YSKJ_LoginViewController alloc] init];
        [self presentViewController:log animated:YES completion:nil];
        
    }
    
}

#pragma mark exitLogin 

-(void)exitAction      //退出账号
{
    menu.exit.hidden=YES;
    
    upLoadPro.hidden = YES;
    
    upLoadSpa.hidden = YES;
    
    self.salesReport.hidden = YES;
    
    self.titleView.hidden =YES;
    
    self.targetData.hidden = YES;
    
    UIView *orderlistView=[self.view viewWithTag:2000];
    
    orderlistView.hidden = YES;
    
    moreWorkToDo=YES;
    
    dataSoure=@[@"离线商品资源至本地"];
    [menu.tableView reloadData];
    
    menu.line.frame=CGRectMake(0, 211+42, 262, 1);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userlogo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    menu.image =[UIImage imageNamed:@"default_user"];
    
    menu.nameStr = @"请登录";
    
    NSDictionary *dict=@{@"fromProVC":@"NO"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationToProDuctCtr" object:self userInfo:dict];
    
    [upLoadSpa.loadData setImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
    
    moreWorkToDo1=YES;
    
    [spaceDbDataArr removeAllObjects];
    
}

#pragma mark 保存主图
-(void)saveThumb_file:(NSString *)thumb_fileStr
{
    NSArray  *picFloder= [[thumb_fileStr substringFromIndex:PICURL.length] componentsSeparatedByString:@"/"];                //从固定地址后截取成数组
    //如图片1.png 系统为“1.png”
    NSString *theStr=[[NSString stringWithFormat:@"%@",picFloder[2]] stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号

    NSArray  *picArr= [theStr componentsSeparatedByString:@"."];  //第三个元素转换成数组，取得图片名和图片类型

    //保存本地主图
    YSKJ_SaveWebImageClass *saveImage=[[YSKJ_SaveWebImageClass alloc] init];
    
    [saveImage SaveShopPicFloder:picFloder[0] p_no:picFloder[1] imageUrl:thumb_fileStr  SaveFileName:picArr[0] SaveFileType:picArr[1] image:nil size:CGSizeMake(0, 0)];

}
#pragma mark 保存3D模型图
-(void)saveDesc_model:(NSString*)desc_modelArr
{
    NSArray *arrMod= [ToolClass arrayWithJsonString:desc_modelArr];
 //   NSLog(@"arrMod=%@",arrMod);
    
    for (NSString *picStr in arrMod) {
        //去掉 “”
        NSString *theStr=[[NSString stringWithFormat:@"%@",picStr ]stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
        
        NSArray  *picFloder= [theStr componentsSeparatedByString:@"/"];                //从固定地址后截取成数组
        //如图片1.png 系统为“1.png”
        
        NSString *picString=[[NSString stringWithFormat:@"%@",picFloder[2]] stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
        
        NSArray  *picArr= [picString componentsSeparatedByString:@"."];  //第三个元素转换成数组，取得图片名和图片类型
        
        //本地详情图
        YSKJ_SaveWebImageClass *saveImage=[[YSKJ_SaveWebImageClass alloc] init];
        [saveImage SaveShopPicFloder:picFloder[0] p_no:picFloder[1] imageUrl:[NSString stringWithFormat:@"%@/%@",PICURL,theStr] SaveFileName:picArr[0] SaveFileType:picArr[1] image:nil size:CGSizeMake(0, 0)];
        
    }

}

#pragma mark 保存详情图

-(void)saveDesc_img:(NSString*)desc_imgStr
{
    
    NSArray *arrPic= [ToolClass arrayWithJsonString:desc_imgStr];
    for (NSString *picStr in arrPic) {
        //去掉 “”
        NSString *theStr=[[NSString stringWithFormat:@"%@",picStr ]stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
        
        NSArray  *picFloder= [theStr componentsSeparatedByString:@"/"];                //从固定地址后截取成数组
        //如图片1.png 系统为“1.png”
        
        NSString *picString=[[NSString stringWithFormat:@"%@",picFloder[2]] stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
        
        NSArray  *picArr= [picString componentsSeparatedByString:@"."];  //第三个元素转换成数组，取得图片名和图片类型
        
        //本地详情图
        YSKJ_SaveWebImageClass *saveImage=[[YSKJ_SaveWebImageClass alloc] init];
        [saveImage SaveShopPicFloder:picFloder[0] p_no:picFloder[1] imageUrl:[NSString stringWithFormat:@"%@/%@",PICURL,theStr] SaveFileName:picArr[0] SaveFileType:picArr[1] image:nil size:CGSizeMake(0, 0)];
        
    }

}

#pragma mark 保存路径到数据库

-(void)savaProDetail:(NSDictionary *)theDict
{
    //1.
    NSString *thumb_file=[theDict objectForKey:@"thumb_file"];    //整个图片url地址
    
    NSArray  *picFloder1= [[thumb_file substringFromIndex:PICURL.length] componentsSeparatedByString:@"/"];                //从固定地址后截取成数组
    //如图片1.png 系统为“1.png”
    NSString *picStr=[[NSString stringWithFormat:@"%@",picFloder1[2]] stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
    
    NSArray  *picArray= [picStr componentsSeparatedByString:@"."];  //第三个元素转换成数组，取得图片名和图片类型
    
    NSLog(@"tupian=%@",[NSString stringWithFormat:@"/%@/%@/%@.%@",picFloder1[0],picFloder1[1],picArray[0],picArray[1]]);
    // 插入数据
    [databasemang addDataToTableCurrentTableName:@"yskj_proDuctTable" thumb_file:[NSString stringWithFormat:@"/%@/%@/%@.%@",picFloder1[0],picFloder1[1],picArray[0],picArray[1]] desc_img:[theDict objectForKey:@"desc_img"] desc_model:[theDict objectForKey:@"desc_model"] product_id:[theDict objectForKey:@"id"] lastTime:[[theDict objectForKey:@"last_time"] intValue]];
    
}
#pragma mark  downloadProduct

-(void)downloadProduct
{

    if (moreWorkToDo==NO) {
        
        [upLoadPro.loadData setImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
        moreWorkToDo=YES;
  
    }else{
        
        [self getData];
        
       [upLoadPro.loadData setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        moreWorkToDo=NO;
        downloadCout=0;
        [self performSelector:@selector(gotherdAction) withObject:self afterDelay:2];
     
    }
    
}

-(void)getData
{
    
    upLoadPro.hidden = NO;
    
    upLoadPro.loadingView.hidden=NO;
    
    //请求后台数据
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    httpRequest.delegate=self;
    [httpRequest postHttpDataWithParam:nil url:LINEOFFURL  success:^(NSDictionary *dict, BOOL success) {
        
    } fail:^(NSError *error) {
    }];
    
}

static int downloadCout=0;
static float float_i;

-(void)threadAction
{
    dispatch_queue_t queue = dispatch_queue_create("GCD",NULL);
    for (int i=0; i<self.lineArr.count; i++) {
        
        if (moreWorkToDo==YES) {
            break;
        }
        dispatch_sync(queue, ^{
            
            //保存本地主图
            [self saveThumb_file:thumb_fileArr[i]];
            
            //保存3D模型图
            [self saveDesc_model:desc_modArr[i]];
            
            //商品详情图片
            [self saveDesc_img:desc_imgArr[i]];
            
            //保存路径到数据库
            [self savaProDetail:self.lineArr[i]];
            
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                downloadCout++;
                
                //进度百分比＝(数据库当前数－原来数量)／待下载个数
                float_i=(float)downloadCout/(float)self.lineArr.count;
                
                //待离线数＝离线请求到的个数－数据库现有的个数
                
                if (self.lineArr.count!=downloadCout) {
                    
                    upLoadPro.titleStr=[NSString stringWithFormat:@"已更新%lu件商品至本地，新增%u件商品未更新",(unsigned long)dbDataArr.count+downloadCout,(self.lineArr.count)-downloadCout];
                    
                }else{
                    
                    upLoadPro.titleStr=[NSString stringWithFormat:@"已经全部离线完毕"];
                    float_i=1;
                    upLoadPro.loadData.hidden=YES;
                    
                    
                }
                if ([[NSString stringWithFormat:@"%f",float_i] isEqualToString:@"nan"]||[[NSString stringWithFormat:@"%f",float_i] isEqualToString:@"inf"]){
                    
                }else{
                    
                    upLoadPro.progressValues = float_i;
                    
                    if (float_i>0.035) {
                        
                        upLoadPro.progressTitle = [NSString stringWithFormat:@"%.f%%",float_i*100];
                    }
                    upLoadPro.progressLable.frame=CGRectMake(0, 50, (upLoadPro.frame.size.width-40)*float_i, 20);
                    
                }
                
                [upLoadPro.loadData setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                
            });
            
        });
        
    }
    
    threadProcess2Finished =YES;
    
}

BOOL moreWorkToDo = YES;
BOOL threadProcess2Finished =NO;
//离线操作
-(void)gotherdAction
{
    threadProcess2Finished =NO;
    
    if (self.lineArr.count!=0) {
        
        [NSThread  detachNewThreadSelector: @selector(threadAction)
                                  toTarget: self
                                withObject: nil];
        
        while (!threadProcess2Finished) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate: [NSDate distantFuture]];
            
            
        }

    }
    
    [upLoadPro.loadData setImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
    
    // 开启动画
    [UIView animateWithDuration:0.2 animations:^{
        upLoadPro.progressValues = 0;
        upLoadPro.progressLable.frame=CGRectMake(0, 50, 0.001, 20);

    }];

}

#pragma mark downloadSpace

-(NSInteger)userUploadCount   //6.得到用户已更新
{
    NSMutableArray *lineSpaceArr=[[NSMutableArray alloc] initWithArray:self.lineSpaceArr];
    
    //4.得到用户全部背景数据
    for (int i=0; i<lineSpaceArr.count; i++)
    {
        NSDictionary *userDict=lineSpaceArr[i];
        
        if ([[userDict objectForKey:@"userid"] integerValue] == 0) {
            
            [lineSpaceArr removeObject:userDict];
            i--;
        }
    }
    NSInteger allUserCount=lineSpaceArr.count;
    userAllCount = lineSpaceArr.count;
    
    //5.得到用户未更新的全部数据
    for (int i=0; i<lineSpaceArr.count; i++)
    {
        NSDictionary *userDict=lineSpaceArr[i];
        [databasemang getOneProDuctDataTableName:@"yskj_bgTable"  with:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"id"]] getStr:@"product_id"];
        if ([_dataString integerValue]==[[userDict objectForKey:@"id"] integerValue]) {
            
            [lineSpaceArr removeObject:userDict];
            i--;
        }
    }
    return allUserCount - lineSpaceArr.count;;
}

-(NSInteger)officialUploadCount //1.得到官方全部背景
{
    NSMutableArray *lineSpaceArr=[[NSMutableArray alloc] initWithArray:self.lineSpaceArr];
    //1.得到官方全部背景
    for (int i=0; i<lineSpaceArr.count; i++)
    {
        NSDictionary *officialDict=lineSpaceArr[i];
        
        if ([[officialDict objectForKey:@"userid"] integerValue] != 0) {
            
            [lineSpaceArr removeObject:officialDict];
            i--;
        }
        
    }
    NSInteger officialBgArrCount=lineSpaceArr.count;
    officialAllCount = lineSpaceArr.count;
    
    //2.得到官方未更新的全部数据
    for (int i=0; i<lineSpaceArr.count; i++)
    {
        NSDictionary *officialDict=lineSpaceArr[i];
        [databasemang getOneProDuctDataTableName:@"yskj_bgTable"  with:[NSString stringWithFormat:@"%@",[officialDict objectForKey:@"id"]] getStr:@"product_id"];
        if ([_dataString integerValue]==[[officialDict objectForKey:@"id"] integerValue]) {
            [lineSpaceArr removeObject:officialDict];
            i--;
        }
    }
    return officialBgArrCount - lineSpaceArr.count;
}

-(void)downloadSpace
{
    
    if (moreWorkToDo1==NO) {
        
        [upLoadSpa.loadData setImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
        
        moreWorkToDo1=YES;
        
    }else{
        
        [self getData1];
        
        [upLoadSpa.loadData setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        
        moreWorkToDo1=NO;
        downloadCout1=0;
        
        [self performSelector:@selector(gotherdAction1) withObject:self afterDelay:2];
        
    }
    
}

static NSInteger officialAllCount=0;
static NSInteger userAllCount=0;

-(void)getData1
{
    
    //进来就查看数据库个数，看有没有待下载的
    [databasemang getAllDataWithTableName:@"yskj_bgTable" from:@"spa"];
    
    upLoadSpa.hidden = NO;
    
    upLoadSpa.loadingView.hidden=NO;
    
    NSDictionary *param=@{
                          @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]
                          };
    //请求后台数据
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    [httpRequest postHttpDataWithParam:param url:LINEOFFSPACE  success:^(NSDictionary *dict, BOOL success) {
        
        self.lineSpaceArr=[dict objectForKey:@"data"];
        
        NSInteger officialUploadCount = [self officialUploadCount];
        NSInteger userUploadCount     = [self userUploadCount];
        
        //获取得到离线数据
        for (int i=0; i<self.lineSpaceArr.count; i++)
        {
            NSDictionary *lineDict=self.lineSpaceArr[i];
            
            [databasemang getOneProDuctDataTableName:@"yskj_bgTable"  with:[NSString stringWithFormat:@"%@",[lineDict objectForKey:@"id"]] getStr:@"product_id"];
            
            if ([_dataString integerValue]==[[lineDict objectForKey:@"id"] integerValue]) {
                
                [self.lineSpaceArr removeObject:lineDict];
                i--;
            }
        }
        
        thumbSpace_fileArr=[[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in self.lineSpaceArr) {
            
            [thumbSpace_fileArr addObject:[dict objectForKey:@"url"]];
        }
        
        upLoadSpa.loadingView.hidden=YES;
        
        if (spaceDbDataArr.count==0) {
            
            upLoadSpa.titleStr=[NSString stringWithFormat:@"已更新0件背景至本地，新增%lu件背景未更新",(unsigned long)self.lineSpaceArr.count];
            
        }else{
            //已更新总数 ＝ 用户背景已更新数 ＋ 官方背景已更新数
            upLoadSpa.titleStr=[NSString stringWithFormat:@"已更新%d件背景至本地，新增%lu件背景未更新",officialUploadCount+userUploadCount,(unsigned long)self.lineSpaceArr.count];
        }
        //如果待下载个数为0隐藏进度控件
        if (self.lineSpaceArr.count==0) {
            
            upLoadSpa.titleStr=[NSString stringWithFormat:@"暂无可离线背景,已有离线背景%d件",officialAllCount+userAllCount];
            
            upLoadSpa.loadData.hidden=YES;
            
        }
        
    } fail:^(NSError *error) {
        
    }];
    
}

BOOL moreWorkToDo1 = YES;
BOOL threadProcess2Finished1 =NO;
//离线操作
static float float_i1;

-(void)gotherdAction1
{
    threadProcess2Finished1 =NO;
    
    moreWorkToDo1=NO;
    
    [NSThread  detachNewThreadSelector: @selector(threadAction1)
                              toTarget: self
                            withObject: nil];
    
    while (!threadProcess2Finished1) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate: [NSDate distantFuture]];
        
    }
    
    upLoadSpa.progressTitle=@"";
    
    upLoadSpa.progressValues=0;
    
    [upLoadSpa.loadData setImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
    
    
}
static int downloadCout1=0;

-(void)threadAction1
{
    dispatch_queue_t queue = dispatch_queue_create("GCD",NULL);
    for (int i=0; i<self.lineSpaceArr.count; i++) {
        
        if (moreWorkToDo1==YES) {
            break;
        }
        dispatch_sync(queue, ^{
            
            NSArray  *picFloder= [thumbSpace_fileArr[i] componentsSeparatedByString:@"/"];                //从固定地址后截取成数组
            //如图片1.png 系统为“1.png”
            NSString *theStr=[[NSString stringWithFormat:@"%@",picFloder[2]] stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
            
            NSArray  *picArr= [theStr componentsSeparatedByString:@"."];  //第三个元素转换成数组，取得图片名和图片类型
            
            //保存背景原图
            YSKJ_SaveWebImageClass *saveImage=[[YSKJ_SaveWebImageClass alloc] init];
            
            [saveImage SaveShopPicFloder:picFloder[0] p_no:picFloder[1] imageUrl:[NSString stringWithFormat:@"%@%@",SPACEBGURL,thumbSpace_fileArr[i]]  SaveFileName:picArr[0] SaveFileType:picArr[1] image:nil size:CGSizeMake(0, 0)];
            
            //保存背景样式图
            [saveImage SaveShopPicFloder:@"appspacebgthumb" p_no:picFloder[1] imageUrl:[NSString stringWithFormat:@"%@%@-%@",SPACEBGURL,thumbSpace_fileArr[i],@"appspacebgthumb"]  SaveFileName:picArr[0] SaveFileType:picArr[1] image:nil size:CGSizeMake(0, 0)];
            
            //保存图片路径到数据库
            [databasemang addDataToTableCurrentTableName:@"yskj_bgTable" thumb_file:[NSString stringWithFormat:@"/%@/%@/%@.%@",picFloder[0],picFloder[1],picArr[0],picArr[1]] desc_img:@"" desc_model:@"" product_id:[self.lineSpaceArr[i] objectForKey:@"id"] lastTime:0];
            
            
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                downloadCout1++;
                
                //进度百分比＝(数据库当前数－原来数量)／待下载个数
                float_i1=(float)downloadCout1/(float)self.lineSpaceArr.count;
                
                if (self.lineSpaceArr.count!=downloadCout1) {
                    
                    upLoadSpa.titleStr=[NSString stringWithFormat:@"已更新%lu件背景至本地，新增%u件背景未更新",(unsigned long)spaceDbDataArr.count+downloadCout1,(self.lineSpaceArr.count)-downloadCout1];
                    
                }else{
                    
                    upLoadSpa.titleStr=[NSString stringWithFormat:@"已经全部离线完毕"];
                    float_i1=1;
                    upLoadSpa.loadData.hidden=YES;
                    
                }
                
                upLoadSpa.progressValues=float_i1;
                
                if (float_i1>0.035) {
                    
                    upLoadSpa.progressTitle = [NSString stringWithFormat:@"%.f%%",float_i1*100];
                }
                
                upLoadSpa.progressLable.frame=CGRectMake(0, 50, (upLoadSpa.size.width-40)*float_i1, 20);
                
                [upLoadSpa.loadData setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                
            });
            
        });
        
    }
    
    threadProcess2Finished1 =YES;
}


#pragma mark GetOrderList

-(void)getListOrderDetailList
{
    
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      
      @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]
      
      };
    
    [requset postHttpDataWithParam:param url:ORDERLIST  success:^(NSDictionary *dict, BOOL success) {
        
        _orderList = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"data"]];
        
        NSMutableArray  *sureOrderArr = [[NSMutableArray alloc] init];
        NSMutableArray  *payMoneyArr = [[NSMutableArray alloc] init];
        NSMutableArray  *successSaleArr = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in _orderList) {
            
            YSKJ_OrderDetailModel *model = [YSKJ_OrderDetailModel mj_objectWithKeyValues:dict];
            
            if ([model.status isEqualToString:@"意向确认"]) {
                [sureOrderArr addObject:dict];
                
            }else if ([model.status isEqualToString:@"已收定金"] || [model.status isEqualToString:@"已收首款"] || [model.status isEqualToString:@"已收尾款"]){
                
                [payMoneyArr addObject:dict];
                
            }else if ([model.status isEqualToString:@"成功销售"])
            {
                [successSaleArr addObject:dict];
                
            }
        }
        
        if (_orderList.count>0) {
            
            _noneOrderImage.hidden = YES;
            _tipTitle.hidden = YES;
            
        }else{
            
            _noneOrderImage.hidden = NO;
            _tipTitle.hidden = NO;
            
        }
        if (self.orderStatusIndex ==1){
    
            _orderList = sureOrderArr;
          
        }else if (self.orderStatusIndex == 2){
        
            _orderList = payMoneyArr;
      
        }else if(self.orderStatusIndex ==3){
            
            _orderList = successSaleArr;
        }

        [_OrederTableView reloadData];
        
    }fail:^(NSError *error) {
        
    }];
    
}


#pragma mark DatabaseManagerDelegate

-(void)readDataBaseDataWithSpaceData:(NSMutableArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    spaceDbDataArr=array;
}
-(void)readDataBaseData:(NSMutableArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    dbDataArr=array;
}
// 获取某个表的某一条数据
-(void)readOneDataBaseData:(NSString *)dataString withDatabaseMan:(DatabaseManager *)readDataCalss
{
    _dataString=dataString;
    
}
BOOL threadProcessFinished =NO;
#pragma mark HttpRequestClassDelegate
//请求成功的方法
- (void)theSuccess:(id)json andHttpRequest:(HttpRequestCalss *)httpClass;
{
    self.lineArr=[json objectForKey:@"data"];
    
    upLoadPro.loadingView.hidden=YES;
  
    upLoadPro.loadData.hidden=NO;

    
    NSString *date = @"2016-11-02 16:09:35";
    int utc = [YSKJ_UTCDataCalss dateFormatToUTC:date dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //进来就查看数据库个数，看有没有待下载的
    [databasemang getAllDataWithTableName:@"yskj_proDuctTable" from:@"pro"];
    
    //获取得到离线数据
    for (int i=0; i<self.lineArr.count; i++)
    {
        NSDictionary *lineDict=self.lineArr[i];
        
        [databasemang getOneProDuctDataTableName:@"yskj_proDuctTable" with:[NSString stringWithFormat:@"%@",[lineDict objectForKey:@"id"]] getStr:@"product_id"];
        
        
        if ([_dataString integerValue]==[[lineDict objectForKey:@"id"] integerValue]) {
            
            NSString *lintLastTime=[lineDict objectForKey:@"last_time"];
            
            [databasemang getOneProDuctDataTableName:@"yskj_proDuctTable" with:[NSString stringWithFormat:@"%@",[lineDict objectForKey:@"id"]] getStr:@"lastTime"];
            
            if ([lintLastTime integerValue]!=[_dataString integerValue]) {
                
                [databasemang deleteDataProduct_id:[lineDict objectForKey:@"id"] from:utc];
                
                
                NSString *thumb_file=[lineDict objectForKey:@"thumb_file"];
                NSString  *subThumb= [thumb_file substringFromIndex:PICURL.length] ;
                
                //更新数据库
               [databasemang updateDataToTableWithUTC:utc thumb_file:subThumb desc_img:subThumb lastTime:[[lineDict objectForKey:@"last_time"] intValue] product_id:[lineDict objectForKey:@"id"]];
                
            }else{
                //lasttime不同并且id不同的商品放进离线数据
                [self.lineArr removeObject:lineDict];
                i--;
            }
            
            
        }

    }
    
    desc_imgArr=[[NSMutableArray alloc] init];
    thumb_fileArr=[[NSMutableArray alloc] init];
    desc_modArr=[[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in self.lineArr) {
        [desc_imgArr addObject:[dict objectForKey:@"desc_img"]];
        [thumb_fileArr addObject:[dict objectForKey:@"thumb_file"]];
        [desc_modArr addObject:[dict objectForKey:@"desc_model"]];
    }
    if (dbDataArr.count==0) {
        
        upLoadPro.titleStr = [NSString stringWithFormat:@"已更新0件商品至本地，新增%lu件商品未更新",(unsigned long)self.lineArr.count];
    }else{
        
        upLoadPro.titleStr = [NSString stringWithFormat:@"已更新%lu件商品至本地，新增%lu件商品未更新",(unsigned long)dbDataArr.count,(unsigned long)self.lineArr.count];
    }
    if (self.lineArr.count==0) {
        
        upLoadPro.titleStr =  [NSString stringWithFormat:@"暂无可离线商品,已有离线商品%ld件",(unsigned long)dbDataArr.count];
        upLoadPro.loadData.hidden=YES;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {

    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
      //  [head setImage:editedImage forState:UIControlStateNormal];
        
        menu.image = editedImage;
        //保存本地主图
        YSKJ_SaveWebImageClass *saveImage=[[YSKJ_SaveWebImageClass alloc] init];
        [saveImage SaveShopPicFloder:@"design" p_no:@"photo" imageUrl:nil SaveFileName:@"design" SaveFileType:@"png" image:editedImage size:CGSizeMake(300, 300)];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        
        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,@"design" ,@"photo"];
        
        NSString *fullPath = [imagePath stringByAppendingPathComponent:@"design.png"];
        
     
        [self getToken:fullPath];
        
    }];
}
#pragma mark 获取token
-(void)getToken:(NSString*)filePath
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"bucket":@"mall"
      };
    
    [requset postHttpDataWithParam:param url:GETTOKEN  success:^(NSDictionary *dict, BOOL success) {
    
        NSDictionary *tokenDict=[dict objectForKey:@"data"];
        
        //把图片保存到七牛云服务器
        [self saveToQiniuServer:[tokenDict objectForKey:@"token"] filePath:filePath];
        
    } fail:^(NSError *error) {
        
    }];
    
}
-(NSString*)key
{
    //当前时间
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSArray *changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];//存放十个数，以备随机取
    NSMutableString * getStr = [[NSMutableString alloc] initWithCapacity:9];
    NSString *changeString = [[NSMutableString alloc] initWithCapacity:10];//申请内存空间，一定要写，要不没有效果，我自己总是吃这个亏
    for (int i = 0; i<10; i++) {
        NSInteger index = arc4random()%([changeArray count]-1);//循环六次，得到一个随机数，作为下标值取数组里面的数放到一个可变字符串里，在存放到自身定义的可变字符串
        getStr = changeArray[index];
        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr];
    }
    NSString *md5PassStr=[changeString md5String];
    NSString *key=[NSString stringWithFormat:@"%@/%@/%@.jpg",@"userface",dateStr,[md5PassStr substringToIndex:16]];
    return key;
}
-(void)saveToQiniuServer:(NSString*)token filePath:(NSString*)filePath
{
    //国内https上传
    BOOL isHttps = TRUE;
    QNZone * httpsZone = [[QNAutoZone alloc] initWithHttps:isHttps dns:nil];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = httpsZone;
    }];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    [upManager putFile:filePath key:[self key] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if(info.ok)
        {
            NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
            
            [userdefault setValue:[NSString stringWithFormat:@"%@%@",PICURL,key] forKey:@"userlogo"];
            
            [userdefault synchronize];
            
            [self updateHead:key];
            
        }
    }
                option:nil];
    
}
#pragma mark 修改头像
-(void)updateHead:(NSString *)key
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
      @"url":key
      };
    [requset postHttpDataWithParam:param url:UPDATEHEAD  success:^(NSDictionary *dict, BOOL success) {
        

    } fail:^(NSError *error) {
        
    }];

}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake((self.view.frame.size.width-self.view.frame.size.height+100)/2, (THEHEIGHT-(self.view.frame.size.height-100))/2, self.view.frame.size.height-100, self.view.frame.size.height-100) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (menu.tableView == tableView) {
        
        return dataSoure.count;
        
    }else{
        
        return _orderList.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (menu.tableView == tableView) {
        
        NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",(long)indexPath.section,(long)indexPath.row];
        tabCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (tabCell == nil) {
            
            tabCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            
            UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tabCell.size.width, 1)];
            line.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.4];
            [tabCell addSubview:line];
            
            UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(16, (128/3-40)/2, 200, 40)];
            titleLable.textColor=[UIColor grayColor];
            titleLable.font=[UIFont systemFontOfSize:14];
            titleLable.text=dataSoure[indexPath.row];
            [tabCell.contentView addSubview:titleLable];
            
            UIImageView *arrowsImage=[[UIImageView alloc] initWithFrame:CGRectMake(263-47,(128/3-28)/2, 15,28)];
            arrowsImage.image=[UIImage imageNamed:@"jiantou"];
            [tabCell.contentView addSubview:arrowsImage];
            
        }
        
        return tabCell;

    }else{
        
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
        
        _cell.nameStr = model.name;
        
        _cell.dateStr = [ToolClass utcToDateString:[model.create_time integerValue] dateFormat:@"yyyy-MM-dd"];
        
        _cell.numberStr = [NSString stringWithFormat:@"%lu",(unsigned long)proCount];
        
        _cell.totailePriceStr = [NSString stringWithFormat:@"实付款：%0.2f",[[dict objectForKey:@"price"] floatValue]];
        
        _cell.waitPassStr = model.status;
        
        _cell.obj = dict;
        
        _cell.button.tag = indexPath.row + 1000;
        
        _cell.width = self.view.frame.size.width - 263;
        
         [_cell.button addTarget:self action:@selector(orderProductAciton:) forControlEvents:UIControlEventTouchUpInside];
        [_cell.leftBut removeTarget:self action:@selector(customerLossAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cell.rightBut removeTarget:self action:@selector(StageOfSuccessAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cell.rightBut removeTarget:self action:@selector(PayInAdvanceAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cell.leftBut removeTarget:self action:@selector(PayTheFirstAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cell.rightBut removeTarget:self action:@selector(PayTheBalancePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([model.status isEqualToString:@"客户流失"]) {
            
            _cell.orderCancleLogo.hidden = NO;
            _cell.line.hidden = YES;
            _cell.leftBut.hidden = YES;
            _cell.rightBut.hidden = YES;
            
        }else{
            
            _cell.orderCancleLogo.hidden = YES;
            _cell.line.hidden = NO;
            _cell.leftBut.hidden = NO;
            _cell.rightBut.hidden = NO;
            
            if ([model.status isEqualToString:@"意向确认"]) {
                
                [_cell.rightBut setTitle:@"进入已收定金阶段" forState:UIControlStateNormal];
                [_cell.leftBut setTitle:@"客户流失" forState:UIControlStateNormal];
                
                [_cell.rightBut addTarget:self action:@selector(PayInAdvanceAction:) forControlEvents:UIControlEventTouchUpInside];
                
            }else if ([model.status isEqualToString:@"已收定金"] || [model.status isEqualToString:@"已收首款"]||[model.status isEqualToString:@"已收尾款"])
            {
                [_cell.rightBut setTitle:@"进入成功销售阶段" forState:UIControlStateNormal];
                [_cell.leftBut setTitle:@"客户流失" forState:UIControlStateNormal];
                
                [_cell.rightBut addTarget:self action:@selector(StageOfSuccessAction:) forControlEvents:UIControlEventTouchUpInside];
                
            }else if ([model.status isEqualToString:@"成功销售"]){
                
                [_cell.rightBut setTitle:@"收尾款" forState:UIControlStateNormal];
                [_cell.leftBut setTitle:@"收首款" forState:UIControlStateNormal];
                
                [_cell.leftBut addTarget:self action:@selector(PayTheFirstAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [_cell.rightBut addTarget:self action:@selector(PayTheBalancePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
        
            }
        }
        
        if (![model.status isEqualToString:@"成功销售"]) {
            
            [_cell.leftBut addTarget:self action:@selector(customerLossAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([model.status isEqualToString:@"成功销售"]){
            
            NSDictionary *payInfo = [ToolClass dictionaryWithJsonString:model.pay_info];
            
            if ([payInfo objectForKey:@"price3"]) {
                
                _cell.leftBut.backgroundColor = UIColorFromHex(0xf1f1f1);
                
                UIColor *titCol = UIColorFromHex(0xbababa);
                
                [_cell.leftBut setTitleColor:titCol forState:UIControlStateNormal];
                
                _cell.leftBut.enabled = NO;
                
                _cell.leftBut.layer.borderColor = [UIColor clearColor].CGColor;
                
                _cell.rightBut.backgroundColor = UIColorFromHex(0xf1f1f1);
                
                [_cell.rightBut setTitleColor:titCol forState:UIControlStateNormal];
                
                _cell.rightBut.enabled = NO;
                
                _cell.rightBut.layer.borderColor = [UIColor clearColor].CGColor;
                
            }else if ([payInfo objectForKey:@"price2"]){
                
                _cell.leftBut.backgroundColor = UIColorFromHex(0xf1f1f1);
                
                UIColor *titCol = UIColorFromHex(0xbababa);
                
                [_cell.leftBut setTitleColor:titCol forState:UIControlStateNormal];
                
                _cell.leftBut.enabled = NO;
                
                _cell.leftBut.layer.borderColor = [UIColor clearColor].CGColor;
                
            }

        }else{
            
            _cell.leftBut.backgroundColor = [UIColor clearColor];
            
            UIColor *titCol = UIColorFromHex(0xf39800);
            
            [_cell.leftBut setTitleColor:titCol forState:UIControlStateNormal];
            
            _cell.leftBut.enabled = YES;
            
            _cell.leftBut.layer.borderColor = UIColorFromHex(0xf39800).CGColor;
            
            _cell.rightBut.backgroundColor = [UIColor clearColor];
            
            [_cell.rightBut setTitleColor:titCol forState:UIControlStateNormal];
            
            _cell.rightBut.enabled = YES;
            
            _cell.rightBut.layer.borderColor = UIColorFromHex(0xf39800).CGColor;
            
            
        }
        
        
        return _cell;
    }
}
-(NSString*)getProjectId:(UIButton*)sender
{
    //get cell
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_OrederTableView indexPathForCell:tableViewCell];
    NSDictionary *dict=[_orderList objectAtIndex:indexPath.row];
    return [dict objectForKey:@"id"];
}

-(void)customerLossAction:(UIButton*)sender
{

    [YSKJ_OrderOperationView operationOrderWithText:@"确定要客户流失吗？" type:CustomerLoss projectId:[self getProjectId:sender] filishBlock:^{
        
        [self getListOrderDetailList];
        
    }];
}

-(void)PayInAdvanceAction:(UIButton*)sender
{
    [YSKJ_OrderOperationView operationOrderWithText:@"请输入定金金额" type:PayInAdvance projectId:[self getProjectId:sender] filishBlock:^{
        
        [self getListOrderDetailList];
        
    }];
}

-(void)PayTheFirstAction:(UIButton*)sender
{
    [YSKJ_OrderOperationView operationOrderWithText:@"请输入首款金额" type:PayTheFirst projectId:[self getProjectId:sender] filishBlock:^{
        
        [self getListOrderDetailList];
        
    }];
}

-(void)PayTheBalancePaymentAction:(UIButton*)sender
{
    [YSKJ_OrderOperationView operationOrderWithText:@"请输入尾款金额" type:PayTheBalancePayment projectId:[self getProjectId:sender] filishBlock:^{
        
        [self getListOrderDetailList];
        
    }];
}

-(void)StageOfSuccessAction:(UIButton*)sender
{
    [YSKJ_OrderOperationView operationOrderWithText:@"确定要进入成功销售阶段吗？" type:StageOfSuccess projectId:[self getProjectId:sender] filishBlock:^{
        
        [self getListOrderDetailList];
        
    }];
}

-(void)orderProductAciton:(UIButton *)sender
{
    UITableViewCell *tableViewCell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_OrederTableView indexPathForCell:tableViewCell];
    YSKJ_OrderProjectDetailViewController *detail = [[YSKJ_OrderProjectDetailViewController alloc] init];
    detail.hidesBottomBarWhenPushed = YES;
    detail.objProduct = _orderList[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma  mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (menu.tableView == tableView) {
        
        return 128/3;
        
    }else{
        
        NSDictionary *dict = _orderList[indexPath.row];
        
        YSKJ_OrderDetailModel *model = [YSKJ_OrderDetailModel mj_objectWithKeyValues:dict];
    
        if ([model.status isEqualToString:@"客户流失"]) {
            return 178;
        }else{
            return HIGHT;
        }

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (menu.tableView == tableView) {
        
        if (indexPath.row==0) {
            
            [self.view bringSubviewToFront:upLoadPro];
            
            if (upLoadPro.hidden == YES) {

                [self getData];
            }
            
        }else if (indexPath.row==1){
            
            [upLoadSpa.superview bringSubviewToFront:upLoadSpa];
            
            if (upLoadSpa.hidden == YES) {
                
                [self getData1];
            }
            
        }else if (indexPath.row==2){
            
            YSKJ_ForGetPasswordViewController *forget=[[YSKJ_ForGetPasswordViewController alloc] init];
            
            forget.title = @"修改密码";
            
            [self presentViewController:forget animated:YES completion:^{
                
                UIView *orderlistView=[self.view viewWithTag:2000];
                
                orderlistView.hidden = YES;
                
                upLoadSpa.hidden = YES;
                
                upLoadPro.hidden = YES;
                
                self.salesReport.hidden = YES;
                
                self.titleView.hidden = YES;
                
                self.targetData.hidden = YES;

            }];
            
        }else if(indexPath.row == 3){
            
            UIView *orderlistView=[self.view viewWithTag:2000];
            
            [orderlistView.superview bringSubviewToFront:orderlistView];
            
            orderlistView.hidden = NO;
            
            [self getListOrderDetailList];
            
            
        }else if (indexPath.row == 4){
            
            if (self.titleView.selectIndex==0) {
                
                [self.salesReport.superview bringSubviewToFront:self.salesReport];
                self.salesReport.hidden = NO;
                [self.titleView.superview bringSubviewToFront:self.titleView];
                self.titleView.hidden = NO;
                
            }else{
                
                [self.targetData.superview bringSubviewToFront:self.targetData];
                self.targetData.hidden = NO;
                [self.titleView.superview bringSubviewToFront:self.titleView];
                self.titleView.hidden = NO;
            }
   
        }
    }
}

//构建模拟数据
-(void)getPointArray
{
    NSMutableArray *pointX = [[NSMutableArray alloc] init];
    for (int i=0 ; i<300; i++) {
        int x = (arc4random() % 1000) % 3000;
        NSDictionary *dict = @{
                               @"time":[self computeDateWithDays:i fromyear:@"2017-01-01"],
                               @"count":[NSString stringWithFormat:@"%d",x]
                               };
        [pointX addObject:dict];
    }
    
    self.salesReport.array = pointX;
}

//计算天数后的新日期
- (NSString *)computeDateWithDays:(NSInteger)days fromyear:(NSString*)fromyear
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [dateFormatter dateFromString:fromyear];
    NSDate *newDate = [myDate dateByAddingTimeInterval:60 * 60 * 24 * days];
    return [dateFormatter stringFromDate:newDate];
}

@end
