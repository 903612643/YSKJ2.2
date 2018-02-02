//
//  YJKJ_ProDuctTogetherViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/29.
//  Copyright © 2016年 5164casa.com. All rights reserved.


#import "YJKJ_ProDuctTogetherViewController.h"
#import <SDAutoLayout/UIView+SDAutoLayout.h>
#import "YSKJ_LoginViewController.h"
#import "HttpRequestCalss.h"
#import "YSKJ_CanvasViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ToolClass.h"
#import "YTAnimation.h"
#import "RootViewController.h"
#import "YSKJ_ProjectPlanViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "YSKJ_ProjectNameView.h"
#import "YSKJ_TipViewCalss.h"

#import <AGGeometryKit/AGGeometryKit.h>

#import <POPAnimatableProperty+AGGeometryKit.h>

#import <pop/POP.h>

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define GETPLANLIST @"http://"API_DOMAIN@"/solution/getmylist" //得到方案列表

#define DELPLAN @"http://"API_DOMAIN@"/solution/del" //删除方案

#define ADDPROJECTNAME @"http://"API_DOMAIN@"/solution/addfavlabel"

#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径

#define SPACEGBCSS @"appspacebgthumb"                 //七牛样式

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@interface YJKJ_ProDuctTogetherViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate>
{
    float sacle;
    
    UICollectionView *planListCollectionView;
    
    BOOL deleteBtnFlag;
    BOOL vibrateAniFlag;
    
    UIButton *buttonItem;
    UIButton *buttontitle;
    
    NSInteger _selectIndex;
    
    YSKJ_ProjectNameView *projectNameView;
    
}

@property (nonatomic,retain)NSMutableArray *planList;

@end

@implementation YJKJ_ProDuctTogetherViewController


-(void)viewDidDisappear:(BOOL)animated{
    
    deleteBtnFlag = YES;
    vibrateAniFlag = YES;
    [planListCollectionView reloadData];
    
    isedit=NO;
    [buttontitle setTitle:@"编辑" forState:UIControlStateNormal];
    [buttonItem setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    UIColor *titlcolor=UIColorFromHex(0x999999);
    [buttontitle setTitleColor:titlcolor forState:UIControlStateNormal];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    _selectIndex = 1;
    
    if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {
        buttontitle.hidden=NO;
        buttonItem.hidden=NO;
        buttontitle.enabled=YES;
        buttonItem.enabled=YES;
    }else{
        buttontitle.hidden=YES;
        buttonItem.hidden=YES;
        buttontitle.enabled=NO;
        buttonItem.enabled=NO;
    }
    
}
static bool isedit=NO;
-(void)isshow
{
    if (isedit==NO) {
        isedit=YES;
        [buttontitle setTitle:@"完成" forState:UIControlStateNormal];
        [buttonItem setImage:[UIImage imageNamed:@"edit1"] forState:UIControlStateNormal];
        UIColor *titlcolor=UIColorFromHex(0xf39800);
        [buttontitle setTitleColor:titlcolor forState:UIControlStateNormal];
        [self showAllDeleteBtn];
    }else{
        isedit=NO;
        [buttontitle setTitle:@"编辑" forState:UIControlStateNormal];
        [buttonItem setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        UIColor *titlcolor=UIColorFromHex(0x999999);
        [buttontitle setTitleColor:titlcolor forState:UIControlStateNormal];
        [self hideAllDeleteBtn];

    }
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title=@"做搭配";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    buttonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [buttonItem addTarget:self action:@selector(isshow) forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem];
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 0;
    
    buttontitle=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,30, 40)];
    UIColor *titlecol=UIColorFromHex(0x999999);
    buttontitle.titleLabel.font=[UIFont systemFontOfSize:14];
    [buttontitle setTitleColor:titlecol forState:UIControlStateNormal];
    [buttontitle addTarget:self action:@selector(isshow) forControlEvents:UIControlEventTouchUpInside];
    [buttontitle setTitle:@"编辑" forState:UIControlStateNormal];
    UIBarButtonItem *titeitem = [[UIBarButtonItem alloc]initWithCustomView:buttontitle];
  //  self.navigationItem.rightBarButtonItems=@[titeitem,fixedSpaceBarButtonItem,leftItem];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePlanNotification) name:@"notificationPlanList" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActionSuccess:) name:@"notificationToProDuctCtr" object:nil];
    
    //修改方案封面得到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFaceNotification) name:@"updateFaceNotification" object:nil];
    
    self.planList=[[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {
    
        [self setUpPlanColletionView];
        [self httpGetPlanListData];
        
    }else{
        [self setUpLoginTipView];
    }
    
    deleteBtnFlag = YES;
    vibrateAniFlag = YES;
    
}

#pragma mark 加载方案列表
-(void)setUpPlanColletionView
{
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小为100*100
    layout.itemSize = CGSizeMake(240, 240);
    //创建collectionView 通过一个布局策略layout来创建
   planListCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, THEWIDTH, THEHEIGHT-100) collectionViewLayout:layout];
    planListCollectionView.tag=1001;
    planListCollectionView.backgroundColor=[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    //代理设置
    planListCollectionView.delegate=self;
    planListCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [planListCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:planListCollectionView];
    
        //下拉刷新
    planListCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];

    
}
-(void)loadNewTopic
{
    [self httpGetPlanListData];
}

#pragma mark 获取方案列表

-(void)httpGetPlanListData
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
        @"userid":[[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"],
    };
    [requset postHttpDataWithParam:param url:GETPLANLIST  success:^(NSDictionary *dict, BOOL success) {
        
      //  NSLog(@"dict=%@",dict);
        
        NSDictionary *adddict=@{@"name":@"新建项目"};
        
        if ([[dict objectForKey:@"success"] boolValue]!=0) {
            
            [self.planList removeAllObjects];
            [self.planList addObject:adddict];
            [self.planList addObjectsFromArray:[dict objectForKey:@"data"]];
            
        }else{
            [self.planList removeAllObjects];
            [self.planList addObject:adddict];
        }
        
        for (UIView *subView in [self.view subviews]) {
            if (subView.tag==1000) {
                subView.hidden=YES;
            }
        }
        
        [planListCollectionView  reloadData];
        
 
        NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:plan_key] && _selectIndex == 1) {
            
            UIAlertController *havePlanNoSave=[UIAlertController alertControllerWithTitle:@"您上次退出时正在搭配的方案尚未保存，是否需要帮您恢复该方案？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *open=[UIAlertAction actionWithTitle:@"需要恢复" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                YSKJ_CanvasViewController *canvasVC=[[YSKJ_CanvasViewController alloc] init];
                [self presentViewController:canvasVC animated:YES completion:nil];
                
            }];
            
            UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"不需要" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
            {
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
                
            }];
            
            [havePlanNoSave addAction:open];
            [havePlanNoSave addAction:cancel];
            
            [self presentViewController:havePlanNoSave animated:YES completion:^{
                
            }];

        }else{
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
            
        }
        
        //结束头部刷新
        [planListCollectionView.mj_header endRefreshing];
        
    } fail:^(NSError *error) {
        //结束头部刷新
        [planListCollectionView.mj_header endRefreshing];
    }];
    
}

#pragma mark 删除方案列表
-(void)deletePlanList
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"userid":[[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]
      };
    
    [requset postHttpDataWithParam:param url:GETPLANLIST  success:^(NSDictionary *dict, BOOL success) {
        
        // NSLog(@"dict=%@",dict);
        
        NSDictionary *adddict=@{@"name":@"新建项目"};
        
        [self.planList addObject:adddict];
        
        if ([[dict objectForKey:@"success"] boolValue]==0) {
            
        }else{
            [self.planList addObjectsFromArray:[dict objectForKey:@"data"]];
        }
        
        for (UIView *subView in [self.view subviews]) {
            if (subView.tag==1000) {
                subView.hidden=YES;
            }
        }
        [planListCollectionView  reloadData];
        //  [self togetherHomeView];       //显示首页
        
    } fail:^(NSError *error) {
        
    }];

}

#pragma mark 登录成功后得到通知

-(void)loginActionSuccess:(NSNotification*)sender
{
    _selectIndex = [[sender.userInfo objectForKey:@"fromProVC"] integerValue];
    
    if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {
        for (UIView *subView in [self.view subviews]) {
            if (subView.tag==1000) {
                [subView removeFromSuperview];
            }
        }
        [self setUpPlanColletionView];
        [self httpGetPlanListData];
        
    }else{
        
        [self setUpLoginTipView];
        for (UIView *subView in [self.view subviews]) {
            if (subView.tag==1001) {
                [subView removeFromSuperview];
            }
        }
    }
    
    
}
#pragma mark 方案保存或修改成功得到通知

-(void)updateFaceNotification
{
    [self httpGetPlanListData];
}

-(void)deletePlanNotification
{
    [self httpGetPlanListData];
}

#pragma mark 登录后首页

//展示方案封面
-(void)showImagePlan:(UIImageView*)createPlanImage withDict:(NSDictionary *)listDict
{
    NSDictionary *dict_info=[ToolClass dictionaryWithJsonString:[listDict  objectForKey:@"data_info"]];
    
  //  NSLog(@"dict_info=%@",dict_info);
    
 //   七牛有图片用七牛，没用就使用1.3及以前版本json还原
    if ([dict_info objectForKey:@"url"]) {
        
        [createPlanImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",SPACEBGURL,[dict_info objectForKey:@"url"]]] placeholderImage:[UIImage imageNamed:@"loading3"]];

        
    }else{
    
        NSString *dataJson=[listDict objectForKey:@"data_value"];
        
        if (dataJson.length>10) {    //长度大于10才对它解析
            
            NSDictionary *dict=[ToolClass dictionaryWithJsonString:[listDict  objectForKey:@"data_value"]];
            
            //属于数据才对它处理，防止数据错误
            if ([[dict objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                
                NSArray *dataArray=[dict objectForKey:@"data"];
                
                for (NSDictionary *dict in dataArray) {
                    
                    float x=[[dict objectForKey:@"x"] floatValue];
                    float y=[[dict objectForKey:@"y"] floatValue];
                    float w=[[dict objectForKey:@"w"] floatValue];
                    float h=[[dict objectForKey:@"h"] floatValue];
                    
                    //得到比例系数
                    sacle=((THEWIDTH-16*4-40)/4)/THEWIDTH;
                    
                    NSString *imageStr=[dict objectForKey:@"url"];
                    NSURL *imagUrl=[NSURL URLWithString:imageStr];
                    NSInteger imageTag=[[dict objectForKey:@"imageTag"] integerValue];
                    
                    const float EPSINON=0.00001;
                    
                    if (((x>=-EPSINON)&&(x<=EPSINON))||((y>=-EPSINON)&&(y<=EPSINON))||((w>=-EPSINON)&&(w<=EPSINON))||((h>=-EPSINON)&&(h<=EPSINON))||imageStr==nil||imageTag==0) {
                    }else{
                        
                        float imageH=h*sacle,imageW=w*sacle; //得到高的值,得到宽的值的值
                        
                        float imageX,imageY;
                        
                        imageX=x*sacle;imageY=(y-63)*sacle;
                        
                        //在确定左右边距
                        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW-10, imageH)];
                        
                        //NSLog(@"imageView=%@",imageView);
                        imageView.transform = CGAffineTransformRotate(imageView.transform, [[dict objectForKey:@"rotate"] floatValue]);
                        
                        //是否镜像
                        if ([[dict objectForKey:@"mirror"]isEqualToString:@"1"]) {
                            imageView.transform = CGAffineTransformMakeScale(-1, 1);
                        }
                        
                        [imageView sd_setImageWithURL:imagUrl placeholderImage:[UIImage imageNamed:@"loading1"]];
                        
                        [createPlanImage addSubview:imageView];
                        
                        NSArray *contorlPointArray=[[NSArray alloc] initWithArray:[dict objectForKey:@"contorlPoint"]];
                        
                        UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton;
                        
                        for (int i=0;i<contorlPointArray.count;i++) {
                            
                            NSDictionary *contorlPointDict=contorlPointArray[i];
                            
                            float ctx=[[contorlPointDict objectForKey:@"centerX"] floatValue];
                            float cty=[[contorlPointDict objectForKey:@"centerY"] floatValue];
                            
                            float ctx1,cty1;
                            
                            ctx1=ctx*sacle;cty1=(cty-63)*sacle;
                            
                            UIButton *controlpoint=[[UIButton alloc] initWithFrame:CGRectMake(ctx1-5, cty1-5, 10, 10)];
                            controlpoint.hidden=YES;
                            [controlpoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
                            [createPlanImage addSubview:controlpoint];
                            if (i==0) {tempTLbutton=controlpoint;}else if (i==1){tempTRbutton=controlpoint;}else if (i==2){tempBLbutton=controlpoint;}else if (i==3)
                            {tempBRbutton=controlpoint;}
                        }
                        [imageView.layer ensureAnchorPointIsSetToZero];
                        imageView.layer.quadrilateral = AGKQuadMake(tempTLbutton.center,tempTRbutton.center,tempBRbutton.center,tempBLbutton.center);
                    }
                    
                    
                }
                
            }
            
        }

    }
    
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
    log.fromProductListVC=@"YES";
    [self presentViewController:log animated:YES completion:nil];
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
    return self.planList.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   UICollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    cell.tag=1000+indexPath.row;
    cell.layer.cornerRadius=4;
    cell.layer.masksToBounds=YES;
    
    for (UIView *sub in cell.subviews) {
        [sub removeFromSuperview];
    }
    
    NSDictionary *listDict=self.planList[indexPath.row];
    
    if (indexPath.row==0) {
        cell.backgroundColor=UIColorFromHex(0xf39800);
    }else{
        
        cell.backgroundColor=UIColorFromHex(0xffffff);
    }
    
  //  NSLog(@"cell=%@",cell);
    
    UIImageView *createPlanImage=[UIImageView new];
    [cell addSubview:createPlanImage];
    
    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(0, cell.size.height-65, cell.size.width,65)];
    if (indexPath.row==0) {
        
        title.font=[UIFont systemFontOfSize:20];
        createPlanImage.image=[UIImage imageNamed:@"add"];
        createPlanImage.sd_layout
        .leftSpaceToView(cell,68)
        .rightSpaceToView(cell,68)
        .topSpaceToView(cell,40)
        .bottomSpaceToView(cell,96);
        
    }else{
        
        title.font=[UIFont systemFontOfSize:14];
        createPlanImage=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, cell.size.width-10, cell.size.height-70)];
        createPlanImage.backgroundColor=[UIColor clearColor];
        [cell addSubview:createPlanImage];
        
        NSArray *dataArr = [listDict objectForKey:@"data"];
        
        if (dataArr.count!=0) {
            
             NSDictionary *dataDict = dataArr[0];
            //展示方案封面
            [self showImagePlan:createPlanImage withDict:dataDict];
        }else
        {
            createPlanImage.image = [UIImage imageNamed:@"folderNone"];
        }
        
    }
    
    [cell addSubview:title];
    title.textAlignment=NSTextAlignmentCenter;
    title.text=[listDict objectForKey:@"name"];
    if (indexPath.row==0) {
        title.backgroundColor=[UIColor clearColor];
        title.textColor=UIColorFromHex(0xffffff);
    }else{
        title.backgroundColor=[UIColor whiteColor];
        title.textColor=UIColorFromHex(0x666666);
    }
    UIButton *delButton;
    if (indexPath.row==0) {
        
    }else{
        
        delButton=[UIButton new];
        delButton.hidden=YES;
        delButton.tag=1000+indexPath.row;
        [cell addSubview:delButton];
        [delButton addTarget:self action:@selector(setAnimationType:) forControlEvents:UIControlEventTouchUpInside];
        [delButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [delButton setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 12, 0)];
        delButton.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, cell.size.width-44, cell.size.width-44, 0));
        
    }
    
    //add this method implementation in your  "cellForItemAtIndexPath"
    [self setCellVibrate:cell IndexPath:indexPath withButton:delButton];
    
    return cell;
}
static NSInteger tempint;
- (void)setAnimationType:(UIButton *)sender
{
    UIAlertController *alterCtr=[UIAlertController alertControllerWithTitle:@"您确定删除方案吗？" message:@"方案删除后不可恢复！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure=[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIView *subVIew in planListCollectionView.subviews) {
            
            if (subVIew.tag==sender.tag) {
                
                NSInteger index=sender.tag-1000;
                
                NSDictionary *dict=[self.planList objectAtIndex:index];
                
                HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
                
                NSDictionary *param=
                @{
                  @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
                  @"id":[dict objectForKey:@"id"]
                  };
                
                [requset postHttpDataWithParam:param url:DELPLAN  success:^(NSDictionary *dict, BOOL success) {
                
                    if ([[dict objectForKey:@"success"] boolValue]==1) {
                        
                        [YTAnimation toMiniAnimation:subVIew];
                        
                        tempint=sender.tag-1000;
                        
                        [self performSelector:@selector(delayAction) withObject:self afterDelay:1];
                        
                    }

                } fail:^(NSError *error) {
                    
                }];
            }
        }
        
    }];
    UIAlertAction *dissmiss=[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alterCtr addAction:sure];
    [alterCtr addAction:dissmiss];
    
    [self presentViewController:alterCtr animated:YES completion:^{
        
    }];
    
}
-(void)delayAction
{
    [self.planList removeObjectAtIndex:tempint];
    
    [planListCollectionView reloadData];
}
- (void)setCellVibrate:(UICollectionViewCell *)cell IndexPath:(NSIndexPath *)indexPath withButton:(UIButton *)delButon{
    if (!vibrateAniFlag) {
        if (indexPath.row!=0) {
            delButon.hidden=NO;
            [YTAnimation vibrateAnimation:cell];
          }
     }else{
         delButon.hidden=YES;
        [cell.layer removeAnimationForKey:@"shake"];
    }
}
-(void)deleteCellAtIndexpath:(NSIndexPath *)indexPath cellView:(UICollectionViewCell *)cell
{
    [planListCollectionView performBatchUpdates:^{
        
        [self.planList removeObjectAtIndex:indexPath.row];
        [planListCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [planListCollectionView reloadData];
    }];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    if ([anim valueForKey:@"animType"] ){
        
    }
    
}
-(void)Tap:(UITapGestureRecognizer*)recognizer
{
    [projectNameView.textfield resignFirstResponder];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        
        projectNameView=[[YSKJ_ProjectNameView alloc] initWithFrame:CGRectMake(0, 0, THEWIDTH, THEHEIGHT)];
        projectNameView.alpha=0.1;
        projectNameView.projectView.alpha = 0.1;
        projectNameView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        projectNameView.textfield.delegate = self;
        [projectNameView.cancle addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
        [projectNameView.sure addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:projectNameView.textfield];
        [[UIApplication sharedApplication].keyWindow addSubview:projectNameView];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Tap:)];
        [projectNameView addGestureRecognizer:doubleTapGestureRecognizer];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            projectNameView.alpha = 1;
            projectNameView.projectView.alpha = 1;
            
        }];

        
    }else{
      
        if (deleteBtnFlag==YES) {
            
            YSKJ_ProjectPlanViewController *projectPlan=[[YSKJ_ProjectPlanViewController alloc] init];
            NSMutableArray *temp = [self.planList[indexPath.row] objectForKey:@"data"];
            projectPlan.dataSource = temp;
            projectPlan.titleStr = [self.planList[indexPath.row] objectForKey:@"name"];
            [self.navigationController pushViewController:projectPlan animated:YES];
            
        }
        
    }
    
}
-(void)textChange
{
    if (projectNameView.textfield.text.length!=0) {
        projectNameView.sure.backgroundColor=UIColorFromHex(0xf39800);
        projectNameView.sure.enabled = YES;
    }else{
        projectNameView.sure.backgroundColor=UIColorFromHex(0xefefef);
        projectNameView.sure.enabled = NO;
    }
}
-(void)cancle
{
    [UIView animateWithDuration:0.3 animations:^{
    
        projectNameView.alpha = 0.1;
        projectNameView.projectView.alpha = 0.1;
        
    } completion:^(BOOL finished) {
        
        [projectNameView removeFromSuperview];
        
    }];
    
}
-(void)sure
{
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"userid":[[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"],
      @"name":projectNameView.textfield.text
      };
    
    [requset postHttpDataWithParam:param url:ADDPROJECTNAME  success:^(NSDictionary *dict, BOOL success) {
        
      //  NSLog(@"dict=%@",dict);
        
        if ([[dict objectForKey:@"success"] integerValue] == 1) {
            
            [self httpGetPlanListData];
            
            [projectNameView removeFromSuperview];
            
            YSKJ_ProjectPlanViewController *projectPlan=[[YSKJ_ProjectPlanViewController alloc] init];
            projectPlan.titleStr = projectNameView.textfield.text;
            [self.navigationController pushViewController:projectPlan animated:YES];

        }else{
            
                if ([[[dict objectForKey:@"data"] objectForKey:@"message"] isEqualToString:@"repeat name"]) {
                    
                    YSKJ_TipViewCalss *tipView=[[YSKJ_TipViewCalss alloc] init];
                    tipView.title = @"已有该项目！";
                    
            }
        }
        
    } fail:^(NSError *error) {
        
    }];

}
//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {17,8,17,8};
    return top;
}

- (void)hideAllDeleteBtn{
    
    if (!deleteBtnFlag) {
        deleteBtnFlag = YES;
        vibrateAniFlag = YES;
        [planListCollectionView reloadData];
    }
}
- (void)showAllDeleteBtn{
    
    deleteBtnFlag = NO;
    vibrateAniFlag = NO;
    [planListCollectionView reloadData];
    
}
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}


@end
