//
//  YSKJ_CanvasViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/12/1.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_CanvasViewController.h"

#import "YSKJ_CanvasLoading.h"

#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径

#define SPACEGBCSS @"appspacebgthumb"                 //七牛样式

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define UPDATEPLAN @"http://"API_DOMAIN@"/solution/edit"    //修改方案

#define DETAIL @"http://"API_DOMAIN@"/store/detail"  //商品详情

#define SPACEBG @"http://"API_DOMAIN@"/solution/getbglist"

#define GETTOKEN @"http://"API_DOMAIN@"/sysconfig/gettoken" //得到token

#define UPLOADSPACEBG @"http://"API_DOMAIN@"/solution/addbg"  //上传空间背景

#define SPACECATE @"http://"API_DOMAIN@"/solution/gettype"  //空间背景分类

#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地址

#define SHOPLISTURL  @"http://"API_DOMAIN@"/store/list"    //商城列表

#define  GETTYPE @"http://"API_DOMAIN@"/store/gettype"     //分类数据

#define  UPDATEPLANFACE @"http://"API_DOMAIN@"/solution/editface"     //修改方案头像


@interface YSKJ_CanvasViewController ()
{
    UIButton *beforeButton;
    
    NSInteger _loadingSelect;
    
    NSTimer *timer;
    
    NSMutableArray *_count;
    
}

@end


@implementation YSKJ_CanvasViewController
/**
 *  只支持横屏显示
 */
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}

static NSString* identifier = @"cell";

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    [self startTimer];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _loadingSelect = 1;
    
    self.view.backgroundColor=UIColorFromHex(0xffffff);
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    _count = [[NSMutableArray alloc] init];
    
    self.lineArr=[[NSMutableArray alloc] init];
    self.dbDataArr=[[NSMutableArray alloc] init];
    self.addDataArr=[[NSMutableArray alloc] init];
    self.spaceArray=[[NSMutableArray alloc] init];
    self.proDuctArray=[[NSMutableArray alloc] init];

    sureArray=[[NSMutableArray alloc] init];
    arrUrl=[[NSMutableArray alloc] init];
    arrMod=[[NSMutableArray alloc] init];
    
    arr=[[NSMutableArray alloc] init];
    
    _isProDuctColletionView=YES;       //默认展示商品列表
    
    NSData *encodemenulist = [NSKeyedArchiver archivedDataWithRootObject:sureArray];
    [[NSUserDefaults standardUserDefaults] setObject:encodemenulist forKey:@"sureArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //默认第一页，全部lable
    _page=@"1";
    _lable=@"";
    
    _selectStyleArray=[[NSMutableArray alloc] init];
    _selectSpaceArray=[[NSMutableArray alloc] init];
    _selectCategoryArray=[[NSMutableArray alloc] init];
    _selectSouresArray=[[NSMutableArray alloc] init];
    
    [self setUpcanvasView];
    
    [self setUpNavigationBarView];
    
    [self setUpshowCheckProDuctPopView];
    
    [self setUpTransFromSureWithDissView];
    
    [self setUpPicModelView];
    
    [self setUpFilterSubView];
    
    [self setUpProductFilterSubView];
    
    [self setUpTempView];
    
    NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
        
        //打开方案
    [self setUpOpenPlanView:[[[NSUserDefaults standardUserDefaults] objectForKey:plan_key] objectForKey:@"data_value"] isAddTag:YES];
    
    [self addProductArray];  //把方案放进Arr[0]步骤里

    //不保存退出得到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(planSavefail) name:@"notificationDissMiss" object:nil];
    
    //方案保存或修改成功得到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(planSaveSuccess:) name:@"notificationPlanList" object:nil];
    
    [self initHttpParam];
    
    shapelayer = [CAShapeLayer layer];
    
}

#pragma mark  lastObjectPlanRecover Action －－－－－－－－－重新获取当前方案数组

-(NSMutableArray *)getCanvasArray
{
    NSMutableArray *arrPro=[[NSMutableArray alloc] init];
    
    //此循环的目的是调整arrUrl的顺序，即当前画布。
    
    for (UIView *thesubView in [canasView subviews]) {
        
        if (thesubView.tag>=3000&&thesubView.tag<8000) {
            
            for (NSDictionary *dict in arrUrl) {
                
                if (thesubView.tag==[[dict objectForKey:@"imageTag"] integerValue]) {
                    
                    [arrPro addObject:dict];
                    
                }
            }
        }
    }
    
    arrUrl = [[NSMutableArray alloc] initWithArray:arrPro];
    
    return arrPro;
}

-(void)startTimer
{
    //开始定时保存
    Timer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(savePlanTimerAction) userInfo:nil repeats:YES];
}

-(void)savePlanTimerAction
{
    UIButton *naviButton=[naviView viewWithTag:TAG3];
    
    if (naviButton.enabled==YES) {
        
        NSArray *jsonArr=[self getCanvasArray];
        
        NSDictionary *jsonDict=@{
                                 @"count":[NSString stringWithFormat:@"%lu",(unsigned long)jsonArr.count],
                                 @"data":jsonArr
                                 };
        
        NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
        
        NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:plan_key];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:plan_key]) {
            
            NSDictionary *planData=@{
                                     @"data_value":[ToolClass stringWithDict:jsonDict],
                                     @"type":[localData objectForKey:@"type"],
                                     @"planId":[[localData objectForKey:@"planId"] isEqual:@""]?@"":[localData objectForKey:@"planId"],
                                     @"projectName":[[localData objectForKey:@"projectName"] isEqual:@""]?@"":[localData objectForKey:@"projectName"],
                                     @"planName":[[localData objectForKey:@"planName"]isEqual:@""]?@"":[localData objectForKey:@"planName"]
                                     };
            
            [[NSUserDefaults standardUserDefaults] setObject:planData forKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    }
    
}

-(void)endTimer
{
    [Timer invalidate];
}

#pragma mark  receiptNotification Action －－－－－－－－－接收通知

-(void)planSaveSuccess:(NSNotification*)notification
{
    self.planName = [notification.userInfo objectForKey:@"planName"];
    self.projectName = [notification.userInfo objectForKey:@"proJectName"];
    shapelayer.hidden=YES;
    tempView.frame=CGRectMake(10, 10, 10, 10);
    [self performSelector:@selector(afterA) withObject:self afterDelay:0.5];
}

-(void)planSavefail
{
    [self saveDissenble:YES];
}

#pragma mark  setUpcanvasView Action －－－－－－－－－添加画布视图
  
-(void)setUpcanvasView
{
    //画布
    canasView = [UIButton new];
    canasView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [canasView addTarget:self action:@selector(canvasViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:canasView];
    canasView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
}

#pragma mark setUpNavigationBarView Action－－－－－－－－主界面导航栏

-(void)setUpNavigationBarView
{
    naviView=[[YSKJ_CanvasnavigationView alloc] initWithFrame:CGRectMake(0, 0, THEWIDTH, 63)];
    [[UIApplication sharedApplication].keyWindow addSubview:naviView];
    
    [naviView.close addTarget:self action:@selector(closePlan) forControlEvents:UIControlEventTouchUpInside];

    [naviView.details addTarget:self action:@selector(proDetailePlan) forControlEvents:UIControlEventTouchUpInside];

    [naviView.add addTarget:self action:@selector(addProductPlan) forControlEvents:UIControlEventTouchUpInside];

    for (UIButton *subView in naviView.subviews) {
        if (subView.tag==1003) {
            [subView addTarget:self action:@selector(savePlan) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1004){
            [subView addTarget:self action:@selector(recallPlan) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1005){
            [subView addTarget:self action:@selector(advancePlan) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1006){
            [subView addTarget:self action:@selector(emptyPlan) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1007){
            [subView addTarget:self action:@selector(favoritePlan:) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1008){
            [subView addTarget:self action:@selector(favoritePlan:) forControlEvents:UIControlEventTouchUpInside];
        }

    }
    [self saveDissenble:NO];
    [self recallDissenble:NO];
    [self nextDissenble:NO];

}
#pragma mark operationBarView Action －－－－－－－－－－－－－操作栏视图

-(void)setUpshowCheckProDuctPopView
{
    proDuctPopView=[[YSKJ_CanvasSediBarView alloc]initWithFrame:CGRectMake(THEWIDTH+58, 64, 58, THEHEIGHT-63)];
    proDuctPopView.backgroundColor=[UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:proDuctPopView];
    
    for (UIView *subView in proDuctPopView.subviews) {
        
        if ([subView isKindOfClass:[UIButton class]]) {
            
           [(UIButton*)subView addTarget:self action:@selector(productPopViewAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    
}
#pragma mark setUpTransFromSureWithDissView－－－－－－－确认变形和取消视图

-(void)setUpTransFromSureWithDissView
{
    transformView = [[YSKJ_CanvasTransfromView alloc]initWithFrame:CGRectMake(THEWIDTH, 0, 58, THEHEIGHT)];
    transformView.backgroundColor=[UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:transformView];
    
    for (UIView *subView in transformView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            
            [(UIButton*)subView addTarget:self action:@selector(productPopViewAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

#pragma mark  setUpProDuctModelView Action －－－－－－－添加商品旋转视图

-(void)setUpPicModelView
{
    picModleView=[[YSKJ_ProductViewDetail alloc] initWithFrame:CGRectMake(0, THEHEIGHT+55, THEWIDTH, 55)];
    picModleView.backgroundColor=[UIColor clearColor];
    picModleView.collect.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:picModleView];
    
  }

-(void)showModelView;
{
    picModleView.frame=CGRectMake(0, THEHEIGHT-55, THEWIDTH , 55);
    picModleView.backgroundColor=[UIColor whiteColor];
    picModlelineView.backgroundColor=UIColorFromHex(0xefefef);

}
-(void)hideModelView
{
    picModleView.frame=CGRectMake(0, THEHEIGHT, THEWIDTH, 55);
    picModleView.backgroundColor=[UIColor clearColor];
    picModlelineView.backgroundColor=[UIColor clearColor];

}

-(void)dissmissModleView
{
    picModleView.hidden=YES;
    proDuctPopView.hidden=YES;
}

-(void)showPicModleView
{
    picModleView.hidden=NO;
    proDuctPopView.hidden=NO;
}

-(void)animationAciton:(BOOL)yes
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=0.2;
    theAnimation.fromValue=[NSNumber numberWithFloat:0.2];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [picModleView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    [proDuctPopView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    
    if (yes) {
        [NSTimer scheduledTimerWithTimeInterval:theAnimation.duration
                                         target:self
                                       selector:@selector(dissmissModleView)
                                       userInfo:nil
                                        repeats:NO];
    }else{
        [NSTimer scheduledTimerWithTimeInterval:theAnimation.duration
                                         target:self
                                       selector:@selector(showPicModleView)
                                       userInfo:nil
                                        repeats:NO];
    }
    
}

#pragma mark  setUpFilterSubView Action －－－－－－－－－添加集合视图父视图window

-(void)setUpFilterSubView
{
    thefilterView=[[UIView alloc] initWithFrame:CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT)];
    thefilterView.backgroundColor=[UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:thefilterView];
    
    theFilterCanbutton=[[UIButton alloc] initWithFrame:CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT)];
    [theFilterCanbutton addTarget:self action:@selector(favoritePlan:) forControlEvents:UIControlEventTouchUpInside];
    theFilterCanbutton.backgroundColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.6];
    [[UIApplication sharedApplication].keyWindow addSubview:theFilterCanbutton];
    
    [self setUpProDuctColletionView];    //默认添加商品列表
    
}

#pragma mark  setUpProductFilterSubView Action －－－－ 添加筛选商城商品父视图window

-(void)setUpProductFilterSubView
{
    proDuctFilterView=[[UIView alloc] initWithFrame:CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT)];
    proDuctFilterView.backgroundColor=[UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:proDuctFilterView];
    
    proDuctFilterCanclebutton=[[UIButton alloc] initWithFrame:CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT)];
    [proDuctFilterCanclebutton addTarget:self action:@selector(proDuctFilterAction) forControlEvents:UIControlEventTouchUpInside];
    proDuctFilterCanclebutton.backgroundColor=[UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:proDuctFilterCanclebutton];
    
    _cateid=@"1";
    [self httpGetProDuctLableList];
}

#pragma mark  setUpColltionView Action －－－－－－－－－－－－－添加集合视图

-(void)setUpProDuctColletionView
{
    //创建一个layout布局类
    UICollectionViewFlowLayout * ProDuctlayout= [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    ProDuctlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    ProDuctlayout.itemSize = CGSizeMake((thefilterView.frame.size.width-16*4)/3, (thefilterView.frame.size.width-16*4)/3+56);
    //创建collectionView 通过一个布局策略layout来创建
    self.proDuctColletionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, PROCOLLETIONVIEW_T,thefilterView.frame.size.width, thefilterView.frame.size.height-PROCOLLETIONVIEW_T) collectionViewLayout:ProDuctlayout];
    self.proDuctColletionView.backgroundColor=[UIColor clearColor];
    //代理设置
    self.proDuctColletionView.delegate=self;
    self.proDuctColletionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.proDuctColletionView registerClass:[YSKJ_FavProductCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [thefilterView addSubview:self.proDuctColletionView];
    
    [self setUpFavoriteListItem];        //导航Item

}

-(void)setUpLableColletionView
{
    YSKJ_LabelLayout* layout1 = [[YSKJ_LabelLayout alloc] init];
    layout1.panding = LabCOLLETIONVIEW_PDD;
    layout1.rowPanding = LabCOLLETIONVIEW_ROWPDD;
    layout1.delegate = self;
    self.lablecollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,LabCOLLETIONVIEW_T, thefilterView.size.width, thefilterView.size.height-LabCOLLETIONVIEW_T) collectionViewLayout:layout1];
    self.lablecollectionView.backgroundColor=[UIColor greenColor];
    self.lablecollectionView.dataSource = self;
    self.lablecollectionView.delegate = self;
    self.lablecollectionView.backgroundColor = [UIColor clearColor];
    [self.lablecollectionView registerNib:[UINib nibWithNibName:@"YSKJ_CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [thefilterView addSubview:self.lablecollectionView];
    
    [self setUpFavoriteLableItem];
    
    UIButton *deleteAll=[UIButton new];
    deleteAll.tag=1004;
    [deleteAll setTitle:@"清除" forState:UIControlStateNormal];
    deleteAll.titleLabel.textColor=UIColorFromHex(0xffffff);
    [deleteAll addTarget:self action:@selector(deleteCheckLableAction) forControlEvents:UIControlEventTouchUpInside];
    deleteAll.titleLabel.font=[UIFont systemFontOfSize:20];
    deleteAll.backgroundColor=UIColorFromHex(0x999999);
    [self.lablecollectionView addSubview:deleteAll];
    deleteAll.sd_layout
    .leftEqualToView(self.lablecollectionView)
    .bottomSpaceToView(self.lablecollectionView,0)
    .widthRatioToView(self.lablecollectionView,0.5)
    .heightIs(56);
    
    UIButton *sureButton=[UIButton new];
    sureButton.tag=1005;
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    sureButton.titleLabel.textColor=UIColorFromHex(0xffffff);
    [sureButton addTarget:self action:@selector(sureButton) forControlEvents:UIControlEventTouchUpInside];
    sureButton.titleLabel.font=[UIFont systemFontOfSize:20];
    sureButton.backgroundColor=UIColorFromHex(0xf39800);
    [self.lablecollectionView addSubview:sureButton];
    sureButton.sd_layout
    .rightEqualToView(self.lablecollectionView)
    .bottomSpaceToView(self.lablecollectionView,0)
    .widthRatioToView(self.lablecollectionView,0.5)
    .heightIs(56);

}
-(void)setUpSpaceColletionView
{
    //创建一个layout布局类
    UICollectionViewFlowLayout * spacelayout= [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    spacelayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    spacelayout.itemSize = CGSizeMake((thefilterView.size.width-40)/2, SPACOLLETIONITEM_H);
    //创建collectionView 通过一个布局策略layout来创建
    self.spaceCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SPACOLLETIONVIEW_T,thefilterView.frame.size.width, thefilterView.frame.size.height-SPACOLLETIONVIEW_T) collectionViewLayout:spacelayout];
    self.spaceCollectionView.backgroundColor=[UIColor clearColor];
    //代理设置
    self.spaceCollectionView.delegate=self;
    self.spaceCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.spaceCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [thefilterView addSubview:self.spaceCollectionView];
    
    [self setUpSpaceBgListItem];        //导航Item

}
-(void)setUpSpaceLableColletionView
{
    //创建一个layout布局类
    UICollectionViewFlowLayout * spacelayout= [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    spacelayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    spacelayout.itemSize = CGSizeMake((thefilterView.size.width-10*4)/3, 24);
    //创建collectionView 通过一个布局策略layout来创建
    self.spaceLableCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SPACOLLETIONVIEW_T,thefilterView.frame.size.width, thefilterView.frame.size.height-SPACOLLETIONVIEW_T) collectionViewLayout:spacelayout];
    self.spaceLableCollectionView.backgroundColor=[UIColor clearColor];
    //代理设置
    self.spaceLableCollectionView.delegate=self;
    self.spaceLableCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.spaceLableCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [thefilterView addSubview:self.spaceLableCollectionView];
    
    [self setUpStoreFiltrListItem];        //导航Item
    
}
-(void)setUpAddProductColletionView
{
    //创建一个layout布局类
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    layout.itemSize = CGSizeMake((thefilterView.frame.size.width-ADDPROCOLLETIONVIEW_ITEMPDD*5)/3, ADDPROCOLLETIONITEM_H);
    //创建collectionView 通过一个布局策略layout来创建
    self.addProductCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, ADDPROCOLLETIONVIEW_T,thefilterView.frame.size.width, thefilterView.frame.size.height-ADDPROCOLLETIONVIEW_T) collectionViewLayout:layout];
    self.addProductCollectionView.backgroundColor=[UIColor clearColor];
    //代理设置
    self.addProductCollectionView.delegate=self;
    self.addProductCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.addProductCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [thefilterView addSubview:self.addProductCollectionView];
    
    [self setUpProductListItem];        //导航Item
    
    [self setUpNoDataView];           //加载没图片的视图
    
    //下拉刷新
    self.addProductCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadPageOne)];
    
}
-(void)loadPageOne
{
    _page1=@"1";
    intPage1=1;
    [self httpGetProDuctList];
}
#pragma mark 加载无商品提示的View
-(void)setUpNoDataView
{
    UIView *noDataView=[UIView new];
    noDataView.hidden=YES;
    noDataView.tag=4748;
    noDataView.backgroundColor=[UIColor clearColor];
    [self.addProductCollectionView addSubview:noDataView];
    noDataView.sd_layout
    .topSpaceToView(self.addProductCollectionView,(thefilterView.size.width)/2-64)
    .leftSpaceToView(self.addProductCollectionView,309/3.5)
    .rightSpaceToView(self.addProductCollectionView,309/3.5)
    .heightRatioToView(self.addProductCollectionView,0.4);
    
    UILabel *tiplable=[UILabel new];
    tiplable.tag=4751;
    tiplable.font=[UIFont systemFontOfSize:14];
    tiplable.textAlignment=NSTextAlignmentCenter;
    [noDataView addSubview:tiplable];
    tiplable.sd_layout
    .topEqualToView(noDataView)
    .rightEqualToView(noDataView)
    .leftEqualToView(noDataView)
    .autoHeightRatio(0);
    
    UIView *noDataline=[UIView new];
    noDataline.hidden=YES;
    noDataline.tag=4749;
    noDataline.backgroundColor=UIColorFromHex(0x999999);
    [self.addProductCollectionView addSubview:noDataline];
    noDataline.sd_layout
    .bottomSpaceToView(self.addProductCollectionView,81)
    .leftSpaceToView(self.addProductCollectionView,12)
    .rightSpaceToView(self.addProductCollectionView,12)
    .heightIs(1);
    
    UIImageView *noDataimage=[UIImageView new];
    noDataimage.hidden=YES;
    noDataimage.tag=4750;
    noDataimage.image=[UIImage imageNamed:@"loading2"];
    noDataimage.backgroundColor=[UIColor clearColor];
    [self.addProductCollectionView addSubview:noDataimage];
    noDataimage.sd_layout
    .topSpaceToView(noDataline,20)
    .widthIs(120)
    .heightIs(44)
    .leftSpaceToView(self.addProductCollectionView,(thefilterView.size.width-120)/2);
}

#pragma mark 显示或隐藏商品提示的View

-(void)showNoDataView
{
    UIView *remView=[self.addProductCollectionView viewWithTag:4748];
    UIView *remView1=[self.addProductCollectionView viewWithTag:4749];
    UIView *remView2=[self.addProductCollectionView viewWithTag:4750];
    if (self.proDuctArray.count==0) {
        remView.hidden=NO;
        remView1.hidden=NO;
        remView2.hidden=NO;
        UILabel *tiplable=[remView viewWithTag:4751];
        UIColor *attColor=UIColorFromHex(0xf39800);
        NSString *textStr;
        if ([_cateid isEqualToString:@"1"]) {
            textStr=@"家具中心";
        }else if ([_cateid isEqualToString:@"2"])
        {
            textStr=@"饰品中心";
            
        }else if ([_cateid isEqualToString:@"3"])
        {
            textStr=@"生活物件";
        }
        
        tiplable.text=[NSString stringWithFormat:@"Srroy！产品汪和程序猿还没有来得及把\"%@\"的素材更新上来，客官请下次再搜搜看",textStr ];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tiplable.text]; // 改变特定范围颜色大小要用的
        [attributedString addAttribute:NSForegroundColorAttributeName value:attColor range:NSMakeRange(21,textStr.length)];
        tiplable.attributedText=attributedString;
        
    }else{
        remView.hidden=YES;
        remView1.hidden=YES;
        remView2.hidden=YES;
    }
    
}

#pragma mark setUpColltionView Item Action －－－－集合视图上的导航栏

-(void)setUpFavoriteListItem      //收藏夹列表的导航栏
{
    UILabel *filterTitle=[UILabel new];
    filterTitle.textAlignment=NSTextAlignmentCenter;
    filterTitle.textColor=UIColorFromHex(0x666666);
    filterTitle.font=[UIFont systemFontOfSize:20];
    filterTitle.text=@"收藏夹";
    [thefilterView addSubview:filterTitle];
    filterTitle.sd_layout
    .centerXEqualToView(thefilterView)
    .topSpaceToView(thefilterView,27)
    .widthIs(80)
    .heightIs(20);
    
    UILabel *moreLable=[UILabel new];
    moreLable.text=@"选择标签";
    moreLable.textColor=UIColorFromHex(0x666666);
    moreLable.font=[UIFont systemFontOfSize:14];
    [thefilterView addSubview:moreLable];
    moreLable.sd_layout
    .rightSpaceToView(thefilterView,8)
    .widthIs(60)
    .heightIs(14)
    .topSpaceToView(thefilterView,33);
    
    UIImageView *filterImage=[UIImageView new];
    [thefilterView addSubview:filterImage];
    filterImage.image=[UIImage imageNamed:@"selection"];
    filterImage.sd_layout
    .rightSpaceToView(moreLable,8)
    .widthIs(16)
    .heightIs(16)
    .topEqualToView(moreLable);
    
    UIButton *filterButton=[UIButton new];
    filterButton.backgroundColor=[UIColor clearColor];
    [filterButton addTarget:self action:@selector(moreProductAction) forControlEvents:UIControlEventTouchUpInside];
    [thefilterView addSubview:filterButton];
    filterButton.sd_layout
    .rightSpaceToView(thefilterView,0)
    .widthIs(100)
    .heightIs(40)
    .topSpaceToView(thefilterView,25);
    
    UIView *lineView=[UIView new];
    lineView.backgroundColor=UIColorFromHex(0xefefef);
    [thefilterView addSubview:lineView];
    lineView.sd_layout
    .leftEqualToView(thefilterView)
    .rightEqualToView(thefilterView)
    .heightIs(1)
    .topSpaceToView(thefilterView,63);
}

-(void)setUpFavoriteLableItem  //收藏夹选择筛选列表的导航栏
{
    UILabel *filterTitle=[UILabel new];
    filterTitle.textAlignment=NSTextAlignmentCenter;
    filterTitle.textColor=UIColorFromHex(0x666666);
    filterTitle.font=[UIFont systemFontOfSize:20];
    filterTitle.text=@"更多";
    [thefilterView addSubview:filterTitle];
    filterTitle.sd_layout
    .centerXEqualToView(thefilterView)
    .topSpaceToView(thefilterView,27)
    .widthIs(70)
    .heightIs(20);
    
    UIImageView *filterImage=[UIImageView new];
    [thefilterView addSubview:filterImage];
    filterImage.image=[UIImage imageNamed:@"selection"];
    filterImage.sd_layout
    .rightSpaceToView(filterTitle,0)
    .widthIs(20)
    .heightIs(20)
    .topEqualToView(filterTitle);
    
    UIButton *returnLable=[UIButton new];
    [returnLable setTitle:@"返回" forState:UIControlStateNormal];
    returnLable.titleLabel.font=[UIFont systemFontOfSize:14];
    UIColor *retitcolor=UIColorFromHex(0x666666);
    [returnLable setTitleColor:retitcolor forState:UIControlStateNormal];
    [thefilterView addSubview:returnLable];
    returnLable.sd_layout
    .rightSpaceToView(thefilterView,8)
    .topSpaceToView(thefilterView,34)
    .widthIs(60)
    .heightIs(14);
    
    UIButton *returnButton=[UIButton new];
    returnButton.backgroundColor=[UIColor clearColor];
    [returnButton addTarget:self action:@selector(returnAction) forControlEvents:UIControlEventTouchUpInside];
    [thefilterView addSubview:returnButton];
    returnButton.sd_layout
    .rightSpaceToView(thefilterView,0)
    .widthIs(100)
    .heightIs(40)
    .topSpaceToView(thefilterView,25);

    UIView *lineView=[UIView new];
    lineView.backgroundColor=UIColorFromHex(0xefefef);
    [thefilterView addSubview:lineView];
    lineView.sd_layout
    .leftEqualToView(thefilterView)
    .rightEqualToView(thefilterView)
    .heightIs(1)
    .topSpaceToView(thefilterView,63);

    
}
-(void)setUpSpaceBgListItem   //空间背景列表的导航栏
{
    NSArray *items=@[@"官方背景",@"我的上传"];
    UISegmentedControl *seg=[[UISegmentedControl alloc] initWithItems:items];
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    seg.tintColor=UIColorFromHex(0xf39800);
    [thefilterView addSubview:seg];
    seg.sd_layout
    .leftSpaceToView(thefilterView,(thefilterView.size.width-200)/2)
    .widthIs(200)
    .heightIs(34)
    .topSpaceToView(thefilterView,(63-34)/2);
    
    spaceFilterButton=[UIButton new];
    UIColor *titlecol=UIColorFromHex(0xf32a00);
    [spaceFilterButton setTitleColor:titlecol forState:UIControlStateNormal];
    [spaceFilterButton setTitleEdgeInsets:(UIEdgeInsetsMake(15, 50, 15, 0))];
    [spaceFilterButton addTarget:self action:@selector(spaceFilterAction) forControlEvents:UIControlEventTouchUpInside];
    spaceFilterButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [spaceFilterButton setTitle:@"筛选" forState:UIControlStateNormal];
    [thefilterView addSubview:spaceFilterButton];
    spaceFilterButton.sd_layout
    .rightSpaceToView(thefilterView,8)
    .widthIs(80)
    .heightIs(44)
    .topSpaceToView(thefilterView,(63-44)/2);
    
    UIView *lineView=[UIView new];
    lineView.backgroundColor=UIColorFromHex(0xefefef);
    [thefilterView addSubview:lineView];
    lineView.sd_layout
    .leftEqualToView(thefilterView)
    .rightEqualToView(thefilterView)
    .heightIs(1)
    .topSpaceToView(thefilterView,63);
    
}

-(void)setUpStoreFiltrListItem  //商城商品分类筛选导航栏
{
    UILabel *filterTitle=[UILabel new];
    filterTitle.textAlignment=NSTextAlignmentCenter;
    filterTitle.textColor=UIColorFromHex(0x666666);
    filterTitle.font=[UIFont systemFontOfSize:20];
    filterTitle.text=@"筛选";
    [thefilterView addSubview:filterTitle];
    filterTitle.sd_layout
    .centerXEqualToView(thefilterView)
    .topSpaceToView(thefilterView,27)
    .widthIs(80)
    .heightIs(20);
    
    UIButton *filterButton=[UIButton new];
    filterButton.backgroundColor=[UIColor clearColor];
    UIColor *titleCol=UIColorFromHex(0xf32a00);
    [filterButton setTitleColor:titleCol forState:UIControlStateNormal];
    filterButton.titleLabel.font=[UIFont systemFontOfSize:14];
    filterButton.titleEdgeInsets=UIEdgeInsetsMake(15, 30, 15, 30);
    [filterButton setTitle:@"确定" forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(retureToSpaceList) forControlEvents:UIControlEventTouchUpInside];
    [thefilterView addSubview:filterButton];
    filterButton.sd_layout
    .rightSpaceToView(thefilterView,0)
    .widthIs(92)
    .heightIs(44)
    .topSpaceToView(thefilterView,20);
    
    UIView *lineView=[UIView new];
    lineView.backgroundColor=UIColorFromHex(0xefefef);
    [thefilterView addSubview:lineView];
    lineView.sd_layout
    .leftEqualToView(thefilterView)
    .rightEqualToView(thefilterView)
    .heightIs(1)
    .topSpaceToView(thefilterView,63);
    
}

-(void)setUpProductListItem  //选择商品的导航栏
{
    UILabel *filterTitle=[UILabel new];
    filterTitle.textAlignment=NSTextAlignmentCenter;
    filterTitle.textColor=UIColorFromHex(0x666666);
    filterTitle.font=[UIFont systemFontOfSize:20];
    filterTitle.text=@"选择商品";
    [thefilterView addSubview:filterTitle];
    filterTitle.sd_layout
    .centerXEqualToView(thefilterView)
    .topSpaceToView(thefilterView,27)
    .widthIs(100)
    .heightIs(20);
    
    UIButton *filter=[UIButton new];
    [filter setTitle:@"筛选" forState:UIControlStateNormal];
    [filter setImageEdgeInsets:UIEdgeInsetsMake(4, 64, 12, 0)];
    [filter setTitleEdgeInsets:UIEdgeInsetsMake(4, 8, 12, 30)];
    [filter setImage:[UIImage imageNamed:@"selection"] forState:UIControlStateNormal];
    UIColor *filterCol=UIColorFromHex(0x999999);
    [filter addTarget:self action:@selector(proDuctFilterAction) forControlEvents:UIControlEventTouchUpInside];
    [filter setTitleColor:filterCol forState:UIControlStateNormal];
    filter.titleLabel.font=[UIFont systemFontOfSize:14];
    [thefilterView addSubview:filter];
    filter.sd_layout
    .rightSpaceToView(thefilterView,8)
    .widthIs(100)
    .heightIs(44)
    .topSpaceToView(thefilterView,20);
    
    UIView *lineView=[UIView new];
    lineView.backgroundColor=UIColorFromHex(0xefefef);
    [thefilterView addSubview:lineView];
    lineView.sd_layout
    .leftEqualToView(thefilterView)
    .rightEqualToView(thefilterView)
    .heightIs(1)
    .topSpaceToView(thefilterView,63);
    
    NSArray *titleArr=@[@"家具中心",@"饰品中心",@"生活物件"];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *typeButton=[UIButton new];
        typeButton.tag=3000+i;
        UIColor *titleC=UIColorFromHex(0x666666);
        [typeButton setTitle:titleArr[i] forState:UIControlStateNormal];
        [typeButton addTarget:self action:@selector(typeButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
        typeButton.titleLabel.font=[UIFont systemFontOfSize:14];
        if (i==0) {
            UIColor *titleC=UIColorFromHex(0xf39800);
            [typeButton setTitleColor:titleC forState:UIControlStateNormal];
        }else{
            [typeButton setTitleColor:titleC forState:UIControlStateNormal];
        }
        [thefilterView addSubview:typeButton];
        typeButton.sd_layout
        .leftSpaceToView(thefilterView,120+80*i+12*i)
        .topSpaceToView(lineView,10)
        .heightIs(44)
        .widthIs(80);
        
    }
}

#pragma mark ColltionView navigation bar Action －－－－集合视图上的导航栏点击事件

-(void)typeButtonAciton:(UIButton*)sender
{
    for (UIView *sub in thefilterView.subviews) {
        if (sub.tag>=3000) {
            UIButton *but=(UIButton *)sub;
            if (sub.tag==sender.tag) {
                UIColor *titleC=UIColorFromHex(0xf39800);
                [but setTitleColor:titleC forState:UIControlStateNormal];
                intPage1=1;
                //——————————————————————————————————先让colletionView滚回顶端，防止intpage1++;————————————————————————————————————————————
                if (self.proDuctArray.count!=0) {    //colletionView存在个数的情况下才让他滚到顶端
                    [self.addProductCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                          atScrollPosition:UICollectionViewScrollPositionNone
                                                                  animated:NO];
                }
                
                [_selectStyleArray removeAllObjects];        //清空之前数据
                [_selectSpaceArray removeAllObjects];        //清空之前数据
                [_selectCategoryArray removeAllObjects];        //清空之前数据
                _style=@"";
                _space=@"";
                _category=@"";
                _source=@"";
               
                if (sender.tag==3000) {        //家具中心
                    [self.proDuctArray removeAllObjects];
                    _cateid=@"1";
                    _page1=@"1";
                    
                    [self httpGetProDuctList];
                     [self httpGetProDuctLableList];
                    
                }else if (sender.tag==3001){   //饰品中心
                    [self.proDuctArray removeAllObjects];
                    _cateid=@"2";
                    _page1=@"1";
                    
                    [self httpGetProDuctList];
                    [self httpGetProDuctLableList];
                    
                }else if (sender.tag){         //生活物件
                    [self.proDuctArray removeAllObjects];
                    _cateid=@"3";
                    _page1=@"1";
                    
                    [self httpGetProDuctList];
                    [self httpGetProDuctLableList];

                }
            }else{
                UIColor *titleC=UIColorFromHex(0x666666);
                [but setTitleColor:titleC forState:UIControlStateNormal];
            }
        }
    }
}
-(void)segmentedChanged:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex==0) {
        _type=@"1";
        _style=@"";
        [self httpGetSpacebgList];
        [spaceFilterButton setTitle:@"筛选" forState:UIControlStateNormal];
        [spaceFilterButton removeTarget:self action:@selector(spaceUploadAction) forControlEvents:UIControlEventTouchUpInside];
        [spaceFilterButton addTarget:self action:@selector(spaceFilterAction) forControlEvents:UIControlEventTouchUpInside];
    }else{
        _type=@"2";
        _style=@"";
        [self httpGetSpacebgList];
        [spaceFilterButton setTitle:@"上传" forState:UIControlStateNormal];
        [spaceFilterButton removeTarget:self action:@selector(spaceFilterAction) forControlEvents:UIControlEventTouchUpInside];
        [spaceFilterButton addTarget:self action:@selector(spaceUploadAction) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)spaceFilterAction
{
    for (UIView *subView in thefilterView.subviews) {
        [subView removeFromSuperview];
    }
    [self setUpSpaceLableColletionView];
    [self httpGetSpaceLableList];
}
-(void)retureToSpaceList
{
    for (UIView *subView in thefilterView.subviews) {
        [subView removeFromSuperview];
    }
    [self setUpSpaceColletionView];
    NSMutableArray *styleSelectArray=[[NSMutableArray alloc]init];
    for (UIView *subview in self.spaceLableCollectionView.subviews) {
        for (UIView *sub in subview.subviews) {
            if ([sub isKindOfClass:[UIButton class]]) {
                UIButton *button=(UIButton *)sub;
                if (button.selected==YES) {
                    [styleSelectArray addObject:button.titleLabel.text];
                }
            }
        }
    }
    _type=@"1";
    _style=[styleSelectArray componentsJoinedByString:@","];
    [self httpGetSpacebgList];
}

-(void)spaceUploadAction
{
    //选择相册模式
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    imagePicker.mediaTypes = mediaTypes;
    imagePicker.delegate = self;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
     popover.popoverContentSize = CGSizeMake(600, 800);//弹出视图的大小
     [popover presentPopoverFromRect:CGRectMake(THEWIDTH, 7, 60, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark  operationPlan Action －－－－－－－－－－－－－打开方案

-(void)setUpOpenPlanView:(NSString *)jsonStr isAddTag:(BOOL)isAddTag
{
    
    [arrUrl removeAllObjects];
    
    NSDictionary *dict=[ToolClass dictionaryWithJsonString:jsonStr];

    NSArray *dataArray=[dict objectForKey:@"data"];
    
    
    if (_loadingSelect == 1) {     //只执行一次
        
        [YSKJ_CanvasLoading showNotificationViewWithText:@"努力加载拼图中..." loadType:isBack];
        
        _loadingSelect = 2;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(selectImage) userInfo:nil repeats:YES];
        
    }
    
    for (int i=0;i<dataArray.count;i++) {
            
        NSDictionary *proDict=dataArray[i];
        
        YSKJ_CanvasParamModel *model = [YSKJ_CanvasParamModel mj_objectWithKeyValues:proDict];
        
        YSKJ_setUpProductInCanvas *product = [[YSKJ_setUpProductInCanvas alloc] initWithFrame:CGRectMake(0, 0, 0, 0) withDict:proDict];
        
        //获取网络图片的Size
        [product.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:model.url] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            if (image!=nil && image.size.height>0) {
                
                [_count addObject:image];
            }
            
            [product setImage:image forState:UIControlStateNormal];
            
        }];
        
        
        if ([model.imageTag integerValue]==6000) {
            
            product.tag=[model.imageTag integerValue];
            
            
        }else{

            if (isAddTag==YES) {
        
                product.tag=3000+10*(i+1);
                
            }else{
                
                product.tag=[model.imageTag integerValue];
                
            }
        }
        
        
       [proDict setValue:[NSString stringWithFormat:@"%ld",(long)product.tag] forKey:@"imageTag"];
    
        [product addTarget:self action:@selector(imageAction:) forControlEvents:UIControlEventTouchDown];
        
        if ([model.netW floatValue] >[model.netH floatValue]) {   //当原图宽大于高时
            
            if (product.frame.size.width > [model.netW floatValue]) {
   
                 product.frame = CGRectMake((canasView.frame.size.width - [model.netW floatValue])/2, (canasView.frame.size.height - [model.netH floatValue])/2, [model.netW floatValue], [model.netH floatValue]);
                
            }
            
        }else{             //当原图高大于宽时
            
            if (product.frame.size.height > [model.netH floatValue]) {
                
           
                product.frame = CGRectMake((canasView.frame.size.width - [model.netW floatValue])/2, (canasView.frame.size.height - [model.netH floatValue])/2, [model.netW floatValue], [model.netH floatValue]);
                
            }
            
        }
        
        
        //添加手势
        [self bindDoubleTap:product];
        [self bindPan:product];
        
        [canasView addSubview:product];
        
        for (int i=0;i<model.borderPoint.count;i++) {
            
            NSDictionary *borderPointDict=model.borderPoint[i];
            
            float ctx=[[borderPointDict objectForKey:@"centerX"] floatValue];
            float cty=[[borderPointDict objectForKey:@"centerY"] floatValue];
            
            UIButton *borderpoint=[[UIButton alloc] initWithFrame:CGRectMake(ctx-15, cty-15, 30, 30)];
            borderpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
            borderpoint.hidden=YES;
            borderpoint.tag=product.tag+10000+i;
            //重新插入tag
            [borderPointDict setValue:[NSString stringWithFormat:@"%ld",(long)borderpoint.tag] forKey:@"pointTag"];
            [borderpoint setImage:[UIImage imageNamed:@"borderpoint"] forState:UIControlStateNormal];
            [canasView addSubview:borderpoint];
        }
        
        
        UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton;
        
        for (int i=0;i<model.contorlPoint.count;i++) {
            
            NSDictionary *contorlPointDict=model.contorlPoint[i];
            
            float ctx=[[contorlPointDict objectForKey:@"centerX"] floatValue];
            float cty=[[contorlPointDict objectForKey:@"centerY"] floatValue];
            
            UIButton *controlpoint=[[UIButton alloc] initWithFrame:CGRectMake(ctx-15, cty-15, 30, 30)];
            controlpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
            controlpoint.hidden=YES;
            controlpoint.tag=product.tag+5000+i;
            //重新插入tag
            [contorlPointDict setValue:[NSString stringWithFormat:@"%ld",(long)controlpoint.tag] forKey:@"pointTag"];
            
            [controlpoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        
            
            [canasView addSubview:controlpoint];
            
            if (i==0) {
                
                tempTLbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer1 addTarget:self action:@selector(topLeftChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer1];
                
            }else if (i==1)
            {
                tempTRbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer2 addTarget:self action:@selector(topRightChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer2];
                
            }else if (i==2)
            {
                tempBLbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer3 addTarget:self action:@selector(bottomLeftChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer3];
                
            }else if (i==3)
            {
                
                tempBRbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer4 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer4 addTarget:self action:@selector(bottomRightChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer4];
                
            }
        
            [product.layer ensureAnchorPointIsSetToZero];
            product.layer.quadrilateral = AGKQuadMake(tempTLbutton.center,tempTRbutton.center,tempBRbutton.center,tempBLbutton.center);
        }
        
    }
    
   arrUrl = [[NSMutableArray alloc] initWithArray:dataArray];
    
   // NSLog(@"arrUrl.count=%lu",(unsigned long)arrUrl.count);
    
}
-(void)selectImage
{
    if (_count.count == arrUrl.count) {
        
        [timer invalidate];
        
        for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
            if (subView.tag == 2017) {
                [subView removeFromSuperview];
            }
        }
        
    }
    
}
-(void)topLeftChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadTopLeft];
}
-(void)topRightChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadTopRight];
}
-(void)bottomLeftChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadBottomLeft];
}
-(void)bottomRightChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadBottomRight];
}
- (void)panGestureChanged:(UIPanGestureRecognizer *)recognizer propertyName:(NSString *)propertyName
{
    
    [self addBorderWithTLView:controlLeftTopView TRView:controlRightTopView BLView:controlBottomLeftView BRView:controlBottomRightView panBool:NO];
    
    UIButton *button=(UIButton*)recognizer.view;
    
    [button setImage:[UIImage imageNamed:@"controlpoint1"] forState:UIControlStateNormal];
    
    tempView.transform = CGAffineTransformRotate(tempView.transform, 0);
    
    CGPoint translation = [recognizer translationInView:canasView];
    
    // Move control point
    recognizer.view.centerX += translation.x;
    recognizer.view.centerY += translation.y;
    [recognizer setTranslation:CGPointZero inView:canasView];
    
    // Animate
    POPSpringAnimation *anim = [checkButton.layer pop_animationForKey:propertyName];
    
    if(anim == nil)
    {
        anim = [POPSpringAnimation animation];
        anim.property = [POPAnimatableProperty AGKPropertyWithName:propertyName];
        [checkButton.layer pop_addAnimation:anim forKey:propertyName];
    }
    anim.velocity = [NSValue valueWithCGPoint:[recognizer velocityInView:canasView]];
    anim.toValue = [NSValue valueWithCGPoint:recognizer.view.center];
    anim.springBounciness = 7;
    anim.springSpeed =0.001;
    anim.dynamicsFriction = 7;
    
    if (recognizer.state==UIGestureRecognizerStateEnded||recognizer.state==UIGestureRecognizerStateCancelled) {
        
        NSDictionary *dict=[self getCGRect];
        borderLeftTopView.frame=CGRectMake([[dict objectForKey:@"tx"] floatValue]-15, [[dict objectForKey:@"ty"] floatValue]-15, 30, 30);
        borderRightTopView.frame=CGRectMake([[dict objectForKey:@"tx"] floatValue]+[[dict objectForKey:@"tw"] floatValue]-15, [[dict objectForKey:@"ty"] floatValue]-15, 30, 30);
        borderBottomLeftView.frame=CGRectMake([[dict objectForKey:@"tx"] floatValue]-15, [[dict objectForKey:@"ty"] floatValue]+[[dict objectForKey:@"th"] floatValue]-15, 30, 30);
        borderBottomRightView.frame=CGRectMake([[dict objectForKey:@"tx"] floatValue]+[[dict objectForKey:@"tw"] floatValue]-15, [[dict objectForKey:@"ty"] floatValue]+[[dict objectForKey:@"th"] floatValue]-15, 30, 30);

        [button setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        
        for (NSDictionary *dict in arrUrl) {
            
            NSInteger imagetag=[[dict objectForKey:@"imageTag"] integerValue];
            
            if (imagetag==checkButton.tag) {
                
                NSArray *contorlPointArray=[dict objectForKey:@"contorlPoint"];
                
                for (NSDictionary *dict in contorlPointArray) {
                    
                    if ([[dict objectForKey:@"pointTag"] integerValue]==recognizer.view.tag) {
                        [ dict setValue:[NSString stringWithFormat:@"%f",recognizer.view.centerX] forKey:@"centerX"];
                        [ dict setValue:[NSString stringWithFormat:@"%f",recognizer.view.centerY] forKey:@"centerY"];
                    }
                }
                [self upDateBorderPoint:dict];
                
            }
           
        }
        
    }
    
    [self addTempView];
    tempView.gestureRecognizers=nil;
    
}

-(void)updateImagePoint:(NSDictionary*)dict //更改图片的frame
{
    float centerX=checkButton.centerX;
    float centerY=checkButton.centerY;
    float w=[[dict objectForKey:@"w"] floatValue];
    float h=[[dict objectForKey:@"h"] floatValue];
    float x=centerX-(w)/2;
    float y=centerY-(h)/2;
    [dict setValue:[NSString stringWithFormat:@"%f",x] forKey:@"x"];
    [dict setValue:[NSString stringWithFormat:@"%f",y] forKey:@"y"];
    [dict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
    [dict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
}

-(void)upDateBorderPoint:(NSDictionary*)dict    //更改border控制点的frame
{
    NSArray *borderPointArray=[dict objectForKey:@"borderPoint"];
        
    for (NSDictionary *CTdict  in borderPointArray) {
        
        for (UIView *thesubView in [canasView subviews]) {
            
            if (borderLeftTopView.tag==thesubView.tag) {
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.center.x] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.center.y] forKey:@"centerY"];
                }
                
            }
            if (borderRightTopView.tag==thesubView.tag){
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerX] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerY] forKey:@"centerY"];
                }
                
            }
            if (borderBottomLeftView.tag==thesubView.tag){
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerX] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerY] forKey:@"centerY"];
                }
            }
            if (borderBottomRightView.tag==thesubView.tag){
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerX] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerY] forKey:@"centerY"];
                    
                }
            }
        }
    }

}
-(void)updateCtrolPoint:(NSDictionary*)dict
{
    //更改控制点的frame
    NSArray *contorlPointArray=[dict objectForKey:@"contorlPoint"];
    
    NSArray *tempArray = [[NSArray alloc] initWithArray:contorlPointArray];
    
    for (NSDictionary *CTdict  in tempArray) {
        
        for (UIView *thesubView in [canasView subviews]) {
            
            if (controlLeftTopView.tag==thesubView.tag) {
                
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.center.x] forKey:@"centerX"];
                    
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.center.y] forKey:@"centerY"];
                }
                
            }
            if (controlRightTopView.tag==thesubView.tag){
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerX] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerY] forKey:@"centerY"];
                }
                
            }
            if (controlBottomLeftView.tag==thesubView.tag){
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerX] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerY] forKey:@"centerY"];
                }
            }
            if (controlBottomRightView.tag==thesubView.tag){
                if (thesubView.tag==[[CTdict objectForKey:@"pointTag"] integerValue]) {
                    
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerX] forKey:@"centerX"];
                    [CTdict setValue:[NSString stringWithFormat:@"%f",thesubView.centerY] forKey:@"centerY"];
                    
                }
            }
        }
    }
}

#pragma mark  createPlan Action －－－－－－－－－－－－－生成方案

-(NSMutableArray *)addProductArray      //获取json数组
{

    NSDictionary *theDict=@{
                            @"count":[NSString stringWithFormat:@"%ld",(unsigned long)[self getCanvasArray].count],
                            @"data":[self getCanvasArray]
                            };
    
    [arr addObject:[ToolClass stringWithDict:theDict]];
    
    arrCount=(int)arr.count;
    
    if (arrCount==1) {
        
        [self saveDissenble:NO];
        [self recallDissenble:NO];
        [self nextDissenble:NO];
        
    }else{
        
        [self saveDissenble:YES];
        [self recallDissenble:YES];
        
    }
    
    [self haveAction];                //判断画布是否有图片
    
    return [self getCanvasArray];
    
}
-(void)haveAction
{
    if ([self getHave]==YES) {
        [self deleteDissenble:YES];
        [self detailDissenble:YES];
    }else{
        [self deleteDissenble:NO];
        [self detailDissenble:NO];
    }
}

-(BOOL)getHave       //统计画布是否有数据
{
    NSMutableArray *haveDataArray=[[NSMutableArray alloc] init];
    for (UIView *thesubView in [canasView subviews]) {
        if (thesubView.tag>3000 && thesubView.tag<8000) {
            [haveDataArray addObject:@"画布有图片"];
        }
    }
    if (haveDataArray.count!=0){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 上拉加载下拉刷新

-(void)setUpMjRefresh
{
    //下拉刷新
    self.proDuctColletionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
    //上拉加载
    self.proDuctColletionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
}

-(void)loadNewTopic
{
    _page=@"1";
    intPage=1;
    [self httpGetColletionList];
    
    //结束头部刷新
    [self.proDuctColletionView.mj_header endRefreshing];
    
}
static int intPage =1;
static int intPage1 =1;
-(void)loadMoreTopic
{
    intPage++;
    _page=[NSString stringWithFormat:@"%d",intPage];
    [self httpGetColletionList];
    // 结束刷新
    [self.proDuctColletionView.mj_footer  endRefreshing];
}

#pragma mark  AFNetwork Action  －－－－－－－－－－－－－网络请求事件

-(void)initHttpParam
{
    _cateid=@"1";_page1=@"1";_order=@"view_amount";_ordername=@"desc";_keyword=@"";_style1=@"";_space=@"";_category=@"";_source=@"";_spagenum=@"20";
    
}
-(void)httpGetColletionList
{
    //状态栏网络监控提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.lineArr=nil;        //清空数据
    self.dbDataArr=nil;      //清空数据
 
    DatabaseManager *databasemang=[[DatabaseManager alloc] init];
    databasemang.delegate=self;
    [databasemang openDatabase];
    [databasemang getAllDataWithTableName:@"yskj_proDuctTable" from:@"pro"];
    
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    NSDictionary *param=
    @{
      @"userid":[[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"],
      @"label":_lable,
      @"page":_page
      };
    
    [requset postHttpDataWithParam:param url:ALLPRODLIST  success:^(NSDictionary *dict, BOOL success) {
        
        self.lineArr=[dict objectForKey:@"data"];
        
        for (int i=0; i<self.lineArr.count; i++)
        {
            NSDictionary *lineDict=self.lineArr[i];
            
            for (int j=0; j<self.dbDataArr.count; j++)
            {
                NSDictionary *dbDict=self.dbDataArr[j];
                
                if ([[NSString stringWithFormat:@"%@",[lineDict objectForKey:@"id"]] isEqualToString:[dbDict objectForKey:@"product_id"]]) {
                    
                    [lineDict setValue:[dbDict objectForKey:@"thumb_file"] forKey:@"thumb_file"];        //数据替换，用数据库的覆盖请求到的字段
                    [lineDict setValue:[dbDict objectForKey:@"desc_img"] forKey:@"desc_img"];
                    
                }
                
            }
            
        }
        if (self.lineArr.count>=20) {
            
            [self setUpMjRefresh];       //有下拉和上拉
            
        }else{
            //只有下拉
            self.proDuctColletionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
        }
        if ([_page isEqualToString:@"1"]) {
            
            [self.addDataArr removeAllObjects];
            self.addDataArr=self.lineArr;
            
        }else{
            [self.addDataArr addObjectsFromArray:self.lineArr];
        }
        if (self.addDataArr.count==0) {
            
            [self proDuctCountIsNul:@"1"];
        }
        
        [self.proDuctColletionView reloadData];
        
        //状态栏网络监控提示
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } fail:^(NSError *error) {
        
    }];

}

-(void)httpGetColletionLable
{
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         
                         @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                         
                         };
    [httpRequest postHttpDataWithParam:dict url:GETLABLE success:^(NSDictionary *dict, BOOL success) {
        
        self.titles=[dict objectForKey:@"data"];
        
        [self titleCountIsNull];
        
        [self.lablecollectionView reloadData];
        
    } fail:^(NSError *error) {
        
    }];
    
}

-(void)httpGetSpacebgList
{
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *param=@{
                         
                         @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                         @"type":_type,
                         @"style":_style
                         };
    [httpRequest postHttpDataWithParam:param url:SPACEBG success:^(NSDictionary *dict, BOOL success) {
        
        if ([[dict objectForKey:@"success"]boolValue]!=0) {
           self.spaceArray=[dict objectForKey:@"data"];
            for (UIView *subView in self.spaceCollectionView.subviews) {
                if (subView.tag==900 || subView.tag==901) {
                    [subView removeFromSuperview];
                }
            }
        }else{
           [self.spaceArray removeAllObjects];
            [self proDuctCountIsNul:@"2"];
        }
    
        [self.spaceCollectionView reloadData];

        
    } fail:^(NSError *error) {
        
    }];
    
}
-(void)httpGetProductDetail:(NSDictionary*)dict
{
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    
    NSDictionary *prodict=@{
                            @"id":[dict objectForKey:@"pro_id"],
                            @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]
                            };
    
    [httpRequest postHttpDataWithParam:prodict url:DETAIL success:^(NSDictionary *dict, BOOL success) {
        
        picModleView.obj = dict;
        
        for (NSDictionary *dict in arrUrl) {
            
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
            
                picModleView.picStr = [[dict objectForKey:@"url"] substringFromIndex:27];
                
            }
        }
        
        
    } fail:^(NSError *error) {
        
    }];
    
}
-(void)httpGetSpaceLableList
{
    [self.spaceLableArray removeAllObjects];
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];

    [httpRequest postHttpDataWithParam:nil url:SPACECATE success:^(NSDictionary *dict, BOOL success) {
        
        self.spaceLableArray=[[[dict objectForKey:@"data"] objectForKey:@"style"] objectForKey:@"data"];
        
        [self.spaceLableCollectionView reloadData];

    } fail:^(NSError *error) {
        
    }];
    
}
static bool ishttpData=NO;         //是否还继续预加载
static bool ishttpagain=NO;        //等上一页加载完再进行下一页
-(void)httpGetProDuctList
{
    self.dbDataArr=nil;
    
    DatabaseManager *databasemang=[[DatabaseManager alloc] init];
    databasemang.delegate=self;
    [databasemang openDatabase];
    [databasemang getAllDataWithTableName:@"yskj_proDuctTable" from:@"pro"];
    
    NSString *useridStr;
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]) {
        useridStr = @"";
    }else{
        useridStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    }
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         @"cateid":_cateid,
                         @"page":_page1,
                         @"order":_order,
                         @"ordername":_ordername,
                         @"keyword":_keyword,
                         @"style":_style1,
                         @"space":_space,
                         @"category":_category,
                         @"source":_source,
                         @"pagenum":_spagenum,
                         @"userid":useridStr
                         };
    [httpRequest postHttpDataWithParam:dict url:SHOPLISTURL success:^(NSDictionary *dict, BOOL success) {
        
        ishttpagain=YES;    //是否继续预加载
        
        NSMutableArray *storeLineArr=[dict objectForKey:@"data"];

        if (storeLineArr.count<20) {
            ishttpData=NO;
        }else{
            ishttpData=YES;
        }
        
        for (int i=0; i<storeLineArr.count; i++)
        {
            NSDictionary *lineDict=storeLineArr[i];
            
            for (int j=0; j<self.dbDataArr.count; j++)
            {
                NSDictionary *dbDict=self.dbDataArr[j];
                
                if ([[NSString stringWithFormat:@"%@",[lineDict objectForKey:@"id"]] isEqualToString:[dbDict objectForKey:@"product_id"]]) {
                    
                    [lineDict setValue:[dbDict objectForKey:@"thumb_file"] forKey:@"thumb_file"];        //数据替换，用数据库的覆盖请求到的字段
                    [lineDict setValue:[dbDict objectForKey:@"desc_img"] forKey:@"desc_img"];
                    
                }
                
            }
            
        }
    
        if ([_page1 isEqualToString:@"1"]) {
            
            [self.proDuctArray removeAllObjects];
            self.proDuctArray=storeLineArr;
            
        }else{
            [self.proDuctArray addObjectsFromArray:storeLineArr];
        }
        
        //结束头部刷新
        [self.addProductCollectionView.mj_header endRefreshing];
        
        [self showNoDataView]; //展示没有商品的提示
        
        [self.addProductCollectionView reloadData];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } fail:^(NSError *error) {
        
    }];
}
-(void)httpGetProDuctLableList
{
    for (UIView *sub in proDuctFilterView.subviews) {
        [sub removeFromSuperview];
    }
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         @"cateid":_cateid,
                         };

    
    [httpRequest postHttpDataWithParam:dict url:GETTYPE success:^(NSDictionary *dict, BOOL success) {
        
        //获取data字典
        NSDictionary *dataDict=[dict objectForKey:@"data"];
        
        NSArray *DataArr=[dict objectForKey:@"data"];
        
       // lableArr=DataArr;
        
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
            
            [filterTableView removeFromSuperview];
            [categoryTableView removeFromSuperview];
            filterTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT)];
            filterTableView.backgroundColor=[UIColor clearColor];
            filterTableView.delegate=self;
            filterTableView.dataSource=self;
            [proDuctFilterView addSubview:filterTableView];
            
            categoryTableView=[[UITableView alloc] initWithFrame:CGRectMake(proDuctFilterView.size.width, 0, proDuctFilterView.size.width, THEHEIGHT)];
            categoryTableView.delegate=self;
            categoryTableView.dataSource=self;
            [proDuctFilterView addSubview:categoryTableView];
            
        }
        
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark OJLLabelLayoutDelegate

-(NSArray *)OJLLabelLayoutTitlesForLabel{
    
    return self.titles;
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.proDuctColletionView==collectionView) {
        
        return self.addDataArr.count;
        
    }else if(self.lablecollectionView==collectionView)
    {
        return self.titles.count;
        
    }else if(self.spaceLableCollectionView==collectionView)
    {
        return self.spaceLableArray.count;
        
    }else if(self.spaceCollectionView==collectionView){
        
        return self.spaceArray.count;
        
    }else{
        
        return self.proDuctArray.count;
    }
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.proDuctColletionView==collectionView) {            //展示商品

        YSKJ_FavProductCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
        
        NSDictionary *dict=self.addDataArr[indexPath.row];
        
        YSKJ_ProDuctModel *model = [YSKJ_ProDuctModel mj_objectWithKeyValues:dict];
        
        cell.titleLable.text = model.name;
        
        cell.url = model.thumb_file;
        
        cell.button.tag = 20000+indexPath.row;
        
        [cell.button setImage:[UIImage imageNamed:@"loading1"] forState:UIControlStateNormal];
        UILongPressGestureRecognizer *panRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [panRecognizer addTarget:self action:@selector(handleLongProDuctImage:)];
        [cell.button addGestureRecognizer:panRecognizer];
        
        [cell.button addTarget:self action:@selector(addFavProduct:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.button sd_setImageWithURL:[[NSURL alloc] initWithString:model.thumb_file]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
        
        //获取网络图片的Size
        [cell.button.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:model.thumb_file] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            if (image.size.width<0) {
                
                [dict setValue:@"" forKey:@"imageW"];
                [dict setValue:@"" forKey:@"imageH"];
                
            }else{
                [dict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"imageW"];
                [dict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"imageH"];
            }
            
        }];
        if (![dict objectForKey:@"imageH"]) {
            [dict setValue:@"" forKey:@"imageW"];
            [dict setValue:@"" forKey:@"imageH"];
        }

        return cell;
        
    }else if(self.lablecollectionView==collectionView){     //展示标签列表
        //选单品收藏视图公用一个Cell
        custCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        custCell.label.layer.cornerRadius=12;
        custCell.label.layer.masksToBounds=YES;
        [custCell setTitle:self.titles[indexPath.item]];
        UIColor *lablCo=UIColorFromHex(0x666666);
        custCell.label.layer.borderColor = lablCo.CGColor;
        custCell.label.layer.borderWidth = 1;
        custCell.label.textColor=lablCo;
  
        if (indexPath.row==self.titles.count-1) {
            [self getCheckOflast];
        }
        return custCell;
        
    }else if (self.spaceLableCollectionView==collectionView){
        
        UICollectionViewCell *spaceLablecell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
        spaceLablecell.tag=10000+indexPath.row;
        spaceLablecell.backgroundColor=[UIColor clearColor];
        
        UIButton *filterText= [UIButton new];
        UIColor *titleColor=UIColorFromHex(0x333333);
        filterText.tag=10000+indexPath.row;
        [filterText setTitleColor:titleColor forState:UIControlStateNormal];
        UIColor *borCol=UIColorFromHex(0x999999);
        filterText.layer.borderColor=borCol.CGColor;
        filterText.layer.borderWidth=1;
        NSDictionary *title=self.spaceLableArray[indexPath.row];
        [filterText setTitle:[title objectForKey:@"display_name"] forState:UIControlStateNormal];
        [filterText addTarget:self action:@selector(getStyleAction:) forControlEvents:UIControlEventTouchUpInside];
        filterText.titleLabel.font=[UIFont systemFontOfSize:14];
        [spaceLablecell addSubview:filterText];
        
        NSDictionary *attribute = @{NSFontAttributeName: filterText.titleLabel.font};
        CGSize labelsize  = [filterText.titleLabel.text boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        filterText.layer.cornerRadius=(labelsize.height+10)/2;
        filterText.layer.masksToBounds=YES;
        
        filterText.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 30, 0, spaceLablecell.size.width-(labelsize.width+28)-30));
        
        return spaceLablecell;
   
    }else if(self.spaceCollectionView==collectionView){                        //展示背景列表
        
        UICollectionViewCell *spacecell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
        spacecell.backgroundColor=[UIColor clearColor];
        //移除队列，防止cell复用
        for (UIView *subview in spacecell.subviews) {
            if (subview) {
                [subview removeFromSuperview];
            }
        }
        NSDictionary *dict=self.spaceArray[indexPath.row];
        
        DatabaseManager *databasemang=[[DatabaseManager alloc] init];
        databasemang.delegate=self;
        [databasemang openDatabase];
        [databasemang getOneProDuctDataTableName:@"yskj_bgTable" with:[dict objectForKey:@"id"] getStr:@"product_id"];
        
        UIButton *spaceImage=[[UIButton alloc] init];
        spaceImage.tag=30000+indexPath.row;
        [spacecell addSubview:spaceImage];
        spaceImage.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
        [spaceImage addTarget:self action:@selector(addSpaceProduct:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *panRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [panRecognizer addTarget:self action:@selector(handleLongProDuctImage:)];
        [spaceImage addGestureRecognizer:panRecognizer];
        
        if (dbDescModlePicStr.length>0) { //数据库有返回说明存在数据库
            
            if ([dbDescModlePicStr integerValue] == [[dict objectForKey:@"id"] integerValue]) {
        
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
                NSArray  *picArr= [[dict objectForKey:@"url"] componentsSeparatedByString:@"/"];
                
                NSString *theStr=[[NSString stringWithFormat:@"%@",picArr[2]] stringByReplacingOccurrencesOfString:@" " withString:@""];//替换掉数组第三个元素的引号
                NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,@"appspacebgthumb",picArr[1]];
                
                NSString *fullPath = [imagePath stringByAppendingPathComponent:theStr];
                
                UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
                
                [spaceImage setImage:savedImage forState:UIControlStateNormal];
                
                NSString *imageStr=[NSString stringWithFormat:@"%@%@",SPACEBGURL,[dict objectForKey:@"url"]];
                NSURL *imagUrl1=[NSURL URLWithString:imageStr];
                //获取网络图片的Size
                [spaceImage.imageView sd_setImageWithPreviousCachedImageWithURL:imagUrl1 placeholderImage:[UIImage imageNamed:@"loading3"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                    [dict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"imageW"];
                    [dict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"imageH"];
                    
                }];

            }
            
        }else{
            
    
            NSString *picStr=[NSString stringWithFormat:@"%@%@-%@",SPACEBGURL,[dict objectForKey:@"url"],SPACEGBCSS];
            NSURL *imagUrl=[[NSURL alloc] initWithString:picStr];
            
            [spaceImage sd_setImageWithURL:imagUrl  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
            
            NSString *imageStr=[NSString stringWithFormat:@"%@%@",SPACEBGURL,[dict objectForKey:@"url"]];
            NSURL *imagUrl1=[NSURL URLWithString:imageStr];
            //获取网络图片的Size
            [spaceImage.imageView sd_setImageWithPreviousCachedImageWithURL:imagUrl1 placeholderImage:[UIImage imageNamed:@"loading3"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                if (image.size.width>0) {
                    [dict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"imageW"];
                    [dict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"imageH"];
                }else{
                    [dict setValue:@"" forKey:@"imageW"];
                    [dict setValue:@"" forKey:@"imageH"];
                }
                
            }];

        }
        if (![dict objectForKey:@"imageH"]) {
            [dict setValue:@"" forKey:@"imageW"];
            [dict setValue:@"" forKey:@"imageH"];
        }
        
        return spacecell;
        
    }else{
        
        UICollectionViewCell *productCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
        
        //移除队列，防止cell复用
        for (UIView *subview in productCell.subviews) {
            if (subview) {
                [subview removeFromSuperview];
            }
        }
        if (self.proDuctArray.count!=0) {
            
            NSDictionary *dict=self.proDuctArray[indexPath.row];
            UIButton *proDuctImage=[[UIButton alloc] initWithFrame:CGRectMake(4, 4, productCell.size.width-8, productCell.size.height-48)];
            proDuctImage.adjustsImageWhenHighlighted=YES;
            proDuctImage.tag=40000+indexPath.row;
            [proDuctImage setImage:[UIImage imageNamed:@"loading1"] forState:UIControlStateNormal];
            [productCell addSubview:proDuctImage];
            
            UILongPressGestureRecognizer *panRecognizer = [[UILongPressGestureRecognizer alloc] init];
            [panRecognizer addTarget:self action:@selector(handleLongProDuctImage:)];
            [proDuctImage addGestureRecognizer:panRecognizer];
            
            [proDuctImage addTarget:self action:@selector(addProduct:) forControlEvents:UIControlEventTouchUpInside];
      
            NSString *picStr=[dict objectForKey:@"thumb_file"];
            
            if (picStr.length<25) {
                
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
                NSArray  *picArr= [picStr componentsSeparatedByString:@"/"];
                
                NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,picArr[1],picArr[2]];
                NSString *fullPath = [imagePath stringByAppendingPathComponent:picArr[3]];
                
                UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
                
                float imageW=(thefilterView.frame.size.width-16*4)/3-24;
                float scaleW;
                if (savedImage.size.width>=savedImage.size.height) {
                    scaleW=imageW/savedImage.size.width;
                }else{
                    scaleW=imageW/savedImage.size.height;
                }
                
                proDuctImage.imageEdgeInsets=UIEdgeInsetsMake(((proDuctImage.size.height-scaleW*(savedImage.size.height))/2), ((proDuctImage.size.width-scaleW*(savedImage.size.width))/2), ((proDuctImage.size.height-scaleW*(savedImage.size.height))/2), ((proDuctImage.size.width-scaleW*(savedImage.size.width))/2));
                
                [proDuctImage setImage:savedImage forState:UIControlStateNormal];
                
                [dict setValue:[NSString stringWithFormat:@"%f",savedImage.size.width] forKey:@"imageW"];
                [dict setValue:[NSString stringWithFormat:@"%f",savedImage.size.height] forKey:@"imageH"];
                
            }else{
                
                [proDuctImage sd_setImageWithURL:[[NSURL alloc] initWithString:picStr]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading1"]];
                //获取网络图片的Size
                [proDuctImage.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:picStr] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                    if (image.size.width>0) {
                        [dict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"imageW"];
                        [dict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"imageH"];
                        
                        float imageW=(thefilterView.frame.size.width-16*4)/3-24;
                        float scaleW;
                        if (image.size.width>=image.size.height) {
                            scaleW=imageW/image.size.width;
                        }else{
                            scaleW=imageW/image.size.height;
                        }
                        
                        proDuctImage.imageEdgeInsets=UIEdgeInsetsMake(((proDuctImage.size.height-scaleW*(image.size.height))/2), ((proDuctImage.size.width-scaleW*(image.size.width))/2), ((proDuctImage.size.height-scaleW*(image.size.height))/2), ((proDuctImage.size.width-scaleW*(image.size.width))/2));

                    }else{
                        
                        [dict setValue:@"" forKey:@"imageW"];
                        [dict setValue:@"" forKey:@"imageH"];
                    }
                }];
            }
            
            if (![dict objectForKey:@"imageH"] || ![dict objectForKey:@"imageW"]) {
                [dict setValue:@"" forKey:@"imageW"];
                [dict setValue:@"" forKey:@"imageH"];
            }
            
            UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(0, proDuctImage.size.height+8, productCell.size.width, 30)];
            titleLable.textColor=UIColorFromHex(0x333333);
            titleLable.font=[UIFont systemFontOfSize:14];
            NSString *titleStr=[dict objectForKey:@"name"];
            if (titleStr.length>20) {
                NSString *subString=[NSString stringWithFormat:@"%@...",[titleStr substringToIndex:20]];
                titleLable.text=subString;
            }else{
                if (titleStr.length<12) {
                    titleLable.textAlignment=NSTextAlignmentCenter;
                }
                titleLable.text=[dict objectForKey:@"name"];
            }
            [productCell addSubview:titleLable];
       
            if (self.proDuctArray.count-indexPath.row<6) {
                if (ishttpagain==YES) {
                    if (ishttpData==YES) {
                        intPage1++;
                        _page1=[NSString stringWithFormat:@"%d",intPage1];
                        [self httpGetProDuctList];
                    }
                    ishttpagain=NO;
                }
            }
        }
        return productCell;
    }
  
}

- (void)handleLongProDuctImage:(UILongPressGestureRecognizer*) longPressGestureReg
{
 
    CGPoint location = [longPressGestureReg locationInView:longPressGestureReg.view];
    
    CGPoint realLocation = [longPressGestureReg.view convertPoint:location toView:canasView];
    
    if (longPressGestureReg.state==UIGestureRecognizerStateBegan) {

        _panView=[[UIView alloc] initWithFrame:self.view.bounds];
        _panView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0];
        [[UIApplication sharedApplication].keyWindow addSubview:_panView];
        
        _panButton=[[UIButton alloc] initWithFrame:CGRectMake(realLocation.x-longPressGestureReg.view.size.width/2, realLocation.y-longPressGestureReg.view.size.width/2, longPressGestureReg.view.size.width, longPressGestureReg.view.size.height)];
        _panButton.backgroundColor=[UIColor clearColor];
        UIButton *image=(UIButton*)longPressGestureReg.view;
        _panButton.imageEdgeInsets=image.imageEdgeInsets;
        [_panButton setImage:image.imageView.image forState:UIControlStateNormal];
        [_panView addSubview:_panButton];
        
        [UIView animateWithDuration:0.3 animations:^{
            //隐藏改变Y轴
            thefilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            theFilterCanbutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            thefilterView.backgroundColor=[UIColor clearColor];
            filterCell.backgroundColor=[UIColor clearColor];
            cateCell.backgroundColor=[UIColor clearColor];
            
        }];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            [_panButton setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        }];

        
    }else{
        
        if (realLocation.x>_panButton.size.width/2-_panButton.imageEdgeInsets.left && realLocation.y>_panButton.size.height/2-_panButton.imageEdgeInsets.top && realLocation.y<_panView.size.height-(_panButton.size.height/2-_panButton.imageEdgeInsets.bottom) && realLocation.x<_panView.size.width-(_panButton.size.width/2-_panButton.imageEdgeInsets.right)) {
            
            _panButton.frame=CGRectMake(realLocation.x-_panButton.size.width/2, realLocation.y-_panButton.size.width/2, _panButton.size.width, _panButton.size.height);
            
            BOOL containsPoint=NO;
            
            for (UIView *subView in canasView.subviews) {
                
                //在画布某个SubView上用替换否则添加
                if (CGRectContainsPoint(subView.frame, realLocation)) {
                    
                    if (subView.tag == checkButton.tag) {
                        [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:YES];
                    }
                    
                    for (UIView *subView1 in canasView.subviews) {
                        if (subView.tag+10000==subView1.tag) {
                            borderLeftTopView=subView1;
                        }
                        if (subView.tag+10001==subView1.tag) {
                            borderRightTopView=subView1;
                        }
                        if (subView.tag+10002==subView1.tag) {
                            borderBottomLeftView=subView1;
                        }
                        if (subView.tag+10003==subView1.tag) {
                            borderBottomRightView=subView1;
                        }
                        
                    }
                
                    if ([subView isKindOfClass:[UIButton class]]) {
                        checkButton=(UIButton*)subView;
                    }
                    
                    [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:YES];
                    
                    [UIView animateWithDuration:0.6 animations:^{
                        proDuctPopView.frame=CGRectMake(THEWIDTH-58, 64, 58, THEHEIGHT-63);
                        proDuctPopView.backgroundColor=[UIColor whiteColor];
                        proDuctPopView.line.backgroundColor=UIColorFromHex(0xefefef);
                    }];
                    
                    
                    containsPoint=YES;
                    
                }else{
                    
                    if (containsPoint==NO) {
                        shapelayer.strokeColor = [UIColor clearColor].CGColor;
                        containsPoint=YES;
                    }
                }
            }

        }
        
        
        NSMutableDictionary *tempdict=[[NSMutableDictionary alloc] init];
        
        if (longPressGestureReg.state==UIGestureRecognizerStateEnded || longPressGestureReg.state==UIGestureRecognizerStateCancelled) {
            
            [_panView removeFromSuperview];
            
            NSString *thumbfileS;
            NSDictionary *_proDict;
          
            for (int i=0; i<self.proDuctArray.count; i++) {
                if (longPressGestureReg.view.tag-40000==i) {
                    NSDictionary *dict=self.proDuctArray[i];
                    _proDict=self.proDuctArray[i];
                    thumbfileS=[dict objectForKey:@"thumb_file"];
                }
            }
            
            for (int i=0; i<self.addDataArr.count; i++) {
                if (longPressGestureReg.view.tag-20000==i) {
                    NSDictionary *dict=self.addDataArr[i];
                     _proDict=self.addDataArr[i];
                    thumbfileS=[dict objectForKey:@"thumb_file"];
                }
            }
            for (int i=0; i<self.spaceArray.count; i++) {
                if (longPressGestureReg.view.tag-30000==i) {
                    NSDictionary *dict=self.spaceArray[i];
                     _proDict=self.spaceArray[i];
                    thumbfileS=[NSString stringWithFormat:@"%@%@",SPACEBGURL,[dict objectForKey:@"url"]];
                }
            }
            
            if (shapelayer.strokeColor!=[UIColor clearColor].CGColor && checkButton.tag!=6000 ) {

                for (int i=0; i<arrUrl.count; i++) {
                    
                    NSDictionary *dictA=arrUrl[i];
                    
                    if ([[dictA objectForKey:@"imageTag"] integerValue] == checkButton.tag) {
                        
                                tempdict=[[NSMutableDictionary alloc] initWithDictionary:dictA];
                        
                                [tempdict setValue:[_proDict objectForKey:@"desc_model"] forKey:@"picModle"];
                
                                if (thumbfileS.length<30) {
                                    [tempdict setValue:[NSString stringWithFormat:@"%@%@",PICURL,thumbfileS] forKey:@"url"];
                                }else{
                                    [tempdict setValue:thumbfileS forKey:@"url"];
                                }
                              
                                NSURL *imageUrl=[NSURL URLWithString:[tempdict objectForKey:@"url"]];
                                
                                //————————————————————————————————————————————————————————————进行网络图片尺寸适配——————————————
                                [checkButton.imageView sd_setImageWithPreviousCachedImageWithURL:imageUrl placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                    
                                    //之前的x,y,w,h
                                    float x,y,w,h,netW,netH;
                                    w=[[tempdict objectForKey:@"w"] floatValue];
                                    h=[[tempdict objectForKey:@"h"] floatValue];
                                    x=[[tempdict objectForKey:@"x"] floatValue];
                                    y=[[tempdict objectForKey:@"y"] floatValue];
                                    
                                    netW=[[tempdict objectForKey:@"netW"] floatValue];
                                    netH=[[tempdict objectForKey:@"netH"] floatValue];
                                    
                                    //计算主图网络尺寸跟本地尺寸比例
                                    float scaleW=w/netW;
                                    float scaleH=h/netH;
                                    
                                    float netW1=image.size.width*scaleW;
                                    float netH1=image.size.height*scaleH;
                                    
                                    float x1=x-(netW1-w)/2;    //改变后的x
                                    float y1=y-(netH1-h)/2;    //改变后的y
                                    
                                    [tempdict setValue:[NSString stringWithFormat:@"%f",x1] forKey:@"x"];
                                    [tempdict setValue:[NSString stringWithFormat:@"%f",y1] forKey:@"y"];
                                    [tempdict setValue:[NSString stringWithFormat:@"%f",netW1] forKey:@"w"];
                                    [tempdict setValue:[NSString stringWithFormat:@"%f",netH1] forKey:@"h"];
                                    [tempdict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"netW"];
                                    [tempdict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"netH"];
                                    
                                    NSArray *controlPoint=[tempdict objectForKey:@"contorlPoint"];
                                    for (int i=0; i<controlPoint.count; i++) {
                                        NSDictionary *controlDict=controlPoint[i];
                                        float centerX,centerY;
                                        if (i==0) {
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                                            
                                        }else if (i==1){
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                                            
                                        }else if (i==2){
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                                            
                                        }else {
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                                        }
                                        [controlDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
                                        [controlDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
                                    }
                                    
                                    NSArray *boderPoint=[tempdict objectForKey:@"borderPoint"];
                                    for (int i=0; i<boderPoint.count; i++) {
                                        NSDictionary *boderDict=boderPoint[i];
                                        float centerX,centerY;
                                        if (i==0) {
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                                            
                                        }else if (i==1){
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                                            
                                        }else if (i==2){
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict
                                                      objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                                            
                                        }else {
                                            centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                                            centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                                        }
                                        [boderDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
                                        [boderDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
                                    }
                                    
                                }];

                        
                    }
                }
                //把arrUrl的url换了
                for (int i=0; i<arrUrl.count; i++) {
                    
                    NSDictionary *jsonDict=arrUrl[i];
                    if ([[jsonDict objectForKey:@"imageTag"] integerValue]==[[tempdict objectForKey:@"imageTag"] integerValue]) {
                        [jsonDict setValue:[tempdict objectForKey:@"url"] forKey:@"url"];
                        [jsonDict setValue:[tempdict objectForKey:@"x"] forKey:@"x"];
                        [jsonDict setValue:[tempdict objectForKey:@"y"] forKey:@"y"];
                        [jsonDict setValue:[tempdict objectForKey:@"w"] forKey:@"w"];
                        [jsonDict setValue:[tempdict objectForKey:@"h"] forKey:@"h"];
                        [jsonDict setValue:[tempdict objectForKey:@"picModle"] forKey:@"picModle"];
                        [jsonDict setValue:[tempdict objectForKey:@"netW"] forKey:@"netW"];
                        [jsonDict setValue:[tempdict objectForKey:@"netH"] forKey:@"netH"];
                        [jsonDict setValue:[_proDict objectForKey:@"id"] forKey:@"pro_id"];
                        
                    }
                }
                
                [self addProductArray];
                
                for (UIView *subViews in [canasView subviews]) {
                    if (subViews!=tempView) {
                        [subViews removeFromSuperview];
                    }
                }
                
                [self setUpOpenPlanView:[arr lastObject] isAddTag:NO];
                
                for (UIView *subView in canasView.subviews) {
                    UIButton *button=(UIButton *)subView;
                    if (button.tag==checkButton.tag) {
                        [self imageAction:button];
                    }
                }
      
            }else{
                
                BOOL add=NO;
                
                if (add != YES) {
                    
                    for (int i=0; i<self.proDuctArray.count; i++) {
                        
                        if (longPressGestureReg.view.tag-40000==i) {
                            
                            NSDictionary *dict=self.proDuctArray[i];
                            
                            add = YES;
                            
                            [self createProductObj:dict withEnumType:PanStroeProDuct];
  
                        }
                        
                    }
                }
                
                if (add != YES) {
                    
                    for (int i=0; i<self.addDataArr.count; i++) {
                        
                        if (longPressGestureReg.view.tag-20000==i) {
                            
                            NSDictionary *dict=self.addDataArr[i];
                            
                            [self createProductObj:dict withEnumType:PanStroeProDuct];
 
                        }
                    }

                }
                if (add != YES) {
                    
                    for (int i=0; i<self.spaceArray.count; i++) {
                        
                        if (longPressGestureReg.view.tag-30000==i) {
                            
                            NSDictionary *dict=self.spaceArray[i];
                            
                            [self createProductObj:dict withEnumType:AddSpaceBgProDuct];
  
                        }
                    }
  
                }
                
                add=NO;
 
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                thefilterView.backgroundColor=UIColorFromHex(0xffffff);
                thefilterView.frame=CGRectMake(THEWIDTH/2, 0, THEWIDTH/2, THEHEIGHT);
                theFilterCanbutton.frame=CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT);
            }];
            
            
        }
    }
}

-(void)addProduct:(UIButton*)sender
{
    for (int i=0; i<self.proDuctArray.count; i++) {
        if (sender.tag-40000==i) {
            NSDictionary *dict=self.proDuctArray[i];
            [self createProductObj:dict withEnumType:AddStroeProDuct];
        }
    }
}
-(void)addFavProduct:(UIButton*)sender
{
    for (int i=0; i<self.addDataArr.count; i++) {
        if (sender.tag-20000==i) {
            NSDictionary *dict=self.addDataArr[i];
            [self createProductObj:dict withEnumType:AddStroeProDuct];
        }
    }
}
-(void)addSpaceProduct:(UIButton*)sender
{
    for (int i=0; i<self.spaceArray.count; i++) {
        if (sender.tag-30000==i) {
            NSDictionary *dict=self.spaceArray[i];
            [self createProductObj:dict withEnumType:AddSpaceBgProDuct];
        }
    }
}

-(void)getStyleAction:(UIButton *)sender
{
    for (UIView *subview in self.spaceLableCollectionView.subviews) {
        if (subview.tag==sender.tag) {
            for (UIView *sub in subview.subviews) {
                if (sub.tag==sender.tag) {
                    UIButton *button=(UIButton *)sub;
                    if (button.selected==NO) {
                        button.selected=YES;
                        button.layer.borderColor=[UIColor orangeColor].CGColor;
                        button.layer.borderWidth=1;
                        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    }else{
                        button.selected=NO;
                        UIColor *borCol=UIColorFromHex(0x999999);
                        button.layer.borderColor=borCol.CGColor;
                        button.layer.borderWidth=1;
                        UIColor *titleColor=UIColorFromHex(0x333333);
                        [button setTitleColor:titleColor forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
}
-(void)getCheckOflast          //还原上一次选中
{
    for (NSString *titleStr in self.titles) {
        for (NSString *sameStr in thearray) {
            if ([titleStr isEqualToString:sameStr]) {
                for (UIView *subView in [self.lablecollectionView subviews]) {
                    for (UIView *thesubView in [subView subviews]) {
                        for (UILabel *lable in [thesubView subviews]) {
                            if ([lable.text isEqualToString:titleStr]) {
                                lable.layer.borderColor = [UIColor orangeColor].CGColor;
                                lable.layer.borderWidth = 1;
                                lable.textColor=[UIColor orangeColor];
                            }
                            
                        }
                    }
                }
            }
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView==self.proDuctColletionView) {                    //创建家具对象
        
        NSDictionary *dict=self.addDataArr[indexPath.row];
        [self createProductObj:dict withEnumType:AddStroeProDuct];
        
    }else if (collectionView==self.lablecollectionView){
        
       static bool ischeck=NO;
        
        for (UIView *subView in [self.lablecollectionView subviews]) {
            for (UIView *thesubView in [subView subviews]) {
                for (UILabel *lable in [thesubView subviews]) {
                    if ([lable.text isEqualToString:self.titles[indexPath.item]]) {
                        if (ischeck==NO) {
                            lable.layer.borderColor = [UIColor orangeColor].CGColor;
                            lable.layer.borderWidth = 1;
                            lable.textColor=[UIColor orangeColor];
                            ischeck=YES;
                            
                        }else{
                            UIColor *lablCo=UIColorFromHex(0x666666);
                            lable.layer.borderColor = lablCo.CGColor;
                            lable.layer.borderWidth = 1;
                            lable.backgroundColor=[UIColor clearColor];
                            lable.textColor=lablCo;
                            ischeck=NO;
                        }
                        
                    }
                    
                }
            }
            
        }
        sureArray=[self getSureArray];

    }else if(self.spaceCollectionView==collectionView){                     //创建空间背景对象对象

        NSDictionary *dict=self.spaceArray[indexPath.row];
        [self createProductObj:dict withEnumType:AddSpaceBgProDuct];
        
    }else if(self.addProductCollectionView==collectionView){                //创建商城对象
        
        NSDictionary *dict=self.proDuctArray[indexPath.row];
        [self createProductObj:dict withEnumType:AddStroeProDuct];
        
    }else if (picModleView.collect == collectionView)
    {
        
        NSString *desc_model = [[picModleView.obj objectForKey:@"data"] objectForKey:@"desc_model"];
        
        NSArray *pic = [ToolClass arrayWithJsonString:desc_model];
        
        NSString *picStr = [NSString stringWithFormat:@"%@",pic[indexPath.row]];
        
        [self picModAction:picStr];
        
        
    }
    
}
//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (self.proDuctColletionView==collectionView) {
        
        UIEdgeInsets edgeSet = {12,28,12,8}; return edgeSet;
        
    }else if (self.spaceCollectionView==collectionView)
    {
        UIEdgeInsets edgeSet = {16,16,16,8}; return edgeSet;
        
    }else if (self.addProductCollectionView==collectionView)
    {
        UIEdgeInsets edgeSet = {12,28,12,8}; return edgeSet;
        
    }else{
        
        UIEdgeInsets edgeSet = {12,8,12,8}; return edgeSet;
    }
   
}

#pragma mark DatabaseManagerDelegate

-(void)readDataBaseData:(NSArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    self.dbDataArr=array;
}
// 获取某个表的某一条数据
-(void)readOneDataBaseData:(NSString *)dataString withDatabaseMan:(DatabaseManager *)readDataCalss
{
    dbDescModlePicStr=dataString;
}

#pragma mark 创建家具对象和背景对象

-(void)createProductObj:(NSDictionary *)dict withEnumType:(AddProDuctType)enumType {
    
   // NSLog(@"dict=%@",dict);
    
    NSLog(@"正在添加商品.....");
    
    NSDictionary *tempDict=[[NSDictionary alloc] initWithDictionary:dict];
    
    if (enumType==AddSpaceBgProDuct) {
        
        for (int i=0;i<arrUrl.count;i++) {
            NSDictionary *proDict = arrUrl[i];
            if ([[proDict objectForKey:@"imageTag"] integerValue] == 6000) {
                [arrUrl removeObject:proDict];
                i--;
            }
        }
        [self removeSpaceView];
    }
    
    UIButton *addImage=[UIButton buttonWithType:UIButtonTypeCustom];
    [addImage addTarget:self action:@selector(imageAction:) forControlEvents:UIControlEventTouchDown];

    if (enumType==AddStroeProDuct) {
        
        float w=[[tempDict objectForKey:@"imageW"] floatValue];
        float h=[[tempDict objectForKey:@"imageH"] floatValue];
        addImage.frame=CGRectMake((THEWIDTH-w*0.25)/2, (THEHEIGHT-h*0.25)/2, w*0.25, h*0.25);
        
        
    }else if(enumType==AddSpaceBgProDuct){
        
        float w=[[tempDict objectForKey:@"imageW"] floatValue];
        float h=[[tempDict objectForKey:@"imageH"] floatValue];
        addImage.frame=CGRectMake((THEWIDTH-w*0.6)/2,(THEHEIGHT-h*0.6)/2, w*0.6, h*0.6);
        
    }else if (enumType==PanStroeProDuct){
        
        float w=[[tempDict objectForKey:@"imageW"] floatValue];
        float h=[[tempDict objectForKey:@"imageH"] floatValue];
        addImage.frame=CGRectMake(_panButton.center.x-w*0.25/2, _panButton.center.y-h*0.25/2, w*0.25, h*0.25);
        
    }else if (enumType==CopyState){
        
        float x,y,w,h;
        x=[[tempDict objectForKey:@"x"] floatValue];
        y=[[tempDict objectForKey:@"y"] floatValue];
        w=[[tempDict objectForKey:@"w"] floatValue];
        h=[[tempDict objectForKey:@"h"] floatValue];
        addImage.frame=CGRectMake(x, y , w, h);
        
        if ([[tempDict objectForKey:@"netW"] floatValue] >[[tempDict objectForKey:@"netH"] floatValue]) {   //当原图宽大于高时
            
            if (addImage.frame.size.width > [[tempDict objectForKey:@"imageW"] floatValue]) {
                
                //    float scale = product.frame.size.width/[model.netW floatValue];
                
                addImage.frame = CGRectMake((canasView.frame.size.width - [[tempDict objectForKey:@"netW"] floatValue])/2, (canasView.frame.size.height - [[tempDict objectForKey:@"netH"] floatValue])/2, [[tempDict objectForKey:@"netW"] floatValue], [[tempDict objectForKey:@"netH"] floatValue]);
                
            }
            
        }else{             //当原图高大于宽时
            
            if (addImage.frame.size.height > [[tempDict objectForKey:@"imageH"] floatValue]) {
                
                addImage.frame = CGRectMake((canasView.frame.size.width - [[tempDict objectForKey:@"netW"] floatValue])/2, (canasView.frame.size.height - [[tempDict objectForKey:@"netH"] floatValue])/2, [[tempDict objectForKey:@"netW"] floatValue], [[tempDict objectForKey:@"netH"] floatValue]);
                
            }
            
        }

        addImage.transform = CGAffineTransformRotate(addImage.transform, [[tempDict objectForKey:@"rotate"] floatValue]);
        //是否镜像
        if ([[tempDict objectForKey:@"mirror"]isEqualToString:@"1"]) {
            addImage.imageView.transform = CGAffineTransformMakeScale(-1, 1);
        }
    }
    NSString *imagStr;
    if (enumType==AddStroeProDuct||enumType==CopyState || enumType==PanStroeProDuct) {
        imagStr=[tempDict objectForKey:@"thumb_file"];
        if (imagStr.length<30) {
            imagStr=[NSString stringWithFormat:@"%@%@",PICURL,imagStr];
        }
        
    }else{
         imagStr=[NSString stringWithFormat:@"%@%@",SPACEBGURL,[tempDict objectForKey:@"url"]];
    }
    
    [addImage sd_setImageWithURL:[NSURL URLWithString:imagStr] forState:UIControlStateNormal];
    [canasView addSubview:addImage];
    
    if (enumType==AddStroeProDuct||enumType==CopyState || enumType == PanStroeProDuct) {
        
        if (arrUrl.count==0) {                        //刚创建没商品
            
            addImage.tag=3010;
            
        }else
        {
            addImage.tag=3000+(arrUrl.count+1)*10;    //tag追加
        }

     }else{
         
         addImage.tag=6000;
        [addImage.superview sendSubviewToBack:addImage];          //背景始终放在最底部
         
    }
    //添加手势
    [self bindDoubleTap:addImage];
    [self bindPan:addImage];
    
    addImage.adjustsImageWhenHighlighted = NO;
    NSMutableDictionary *urlDict=[[NSMutableDictionary alloc] init];
    [urlDict setObject:[NSString stringWithFormat:@"%ld",(long)addImage.tag] forKey:@"imageTag"];
    [urlDict setObject:imagStr forKey:@"url"];
    [urlDict setObject:@"NO" forKey:@"lockState"];
    
    if (enumType==AddStroeProDuct || enumType == PanStroeProDuct) {
        
        [urlDict setObject:[tempDict objectForKey:@"desc_model"] forKey:@"picModle"];
        [urlDict setObject:[tempDict objectForKey:@"id"] forKey:@"pro_id"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.origin.x] forKey:@"x"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.origin.y] forKey:@"y"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.size.width] forKey:@"w"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.size.height] forKey:@"h"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.center.x] forKey:@"centerX"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.center.y] forKey:@"centerY"];
        [urlDict setObject:@"0" forKey:@"rotate"];
        [urlDict setObject:@"0" forKey:@"mirror"];
        float pattern=addImage.size.width/200*8;
        float lineW=addImage.size.width/200;
        [urlDict setObject:[NSString stringWithFormat:@"%f",pattern] forKey:@"pattern"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",lineW] forKey:@"lineW"];
        [urlDict setObject:[tempDict objectForKey:@"imageW"] forKey:@"netW"];
        [urlDict setObject:[tempDict objectForKey:@"imageH"] forKey:@"netH"];
        
    }else if(enumType==AddSpaceBgProDuct){
        
        [urlDict setObject:@"" forKey:@"picModle"];
        [urlDict setObject:[dict objectForKey:@"id"] forKey:@"pro_id"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.origin.x] forKey:@"x"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.origin.y] forKey:@"y"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.size.width] forKey:@"w"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.size.height] forKey:@"h"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.center.x] forKey:@"centerX"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",addImage.center.y] forKey:@"centerY"];
        [urlDict setObject:@"0" forKey:@"rotate"];
        [urlDict setObject:@"0" forKey:@"mirror"];
        float pattern=addImage.size.width/200*8;
        float lineW=addImage.size.width/200;
        [urlDict setObject:[NSString stringWithFormat:@"%f",pattern] forKey:@"pattern"];
        [urlDict setObject:[NSString stringWithFormat:@"%f",lineW] forKey:@"lineW"];
        [urlDict setObject:[tempDict objectForKey:@"imageW"] forKey:@"netW"];
        [urlDict setObject:[tempDict objectForKey:@"imageH"] forKey:@"netH"];

    }else if(enumType==CopyState){
        
        [urlDict setObject:[tempDict objectForKey:@"picModle"]==nil?@"":[tempDict objectForKey:@"picModle"] forKey:@"picModle"];
        [urlDict setObject:[tempDict objectForKey:@"pro_id"] forKey:@"pro_id"];
        [urlDict setObject:[tempDict objectForKey:@"x"] forKey:@"x"];
        [urlDict setObject:[tempDict objectForKey:@"y"] forKey:@"y"];
        [urlDict setObject:[tempDict objectForKey:@"w"] forKey:@"w"];
        [urlDict setObject:[tempDict objectForKey:@"h"] forKey:@"h"];
        [urlDict setObject:[tempDict objectForKey:@"centerX"] forKey:@"centerX"];
        [urlDict setObject:[tempDict objectForKey:@"centerY"] forKey:@"centerY"];
        [urlDict setObject:[tempDict objectForKey:@"rotate"] forKey:@"rotate"];
        [urlDict setObject:[tempDict objectForKey:@"mirror"] forKey:@"mirror"];
        [urlDict setObject:[tempDict objectForKey:@"pattern"] forKey:@"pattern"];
        [urlDict setObject:[tempDict objectForKey:@"lineW"] forKey:@"lineW"];
        [urlDict setObject:[tempDict objectForKey:@"netW"] forKey:@"netW"];
        [urlDict setObject:[tempDict objectForKey:@"netH"] forKey:@"netH"];
    }
    
    
    if (enumType==AddStroeProDuct||enumType==AddSpaceBgProDuct || enumType == PanStroeProDuct) {
        
        NSMutableArray *array=[[NSMutableArray alloc] init];
        
        //创建4个contorlPoint
        UIButton *topLeftContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x-addImage.width/2-15, addImage.center.y-addImage.height/2-15, 30, 30)];
        topLeftContorlPoint.tag=addImage.tag+5000;
        topLeftContorlPoint.hidden=YES;
        topLeftContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [topLeftContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        [canasView addSubview:topLeftContorlPoint];
        UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer1 addTarget:self action:@selector(topLeftChanged:)];
        [topLeftContorlPoint addGestureRecognizer:panRecognizer1];
        
        NSMutableDictionary *dict1=[[NSMutableDictionary alloc] init];
        [dict1 setValue:[NSString stringWithFormat:@"%ld",(long)topLeftContorlPoint.tag] forKey:@"pointTag"];
        [dict1 setValue:[NSString stringWithFormat:@"%f",topLeftContorlPoint.centerX] forKey:@"centerX"];
        [dict1 setValue:[NSString stringWithFormat:@"%f",topLeftContorlPoint.centerY] forKey:@"centerY"];
        [array addObject:dict1];
        
        UIButton *topRightContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x+addImage.width/2-15, addImage.center.y-addImage.height/2-15, 30, 30)];
        topRightContorlPoint.tag=addImage.tag+5001;
        topRightContorlPoint.hidden=YES;
        topRightContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [topRightContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        [canasView addSubview:topRightContorlPoint];
        UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer2 addTarget:self action:@selector(topRightChanged:)];
        [topRightContorlPoint addGestureRecognizer:panRecognizer2];
        
        NSMutableDictionary *dict2=[[NSMutableDictionary alloc] init];
        [dict2 setValue:[NSString stringWithFormat:@"%ld",(long)topRightContorlPoint.tag] forKey:@"pointTag"];
        [dict2 setValue:[NSString stringWithFormat:@"%f",topRightContorlPoint.centerX] forKey:@"centerX"];
        [dict2 setValue:[NSString stringWithFormat:@"%f",topRightContorlPoint.centerY] forKey:@"centerY"];
        [array addObject:dict2];
        
        UIButton *bottomLeftContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x-addImage.width/2-15, addImage.center.y+addImage.height/2-15, 30, 30)];
        bottomLeftContorlPoint.tag=addImage.tag+5002;
        [bottomLeftContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        bottomLeftContorlPoint.hidden=YES;
        bottomLeftContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [canasView addSubview:bottomLeftContorlPoint];
        UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer3 addTarget:self action:@selector(bottomLeftChanged:)];
        [bottomLeftContorlPoint addGestureRecognizer:panRecognizer3];
        
        NSMutableDictionary *dict3=[[NSMutableDictionary alloc] init];
        [dict3 setValue:[NSString stringWithFormat:@"%ld",(long)bottomLeftContorlPoint.tag] forKey:@"pointTag"];
        [dict3 setValue:[NSString stringWithFormat:@"%f",bottomLeftContorlPoint.centerX] forKey:@"centerX"];
        [dict3 setValue:[NSString stringWithFormat:@"%f",bottomLeftContorlPoint.centerY] forKey:@"centerY"];
        [array addObject:dict3];
        
        UIButton *bottomRightContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x+addImage.width/2-15, addImage.center.y+addImage.height/2-15, 30, 30)];
        bottomRightContorlPoint.tag=addImage.tag+5003;
        bottomRightContorlPoint.hidden=YES;
        [bottomRightContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        bottomRightContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [canasView addSubview:bottomRightContorlPoint];
        UIPanGestureRecognizer *panRecognizer4 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer4 addTarget:self action:@selector(bottomRightChanged:)];
        [bottomRightContorlPoint addGestureRecognizer:panRecognizer4];
        
        NSMutableDictionary *dict4=[[NSMutableDictionary alloc] init];
        [dict4 setValue:[NSString stringWithFormat:@"%ld",(long)bottomRightContorlPoint.tag] forKey:@"pointTag"];
        [dict4 setValue:[NSString stringWithFormat:@"%f",bottomRightContorlPoint.centerX] forKey:@"centerX"];
        [dict4 setValue:[NSString stringWithFormat:@"%f",bottomRightContorlPoint.centerY] forKey:@"centerY"];
        [array addObject:dict4];
        
        [urlDict setObject:array forKey:@"contorlPoint"];
    
        [urlDict setObject:[self addBorderView:addImage] forKey:@"borderPoint"];
        
        [addImage.layer ensureAnchorPointIsSetToZero];
        addImage.layer.quadrilateral = AGKQuadMake(topLeftContorlPoint.center,topRightContorlPoint.center,bottomRightContorlPoint.center,bottomLeftContorlPoint.center);
        
    }else{
     
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        
        NSArray *controlPointArray=[[NSArray alloc] initWithArray:[tempDict objectForKey:@"contorlPoint"]];
        
        for (int i=0;i<controlPointArray.count;i++) {
            NSMutableDictionary *controlPointDict=[[NSMutableDictionary alloc] initWithDictionary:controlPointArray[i]];
            float centerX=[[controlPointDict objectForKey:@"centerX"] floatValue]+20;
            float centerY=[[controlPointDict objectForKey:@"centerY"] floatValue]+20;
            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
            [controlPointDict setValue:[NSString stringWithFormat:@"%ld",addImage.tag+5000+i] forKey:@"pointTag"];
            [tempArr addObject:controlPointDict];
        }
         [urlDict setObject:tempArr forKey:@"contorlPoint"];
        
        NSMutableArray *tempBorderArr=[[NSMutableArray alloc] init];
        NSArray *borderPointArray=[[NSArray alloc] initWithArray:[tempDict objectForKey:@"borderPoint"]];
        for (int i=0;i<borderPointArray.count;i++) {
            NSMutableDictionary *borderPointDict=[[NSMutableDictionary alloc] initWithDictionary:borderPointArray[i]];
            float centerX=[[borderPointDict objectForKey:@"centerX"] floatValue]+20;
            float centerY=[[borderPointDict objectForKey:@"centerY"] floatValue]+20;
            [borderPointDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
            [borderPointDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
            [borderPointDict setValue:[NSString stringWithFormat:@"%ld",addImage.tag+10000+i] forKey:@"pointTag"];
            [tempBorderArr addObject:borderPointDict];
        }
        
        [urlDict setObject:tempBorderArr forKey:@"borderPoint"];
        
        for (int i=0;i<tempBorderArr.count;i++) {
            
            NSDictionary *borderPointDict=tempBorderArr[i];
            float ctx=[[borderPointDict objectForKey:@"centerX"] floatValue];
            float cty=[[borderPointDict objectForKey:@"centerY"] floatValue];
            UIButton *borderpoint=[[UIButton alloc] initWithFrame:CGRectMake(ctx-15, cty-15, 30, 30)];
            borderpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
            borderpoint.hidden=YES;
            borderpoint.tag=[[borderPointDict objectForKey:@"pointTag"] integerValue];
            [borderpoint setImage:[UIImage imageNamed:@"borderpoint"] forState:UIControlStateNormal];
            [canasView addSubview:borderpoint];
        }
        
        UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton;
        
        for (int i=0;i<tempArr.count;i++) {
            
            NSDictionary *contorlPointDict=tempArr[i];
            float ctx=[[contorlPointDict objectForKey:@"centerX"] floatValue];
            float cty=[[contorlPointDict objectForKey:@"centerY"] floatValue];
            UIButton *controlpoint=[[UIButton alloc] initWithFrame:CGRectMake((ctx)-15, cty-15, 30, 30)];
            controlpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
            controlpoint.tag=[[contorlPointDict objectForKey:@"pointTag"] integerValue];
            controlpoint.hidden=YES;
            [controlpoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
            
            [canasView addSubview:controlpoint];
            
            if (i==0) {
                tempTLbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer1 addTarget:self action:@selector(topLeftChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer1];
                
            }else if (i==1)
            {
                tempTRbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer2 addTarget:self action:@selector(topRightChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer2];
                
            }else if (i==2)
            {
                tempBLbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer3 addTarget:self action:@selector(bottomLeftChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer3];
            }else if (i==3)
            {
                tempBRbutton=controlpoint;
                UIPanGestureRecognizer *panRecognizer4 = [[UIPanGestureRecognizer alloc] init];
                [panRecognizer4 addTarget:self action:@selector(bottomRightChanged:)];
                [controlpoint addGestureRecognizer:panRecognizer4];
                
            }
            
        }
        
        [addImage.layer ensureAnchorPointIsSetToZero];
        addImage.layer.quadrilateral = AGKQuadMake(tempTLbutton.center,tempTRbutton.center,tempBRbutton.center,tempBLbutton.center);
        
    }
    
    [arrUrl addObject:urlDict];
    
    [self imageAction:addImage];
    
    [self addProductArray];
    
}

-(NSArray *)addBorderView:(UIButton *)addImage
{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    
    NSMutableDictionary *urlDict=[[NSMutableDictionary alloc] init];
    
    //创建4个contorlPoint
    UIButton *topLeftContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x-addImage.width/2-15, addImage.center.y-addImage.height/2-15, 30, 30)];
    topLeftContorlPoint.tag=addImage.tag+10000;
    topLeftContorlPoint.hidden=YES;
    topLeftContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
    [topLeftContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
    [canasView addSubview:topLeftContorlPoint];
    UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] init];
    [panRecognizer1 addTarget:self action:@selector(topLeftChanged:)];
    [topLeftContorlPoint addGestureRecognizer:panRecognizer1];
    
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc] init];
    [dict1 setValue:[NSString stringWithFormat:@"%ld",(long)topLeftContorlPoint.tag] forKey:@"pointTag"];
    [dict1 setValue:[NSString stringWithFormat:@"%f",topLeftContorlPoint.centerX] forKey:@"centerX"];
    [dict1 setValue:[NSString stringWithFormat:@"%f",topLeftContorlPoint.centerY] forKey:@"centerY"];
    [array addObject:dict1];
    
    UIButton *topRightContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x+addImage.width/2-15, addImage.center.y-addImage.height/2-15, 30, 30)];
    topRightContorlPoint.tag=addImage.tag+10001;
    topRightContorlPoint.hidden=YES;
    topRightContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
    [topRightContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
    [canasView addSubview:topRightContorlPoint];
    UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] init];
    [panRecognizer2 addTarget:self action:@selector(topRightChanged:)];
    [topRightContorlPoint addGestureRecognizer:panRecognizer2];
    
    NSMutableDictionary *dict2=[[NSMutableDictionary alloc] init];
    [dict2 setValue:[NSString stringWithFormat:@"%ld",(long)topRightContorlPoint.tag] forKey:@"pointTag"];
    [dict2 setValue:[NSString stringWithFormat:@"%f",topRightContorlPoint.centerX] forKey:@"centerX"];
    [dict2 setValue:[NSString stringWithFormat:@"%f",topRightContorlPoint.centerY] forKey:@"centerY"];
    [array addObject:dict2];
    
    UIButton *bottomLeftContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x-addImage.width/2-15, addImage.center.y+addImage.height/2-15, 30, 30)];
    bottomLeftContorlPoint.tag=addImage.tag+10002;
    [bottomLeftContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
    bottomLeftContorlPoint.hidden=YES;
    bottomLeftContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
    [canasView addSubview:bottomLeftContorlPoint];
    UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] init];
    [panRecognizer3 addTarget:self action:@selector(bottomLeftChanged:)];
    [bottomLeftContorlPoint addGestureRecognizer:panRecognizer3];
    
    NSMutableDictionary *dict3=[[NSMutableDictionary alloc] init];
    [dict3 setValue:[NSString stringWithFormat:@"%ld",(long)bottomLeftContorlPoint.tag] forKey:@"pointTag"];
    [dict3 setValue:[NSString stringWithFormat:@"%f",bottomLeftContorlPoint.centerX] forKey:@"centerX"];
    [dict3 setValue:[NSString stringWithFormat:@"%f",bottomLeftContorlPoint.centerY] forKey:@"centerY"];
    [array addObject:dict3];
    
    UIButton *bottomRightContorlPoint=[[UIButton alloc] initWithFrame:CGRectMake(addImage.center.x+addImage.width/2-15, addImage.center.y+addImage.height/2-15, 30, 30)];
    bottomRightContorlPoint.tag=addImage.tag+10003;
    bottomRightContorlPoint.hidden=YES;
    [bottomRightContorlPoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
    bottomRightContorlPoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
    [canasView addSubview:bottomRightContorlPoint];
    UIPanGestureRecognizer *panRecognizer4 = [[UIPanGestureRecognizer alloc] init];
    [panRecognizer4 addTarget:self action:@selector(bottomRightChanged:)];
    [bottomRightContorlPoint addGestureRecognizer:panRecognizer4];
    
    NSMutableDictionary *dict4=[[NSMutableDictionary alloc] init];
    [dict4 setValue:[NSString stringWithFormat:@"%ld",(long)bottomRightContorlPoint.tag] forKey:@"pointTag"];
    [dict4 setValue:[NSString stringWithFormat:@"%f",bottomRightContorlPoint.centerX] forKey:@"centerX"];
    [dict4 setValue:[NSString stringWithFormat:@"%f",bottomRightContorlPoint.centerY] forKey:@"centerY"];
    [array addObject:dict4];
    
    [urlDict setObject:array forKey:@"borderPoint"];
    
    return array;
    
}

//移除背景，始终保持只有一个背景
-(void)removeSpaceView
{
    for (UIView *thesubView in [canasView subviews]) {
        if (thesubView.tag==6000) {
            [thesubView removeFromSuperview];
        }
        //同时移除四个controlPoint
        if (thesubView.tag==11000||thesubView.tag==11001||thesubView.tag==11002||thesubView.tag==11003) {
            [thesubView removeFromSuperview];
        }
    }
}

-(void)canvasViewAction:(UIButton *)sender
{
    
    for (UIView *subView in canasView.subviews) {
        if (subView.tag >3000 && subView.tag<8000) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *but =(UIButton*)subView;
                but.enabled = YES;
            }
        }
    }
    
    filterTableView.backgroundColor=[UIColor clearColor];
    tempView.hidden=YES;
    [UIView animateWithDuration:0.6 animations:^{
        if (transformView.origin.x>=THEWIDTH) {
            proDuctPopView.frame=CGRectMake(THEWIDTH+58, 64, 58, THEHEIGHT-63);
            proDuctPopView.backgroundColor=[UIColor clearColor];
            proDuctPopView.line.backgroundColor=[UIColor clearColor];
            shapelayer.strokeColor = [UIColor clearColor].CGColor;
        }
        [self hideModelView];

    }];
    for (UIView *view in checkButton.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.hidden=YES;
        }
    }
}


-(void)picModAction:(NSString *)picStr
{
    NSArray *jsonArr = [self getCanvasArray];
    
    NSMutableDictionary *tempdict=[[NSMutableDictionary alloc] init];
    
    for (int j=0; j<jsonArr.count; j++) {
        
        NSMutableDictionary *jsonDict=jsonArr[j];
        
        if (checkButton.tag==[[jsonDict objectForKey:@"imageTag"] integerValue]) {
            
            tempdict=[[NSMutableDictionary alloc] initWithDictionary:jsonDict];
            
            NSString *urlStr=[NSString stringWithFormat:@"%@/%@",PICURL,picStr];

            [tempdict setValue:urlStr forKey:@"url"];
            
            NSURL *imageUrl=[NSURL URLWithString:[tempdict objectForKey:@"url"]];
            //————————————————————————————————————————————————————————————进行网络图片尺寸适配——————————————
            [checkButton.imageView sd_setImageWithPreviousCachedImageWithURL:imageUrl placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                //之前的x,y,w,h
                float x,y,w,h,netW,netH;
                w=[[tempdict objectForKey:@"w"] floatValue];
                h=[[tempdict objectForKey:@"h"] floatValue];
                x=[[tempdict objectForKey:@"x"] floatValue];
                y=[[tempdict objectForKey:@"y"] floatValue];
                
                netW=[[tempdict objectForKey:@"netW"] floatValue];
                netH=[[tempdict objectForKey:@"netH"] floatValue];
                
                //计算主图网络尺寸跟本地尺寸比例
                float scaleW=w/netW;
                float scaleH=h/netH;
                
                float netW1=image.size.width*scaleW;
                float netH1=image.size.height*scaleH;
                
                float x1=x-(netW1-w)/2;    //改变后的x
                float y1=y-(netH1-h)/2; //改变后的y
                
                [tempdict setValue:[NSString stringWithFormat:@"%f",x1] forKey:@"x"];
                [tempdict setValue:[NSString stringWithFormat:@"%f",y1] forKey:@"y"];
                [tempdict setValue:[NSString stringWithFormat:@"%f",netW1] forKey:@"w"];
                [tempdict setValue:[NSString stringWithFormat:@"%f",netH1] forKey:@"h"];
                [tempdict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"netW"];
                [tempdict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"netH"];
                
                NSArray *controlPoint=[tempdict objectForKey:@"contorlPoint"];
                for (int i=0; i<controlPoint.count; i++) {
                    NSDictionary *controlDict=controlPoint[i];
                    float centerX,centerY;
                    if (i==0) {
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                        
                    }else if (i==1){
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                        
                    }else if (i==2){
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                        
                    }else {
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                    }
                    [controlDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
                    [controlDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
                }
                
                NSArray *boderPoint=[tempdict objectForKey:@"borderPoint"];
                for (int i=0; i<boderPoint.count; i++) {
                    NSDictionary *boderDict=boderPoint[i];
                    float centerX,centerY;
                    if (i==0) {
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                        
                    }else if (i==1){
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]-[[tempdict objectForKey:@"h"] floatValue]/2;
                        
                    }else if (i==2){
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]-[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                        
                    }else {
                        centerX=[[tempdict objectForKey:@"centerX"] floatValue]+[[tempdict objectForKey:@"w"] floatValue]/2;
                        centerY=[[tempdict objectForKey:@"centerY"] floatValue]+[[tempdict objectForKey:@"h"] floatValue]/2;
                    }
                    [boderDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
                    [boderDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
                }
                
            }];
            
        }
    }
    
    //把arrUrl的url换了
    for (int i=0; i<arrUrl.count; i++) {
        NSDictionary *jsonDict=arrUrl[i];
        if ([[jsonDict objectForKey:@"imageTag"] integerValue]==[[tempdict objectForKey:@"imageTag"] integerValue]) {
            [jsonDict setValue:[tempdict objectForKey:@"url"] forKey:@"url"];
            [jsonDict setValue:[tempdict objectForKey:@"x"] forKey:@"x"];
            [jsonDict setValue:[tempdict objectForKey:@"y"] forKey:@"y"];
            [jsonDict setValue:[tempdict objectForKey:@"w"] forKey:@"w"];
            [jsonDict setValue:[tempdict objectForKey:@"h"] forKey:@"h"];
            [jsonDict setValue:[tempdict objectForKey:@"netW"] forKey:@"netW"];
            [jsonDict setValue:[tempdict objectForKey:@"netH"] forKey:@"netH"];
            
        }
    }
    
    [self addProductArray];
    
    for (UIView *subViews in [canasView subviews]) {
        if (subViews!=tempView) {
            [subViews removeFromSuperview];
        }
    }
    
    [self setUpOpenPlanView:[arr lastObject] isAddTag:NO];
    
    for (UIView *subView in canasView.subviews) {
        UIButton *button=(UIButton *)subView;
        if (button.tag==checkButton.tag) {
            [self imageAction:button];
        }
    }
    
}

static int mov;
static int tempMov;

static NSDictionary *_tempCheckDict;

-(void)imageAction:(UIButton *)sender
{
    for (UIView *subView in canasView.subviews) {
        if (subView.tag == 50000) {
            [subView removeFromSuperview];
        }
    }
    
    shapelayer.hidden=NO;
    [arrMod removeAllObjects];
    
    beforeButton = nil;
    [beforeButton removeFromSuperview];
    
    beforeButton = checkButton;
    
    UIButton *beforView = [canasView viewWithTag:beforeButton.tag];
    
    beforView.gestureRecognizers = nil;

    
    [UIView animateWithDuration:0.6 animations:^{
        proDuctPopView.frame=CGRectMake(THEWIDTH-58, 64, 58, THEHEIGHT-63);
        proDuctPopView.backgroundColor=[UIColor whiteColor];
        proDuctPopView.line.backgroundColor=UIColorFromHex(0xefefef);
    }];
    
    float centerX1 = 0.0;
    float centerY1 = 0.0;
    
    
    for (NSDictionary *dict in arrUrl) {
        
        if ([[dict objectForKey:@"imageTag"] integerValue]==sender.tag) {
            
            _tempCheckDict = dict;
            
        }
    }
    
    for (UIView *subview in [canasView subviews]) {
    
            if (subview.tag>3000) {
                
                if (subview.tag==sender.tag ) {
                    
                    checkButton=sender;
                    
                    //1.判断是空间背景还是商品，空间背景没有模型图
                    if (sender.tag==6000) {
                        // 开启动画
                        [UIView animateWithDuration:0.6 animations:^{
                            
                            [self hideModelView];
                            
                        }];
                        
                        for (UIView *view in sender.subviews) {
                            if ([view isKindOfClass:[UIButton class]]) {
                                view.hidden=NO;
                            }
                        }
                        
                        [self lockAction];    //是否锁定

                        
                    }else{
                        
                        for (UIView *subview in [canasView subviews]) {
                            if (subview.tag>3000) {
                                if (subview.tag==6000) {
                                    for (UIView *view in subview.subviews) {
                                        if ([view isKindOfClass:[UIButton class]]) {
                                            view.hidden=YES;
                                        }
                                    }

                                }
                            }
                        }
                        

                        [self lockAction];    //是否锁定
                        
                        [self httpGetProductDetail:_tempCheckDict];
                        
                        centerX1 = [[_tempCheckDict objectForKey:@"centerX"] floatValue];
                        centerY1 = [[_tempCheckDict objectForKey:@"centerY"] floatValue];
               
                    }
                    
                }
                
            }
            
        }

    //显示选中的controlPoint,隐藏其他的controlPoint
    for (UIView *thesubView in [canasView subviews]) {
        
        if (checkButton.tag+5000==thesubView.tag||checkButton.tag+5001==thesubView.tag||checkButton.tag+5002==thesubView.tag||checkButton.tag+5003==thesubView.tag) {
            
           if (checkButton.tag+5000==thesubView.tag) {
                controlLeftTopView=thesubView;
            }
            if (checkButton.tag+5001==thesubView.tag) {
                controlRightTopView=thesubView;
            }
            if (checkButton.tag+5002==thesubView.tag) {
                controlBottomLeftView=thesubView;
            }
            if (checkButton.tag+5003==thesubView.tag) {
                controlBottomRightView=thesubView;
            }
        }
        if (checkButton.tag+10000==thesubView.tag||checkButton.tag+10001==thesubView.tag||checkButton.tag+10002==thesubView.tag||checkButton.tag+10003==thesubView.tag) {
            
            if (checkButton.tag+10000==thesubView.tag) {
                borderLeftTopView=thesubView;
            }
            if (checkButton.tag+10001==thesubView.tag) {
                borderRightTopView=thesubView;
            }
            if (checkButton.tag+10002==thesubView.tag) {
                borderBottomLeftView=thesubView;
            }
            if (checkButton.tag+10003==thesubView.tag) {
                borderBottomRightView=thesubView;
            }
        }

      
    }
    
    int j=0;
    for (UIView *thesubView in [canasView subviews]) {
        //说明屏蔽主界面导航栏，popView,以及他们所有子视图，定义时确保他们tag小于3000即可
        if (thesubView.tag>=3000&&thesubView.tag<8000) {
            j++;
            if (checkButton.tag==thesubView.tag) {
                mov=j;
            }
        }
    }
    
    [tempView removeFromSuperview];
    tempView = [[UIView alloc] init];
    [canasView  addSubview:tempView];
    
    [self addTempView];
    
    [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:NO];
    
    if (checkButton.tag == 6000) {
        for (UIView *subView in proDuctPopView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                if (subView.tag!=2004 && subView.tag!=2005) {
                    subView.hidden = YES;
                }
            }
        }
    }
}

-(void)addBorderWithTLView:(UIView*)TLView TRView:(UIView *)TRView BLView:(UIView *)BLView BRView:(UIView *)BRView panBool:(BOOL)isPan
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    //开始点 从上左下右的点
    [aPath moveToPoint:CGPointMake(TLView.center.x,TLView.center.y)];
    [aPath addLineToPoint:CGPointMake(TRView.center.x, TRView.center.y)];
    [aPath addLineToPoint:CGPointMake(BRView.center.x, BRView.center.y)];
    [aPath addLineToPoint:CGPointMake(BLView.center.x, BLView.center.y)];
    [aPath closePath];
    
    if (isPan==YES) {
        UIColor *col=UIColorFromHex(0x65bc5d);
        shapelayer.strokeColor = col.CGColor;
        shapelayer.fillColor=nil;
        shapelayer.path = aPath.CGPath;
        
        [shapelayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:8],
          [NSNumber numberWithInt:5],nil]];
        shapelayer.lineWidth=2.0f;
     

    }else{
        UIColor *col=UIColorFromHex(0x65bc5d);
        shapelayer.strokeColor = col.CGColor;
        shapelayer.fillColor=nil;
        shapelayer.path = aPath.CGPath;
        
        [shapelayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:8],
          [NSNumber numberWithInt:5],nil]];
        shapelayer.lineWidth=2.0f;

    }

    [canasView.layer addSublayer:shapelayer];
    
    //把选中的border置前
    [borderLeftTopView.superview bringSubviewToFront:borderLeftTopView];
    [borderRightTopView.superview bringSubviewToFront:borderRightTopView];
    [borderBottomLeftView.superview bringSubviewToFront:borderBottomLeftView];
    [borderBottomRightView.superview bringSubviewToFront:borderBottomRightView];
    
    //把选中的controlPoint置前
    [controlLeftTopView.superview bringSubviewToFront:controlLeftTopView];
    [controlRightTopView.superview bringSubviewToFront:controlRightTopView];
    [controlBottomLeftView.superview bringSubviewToFront:controlBottomLeftView];
    [controlBottomRightView.superview bringSubviewToFront:controlBottomRightView];
    
}
-(void)lockAction
{
    if ([[_tempCheckDict objectForKey:@"lockState"] isEqualToString:@"YES"]) {
        
        checkButton.selected=YES;
        [self showLockState];
        
    }else{
        checkButton.selected=NO;
        [self showLockState];
        
    }
}
-(void)showLockState
{
    if (checkButton.selected==YES) {
        
        [UIView animateWithDuration:0.6 animations:^{
            [self hideModelView];
        }];
        for (UIView *sub in proDuctPopView.subviews) {
            if (sub.tag==2005) {
                UIButton *lock=(UIButton*)sub;
                [lock setTitle:@"解锁" forState:UIControlStateNormal];
                
            }else{
                if ([sub isKindOfClass:[UIButton class]]) {
                    sub.hidden=YES;
                }
                
            }
        }
        
    }else{
        
        if (checkButton.tag!=6000) {
            [UIView animateWithDuration:0.6 animations:^{
                [self showModelView];
            }];
        }
        
        for (UIView *sub in proDuctPopView.subviews) {
            if (sub.tag==2005) {
                UIButton *lock=(UIButton*)sub;
                [lock setTitle:@"锁定" forState:UIControlStateNormal];
            }else{
                if ([sub isKindOfClass:[UIButton class]]) {
                    sub.hidden=NO;
                }
            }
            
        }

    }

}

#pragma mark 添加tempView

-(NSDictionary*)getCGRect
{
    NSArray *arrayX=[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%f",controlLeftTopView.center.x],[NSString stringWithFormat:@"%f",controlRightTopView.center.x],[NSString stringWithFormat:@"%f",controlBottomLeftView.center.x],[NSString stringWithFormat:@"%f",controlBottomRightView.center.x], nil];
    
    NSArray *arrayY=[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%f",controlLeftTopView.center.y],[NSString stringWithFormat:@"%f",controlRightTopView.center.y],[NSString stringWithFormat:@"%f",controlBottomLeftView.center.y],[NSString stringWithFormat:@"%f",controlBottomRightView.center.y], nil];
    
    NSNumber *minX = [arrayX valueForKeyPath:@"@min.floatValue"];
    NSNumber *minY = [arrayY valueForKeyPath:@"@min.floatValue"];
    NSNumber *maxX = [arrayX valueForKeyPath:@"@max.floatValue"];
    NSNumber *maxY = [arrayY valueForKeyPath:@"@max.floatValue"];
    
    float tx=[minX floatValue];
    float ty=[minY floatValue];
    float tw=[maxX floatValue]-tx;
    float th=[maxY floatValue]-ty;
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%f",tx] forKey:@"tx"];
    [dict setObject:[NSString stringWithFormat:@"%f",ty] forKey:@"ty"];
    [dict setObject:[NSString stringWithFormat:@"%f",tw] forKey:@"tw"];
    [dict setObject:[NSString stringWithFormat:@"%f",th] forKey:@"th"];
    
    return dict;

}
#pragma mark  setUpBorderPointView Action －－－－－－－－－－－－－添加矩形框四个控制点

-(void)setUpBroderPointView
{
    [tempborderLeftTopView removeFromSuperview];
    [tempborderRightTopView removeFromSuperview];
    [tempborderBottomLeftView removeFromSuperview];
    [tempborderBottomRightView removeFromSuperview];
    
    tempborderLeftTopView=[[UIView alloc] init];
    // tempborderLeftTopView.backgroundColor=[UIColor purpleColor];
    [tempView addSubview:tempborderLeftTopView];
    
    tempborderRightTopView=[[UIView alloc] init];
    // tempborderRightTopView.backgroundColor=[UIColor purpleColor];
    [tempView addSubview:tempborderRightTopView];
    
    tempborderBottomLeftView=[[UIView alloc] init];
    // tempborderBottomLeftView.backgroundColor=[UIColor purpleColor];
    [tempView addSubview:tempborderBottomLeftView];
    
    tempborderBottomRightView=[[UIView alloc] init];
    //  tempborderBottomRightView.backgroundColor=[UIColor purpleColor];
    [tempView addSubview:tempborderBottomRightView];
    
    CGRect letfTopRect1 = [borderLeftTopView.superview convertRect:borderLeftTopView.frame toView:tempView];
    CGRect rightTopRect1 = [borderRightTopView.superview convertRect:borderRightTopView.frame toView:tempView];
    CGRect letfbottomRect1 = [borderBottomLeftView.superview convertRect:borderBottomLeftView.frame toView:tempView];
    CGRect rightBottomRect1 = [borderBottomRightView.superview convertRect:borderBottomRightView.frame toView:tempView];
    
    tempborderLeftTopView.frame=CGRectMake(letfTopRect1.origin.x, letfTopRect1.origin.y, letfTopRect1.size.width, letfTopRect1.size.height);
    
    tempborderRightTopView.frame=CGRectMake(rightTopRect1.origin.x, rightTopRect1.origin.y, rightTopRect1.size.width, rightTopRect1.size.height);
    
    tempborderBottomLeftView.frame=CGRectMake(letfbottomRect1.origin.x, letfbottomRect1.origin.y, letfbottomRect1.size.width, letfbottomRect1.size.height);
    
    tempborderBottomRightView.frame=CGRectMake(rightBottomRect1.origin.x, rightBottomRect1.origin.y, rightBottomRect1.size.width, rightBottomRect1.size.height);

}

#pragma mark  setUpBorderPointView Action －－－－－－－－－－－－－添加变形四个控制点

-(void)setUpCortolPointView
{
    [tempControlLeftTopView removeFromSuperview];
    [tempControlRightTopView removeFromSuperview];
    [tempControlBottomLeftView removeFromSuperview];
    [tempControlBottomRightView removeFromSuperview];
    
    tempControlLeftTopView=[[UIView alloc] init];
    //  tempControlLeftTopView.backgroundColor=[UIColor redColor];
    [tempView addSubview:tempControlLeftTopView];
    
    tempControlRightTopView=[[UIView alloc] init];
    // tempControlRightTopView.backgroundColor=[UIColor redColor];
    [tempView addSubview:tempControlRightTopView];
    
    tempControlBottomLeftView=[[UIView alloc] init];
    //  tempControlBottomLeftView.backgroundColor=[UIColor redColor];
    [tempView addSubview:tempControlBottomLeftView];
    
    tempControlBottomRightView=[[UIView alloc] init];
    // tempControlBottomRightView.backgroundColor=[UIColor redColor];
    [tempView addSubview:tempControlBottomRightView];
    
    CGRect letfTopRect = [controlLeftTopView.superview convertRect:controlLeftTopView.frame toView:tempView];
    CGRect rightTopRect = [controlRightTopView.superview convertRect:controlRightTopView.frame toView:tempView];
    CGRect letfbottomRect = [controlBottomLeftView.superview convertRect:controlBottomLeftView.frame toView:tempView];
    CGRect rightBottomRect = [controlBottomRightView.superview convertRect:controlBottomRightView.frame toView:tempView];
    
    tempControlLeftTopView.frame=CGRectMake(letfTopRect.origin.x, letfTopRect.origin.y, letfTopRect.size.width, letfTopRect.size.height);
    
    tempControlRightTopView.frame=CGRectMake(rightTopRect.origin.x, rightTopRect.origin.y, rightTopRect.size.width, rightTopRect.size.height);
    
    tempControlBottomLeftView.frame=CGRectMake(letfbottomRect.origin.x, letfbottomRect.origin.y, letfbottomRect.size.width, letfbottomRect.size.height);
    
    tempControlBottomRightView.frame=CGRectMake(rightBottomRect.origin.x, rightBottomRect.origin.y, rightBottomRect.size.width, rightBottomRect.size.height);
}

#pragma mark  setUpTempView Action －－－－－－－－－－－－－添加操作商品的控制视图

-(void)setUpTempView
{
    tempView=[[UIView alloc] init];
    [canasView addSubview:tempView];
    [self addGestureRecognizer];
}
-(void)addTempView
{
    NSDictionary *dict=[self getCGRect];
    tempView.frame=CGRectMake([[dict objectForKey:@"tx"] floatValue], [[dict objectForKey:@"ty"] floatValue], [[dict objectForKey:@"tw"] floatValue], [[dict objectForKey:@"th"] floatValue]);
    tempView.hidden=NO;
    tempView.tag = 50000;
    tempView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0];
    [tempView.superview bringSubviewToFront:tempView];
    
    if (checkButton.tag==6000) {
        [tempView.superview sendSubviewToBack:tempView];
        [checkButton.superview sendSubviewToBack:checkButton];
    }
    
    [self addGestureRecognizer];

    for (NSDictionary *dict in arrUrl) {
        if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
            if ([[dict objectForKey:@"lockState"] isEqualToString:@"YES"]) {
                tempView.gestureRecognizers=nil;
            }
        }
    }

    [self setUpCortolPointView];
    
    [self setUpBroderPointView];
    
    //把选中的border置前
    [borderLeftTopView.superview bringSubviewToFront:borderLeftTopView];
    [borderRightTopView.superview bringSubviewToFront:borderRightTopView];
    [borderBottomLeftView.superview bringSubviewToFront:borderBottomLeftView];
    [borderBottomRightView.superview bringSubviewToFront:borderBottomRightView];
    
    //把选中的controlPoint置前
    [controlLeftTopView.superview bringSubviewToFront:controlLeftTopView];
    [controlRightTopView.superview bringSubviewToFront:controlRightTopView];
    [controlBottomLeftView.superview bringSubviewToFront:controlBottomLeftView];
    [controlBottomRightView.superview bringSubviewToFront:controlBottomRightView];

}
#pragma mark  bindGestureRecognizer Action －－－－－－－－－－－－－绑定手势

-(void)addGestureRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] init];
    [panRecognizer addTarget:self action:@selector(handlePanTempView:)];
    [tempView addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchTempView:)];
    [tempView addGestureRecognizer:recognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationTempView:)];
    [tempView addGestureRecognizer:rotationRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [tempView addGestureRecognizer:doubleTapGestureRecognizer];
    
}

- (void)bindDoubleTap:(UIView *)imgVCustom {
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [imgVCustom addGestureRecognizer:doubleTapGestureRecognizer];
    
}

- (void)bindPan:(UIButton *)imgVCustom {
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] init];
    panRecognizer.view.tag=imgVCustom.tag;
    [panRecognizer addTarget:self action:@selector(handlePan:)];
    [imgVCustom addGestureRecognizer:panRecognizer];
    
}

#pragma mark  handleGestureRecognizer Action －－－－－－－－－－－－－处理手势

-(void)doubleTap:(UITapGestureRecognizer*)recognizer
{
    NSLog(@"双击");
    NSDictionary *copyDict=[ToolClass dictionaryWithJsonString:[arr objectAtIndex:arrCount-1]];
    NSMutableArray *jsonArr=[[NSMutableArray alloc] initWithArray:[copyDict objectForKey:@"data"]];
    
    for (int i=0;i<jsonArr.count;i++) {
        
        NSDictionary *jsonDict=jsonArr[i];
        
        if ([[jsonDict objectForKey:@"imageTag"] integerValue ] ==checkButton.tag) {
            
            for (NSDictionary *dict in arrUrl) {
                
                if ([[dict objectForKey:@"imageTag"] integerValue]==[[jsonDict objectForKey:@"imageTag"] integerValue]) {
                    
                    float centerX=[[dict objectForKey:@"centerX"] floatValue];
                    float centerY=[[dict objectForKey:@"centerY"] floatValue];
                    float w=[[dict objectForKey:@"w"] floatValue];
                    float h=[[dict objectForKey:@"h"] floatValue];
                    float x=centerX-(w)/2;
                    float y=centerY-(h)/2;
                    [jsonDict setValue:[NSString stringWithFormat:@"%f",x] forKey:@"x"];
                    [jsonDict setValue:[NSString stringWithFormat:@"%f",y] forKey:@"y"];
                    [jsonDict setValue:@"0" forKey:@"rotate"];
                    
                    NSArray *controlPointArray=[jsonDict objectForKey:@"contorlPoint"];
                    for (int i=0;i<controlPointArray.count;i++) {
                        NSDictionary *controlPointDict=controlPointArray[i];
                        if (i==0) {
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerX-w/2-7.5] forKey:@"centerX"];
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerY-h/2-7.5] forKey:@"centerY"];
                        }else if (i==1)
                        {
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerX+w/2-7.5] forKey:@"centerX"];
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerY-h/2-7.5] forKey:@"centerY"];
                        }else if (i==2)
                        {
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerX-w/2-7.5] forKey:@"centerX"];
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerY+h/2-7.5] forKey:@"centerY"];
                        }else if (i==3)
                        {
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerX+w/2-7.5] forKey:@"centerX"];
                            [controlPointDict setValue:[NSString stringWithFormat:@"%f",centerY+h/2-7.5] forKey:@"centerY"];
                        }
                        
                    }
                    NSArray *boderPointArray=[jsonDict objectForKey:@"borderPoint"];
                    for (int i=0;i<boderPointArray.count;i++) {
                        NSDictionary *boderPointDict=boderPointArray[i];
                        if (i==0) {
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerX-w/2-7.5] forKey:@"centerX"];
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerY-h/2-7.5] forKey:@"centerY"];
                        }else if (i==1)
                        {
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerX+w/2-7.5] forKey:@"centerX"];
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerY-h/2-7.5] forKey:@"centerY"];
                        }else if (i==2)
                        {
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerX-w/2-7.5] forKey:@"centerX"];
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerY+h/2-7.5] forKey:@"centerY"];
                        }else if (i==3)
                        {
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerX+w/2-7.5] forKey:@"centerX"];
                            [boderPointDict setValue:[NSString stringWithFormat:@"%f",centerY+h/2-7.5] forKey:@"centerY"];
                        }
                        
                    }
                    
                    
                }
            }
        }
        
    }
    NSDictionary *theDict=@{
                            @"count":[NSString stringWithFormat:@"%ld",(unsigned long)jsonArr.count],
                            @"data":jsonArr
                            };
    
    [arr addObject:[ToolClass stringWithDict:theDict]];
    
    for (UIView *subViews in [canasView subviews]) {
        if (subViews!=tempView) {
            [subViews removeFromSuperview];
        }
    }
    [self setUpOpenPlanView:[arr lastObject] isAddTag:NO];
    
    [self addProductArray];
    
    UIButton *but = [canasView viewWithTag:checkButton.tag];
    
    [self imageAction:but];
    
}

- (void)handlePanTempView:(UIPanGestureRecognizer*) recognizer
{

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self animationAciton:YES];
        for (UIView *subView in canasView.subviews) {
            if (subView.tag >3000 && subView.tag<8000) {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *but =(UIButton*)subView;
                    but.enabled = NO;
                    but.adjustsImageWhenDisabled = NO;
                }
            }
        }
        
    }
    
    //手指离开监听事件
    if (([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateEnded) || ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateCancelled)) {
        
        [self animationAciton:NO]; //显示
        
        for (UIView *subView in canasView.subviews) {
            if (subView.tag >3000 && subView.tag<8000) {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *but =(UIButton*)subView;
                    but.enabled = YES;
                }
            }
        }

        for (UIView *subView in canasView.subviews) {
            
            if (subView.tag >3000 && subView.tag<=8000) {
                
                [self bindPan:(UIButton*)subView];

            }
        }
        
        for (NSDictionary *dict in arrUrl) {
        
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                
                [self updateImagePoint:dict];
                
                [self updateCtrolPoint:dict];
                
                [self upDateBorderPoint:dict];
                
            }
        }
        
        //判断是在最后一步，还是中间步骤
        if (arrCount==arr.count) {
            
            [self addProductArray];      //直接添加步骤
            
        }else{
            
            NSMutableArray *tempArray=[[NSMutableArray alloc] init];
            //先删除掉后面的步骤再，插入步骤
            for (int i=0; i<arrCount; i++) {
                
                [tempArray addObject:arr[i]];
                
            }
            [arr removeAllObjects];
            arr=tempArray;
            [self addProductArray];
            
        }
        
    }

    CGPoint translation = [recognizer translationInView:canasView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    controlLeftTopView.center = CGPointMake(controlLeftTopView.center.x + translation.x,
                                 controlLeftTopView.center.y + translation.y);
    controlRightTopView.center = CGPointMake(controlRightTopView.center.x + translation.x,
                                 controlRightTopView.center.y + translation.y);
    controlBottomLeftView.center = CGPointMake(controlBottomLeftView.center.x + translation.x,
                                 controlBottomLeftView.center.y + translation.y);
    controlBottomRightView.center = CGPointMake(controlBottomRightView.center.x + translation.x,
                                 controlBottomRightView.center.y + translation.y);
    checkButton.center = CGPointMake(checkButton.center.x + translation.x,
                                 checkButton.center.y + translation.y);
    borderLeftTopView.center = CGPointMake(borderLeftTopView.center.x + translation.x,
                                            borderLeftTopView.center.y + translation.y);
    borderRightTopView.center = CGPointMake(borderRightTopView.center.x + translation.x,
                                             borderRightTopView.center.y + translation.y);
    borderBottomLeftView.center = CGPointMake(borderBottomLeftView.center.x + translation.x,
                                               borderBottomLeftView.center.y + translation.y);
    borderBottomRightView.center = CGPointMake(borderBottomRightView.center.x + translation.x,
                                                borderBottomRightView.center.y + translation.y);
    
    [recognizer setTranslation:CGPointZero inView:canasView];
    
    [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:NO];
}

static float theScale=0;
static float _lastScale=0;
-(void)handlePinchTempView:(UIPinchGestureRecognizer*)recognizer
{
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
        return;
    }
    //手指离开监听事件
    if (([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateEnded) || ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateCancelled)) {
        
      for (NSDictionary *dict in arrUrl) {
          
        if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
            
            [self updateCtrolPoint:dict];
            
            [self upDateBorderPoint:dict];
        }
      }
        
      [self addProductArray];
        
    }else{
        
        CGFloat scale = recognizer.scale;
        CGFloat scale1 = scale/_lastScale;
        
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale1, scale1);
        
        theScale=recognizer.view.transform.a;
        
        for (NSDictionary *dict in arrUrl) {
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                
                [checkButton.imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
                
                float centerX=[[dict objectForKey:@"centerX"] floatValue];
                float centerY=[[dict objectForKey:@"centerY"] floatValue];
                float w=[[dict objectForKey:@"w"] floatValue];
                float h=[[dict objectForKey:@"h"] floatValue];
                float x=centerX-(w*scale1)/2;
                float y=centerY-(h*scale1)/2;
                [dict setValue:[NSString stringWithFormat:@"%f",w*scale1] forKey:@"w"];
                [dict setValue:[NSString stringWithFormat:@"%f",h*scale1] forKey:@"h"];
                [dict setValue:[NSString stringWithFormat:@"%f",x] forKey:@"x"];
                [dict setValue:[NSString stringWithFormat:@"%f",y] forKey:@"y"];
                
            }
            
        }
        _lastScale=scale;
        
        for (NSDictionary *dict in arrUrl) {
            
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                
                for (UIView *subView in [canasView subviews]) {
    
                    if (subView.tag==controlLeftTopView.tag) {
                        CGRect rect=[tempControlLeftTopView.superview convertRect:tempControlLeftTopView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                        [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                        [self pop_animationStriong:kPOPLayerAGKQuadTopLeft forView:subView];
    
                    }
                    if (subView.tag==controlRightTopView.tag) {
                        CGRect rect=[tempControlRightTopView.superview convertRect:tempControlRightTopView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                        [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                        [self pop_animationStriong:kPOPLayerAGKQuadTopRight forView:subView];
                    }
                    if (subView.tag==controlBottomLeftView.tag) {
                        CGRect rect=[tempControlBottomLeftView.superview convertRect:tempControlBottomLeftView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                        [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                        [self pop_animationStriong:kPOPLayerAGKQuadBottomLeft forView:subView];
                    }
                    if (subView.tag==controlBottomRightView.tag) {
                        CGRect rect=[tempControlBottomRightView.superview convertRect:tempControlBottomRightView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                        [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                        [self pop_animationStriong:kPOPLayerAGKQuadBottomRight forView:subView];
                        
                    }
                    if (subView.tag==borderLeftTopView.tag) {
                        CGRect rect=[tempborderLeftTopView.superview convertRect:tempborderLeftTopView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    }
                    if (subView.tag==borderRightTopView.tag) {
                        CGRect rect=[tempborderRightTopView.superview convertRect:tempborderRightTopView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    }
                    if (subView.tag==borderBottomLeftView.tag) {
                        CGRect rect=[tempborderBottomLeftView.superview convertRect:tempborderBottomLeftView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    }
                    if (subView.tag==borderBottomRightView.tag) {
                        CGRect rect=[tempborderBottomRightView.superview convertRect:tempborderBottomRightView.frame toView:canasView];
                        subView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    }
                }
            }
        }
    }
    
    [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:NO];
    
}

- (void)handleRotationTempView:(UIRotationGestureRecognizer *)recognizer {
    
    
    //手指离开监听事件
    if (([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateEnded) || ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateCancelled)) {
        
        UIView *temp=[[UIView alloc]init];
        temp.tag = 50000;
        NSDictionary *dict=[self getCGRect];
        temp.frame=CGRectMake([[dict objectForKey:@"tx"] floatValue], [[dict objectForKey:@"ty"] floatValue], [[dict objectForKey:@"tw"] floatValue], [[dict objectForKey:@"th"] floatValue]);
        [canasView addSubview:temp];
        temp.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0];
        temp.hidden=NO;
        [temp.superview bringSubviewToFront:temp];
        
        for (NSDictionary *dict in arrUrl) {
            
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                
                if ([[dict objectForKey:@"lockState"] isEqualToString:@"YES"]) {
                    
                    temp.gestureRecognizers=nil;
                    
                }else{
                    
                    [self addGestureRecognizer];
                    
                }
            }
        }
        
        [tempView removeFromSuperview];
        tempView=temp;
        
        [self addGestureRecognizer];
        
        [self setUpCortolPointView];
        
        [self setUpBroderPointView];
        
        //旋转不需要对frame改变，只改变旋转角度
        float rotate = acosf(recognizer.view.transform.a);
        
        for (NSDictionary *dict in arrUrl) {
            
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                
                if (![[NSString stringWithFormat:@"%f",rotate] isEqualToString:@"nan"])
                {
                    [dict setValue:[NSString stringWithFormat:@"%f",rotate] forKey:@"rotate"];
                }
                
                [self updateImagePoint:dict];
                
                [self updateCtrolPoint:dict];

                [self upDateBorderPoint:dict];
            }
            
        }
    
        //判断是在最后一步，还是中间步骤
        if (arrCount==arr.count) {
        
            [self addProductArray];      //直接添加步骤
            
        }else{
            NSMutableArray *tempArray=[[NSMutableArray alloc] init];
            //先删除掉后面的步骤再，插入步骤
            for (int i=0; i<arrCount; i++) {
                
                [tempArray addObject:arr[i]];
                
            }
            [arr removeAllObjects];
            arr=tempArray;
            [self addProductArray];
        }
    }
    
    for (NSDictionary *dict in arrUrl) {
        
        if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
            
            for (UIView *thesubView in [canasView subviews]) {
                if (thesubView.tag==controlLeftTopView.tag) {
                    CGRect rect=[tempControlLeftTopView.superview convertRect:tempControlLeftTopView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                    [self pop_animationStriong:kPOPLayerAGKQuadTopLeft forView:thesubView];
                    
                }
                if (thesubView.tag==controlRightTopView.tag) {
                    CGRect rect=[tempControlRightTopView.superview convertRect:tempControlRightTopView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                    [self pop_animationStriong:kPOPLayerAGKQuadTopRight forView:thesubView];
                }
                if (thesubView.tag==controlBottomLeftView.tag) {
                    CGRect rect=[tempControlBottomLeftView.superview convertRect:tempControlBottomLeftView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                    [self pop_animationStriong:kPOPLayerAGKQuadBottomLeft forView:thesubView];
                }
                if (thesubView.tag==controlBottomRightView.tag) {
                    CGRect rect=[tempControlBottomRightView.superview convertRect:tempControlBottomRightView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                    [checkButton sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] forState:UIControlStateNormal];
                    [self pop_animationStriong:kPOPLayerAGKQuadBottomRight forView:thesubView];
                    
                }
                if (thesubView.tag==borderLeftTopView.tag) {
                    CGRect rect=[tempborderLeftTopView.superview convertRect:tempborderLeftTopView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                }
                if (thesubView.tag==borderRightTopView.tag) {
                    
                    CGRect rect=[tempborderRightTopView.superview convertRect:tempborderRightTopView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                }
                if (thesubView.tag==borderBottomLeftView.tag) {
                    
                    CGRect rect=[tempborderBottomLeftView.superview convertRect:tempborderBottomLeftView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                }
                if (thesubView.tag==borderBottomRightView.tag) {
                    
                    CGRect rect=[tempborderBottomRightView.superview convertRect:tempborderBottomRightView.frame toView:canasView];
                    thesubView.frame= CGRectMake(rect.origin.x+(rect.size.width-30)/2,rect.origin.y+(rect.size.height-30)/2, 30, 30);
                }

            }
            
        }
    }
    
    [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:NO];
    
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0.0;
    
}

//没选中的商品直接拖事件
static bool actionPan = NO;

- (void)handlePan:(UIPanGestureRecognizer*) recognizer
{
   
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        actionPan = YES;
        
        [self animationAciton:YES];
        
        if ([[_tempCheckDict objectForKey:@"lockState"] isEqualToString:@"YES"]) {
            
            [self animationAciton:NO]; //显示
            
            checkButton.gestureRecognizers = nil;
            
        }
        
        for (UIView *subView in canasView.subviews) {
            if (subView.tag >3000 && subView.tag<8000) {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *but =(UIButton*)subView;
                    but.enabled = NO;
                    but.adjustsImageWhenDisabled = NO;
                }
            }
        }
        
    }
    
    
    //手指离开监听事件
    if (([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateEnded) || ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateCancelled)) {
        
        [self animationAciton:NO]; //显示
        
        for (UIView *subView in canasView.subviews) {
            if (subView.tag >3000 && subView.tag<8000) {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *but =(UIButton*)subView;
                    but.enabled = YES;
                }
            }
        }

        for (UIView *subView in canasView.subviews) {
            
            if (subView.tag >3000&&subView.tag<=8000) {
                [self bindPan:(UIButton*)subView];
                
            }
        }
        
        for (NSDictionary *dict in arrUrl) {
            
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
        
                [self updateImagePoint:dict];
                
                [self updateCtrolPoint:dict];
            
                [self upDateBorderPoint:dict];
  
            }
        }
        
    
        
        //判断是在最后一步，还是中间步骤
        if (arrCount==arr.count) {
            
    
            [self addProductArray];      //直接添加步骤
            
        
            
        }else{
        

            NSMutableArray *tempArray=[[NSMutableArray alloc] init];
            
            //先删除掉后面的步骤再，插入步骤
            for (int i=0; i<arrCount; i++) {
                
                [tempArray addObject:arr[i]];
                
            }
        

            [arr removeAllObjects];
            
            arr=tempArray;
            
            [self addProductArray];
            
        }

    
    }
    
    CGPoint translation = [recognizer translationInView:canasView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    controlLeftTopView.center = CGPointMake(controlLeftTopView.center.x + translation.x,
                                 controlLeftTopView.center.y + translation.y);
    controlRightTopView.center = CGPointMake(controlRightTopView.center.x + translation.x,
                                 controlRightTopView.center.y + translation.y);
    controlBottomLeftView.center = CGPointMake(controlBottomLeftView.center.x + translation.x,
                                 controlBottomLeftView.center.y + translation.y);
    controlBottomRightView.center = CGPointMake(controlBottomRightView.center.x + translation.x,
                                 controlBottomRightView.center.y + translation.y);
    tempView.center=CGPointMake(tempView.center.x + translation.x, tempView.center.y+translation.y);
    borderLeftTopView.center = CGPointMake(borderLeftTopView.center.x + translation.x,
                                           borderLeftTopView.center.y + translation.y);
    borderRightTopView.center = CGPointMake(borderRightTopView.center.x + translation.x,
                                            borderRightTopView.center.y + translation.y);
    borderBottomLeftView.center = CGPointMake(borderBottomLeftView.center.x + translation.x,
                                              borderBottomLeftView.center.y + translation.y);
    borderBottomRightView.center = CGPointMake(borderBottomRightView.center.x + translation.x,
                                               borderBottomRightView.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:canasView];
    
    [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView  panBool:NO];

    
   
}


-(void)pop_animationStriong:(NSString*)animationName forView:(UIView *)subView
{
    POPSpringAnimation *anim = [checkButton.layer pop_animationForKey:animationName];
    if(anim == nil)
    {
        anim = [POPSpringAnimation animation];
        anim.property = [POPAnimatableProperty AGKPropertyWithName:animationName];
        [checkButton.layer pop_addAnimation:anim forKey:animationName];
    }
    anim.toValue = [NSValue valueWithCGPoint:subView.center];
    anim.springBounciness = 7;
    anim.springSpeed =0.001;
    anim.dynamicsFriction = 7;
   
    
}
#pragma mark 收藏夹导航栏上的点击事件
// 点击更多
-(void)moreProductAction
{
    thearray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"sureArray"]];
    
    for (UIView *subView in [thefilterView subviews]) {
        [subView removeFromSuperview];
    }
    _isProDuctColletionView=NO;
    
    [self setUpLableColletionView];
    
    [self httpGetColletionLable];
    
}
-(NSMutableArray *)getSureArray          //获选选中的lable放入sureArray
{
    NSMutableArray *sure=[[NSMutableArray alloc] init];
    for (UIView *subView in [self.lablecollectionView subviews]) {
        for (UIView *thesubView in [subView subviews]) {
            for (UILabel *lable in [thesubView subviews]) {
                
                if (lable.textColor==[UIColor orangeColor]) {
                    
                    [sure addObject:lable.text];
                }
            }
        }
    }
    return sure;
    
}
//确认筛选标签
-(void)sureButton
{
    sureArray=[self getSureArray];
    
    //NSLog(@"sureArray=%@",sureArray);
    
    if (sureArray.count!=0) {
        
        for (UIView *subView  in [thefilterView subviews]) {
            [subView removeFromSuperview];
        }
        _isProDuctColletionView=YES;
        
        [self setUpProDuctColletionView];
        
        //数组转为json格式
        NSData *data=[NSJSONSerialization dataWithJSONObject:sureArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonlabel=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        _lable=jsonlabel;
        _page=@"1";
        
        [self httpGetColletionList];          //筛选选中
        
        //____________________________________确认前保存到UserDefualt供下次使用
        NSData *encodemenulist = [NSKeyedArchiver archivedDataWithRootObject:sureArray];
        [[NSUserDefaults standardUserDefaults] setObject:encodemenulist forKey:@"sureArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    }else{
        
        [self showAlertWithText:@"请选择标签"];
        
    }
    
}
// 清除筛选标签
-(void)deleteCheckLableAction
{
    [sureArray removeAllObjects];
    //————————————————————插入空数据
    NSData *encodemenulist = [NSKeyedArchiver archivedDataWithRootObject:sureArray];
    [[NSUserDefaults standardUserDefaults] setObject:encodemenulist forKey:@"sureArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (UIView *subView in [self.lablecollectionView subviews]) {
        for (UIView *thesubView in [subView subviews]) {
            for (UILabel *lable in [thesubView subviews]) {
                UIColor *lablCo=UIColorFromHex(0x666666);
                lable.layer.borderColor = lablCo.CGColor;
                lable.layer.borderWidth = 1;
                lable.backgroundColor=[UIColor clearColor];
                lable.textColor=lablCo;
            }
        }
    }
    
}
//判断标签是否为空
-(void)titleCountIsNull
{
    if (self.titles.count!=0) {
        UIButton *missButton=[self.lablecollectionView viewWithTag:1004];
        UIButton *sureButton=[self.lablecollectionView viewWithTag:1005];
        missButton.enabled=YES;
        sureButton.enabled=YES;
        missButton.hidden=NO;
        sureButton.hidden=NO;
        
    }else{
        UIButton *missButton=[self.lablecollectionView viewWithTag:1004];
        UIButton *sureButton=[self.lablecollectionView viewWithTag:1005];
        missButton.enabled=NO;
        sureButton.enabled=NO;
        missButton.hidden=YES;
        sureButton.hidden=YES;
        
        UIImageView *tipImage=[UIImageView new];
        tipImage.image=[UIImage imageNamed:@"colection_ba"];
        [self.lablecollectionView addSubview:tipImage];
        tipImage.sd_layout
        .topSpaceToView(self.lablecollectionView,180)
        .centerXEqualToView(self.lablecollectionView)
        .widthRatioToView(self.lablecollectionView,0.28)
        .heightEqualToWidth();
        
        UILabel *tipLable=[UILabel new];
        tipLable.font=[UIFont systemFontOfSize:20];
        tipLable.textColor=UIColorFromHex(0x666666);
        tipLable.textAlignment=NSTextAlignmentCenter;
        [self.lablecollectionView addSubview:tipLable];
        tipLable.sd_layout
        .topSpaceToView(tipImage,22)
        .leftEqualToView(self.lablecollectionView)
        .rightEqualToView(self.lablecollectionView)
        .heightIs(20);
        
        UIColor *attColor=UIColorFromHex(0xf39800);
        tipLable.text=[NSString stringWithFormat:@"您的收藏夹为空，请前往\"选单品\"选板块收藏商品"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tipLable.text]; // 改变特定范围颜色大小要用的
        [attributedString addAttribute:NSForegroundColorAttributeName value:attColor range:NSMakeRange(12,3)];
        tipLable.attributedText=attributedString;
        
    }
    
}
//商品是否为空
-(void)proDuctCountIsNul:(NSString *)tagStr
{
    UIImageView *tipImage=[UIImageView new];
    tipImage.image=[UIImage imageNamed:@"search"];
    if ([tagStr isEqualToString:@"1"]) {
        [self.proDuctColletionView addSubview:tipImage];
        tipImage.sd_layout
        .topSpaceToView(self.proDuctColletionView,180)
        .centerXEqualToView(self.proDuctColletionView)
        .widthRatioToView(self.proDuctColletionView,0.28)
        .heightEqualToWidth();
    }else{
        tipImage.tag=900;
        [self.spaceCollectionView addSubview:tipImage];
        tipImage.sd_layout
        .topSpaceToView(self.spaceCollectionView,180)
        .centerXEqualToView(self.spaceCollectionView)
        .widthRatioToView(self.spaceCollectionView,0.28)
        .heightEqualToWidth();
    }
    UILabel *tipLable=[[UILabel alloc] init];
    tipLable.textColor=UIColorFromHex(0x666666);
    tipLable.font=[UIFont systemFontOfSize:20];
    NSString *titleStr;
    if ([tagStr isEqualToString:@"1"]) {
        titleStr=@"抱歉，没有找到符合条件的商品请重新筛选标签";
        [self.proDuctColletionView addSubview:tipLable];
        tipLable.sd_layout
        .topSpaceToView(tipImage,22)
        .widthIs(280)
        .centerXEqualToView(self.proDuctColletionView)
        .autoHeightRatio(0);
    }else{
        tipLable.tag=901;
        titleStr=@"抱歉，没有找到符合条件的背景请重新筛选标签";
        [self.spaceCollectionView addSubview:tipLable];
        tipLable.sd_layout
        .topSpaceToView(tipImage,22)
        .widthIs(280)
        .centerXEqualToView(self.spaceCollectionView)
        .autoHeightRatio(0);
    }
    tipLable.text=titleStr;
    tipLable.textAlignment=NSTextAlignmentCenter;
    
    
}
//标签列表返回按钮
-(void)returnAction
{
    if (sureArray.count==0) {
        
        for (UIView *subView in [thefilterView subviews]) {
            [subView removeFromSuperview];
        }
        [self.lablecollectionView removeFromSuperview];      //移除标签ColletionView
        _isProDuctColletionView=YES;
        
        [self setUpProDuctColletionView];
        _lable=@"";
        _page=@"1";
        intPage=1;
        [self deleteCheckLableAction];     //清除按钮
        [self.addDataArr removeAllObjects];
        [self httpGetColletionList];
        
        
    }else{
        
        UIAlertController *alterCtr=[UIAlertController alertControllerWithTitle:@"是否放弃筛选？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sure=[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            [self deleteCheckLableAction];     //清除按钮
            
            for (UIView *subView in [thefilterView subviews]) {
                [subView removeFromSuperview];
            }
            [self.lablecollectionView removeFromSuperview];      //移除标签ColletionView
            _isProDuctColletionView=YES;
            [self setUpProDuctColletionView];
            _lable=@"";
            [self httpGetColletionList];
        
        }];
        
        UIAlertAction *dissmiss=[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alterCtr addAction:sure];
        [alterCtr addAction:dissmiss];
        
        [self presentViewController:alterCtr animated:YES completion:^{

        }];
    }
}

-(NSString*)getDesignPath
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), NO, 1);
    [canasView drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    YSKJ_SaveWebImageClass *save = [[YSKJ_SaveWebImageClass alloc] init];
     [save SaveShopPicFloder:@"design" p_no:@"photo" imageUrl:nil SaveFileName:@"design" SaveFileType:@"png" image:snapshot size:CGSizeMake(410, 308)];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,@"design",@"photo"];
    
    NSString *fullPath = [imagePath stringByAppendingPathComponent:@"design.png"];
    
    return fullPath;
    
}
-(void)alterWithTitle:(NSString *)title message:(NSString*)mes cancle:(NSString*)cancleTilte sure:(NSString *)sureTilte
{
    UIAlertController *alterCtr=[UIAlertController alertControllerWithTitle:title message:mes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure=[UIAlertAction actionWithTitle:sureTilte style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [arr removeAllObjects];
        
        [timer invalidate];
        
        [canasView removeFromSuperview];
        [picModleView removeFromSuperview]; //移除3D模型图承载的View
        [proDuctPopView removeFromSuperview];
        [naviView removeFromSuperview];
        [transformView removeFromSuperview];
        
        for (UIView *sub in [canasView subviews]) {
            if (sub.tag>3000) {
                [sub removeFromSuperview];
            }
        }
        
        for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
            if (subView.tag == 2017) {
                [subView removeFromSuperview];
            }
        }
        
        [self endTimer];
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
        
        [self performSelector:@selector(sureDiss) withObject:self afterDelay:0.3];
        
    }];
    UIAlertAction *dissmiss=[UIAlertAction actionWithTitle:cancleTilte style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alterCtr addAction:sure];
    [alterCtr addAction:dissmiss];
    
    [self presentViewController:alterCtr animated:YES completion:^{
    }];
    
}

-(void)sureDiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)spaceBottom     //下移家具的同时吧空间下移保持空间在最下面
{
    for (UIView *thesubView in [canasView subviews]) {
        if (thesubView.tag==6000) {
            [canasView sendSubviewToBack:thesubView];
        }
    }
    
}

#pragma mark  NavigationBar Action －－－－－－－－－－－－－导航栏点击事件

-(void)closePlan
{
    UIButton *naviButton=[naviView viewWithTag:TAG3];
    
    
    if (naviButton.enabled == YES) {
        
        [self alterWithTitle:@"您是否要退出编辑？" message:nil cancle:@"否" sure:@"是"];
        
    }else{
        
        
        [arr removeAllObjects];
        [canasView removeFromSuperview];
        [picModleView removeFromSuperview]; //移除3D模型图承载的View
        [proDuctPopView removeFromSuperview];
        [naviView removeFromSuperview];
        [transformView removeFromSuperview];

        [timer invalidate];
        
        for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
            if (subView.tag == 2017) {
                [subView removeFromSuperview];
            }
        }
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];

        [self dismissViewControllerAnimated:YES completion:^{

            [self endTimer];
            
        }];
        
    }
    
}

-(void)savePlan
{
    
    NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    NSArray *jsonArr = [self getCanvasArray];
    
    NSDictionary *jsonDict=@{
                             @"count":[NSString stringWithFormat:@"%lu",(unsigned long)jsonArr.count],
                             @"data":jsonArr
                             };
    
    NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:plan_key];
    
    NSDictionary *planData=@{
                             @"data_value":[ToolClass stringWithDict:jsonDict],
                             @"type":[localData objectForKey:@"type"],
                             @"planId":[localData objectForKey:@"planId"],
                             @"projectName":[localData objectForKey:@"projectName"],
                             @"planName":[localData objectForKey:@"planName"]
                             };
    
    [[NSUserDefaults standardUserDefaults] setObject:planData forKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"planData=%@",planData);
    
    NSString *data_value = [planData objectForKey:@"data_value"];
    
    if (data_value.length<10 || [[planData objectForKey:@"planId"]  isEqual: @""] || [[planData objectForKey:@"type"]  isEqual: @""] ) {
        NSLog(@"数据有错误");
    }
    //新建
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:plan_key] objectForKey:@"type"] isEqualToString:@"create"]) {
        
        [self presentPlanViewController:YES];
        
        
    }else{
    //修改
        
        [self presentPlanViewController:NO];
        
    }
    
    
    [self saveDissenble:NO];
    
    
}

-(void)presentPlanViewController:(BOOL)opertingMode
{
    YSKJ_PlanViewController *plan=[[YSKJ_PlanViewController alloc] init];
    UINavigationController *naviModel=[[UINavigationController alloc] initWithRootViewController:plan];
    
    plan.operatingMode = opertingMode;

    shapelayer.strokeColor=[UIColor clearColor].CGColor;
    //模态风格
    naviModel.modalPresentationStyle= UIModalPresentationFormSheet;
    naviModel.preferredContentSize = CGSizeMake(self.view.frame.size.width-264*2,self.view.frame.size.height-153-203);
    [self presentViewController:naviModel animated:YES completion:^{
        
    }];

};
-(void)afterA
{
    [self getToken:[self getDesignPath]  tokenType:@"design" isPlan:YES];
}
static int arrCount;
-(void)recallPlan
{
    
    tempView.backgroundColor=[UIColor clearColor];
    shapelayer.strokeColor=[UIColor clearColor].CGColor;
    
    [UIView animateWithDuration:0.6 animations:^{
        
        [self hideModelView];
        
        proDuctPopView.frame=CGRectMake(THEWIDTH+58, 64, 58, THEHEIGHT-63);
        proDuctPopView.backgroundColor=[UIColor clearColor];
        proDuctPopView.line.backgroundColor=[UIColor clearColor];
        
    }];
    
    if (arr.count!=0) {
        
        if (arrCount!=1) {
            
            arrCount--;
            
            for (UIView *subViews in [canasView subviews]) {
                if (subViews!=tempView) {
                    [subViews removeFromSuperview];

                }
            }
            [self setUpOpenPlanView:arr[arrCount-1] isAddTag:NO];
        }
    }
    if (arrCount==1) {    //回到第一步骤
        
        [self saveDissenble:NO];
        [self recallDissenble:NO];
        [self nextDissenble:YES];
        
    }else{               //中间步骤
        [self saveDissenble:YES];
        [self nextDissenble:YES];
    }
    
    [self haveAction];
  
}
-(void)advancePlan
{
    tempView.backgroundColor=[UIColor clearColor];
    shapelayer.strokeColor=[UIColor clearColor].CGColor;
    
    [UIView animateWithDuration:0.6 animations:^{
        
        [self hideModelView];
        
        proDuctPopView.frame=CGRectMake(THEWIDTH+58, 64, 58, THEHEIGHT-63);
        proDuctPopView.backgroundColor=[UIColor clearColor];
        proDuctPopView.line.backgroundColor=[UIColor clearColor];
    }];
    if (arrCount<arr.count) {
        arrCount++;
        
        for (UIView *subViews in [canasView subviews]) {
            if (subViews!=tempView) {
                [subViews removeFromSuperview];
                
            }
        }
        [self setUpOpenPlanView:arr[arrCount-1] isAddTag:NO];
        
    }
    if (arrCount==arr.count) {
        
        [self saveDissenble:YES];
        [self recallDissenble:YES];
        [self nextDissenble:NO];
        
    }else{
        
        [self saveDissenble:YES];
        [self recallDissenble:YES];
    }
    
    [self haveAction];
    
}
//清空
-(void)emptyPlan
{
    UIAlertController *alterCtr=[UIAlertController alertControllerWithTitle:@"您确定要清空？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure=[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [arrUrl removeAllObjects];
        
        shapelayer.strokeColor = [UIColor clearColor].CGColor;
        
        for (UIView *subViews in [canasView subviews]) {
            if (subViews!=tempView) {
                [subViews removeFromSuperview];
            }
        }
        [self addProductArray];  //获取空画布数据放进步骤1里
        
        tempView.frame = CGRectMake(1, 1, 1, 1);
        
    }];
    
    UIAlertAction *dissmiss=[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alterCtr addAction:sure];
    [alterCtr addAction:dissmiss];
    
    [self presentViewController:alterCtr animated:YES completion:^{
    }];

}
//是否展示筛选视图
static bool isShowFilter=NO;
-(void)favoritePlan:(UIButton *)sender
{
    UIButton *spaceButton1=[naviView viewWithTag:1007];
    UIButton *spaceButton2=[naviView viewWithTag:1008];
    UIButton *spaceButton3=[naviView viewWithTag:1013];
    UIButton *spaceButton4=[naviView viewWithTag:1014];
    
    if (spaceButton1.tag==sender.tag||spaceButton3.tag==sender.tag) {                //空间背景
        [self.spaceArray removeAllObjects];
        for (UIView *subView in thefilterView.subviews) {
            [subView removeFromSuperview];
        }
        [self setUpSpaceColletionView];
        
    }else if(spaceButton2.tag==sender.tag||spaceButton4.tag==sender.tag){         //来自收藏夹
        if (_isProDuctColletionView==YES) {
            
            for (UIView *subView in thefilterView.subviews) {
                [subView removeFromSuperview];
            }
            _page=@"1";
            [self setUpProDuctColletionView];
            
        }else{
            for (UIView *subView in thefilterView.subviews) {
                [subView removeFromSuperview];
            }
            [self setUpLableColletionView];
        }
        
    }
    [self.addDataArr removeAllObjects];
 
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (isShowFilter==NO) {
            
            if (spaceButton1.tag==sender.tag||spaceButton3.tag==sender.tag) {
                _type=@"1";
                _style=@"";
                [self httpGetSpacebgList];
                
            }else if (spaceButton2.tag==sender.tag||spaceButton4.tag==sender.tag)
            {
                intPage=1;
                [self httpGetColletionList];
            }
            thefilterView.backgroundColor=UIColorFromHex(0xffffff);
            thefilterView.frame=CGRectMake(THEWIDTH/2, 0, THEWIDTH/2, THEHEIGHT);
            theFilterCanbutton.frame=CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT);
            isShowFilter=YES;
            
        }else{
            
            _cateid=@"1";
            [self httpGetProDuctLableList];
            //隐藏改变Y轴
            thefilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            theFilterCanbutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            isShowFilter=NO;
            thefilterView.backgroundColor=[UIColor clearColor];
            filterCell.backgroundColor=[UIColor clearColor];
            cateCell.backgroundColor=[UIColor clearColor];
            
        }
    }];
}
-(void)proDetailePlan       //商品清单
{
    NSMutableArray *pro= [self getCanvasArray];     //获取当前画布信息，不加入历史纪录
    //移除背景json数据
    NSMutableArray *temp=[[NSMutableArray alloc]init];
    for (int i=0;i<pro.count;i++) {
        NSDictionary *proDict=pro[i];
        if ([[proDict objectForKey:@"imageTag"] integerValue]==6000) {
            [pro removeObject:proDict];
            i--;
        }else{
            [temp addObject:proDict];
        }
    }
    YSKJ_ProDetaileViewController *detail=[[YSKJ_ProDetaileViewController alloc] init];
    detail.proArr=temp;
    UINavigationController *naviModel=[[UINavigationController alloc] initWithRootViewController:detail];
    //模态风格
    [self presentViewController:naviModel animated:YES completion:^{
    }];
}
-(void)addProductPlan     //添加商品
{
    
    for (UIView *subView in thefilterView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self setUpAddProductColletionView];
    
    // 开启动画
    [UIView animateWithDuration:0.3 animations:^{
        
        if (isShowFilter==NO) {
            
            filterCell.backgroundColor=[UIColor whiteColor];
            cateCell.backgroundColor=[UIColor whiteColor];
            thefilterView.backgroundColor=[UIColor whiteColor];
            thefilterView.frame=CGRectMake(THEWIDTH/2, 0, THEWIDTH/2, THEHEIGHT);
            theFilterCanbutton.frame=CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT);
            isShowFilter=YES;
            
            [self initHttpParam];
            [self httpGetProDuctList];
    
        }else{
            //隐藏改变Y轴
            thefilterView.backgroundColor=[UIColor clearColor];
            thefilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            theFilterCanbutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            isShowFilter=NO;
            
            filterCell.backgroundColor=[UIColor clearColor];
            cateCell.backgroundColor=[UIColor clearColor];
            
        }
        
    }];
    

}
//是否展示筛选视图
static bool isShowProductFilter=NO;

-(void)proDuctFilterAction
{
    // 开启动画
    [UIView animateWithDuration:0.3 animations:^{
        if (isShowProductFilter==NO) {
            filterCell.backgroundColor=[UIColor whiteColor];
            cateCell.backgroundColor=[UIColor whiteColor];
            proDuctFilterView.backgroundColor=[UIColor whiteColor];
            proDuctFilterView.frame=CGRectMake(THEWIDTH/2, 0, THEWIDTH/2, THEHEIGHT);
            proDuctFilterCanclebutton.frame=CGRectMake(0, 0, THEWIDTH/2, THEHEIGHT);
            isShowProductFilter=YES;
            
        }else{
            //隐藏改变Y轴
            proDuctFilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
            proDuctFilterCanclebutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2,THEHEIGHT);
            isShowProductFilter=NO;
            filterCell.backgroundColor=[UIColor clearColor];
            cateCell.backgroundColor=[UIColor clearColor];
            proDuctFilterView.backgroundColor=[UIColor clearColor];
        }
    }];
    
}

#pragma mark  operationBar Action －－－－－－－－－－－－－操作栏点击事件

-(void)productPopViewAction:(UIButton *)sender
{
    if (sender.tag==copy)     //复制
    {
        NSMutableArray *jsonArr=[self getCanvasArray];   //获取当前json，不放入历史纪录
        
        NSMutableDictionary *tempDict=[[NSMutableDictionary alloc] init];
        
        for (int i=0;i<jsonArr.count;i++) {
            
            NSDictionary *jsonDict=jsonArr[i];
            
            if ([[jsonDict objectForKey:@"imageTag"] integerValue ] ==checkButton.tag) {
                
                tempDict=[[NSMutableDictionary alloc] initWithDictionary:jsonDict];
                
                float centerX=[[tempDict objectForKey:@"centerX"] floatValue]+20;
                float centerY=[[tempDict objectForKey:@"centerY"] floatValue]+20;
                float x=[[tempDict objectForKey:@"x"] floatValue]+20;
                float y=[[tempDict objectForKey:@"y"] floatValue]+20;
                
                [tempDict setValue:[NSString stringWithFormat:@"%f",x] forKey:@"x"];
                [tempDict setValue:[NSString stringWithFormat:@"%f",y] forKey:@"y"];
                [tempDict setValue:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
                [tempDict setValue:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
                
                NSInteger tag=3000+(jsonArr.count+1)*10; //最后一个商品tag
                
                [tempDict setValue:[NSString stringWithFormat:@"%ld",(long)tag] forKey:@"imageTag"];
                
                [tempDict setValue:[tempDict objectForKey:@"url"] forKey:@"thumb_file"];
            }
        }
        
        [self createProductObj:tempDict withEnumType:CopyState];      //复制相当拉一个商品到画布
        
        
    }else if (sender.tag==transformation)     //变形
    {
        [self addBorderWithTLView:controlLeftTopView TRView:controlRightTopView BLView:controlBottomLeftView BRView:controlBottomRightView panBool:NO];
        
        [UIView animateWithDuration:0.6 animations:^{
            
            transformView.frame=CGRectMake(THEWIDTH-58, 0, 58, THEHEIGHT);
            transformView.backgroundColor=[UIColor whiteColor];
            transformView.transformViewLine.backgroundColor=UIColorFromHex(0xefefef);
            naviView.frame=CGRectMake(0, -63, THEWIDTH, 63);
            naviView.backgroundColor=[UIColor clearColor];
            naviView.line.backgroundColor=[UIColor clearColor];
            
            [self hideModelView];
            
        }];
        
        //显示选中的controlPoint,隐藏其他的controlPoint
        for (UIView *thesubView in [canasView subviews]) {
            if (checkButton.tag+5000==thesubView.tag||checkButton.tag+5001==thesubView.tag||checkButton.tag+5002==thesubView.tag||checkButton.tag+5003==thesubView.tag) {
                thesubView.hidden=NO;
            }else if(thesubView.tag>8000){
                thesubView.hidden=YES;
            }
            
        }
        tempView.gestureRecognizers=nil;
        for (UIView *subview in canasView.subviews) {
            if (subview.tag>3000 && subview.tag<8000) {
                subview.gestureRecognizers=nil;
                UIButton *button=(UIButton *)subview;
                button.enabled=NO;
                button.adjustsImageWhenDisabled=NO;
            }
        }
        
    }else if (sender.tag==mirroring) {       //镜像
        for (NSDictionary *dict in arrUrl) {
            if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                if ([[dict objectForKey:@"mirror"]isEqualToString:@"0"]) {
                    checkButton.imageView.transform = CGAffineTransformMakeScale(-1, 1);;
                    [dict setValue:@"1" forKey:@"mirror"];
                }else{
                    checkButton.imageView.transform = CGAffineTransformMakeScale(1, 1);;
                    [dict setValue:@"0" forKey:@"mirror"];
                }
            }
        }
        
        [self addProductArray];
        [self saveDissenble:YES];
        [self recallDissenble:YES];
        
        
    }else if (sender.tag==delete)     //删除
    {
        
        [self addProductArray];
        
        [checkButton removeFromSuperview];
        
        NSDictionary *dict = @{
                               @"count":[NSString stringWithFormat:@"%lu",(unsigned long)arrUrl.count],
                               @"data":[self getCanvasArray]
                               };
        
        for (UIView *subViews in [canasView subviews]) {
            if (subViews!=tempView) {
                [subViews removeFromSuperview];
            }
        }
        
        [self setUpOpenPlanView:[ToolClass stringWithDict:dict] isAddTag:YES];
        
        
        [self addProductArray];
        
        tempView.hidden=YES;
        tempView.frame=CGRectMake(1, 1, 1, 1);
        
        shapelayer.strokeColor=[UIColor clearColor].CGColor;
        
        [UIView animateWithDuration:0.6 animations:^{

            [self hideModelView];
            
            proDuctPopView.frame=CGRectMake(THEWIDTH+58, 64, 58, THEHEIGHT-63);
            proDuctPopView.backgroundColor=[UIColor clearColor];
            proDuctPopView.line.backgroundColor=[UIColor clearColor];
            
        }];
        
//        
//        [self addProductArray];
//        
//        [UIView animateWithDuration:0.6 animations:^{
//            
//            [self hideModelView];
//            
//            proDuctPopView.frame=CGRectMake(THEWIDTH+58, 64, 58, THEHEIGHT-63);
//            proDuctPopView.backgroundColor=[UIColor clearColor];
//            proDuctPopView.line.backgroundColor=[UIColor clearColor];
//            
//        }];
//        
//        [checkButton removeFromSuperview];
//        [controlLeftTopView removeFromSuperview];
//        [controlRightTopView removeFromSuperview];
//        [controlBottomLeftView removeFromSuperview];
//        [controlBottomRightView removeFromSuperview];
//        
//        [borderLeftTopView removeFromSuperview];
//        [borderRightTopView removeFromSuperview];
//        [borderBottomLeftView removeFromSuperview];
//        [borderBottomRightView removeFromSuperview];
//        
//        [self addProductArray];
//        
//        tempView.hidden=YES;
//        tempView.frame=CGRectMake(1, 1, 1, 1);


    }else if (sender.tag==lock)             //锁定
    {
        if (checkButton.selected==NO) {
            
            [UIView animateWithDuration:0.6 animations:^{
                [self hideModelView];
            }];
            
            checkButton.gestureRecognizers=nil;
            tempView.gestureRecognizers=nil;
            
            for (NSDictionary *dict in arrUrl) {
                
                if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                    [dict setValue:@"YES" forKey:@"lockState"];
                }
            }
            checkButton.selected=YES;
            [self showLockState];
            [self addProductArray];
            
        }else{
            if (checkButton.tag!=6000) {
                [UIView animateWithDuration:0.6 animations:^{
                    [self showModelView];
                }];
            }
            checkButton.selected=NO;
            [self showLockState];
            [self addGestureRecognizer];
            if (checkButton.tag==6000) {
                [self bindDoubleTap:checkButton];
                [self bindPan:checkButton];
                
            }else{
                [self bindDoubleTap:checkButton];
                [self bindPan:checkButton];
            }
            for (NSDictionary *dict in arrUrl) {
                if ([[dict objectForKey:@"imageTag"] integerValue]==checkButton.tag) {
                    [dict setValue:@"NO" forKey:@"lockState"];
                }
            }
            for (UIView *thesubView in [canasView subviews]) {
                if (controlLeftTopView.tag==thesubView.tag) {
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] init];
                    [panRecognizer addTarget:self action:@selector(topLeftChanged:)];
                    [thesubView addGestureRecognizer:panRecognizer];
                    
                }
                if (controlRightTopView.tag==thesubView.tag){
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] init];
                    [panRecognizer addTarget:self action:@selector(topRightChanged:)];
                    [thesubView addGestureRecognizer:panRecognizer];
                    
                }
                if (controlBottomLeftView.tag==thesubView.tag){
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] init];
                    [panRecognizer addTarget:self action:@selector(bottomLeftChanged:)];
                    [thesubView addGestureRecognizer:panRecognizer];
                }
                if (controlBottomRightView.tag==thesubView.tag){
                    UIPanGestureRecognizer *panRecognizer= [[UIPanGestureRecognizer alloc] init];
                    [panRecognizer addTarget:self action:@selector(bottomRightChanged:)];
                    [thesubView addGestureRecognizer:panRecognizer];
                    
                }
            }
            [self addProductArray];
        }
        
        if (checkButton.tag == 6000) {
            for (UIView *subView in proDuctPopView.subviews) {
                if ([subView isKindOfClass:[UIButton class]]) {
                    if (subView.tag!=2004 && subView.tag!=2005) {
                        subView.hidden = YES;
                    }
                }
            }
        }
        
    }else if (sender.tag==stick)    //置顶
    {
        if (checkButton.tag!=6000) {
            
            mov=(int)arrUrl.count+1;
            [canasView bringSubviewToFront:checkButton];
            [canasView bringSubviewToFront:tempView];
            //把选中的controlPoint置前
            [controlLeftTopView.superview bringSubviewToFront:controlLeftTopView];
            [controlRightTopView.superview bringSubviewToFront:controlRightTopView];
            [controlBottomLeftView.superview bringSubviewToFront:controlBottomLeftView];
            [controlBottomRightView.superview bringSubviewToFront:controlBottomRightView];
            
            [self addProductArray];  //获取画布数据放进Arr[0]步骤里
            

        }else{
            
            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
            tip.title = @"背景不支持置顶";
        }
        
    }else if (sender.tag==moveup)         //上移
    {
        if (checkButton.tag!=6000) {
            
            [tempView.superview bringSubviewToFront:tempView];
            for (UIView *thesubView in [canasView subviews]) {
                if(thesubView.tag>8000){
                    [thesubView.superview bringSubviewToFront:thesubView];
                }
            }
            
            tempMov=mov-1;
            tempMov++;
            
            if (mov==arrUrl.count) {
                mov=(int)arrUrl.count;
                
                YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
                tip.title = @"已经到最上";
            }else{
                
                [checkButton.superview exchangeSubviewAtIndex:mov-1 withSubviewAtIndex:tempMov];
                mov++;
            }
            
            [self addProductArray];
            
        }else{
            
            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
            tip.title = @"背景不支持上移";
        }
        
        
    }else if (sender.tag==movedown)         //下移
    {
        
        [tempView.superview bringSubviewToFront:tempView];
        
        for (UIView *thesubView in [canasView subviews]) {
            if(thesubView.tag>8000){
                [thesubView.superview bringSubviewToFront:thesubView];
            }
        }
    
        if (mov!=2) {
            
            tempMov=mov-1;
            tempMov--;
            
            [checkButton.superview exchangeSubviewAtIndex:mov-1 withSubviewAtIndex:tempMov];
            if (mov==1) {
                mov=1;
            }else{
                mov--;
            }
            
            [self addProductArray];
            
        }else{
            
            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
            tip.title = @"已经到最底";
        }
        
        
        
    }else if (sender.tag==bottom)   //置底
    {
        NSLog(@"arrUrl=%@",arrUrl);
        
        if (checkButton.tag!=6000) {
             mov=2;
        }else{
            mov=1;
            YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
            tip.title = @"已经到最底";
        }
       
        [canasView sendSubviewToBack:checkButton];
        
        for (UIView *thesubView in [canasView subviews]) {
            if (thesubView.tag==6000) {
                [canasView sendSubviewToBack:thesubView];
            }
        }
        
        [self addProductArray];  //获取画布数据放进Arr[0]步骤里
        

    }else if (sender.tag==sure)     //确认变形
    {
        [UIView animateWithDuration:0.6 animations:^{
            
            transformView.frame=CGRectMake(THEWIDTH,0, 58, THEHEIGHT);
            transformView.backgroundColor=[UIColor clearColor];
            transformView.transformViewLine.backgroundColor=[UIColor clearColor];
            naviView.frame=CGRectMake(0, 0, THEWIDTH, 63);
            naviView.backgroundColor=[UIColor whiteColor];
            naviView.line.backgroundColor=UIColorFromHex(0xd8d8d8);
            
            if (checkButton.tag!=6000) {
                
                [self showModelView];
            }
        }];
        for (UIView *thesubView in [canasView subviews]) {
            if (controlLeftTopView.tag==thesubView.tag||controlRightTopView.tag==thesubView.tag||controlBottomLeftView.tag==thesubView.tag||controlBottomRightView.tag==thesubView.tag) {
                 thesubView.hidden=YES;
            }
        }
        for (UIView *subview in canasView.subviews) {
            if (subview.tag>3000 && subview.tag<8000) {
                UIButton *button=(UIButton *)subview;
                button.enabled=YES;
                [self addGestureRecognizer];       //添加手势
                [self bindDoubleTap:button];
                [self bindPan:button];
            }
        }
        
        //判断是在最后一步，还是中间步骤
        if (arrCount==arr.count) {
            [self addProductArray];      //直接添加步骤
        }else{
            
            NSMutableArray *tempArray=[[NSMutableArray alloc] init];
            //先删除掉后面的步骤再，插入步骤
            for (int i=0; i<arrCount; i++) {
                [tempArray addObject:arr[i]];
            }
            [arr removeAllObjects];
            arr=tempArray;
            [self addProductArray];
        }
        
        [self addBorderWithTLView:borderLeftTopView TRView:borderRightTopView BLView:borderBottomLeftView BRView:borderBottomRightView panBool:NO];
        
    }else if (sender.tag==cancel)        //取消变形
    {
        [UIView animateWithDuration:0.6 animations:^{
            transformView.frame=CGRectMake(THEWIDTH, 0, 58, THEHEIGHT);
            transformView.backgroundColor=[UIColor clearColor];
            transformView.transformViewLine.backgroundColor=[UIColor clearColor];
            naviView.frame=CGRectMake(0, 0, THEWIDTH, 63);
            naviView.backgroundColor=[UIColor whiteColor];
            naviView.line.backgroundColor=UIColorFromHex(0xd8d8d8);
            
            [self showModelView];
        }];
        for (UIView *thesubView in [canasView subviews]) {
            if (controlLeftTopView.tag==thesubView.tag||controlRightTopView.tag==thesubView.tag||controlBottomLeftView.tag==thesubView.tag||controlBottomRightView.tag==thesubView.tag) {
                thesubView.hidden=YES;
            }
        }
        for (UIView *subview in canasView.subviews) {
            if (subview.tag>3000 && subview.tag<8000) {
                UIButton *button=(UIButton *)subview;
                button.enabled=YES;
                [self addGestureRecognizer];       //添加手势
                [self bindDoubleTap:button];
                [self bindPan:button];
            }
        }
        
        for (UIView *subViews in [canasView subviews]) {
            if (subViews!=tempView) {
                [subViews removeFromSuperview];
            }
        }
        [self setUpOpenPlanView:[arr lastObject] isAddTag:NO];
        
        for (UIView *subView in canasView.subviews) {
            UIButton *button=(UIButton *)subView;
            if (button.tag==checkButton.tag) {
                [self imageAction:button];
            }
        }

    }
    
}
#pragma 提示
- (void)showAlertWithText:(NSString *)text
{
    YSKJ_TipViewCalss *tipView=[[YSKJ_TipViewCalss alloc] init];
    tipView.title = text;
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
  
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        [coverView removeFromSuperview];
        
        YSKJ_SaveWebImageClass *save = [[YSKJ_SaveWebImageClass alloc] init];
        
        [save SaveShopPicFloder:@"design" p_no:@"photo" imageUrl:nil SaveFileName:@"design" SaveFileType:@"png" image:tempImage size:CGSizeMake(tempImage.size.width, tempImage.size.height)];
    
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,@"design",@"photo"];
    
        NSString *fullPath = [imagePath stringByAppendingPathComponent:@"design.png"];
    
        [self showAlertImageLoading];

        [self getToken:fullPath  tokenType:@"design" isPlan:NO];

    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [coverView removeFromSuperview];
    }];
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        tempImage=[self imageWithImageSimple:portraitImg scaledToSize:CGSizeMake(portraitImg.size.width*0.65, portraitImg.size.height*0.65)];
        coverView = [UIView new];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.sd_layout
        .centerXEqualToView(coverView.superview)
        .centerYEqualToView(coverView.superview)
        .widthIs(THEWIDTH)
        .heightIs(THEHEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:coverView];
        
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake((THEWIDTH-(THEHEIGHT-200))/2,100, THEHEIGHT-200, THEHEIGHT-200) limitScaleRatio:3.0];
        imgEditorVC.forVC=@"1";
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^(){
        
        [coverView removeFromSuperview];
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

#pragma mark 获取token
-(void)getToken:(NSString*)filePath  tokenType:(NSString*)tokenStr isPlan:(BOOL)yes
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"bucket":tokenStr
      };
    
    [requset postHttpDataWithParam:param url:GETTOKEN  success:^(NSDictionary *dict, BOOL success) {
        
        NSDictionary *tokenDict=[dict objectForKey:@"data"];
        
        if (yes==YES) {
            //把图片保存到七牛云服务器
            [self saveToQiniuServer:[tokenDict objectForKey:@"token"] filePath:filePath key:[NSString stringWithFormat:@"%@/%@",@"solutionface",[self stringKey]] isPlan:YES];
        }else{
            //把图片保存到七牛云服务器
            [self saveToQiniuServer:[tokenDict objectForKey:@"token"] filePath:filePath key:[NSString stringWithFormat:@"%@/%@",@"spacebg",[self stringKey]] isPlan:NO];
        }
        
  
    } fail:^(NSError *error) {
        
    }];

}
-(NSString *)stringKey
{
    //当前时间
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSArray *changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];//存放十个数，以备随机取
    NSMutableString * getStr = [[NSMutableString alloc] initWithCapacity:9];
    NSString *changeString = [[NSMutableString alloc] initWithCapacity:10];
    for (int i = 0; i<10; i++) {
        NSInteger index = arc4random()%([changeArray count]-1);
        getStr = changeArray[index];
        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr];
    }
    NSString *md5PassStr=[changeString md5String];
    
    NSString *key=[NSString stringWithFormat:@"%@/%@.jpg",dateStr,[md5PassStr substringToIndex:16]];
    
    return key;
}

-(void)saveToQiniuServer:(NSString*)token filePath:(NSString*)filePath key:(NSString *)key isPlan:(BOOL)yes
{
    //国内https上传
    BOOL isHttps = TRUE;
    QNZone * httpsZone = [[QNAutoZone alloc] initWithHttps:isHttps dns:nil];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = httpsZone;
    }];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    [upManager putFile:filePath key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if(info.ok)
        {
            if (yes==YES) {
                
                NSLog(@"key=%@",key);
                
                [self updatePlanFace:key];
                
            }else{
                [self upLoadSpaceBg:key];
            }
           
        }else{
            [self showAlertWithText:@"上传失败"];
            [_alertLoading removeFromSuperview];
            
        }}option:nil];

}

//修改方案头像
-(void)updatePlanFace:(NSString *)key
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:plan_key]) {
        
        NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:plan_key];
        
        NSDictionary *param=
        @{
          @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
          @"id":[[localData objectForKey:@"planId"] isEqual:@""]?@"":[localData objectForKey:@"planId"],
          @"url":key
          };
        NSLog(@"param=%@",param);
        
        [requset postHttpDataWithParam:param url:UPDATEPLANFACE  success:^(NSDictionary *dict, BOOL success) {
            
            
            for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
                if (subView.tag == 2017) {
                    [subView removeFromSuperview];
                }
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFaceNotification" object:self userInfo:nil];
            
        } fail:^(NSError *error) {
            
            for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
                if (subView.tag == 2017) {
                    [subView removeFromSuperview];
                }
            }
            
        }];

    }else{
        
        for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
            if (subView.tag == 2017) {
                [subView removeFromSuperview];
            }
        }
    }
    
}

//上传空间背景
-(void)upLoadSpaceBg:(NSString*)key
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
      @"url":key
      };
    
    [requset postHttpDataWithParam:param url:UPLOADSPACEBG  success:^(NSDictionary *dict, BOOL success) {
        
        [_alertLoading removeFromSuperview];
        
      //获取空间上传空间背景列表
        _type=@"2";
        _style=@"";
        [self httpGetSpacebgList];

        
    } fail:^(NSError *error) {
        
    }];

}

- (void)showAlertImageLoading
{
    _alertLoading = [UIView new];
    _alertLoading.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.6];
    _alertLoading.sd_layout
    .centerXEqualToView(_alertLoading.superview)
    .centerYEqualToView(_alertLoading.superview)
    .widthIs(THEWIDTH)
    .heightIs(THEHEIGHT);
    
    UIImageView *imageView = [UIImageView new];
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]];
    imageView= [AnimatedGif getAnimationForGifAtUrl:localUrl];
    [_alertLoading addSubview:imageView];
    
    imageView.sd_layout
    .centerXEqualToView(imageView.superview)
    .centerYEqualToView(imageView.superview)
    .widthIs(64)
    .heightEqualToWidth();
    
    [[UIApplication sharedApplication].keyWindow addSubview:_alertLoading];
    
}
//等比例缩小原图的图片
- ( UIImage *)imageWithImageSimple:( UIImage *)image scaledToSize:( CGSize )newSize
{
    UIGraphicsBeginImageContext (newSize);
    
    [image drawInRect : CGRectMake ( 0 , 0 ,newSize. width ,newSize. height )];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
    
}

#pragma mark save_dissenble

-(void)saveDissenble:(BOOL)yes
{
    UIButton *naviButton=[naviView viewWithTag:TAG3];
    
    if (yes==NO) {
        naviButton.enabled=NO;
        naviButton.alpha=0.6;
        
    }else{
        naviButton.enabled=YES;
        naviButton.alpha=1;
    }
}
#pragma mark recall_Dissenble

-(void)recallDissenble:(BOOL)yes
{
    UIButton *naviButton=[naviView viewWithTag:TAG4];
    
    if (yes==NO) {
        naviButton.enabled=NO;
        naviButton.alpha=0.4;
    }else{
        naviButton.enabled=YES;
        naviButton.alpha=1;
    }
}

#pragma mark next_Dissenble

-(void)nextDissenble:(BOOL)yes
{
        UIButton *naviButton=[naviView viewWithTag:TAG5];
    
    if (yes==NO) {
    
        naviButton.enabled=NO;
        naviButton.alpha=0.4;
        
    }else{
        naviButton.enabled=YES;
        naviButton.alpha=1;
    }
}

#pragma mark detail_Dissenble

-(void)detailDissenble:(BOOL)yes
{
    UIButton *naviButton=[naviView viewWithTag:TAG9];
    
    if (yes==NO) {
        naviButton.enabled=NO;
        naviButton.alpha=0.6;
        
    }else{
        naviButton.enabled=YES;
        naviButton.alpha=1;
    }
}

#pragma mark delete_Dissenble

-(void)deleteDissenble:(BOOL)yes
{
    UIButton *naviButton=[naviView viewWithTag:TAG6];

    if (yes==NO) {
        naviButton.enabled=NO;
        naviButton.alpha=0.6;

    }else{
        naviButton.enabled=YES;
        naviButton.alpha=1;
    }
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
            lineView.tag=TAG;
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
    lineView.tag=TAG;
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
    
    _source=[_selectSouresArray componentsJoinedByString:@","];
    
    
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
            [filterText addTarget:self action:@selector(getStyleAction1:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)getStyleAction1:(UIButton *)sender
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
        _style1=[_selectStyleArray componentsJoinedByString:@","];
        
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
    
    _space=[_selectSpaceArray componentsJoinedByString:@","];
    
    
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
    .widthIs(proDuctFilterView.size.width-12)
    .heightIs(52);
    
    UIButton *button=[[UIButton alloc] init];
    button.backgroundColor=[UIColor clearColor];
    [tabCell addSubview:button];
    [button addTarget:self action:@selector(showSubCategory) forControlEvents:UIControlEventTouchUpInside];
    button.sd_layout
    .leftSpaceToView(tabCell,0)
    .topSpaceToView(lineView,0)
    .heightIs(52)
    .widthIs(proDuctFilterCanclebutton.size.width);
    
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
        categoryTableView.frame=CGRectMake(0, 0, proDuctFilterView.size.width, THEHEIGHT);
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
    
    categoryTableView.frame=CGRectMake(proDuctFilterView.size.width, 0, proDuctFilterView.size.width, THEHEIGHT);
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
        if (subView.tag>=6000) {
            for (UIView *scroll in subView.subviews){
                if (scroll.tag>=7000) {
                    for (UIView *subVIew in scroll.subviews){
                        if (subVIew.tag>=8000) {
                            for (UIView *viewbg in scroll.subviews) {
                                for (UIView *filterText in viewbg.subviews) {
                                    for (UIView *sub in filterText.subviews) {
                                        UIButton *filterButton=(UIButton*)sub;
                                        if (sub.tag==sender.tag) {
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
    _category=[_selectCategoryArray componentsJoinedByString:@","];
}


#pragma mark －－－－－－－－－－－－－－－－－－－－上拉下拉事件

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

//确认筛选
-(void)filterSure
{
    if (_selectStyleArray.count==0 && _selectSpaceArray.count==0 && _selectCategoryArray.count==0) {
        // NSLog(@"没选不需要做请求");
        [self.proDuctArray removeAllObjects];
        _page1=@"1";
        [self httpGetProDuctList];
        
    }else{
        [self.proDuctArray removeAllObjects];
        _page1=@"1";
        [self httpGetProDuctList];
        
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        //隐藏
        proDuctFilterView.backgroundColor=[UIColor clearColor];
        proDuctFilterView.frame=CGRectMake(THEWIDTH/2, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
        proDuctFilterCanclebutton.frame=CGRectMake(0, -THEHEIGHT, THEWIDTH/2, THEHEIGHT);
        isShowProductFilter=NO;
    }];
    
}

@end

