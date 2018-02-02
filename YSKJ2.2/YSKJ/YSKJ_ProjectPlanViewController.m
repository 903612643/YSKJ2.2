//
//  YSKJ_CheckSceneViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/6/19.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_ProjectPlanViewController.h"
#import "YSKJ_ProjectPlanCollectionViewCell.h"
#import "HttpRequestCalss.h"
#import "YSKJ_CheckSceneModel.h"
#import <MJExtension/MJExtension.h>
#import "ToolClass.h"
#import "YTAnimation.h"
#import <SDAutoLayout/SDAutoLayout.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "YSKJ_CanvasViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "YSKJ_CanvasLoading.h"

#import <AGGeometryKit/AGGeometryKit.h>

#import <POPAnimatableProperty+AGGeometryKit.h>

#import <pop/POP.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器
#define GETFORMATLIST @"http://"API_DOMAIN@"/solution/getformatlist"   //场景列表
#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径
#define DELPLAN @"http://"API_DOMAIN@"/solution/del" //删除方案

#define GETPLANLIST @"http://"API_DOMAIN@"/solution/getmylist" //得到方案列表

#define SPACEBG @"http://"API_DOMAIN@"/solution/getbglist"

@interface YSKJ_ProjectPlanViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *_listArray;
    
    UIButton *buttonItem1;
    UIButton *buttontitle1;
    
    BOOL deleteBtnFlag;
    BOOL vibrateAniFlag;
    
    float sacle;
    
    NSMutableArray *_spaceArr;
    
}

@property (nonatomic, strong) UICollectionView* collect;

@property (nonatomic, strong) UIView *corssView;

@end

@implementation YSKJ_ProjectPlanViewController


-(void)viewWillAppear:(BOOL)animated
{
    
    if ([[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]!=nil) {
        buttontitle1.hidden=NO;
        buttonItem1.hidden=NO;
        buttontitle1.enabled=YES;
        buttonItem1.enabled=YES;
    }else{
        buttontitle1.hidden=YES;
        buttonItem1.hidden=YES;
        buttontitle1.enabled=NO;
        buttonItem1.enabled=NO;
    }
   
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
    
    buttonItem1=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [buttonItem1 addTarget:self action:@selector(isshow) forControlEvents:UIControlEventTouchUpInside];
    [buttonItem1 setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    UIBarButtonItem *riItem = [[UIBarButtonItem alloc]initWithCustomView:buttonItem1];
    UIBarButtonItem *riButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 0;
    
    buttontitle1=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,30, 40)];
    UIColor *titlecol=UIColorFromHex(0x999999);
    buttontitle1.titleLabel.font=[UIFont systemFontOfSize:14];
    [buttontitle1 setTitleColor:titlecol forState:UIControlStateNormal];
    [buttontitle1 addTarget:self action:@selector(isshow) forControlEvents:UIControlEventTouchUpInside];
    [buttontitle1 setTitle:@"编辑" forState:UIControlStateNormal];
    UIBarButtonItem *titeitem = [[UIBarButtonItem alloc]initWithCustomView:buttontitle1];
    self.navigationItem.rightBarButtonItems=@[titeitem,riButtonItem,riItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActionSuccess:) name:@"notificationToProDuctCtr" object:nil];

    
    self.title = self.titleStr;
    
    _listArray = [[NSMutableArray alloc] init];
    
    [self setUpCollectionView];
    
    deleteBtnFlag = YES;
    vibrateAniFlag = YES;
    
    _spaceArr = [[NSMutableArray alloc] init];
    
    [self httpGetPlanListData];
    
    
    //修改方案封面得到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFaceNotification) name:@"updateFaceNotification" object:nil];
    
}

#pragma mark 方案保存或修改成功得到通知

-(void)updateFaceNotification
{
    [self httpGetPlanListData];
}

#pragma mark 获取方案列表

-(void)httpGetPlanListData
{
    [_listArray removeAllObjects];
    [_collect reloadData];
    
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    UIImageView *imageView = [UIImageView new];
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]];
    imageView= [AnimatedGif getAnimationForGifAtUrl:localUrl];
    [self.view addSubview:imageView];
    imageView.sd_layout
    .centerXEqualToView(imageView.superview)
    .centerYEqualToView(imageView.superview)
    .widthIs(48)
    .heightEqualToWidth();
    
    NSDictionary *param=
  @{@"userid":[[NSUserDefaults standardUserDefaults ]objectForKey:@"userId"]};
    
    [requset postHttpDataWithParam:param url:GETPLANLIST  success:^(NSDictionary *dict, BOOL success) {
        
        NSArray *data = [[NSArray alloc] initWithArray:[dict objectForKey:@"data"]];
        
        [imageView removeFromSuperview];
        
        for (NSDictionary *dict in data) {
            
            if ([[dict objectForKey:@"name"] isEqualToString:self.title]) {
                
                NSDictionary *adddict=@{@"name":@"新建空间方案"};
                [_listArray addObject:adddict];
                [_listArray addObjectsFromArray:[dict objectForKey:@"data"]];
                
            }
        }
        
        [_collect  reloadData];
        
    }fail:^(NSError *error) {
        
        [imageView removeFromSuperview];
        
    }];
    
}

-(void)loginActionSuccess:(NSNotification *)notfication
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

static bool isedit=NO;
-(void)isshow
{
    if (isedit==NO) {
        isedit=YES;
        [buttontitle1 setTitle:@"完成" forState:UIControlStateNormal];
        [buttonItem1 setImage:[UIImage imageNamed:@"edit1"] forState:UIControlStateNormal];
        UIColor *titlcolor=UIColorFromHex(0xf39800);
        [buttontitle1 setTitleColor:titlcolor forState:UIControlStateNormal];
        [self showAllDeleteBtn];
    }else{
        isedit=NO;
        [buttontitle1 setTitle:@"编辑" forState:UIControlStateNormal];
        [buttonItem1 setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        UIColor *titlcolor=UIColorFromHex(0x999999);
        [buttontitle1 setTitleColor:titlcolor forState:UIControlStateNormal];
        [self hideAllDeleteBtn];
        
    }
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
    [_collect registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    
    [self.view addSubview:_collect];
    
 //   [_listArray removeAllObjects];
    
//    NSLog(@"_listArr=%lu  ,dataSoure=%lu",(unsigned long)_listArray.count,(unsigned long)self.dataSource.count);
//    
//    if (self.dataSource != nil) {
//        NSDictionary *adddict=@{@"name":@"新建空间方案"};
//        [_listArray addObject:adddict];
//        [_listArray addObjectsFromArray:self.dataSource];
//    }
    
    
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
    
    return _listArray.count;
    
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
    
    NSDictionary *listDict=_listArray[indexPath.row];
    
    if (indexPath.row==0) {
        cell.backgroundColor=UIColorFromHex(0xf39800);
    }else{
        
        cell.backgroundColor=UIColorFromHex(0xffffff);
    }

    UIImageView *createPlanImage=[UIImageView new];
    [cell addSubview:createPlanImage];
    
    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-65, cell.frame.size.width,65)];
    
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
        [cell addSubview:createPlanImage];
        
        //展示方案封面
        [self showImagePlan:createPlanImage withDict:listDict];
    
        
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
 
    [self setCellVibrate:cell IndexPath:indexPath withButton:delButton];
    
    return cell;
    
}
static NSInteger tempint;
- (void)setAnimationType:(UIButton *)sender
{
    UIAlertController *alterCtr=[UIAlertController alertControllerWithTitle:@"您确定删除方案吗？" message:@"方案删除后不可恢复！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure=[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (UIView *subVIew in _collect.subviews) {
            
            if (subVIew.tag==sender.tag) {
                
                NSInteger index=sender.tag-1000;
                
                NSDictionary *dict=[_listArray objectAtIndex:index];
                
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
    
    if (tempint<_listArray.count) {
        
        [_listArray removeObjectAtIndex:tempint];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationPlanList" object:self userInfo:nil];
    
    [_collect reloadData];
    
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        
            YSKJ_CanvasViewController *newCanvas=[[YSKJ_CanvasViewController alloc] init];
            newCanvas.projectName = self.titleStr;
        
            NSDictionary *planData=@{
                                     @"data_value":@"",
                                     @"type":@"create",
                                     @"planId":@"",
                                     @"projectName":self.titleStr,
                                     @"planName":@""
                                     };
        
            [[NSUserDefaults standardUserDefaults] setObject:planData forKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
        
            [[NSUserDefaults standardUserDefaults] synchronize];
        
            [self presentViewController:newCanvas animated:YES completion:nil];
    
    }else{
        
        if (deleteBtnFlag==YES) {
            
            if (_listArray.count!=0) {
                
                YSKJ_CanvasViewController *oldCanvas=[[YSKJ_CanvasViewController alloc] init];
                
                NSDictionary *dict=[ToolClass dictionaryWithJsonString:[_listArray[indexPath.row] objectForKey:@"data_value"]];
                
                NSDictionary *planData=@{
                                         @"data_value":[_listArray[indexPath.row] objectForKey:@"data_value"],
                                         @"type":@"open",
                                         @"planId":[_listArray[indexPath.row] objectForKey:@"id"],
                                         @"projectName":self.titleStr,
                                         @"planName":[_listArray[indexPath.row] objectForKey:@"name"]
                                         };
                
                [[NSUserDefaults standardUserDefaults] setObject:planData forKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSArray *dataArray=[dict objectForKey:@"data"];
                
                if (dataArray.count !=0) {
                    
                    NSDictionary *firstDict = dataArray[0];
                    
                    NSString *url = [firstDict objectForKey:@"url"];
                    
                    if (url.length > 27) {
                        
                        NSString *urlsubStr = [url substringFromIndex:27];
                        
                        for (NSDictionary *dict in _spaceArr) {
                            
                            if ([[dict objectForKey:@"url"] isEqualToString:urlsubStr]) {
                                
                                oldCanvas.bgId = [dict objectForKey:@"id"];
                     
                            }
                        }
                        
                    }
 
                }

                oldCanvas.projectName = self.titleStr;
                oldCanvas.planName = [_listArray[indexPath.row] objectForKey:@"name"];
                
                self.corssView = [[UIView alloc] initWithFrame:_collect.bounds];
                self.corssView.backgroundColor = [UIColor whiteColor];
                [_collect addSubview:self.corssView];
                
                
                [self presentViewController:oldCanvas animated:YES completion:nil];
                
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
            
           _spaceArr = [dict objectForKey:@"data"];
    
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

- (void)hideAllDeleteBtn{
    
    if (!deleteBtnFlag) {
        deleteBtnFlag = YES;
        vibrateAniFlag = YES;
        [_collect reloadData];
    }
}
- (void)showAllDeleteBtn{
    
    deleteBtnFlag = NO;
    vibrateAniFlag = NO;
    [_collect reloadData];
    
}

//展示方案封面
-(void)showImagePlan:(UIImageView*)createPlanImage withDict:(NSDictionary *)listDict
{
    NSDictionary *dict_info=[ToolClass dictionaryWithJsonString:[listDict  objectForKey:@"data_info"]];
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


@end
