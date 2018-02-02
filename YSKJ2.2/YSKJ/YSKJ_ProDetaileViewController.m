//
//  YSKJ_ProDetaileViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/12/30.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_ProDetaileViewController.h"
#import "HttpRequestCalss.h"
#import <SDAutoLayout/UIView+SDAutoLayout.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ToolClass.h"
#import "DatabaseManager.h"
#import "YSKJ_OrderViewController.h"
#import "YSKJ_TipViewCalss.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define DETAIL @"http://"API_DOMAIN@"/store/detail"  //商品详情

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface YSKJ_ProDetaileViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,DatabaseManagerDelegate>
{
    NSMutableArray  *proDetailCount;
    UICollectionView *proDetailCell;
    NSMutableArray *tempArray;
    
    UIView *sumView;
    
    NSString *textStr;
    
    NSString *totalPriceStr;
}
@property (nonatomic,retain)NSArray *dbDataArr;  //数据库数组;

@end

@implementation YSKJ_ProDetaileViewController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title=@"方案清单";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    
    self.navigationController.view.backgroundColor=UIColorFromHex(0xffffff);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    
    [self setUpColletionView];            //加载商品清单colletionView
    
    [self sumView];                       //加载总计视图
    
    proDetailCount=[[NSMutableArray alloc] init];
    
    NSLog(@"self.proArr=%@",self.proArr);
    
    for (int i=0; i<self.proArr.count; i++) {
        
        NSDictionary *proDict=self.proArr[i];
        
        HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
        NSDictionary *prodict=@{
                             @"id":[proDict objectForKey:@"pro_id"],
                             @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]
                             };
        
        [httpRequest postHttpDataWithParam:prodict url:DETAIL success:^(NSDictionary *dict, BOOL success) {
            
            [proDetailCount addObject:dict];
     
            if (proDetailCount.count==self.proArr.count) {
                
                [self dataSoure];  //得到数据源
                
            }

        } fail:^(NSError *error) {
            
        
        }];
    
    }
    
    
}
static float ProTotalPrice=0;

-(void)dataSoure
{
    //取出统计的id数组
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.proArr) {
        [array addObject:[dict objectForKey:@"pro_id"]];
    }
    
    NSDictionary *dic=[self statisticsArrayCountDict:array];   //统计数组相同元素的个数

    
    NSArray *allKeys=[dic allKeys];
    
    NSMutableDictionary *theDict=[[NSMutableDictionary alloc] init];
    
    for (NSString *key in allKeys) {
        
        for (NSDictionary *proDict in proDetailCount) {
            
            NSDictionary *prosubDict=[proDict objectForKey:@"data"];
            
            if ([[prosubDict objectForKey:@"id"] integerValue]==[key integerValue]) {
                
                [theDict setValue:prosubDict forKey:key];
            }
        }
    }
    
    
    NSArray *allValue=[theDict allValues];
    
    tempArray=[[NSMutableArray alloc] init];
    
    for (NSDictionary *valueDict in allValue) {
        
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([[NSString stringWithFormat:@"%@",key] isEqualToString:[NSString stringWithFormat:@"%@",[valueDict objectForKey:@"id"]]]) {
                
                [valueDict setValue:obj forKey:@"count"];
                
                float price=[[valueDict objectForKey:@"price"] floatValue];
       
                int count=[obj intValue];
         
                float totalPrice=price*count;
            
                [valueDict setValue:[NSString stringWithFormat:@"%f",totalPrice] forKey:@"totalPrice"];
                
                //以下key为订货单做准备
                [valueDict setValue:@"1" forKey:@"check"];

                [valueDict setValue:@"0" forKey:@"disCountNum"];
                
                [valueDict setValue:@"0" forKey:@"disCountMoney"];
                
                [valueDict setValue:@"0" forKey:@"payMoney"];
                
                [valueDict setValue:@"10" forKey:@"disCount"];
                
                [valueDict setValue:@"0" forKey:@"edit"];
                
                [valueDict setValue:@"" forKey:@"editText"];

                [tempArray addObject:valueDict];
                
            }
        }];
        
    }
   
    DatabaseManager *databasemang=[[DatabaseManager alloc] init];
    databasemang.delegate=self;
    [databasemang openDatabase];
    [databasemang getAllDataWithTableName:@"yskj_proDuctTable" from:@"pro"];
    
    for (int i=0; i<tempArray.count; i++)
    {
        NSDictionary *lineDict=tempArray[i];

        float totalPrice=[[lineDict objectForKey:@"totalPrice"] floatValue];
        ProTotalPrice=ProTotalPrice+totalPrice;
        for (int j=0; j<self.dbDataArr.count; j++)
        {
            NSDictionary *dbDict=self.dbDataArr[j];
            
            if ([[NSString stringWithFormat:@"%@",[lineDict objectForKey:@"id"]] isEqualToString:[dbDict objectForKey:@"product_id"]]) {
                
                [lineDict setValue:[dbDict objectForKey:@"thumb_file"] forKey:@"thumb_file"];        //数据替换，用数据库的覆盖请求到的字段

            }
            
        }
        
    }

    
    UILabel *sumLable=[sumView viewWithTag:1000];
   
    textStr=[NSString stringWithFormat:@"已有%lu种商品，共%lu件",(unsigned long)tempArray.count,(unsigned long)self.proArr.count];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textStr]; // 改变特定范围颜色大小要用的
    //种类的属性
    if (tempArray.count>=10) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(2,2)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(2,2)];
    }else {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(2,1)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(2,1)];
    }
    
    if (self.proArr.count>=10) {
        //数量的属性
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(textStr.length-3,2)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(textStr.length-3,2)];
    }else{
        //数量的属性
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(textStr.length-2,1)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(textStr.length-2,1)];
    }
    sumLable.attributedText=attributedString;
    
    UILabel *totalPrice=[sumView viewWithTag:1001];
    UIColor *attColor=UIColorFromHex(0xf32a00);
    NSString *totalStr=[NSString stringWithFormat:@"总计  ¥%0.2f",ProTotalPrice];
    totalPriceStr = [NSString stringWithFormat:@"¥%0.2f",ProTotalPrice];
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:totalStr]; // 改变特定范围颜色大小要用的
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:attColor range:NSMakeRange(2,totalStr.length-2)];
    [attributedString1 addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:24.0]
                             range:NSMakeRange(2, totalStr.length-2)];
    totalPrice.attributedText=attributedString1;
    
    [proDetailCell reloadData];            //刷新界面
 
}

-(UIImage *)getImageForView:(UIView *)view
{
    //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(400, 200), NO, 0);
    
    //renderInContext呈现接受者及其子范围到指定的上下文
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //返回一个基于当前图形上下文的图片
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //移除栈顶的基于当前位图的图形上下文
    UIGraphicsEndImageContext();
    
    //然后将该图片保存到图片图
    // UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    return viewImage;

}
-(void)dissmissAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        ProTotalPrice=0;
        [sumView removeFromSuperview];
    }];
}
#pragma mark 统计数组相同元素的个数（使用数组筛选计算）
-(NSDictionary *)statisticsArrayCountDict:(NSMutableArray *)array
{
    //统计数组相同元素的个数
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    //需要统计的数组
    NSSet *set = [NSSet setWithArray:array];
    
    for (NSString *setstring in set) {
        
        //需要去掉的元素数组
        NSMutableArray *filteredArray = [[NSMutableArray alloc]initWithObjects:setstring, nil];
        
        NSMutableArray *dataArray = array;
        
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",filteredArray];
        //过滤数组
        NSArray * reslutFilteredArray = [dataArray filteredArrayUsingPredicate:filterPredicate];
        
        int number = (int)(dataArray.count-reslutFilteredArray.count);
        
        [dic setObject:[NSString stringWithFormat:@"%d",number] forKey:setstring];
    }
    
    return dic;

}

#pragma mark 商品总计视图

-(void)sumView
{
    sumView=[[UIView alloc] initWithFrame:CGRectMake(0, THEHEIGHT-119, THEWIDTH, 55)];
    sumView.backgroundColor=UIColorFromHex(0xffffff);
  //  sumView.backgroundColor=[UIColor greenColor];
    [self.view addSubview:sumView];
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, -1, THEWIDTH, 1)];
    lineView.backgroundColor=UIColorFromHex(0xd8d8d8);
    [sumView addSubview:lineView];
    
    
    UILabel *sumProLable=[UILabel new];
    sumProLable.textAlignment=NSTextAlignmentLeft;
    sumProLable.tag=1000;
    sumProLable.backgroundColor=[UIColor clearColor];
    sumProLable.font=[UIFont systemFontOfSize:14];
    [sumView addSubview:sumProLable];
    sumProLable.sd_layout
    .leftSpaceToView(sumView,16)
    .heightIs(24)
    .topSpaceToView(sumView,15)
    .rightSpaceToView(sumView,760);
    
    if (self.proArr.count==0) {
        
        textStr=[NSString stringWithFormat:@"已有%lu种商品，共%lu件",(unsigned long)tempArray.count,(unsigned long)self.proArr.count];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textStr]; // 改变特定范围颜色大小要用的
        //种类的属性
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(2,1)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(2,1)];
        //数量的属性
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(textStr.length-2,1)];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:24.0]
                                 range:NSMakeRange(textStr.length-2,1)];
        
        sumProLable.attributedText=attributedString;
    }
    
    UILabel *sumPriceLable=[UILabel new];
    sumPriceLable.textAlignment=NSTextAlignmentLeft;
    sumPriceLable.tag=1001;
    UIColor *attColor=UIColorFromHex(0xf32a00);
    sumPriceLable.font=[UIFont systemFontOfSize:14];
    NSString *totailPrice=[NSString stringWithFormat:@"总计   %@",@"¥0.00"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:totailPrice]; // 改变特定范围颜色大小要用的
    [attributedString addAttribute:NSForegroundColorAttributeName value:attColor range:NSMakeRange(2,totailPrice.length-2)];
    [attributedString addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:24.0]
                          range:NSMakeRange(2, totailPrice.length-2)];
    sumPriceLable.attributedText=attributedString;
    
    [sumView addSubview:sumPriceLable];
    sumPriceLable.sd_layout
    .leftSpaceToView(sumView,476)
    .heightIs(24)
    .topSpaceToView(sumView,15)
    .rightSpaceToView(sumView,353);
    
    UIButton *exportProList=[UIButton new];
    exportProList.backgroundColor=UIColorFromHex(0xf95f3e);
    exportProList.titleLabel.font=[UIFont systemFontOfSize:14];
    [exportProList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exportProList addTarget:self action:@selector(addCar) forControlEvents:UIControlEventTouchUpInside];
    [exportProList setTitle:@"加入订货单" forState:UIControlStateNormal];
    [sumView addSubview:exportProList];
    exportProList.sd_layout
    .widthIs(140)
    .heightIs(40)
    .topSpaceToView(sumView,7)
    .rightSpaceToView(sumView,38);
    
}

-(void)addCar
{
    
    NSString *_planId,*_planName;
    
    NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:plan_key];
    
    if ([[localData objectForKey:@"planId"]  isEqual: @""]) {
        
        _planId = @"000";
        
        _planName = @"新建";
        
    }
    else{
        
        _planId = [localData objectForKey:@"planId"];
    
        _planName = [localData objectForKey:@"planName"] ;
    
    }
    
    if (tempArray.count!=0) {
        
        if ([[NSUserDefaults standardUserDefaults ]objectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]]) {
            
            //得到本地数组
            NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]];
            
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:array];
            
            BOOL containsPoint=NO;
            BOOL boolremove = NO;
    
            for (NSDictionary *dict in tempArr) {
                
                if ([[dict objectForKey:@"plan_id"] integerValue] == [_planId integerValue]) {
                    
                    NSMutableArray *temp1 = [dict objectForKey:@"data"];
                    
                    NSMutableArray *temp3 = [[NSMutableArray alloc] initWithArray:tempArray];
                    
                    for (int i=0; i<temp1.count; i++) {
                        
                        NSDictionary *dicti = temp1[i];
                        
                        for (int j=0; j<tempArray.count; j++) {
                            
                            NSDictionary *dictj = tempArray[j];
                            
                            if ([[dicti objectForKey:@"id"]intValue] == [[dictj objectForKey:@"id"] intValue]) {
                                
                                [dicti setValue:[NSString stringWithFormat:@"%d",[[dicti objectForKey:@"count"] intValue]+[[dictj objectForKey:@"count"] intValue]] forKey:@"count"];
                                
                            }
  
                        }
                        
                    }
                    
                    for (int i=0; i<temp3.count; i++) {
                        
                        NSDictionary *dicti = temp3[i];
                        
                        for (int j=0; j<temp1.count; j++) {
                            
                            NSDictionary *dictj = temp1[j];
                            
                            if ([[dicti objectForKey:@"id"]intValue] == [[dictj objectForKey:@"id"] intValue]) {
                                
                                [temp3 removeObject:dicti];
                                i--;
                                
                            }
                        }
                        
                    }
                    [temp1 addObjectsFromArray:temp3];
                    
                    boolremove = YES;
                    
                    
                }else{

                    if (containsPoint==NO) {
                        
                        NSDictionary *dict = @{
                                               @"title":_planName,
                                               @"plan_id":_planId,
                                               @"check":@"1",
                                               @"data":tempArray
                                               };
                        [array addObject:dict];

                        
                        containsPoint=YES;
                    }
                    
                }
                
            }
            
            
            if (boolremove == YES && array.count>1) {
                
                [array removeLastObject];
                
            }
        
 
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
            
        }else{
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSDictionary *dict = @{
                                   @"title":_planName,
                                   @"plan_id":_planId,
                                   @"check":@"1",
                                   @"data":tempArray
                                   };
            [array addObject:dict];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
        
    }
    
    
    YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
    tip.title = @"加入订货单成功";
    
}


-(void)aferAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark 加载清单ColletionView

-(void)setUpColletionView
{
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小为100*100
    layout.itemSize = CGSizeMake(THEWIDTH, 120);
    //创建collectionView 通过一个布局策略layout来创建
    proDetailCell = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, THEWIDTH, THEHEIGHT-120) collectionViewLayout:layout];
    proDetailCell.backgroundColor=UIColorFromHex(0xd7dee4);
    //代理设置
    proDetailCell.delegate=self;
    proDetailCell.dataSource=self;
    //注册item类型 这里使用系统的类型
    [proDetailCell registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:proDetailCell];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark DatabaseManagerDelegate

-(void)readDataBaseData:(NSArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    //NSLog(@"array.count=%lu",(unsigned long)array.count);
    
    self.dbDataArr=array;
    
}
-(void)numData:(int)num withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return tempArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   UICollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    cell.backgroundColor=UIColorFromHex(0xffffff);

    for (UIView *subview in cell.subviews) {
        if (subview) {
            [subview removeFromSuperview];
        }
    }
    
    UIView *bgView=[UIView new];
    bgView.backgroundColor=[UIColor clearColor];
    [cell addSubview:bgView];
    bgView.sd_layout
    .topSpaceToView(cell,20)
    .leftSpaceToView(cell,18)
    .heightIs(80)
    .widthEqualToHeight();
    
    UIImageView *imagebg=[[UIImageView alloc] init];
    imagebg.image=[UIImage imageNamed:@"loading1"];
    imagebg.backgroundColor=[UIColor clearColor];
    [bgView addSubview:imagebg];
    imagebg.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    UIImageView *imageView=[[UIImageView alloc] init];
    imageView.backgroundColor=[UIColor clearColor];
    [imagebg addSubview:imageView];
    NSDictionary *dict=tempArray[indexPath.row];
    NSString *picStr=[dict objectForKey:@"thumb_file"];
    NSURL *imagUrl;
    
    if (picStr.length<25) {
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSArray  *picArr= [picStr componentsSeparatedByString:@"/"];
        
        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,picArr[1],picArr[2]];
        
        NSString *fullPath = [imagePath stringByAppendingPathComponent:picArr[3]];
        
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        if (savedImage!=nil) {
            imagebg.image=nil;
        }
        float imageW=80;
        float scaleW;
        if (savedImage.size.width>=savedImage.size.height) {
            scaleW=imageW/savedImage.size.width;
        }else{
            scaleW=imageW/savedImage.size.height;
        }
        
        imageView.sd_layout
        .centerXEqualToView(imagebg)
        .centerYEqualToView(imagebg)
        .widthIs(scaleW*(savedImage.size.width))
        .heightIs(scaleW*(savedImage.size.height));
        
        imageView.image=savedImage;

    }else{
        
        imagUrl=[[NSURL alloc] initWithString:picStr];
        //获取网络图片的Size
        [imageView sd_setImageWithPreviousCachedImageWithURL:imagUrl placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            imagebg.image=nil;
            
            float imageW=80;
            float scaleW;
            if (image.size.width>=image.size.height) {
                scaleW=imageW/image.size.width;
            }else{
                scaleW=imageW/image.size.height;
            }
            
            imageView.sd_layout
            .centerXEqualToView(imagebg)
            .centerYEqualToView(imagebg)
            .widthIs(scaleW*(image.size.width))
            .heightIs(scaleW*(image.size.height));
        
        }];
        
        [imageView sd_setImageWithURL:imagUrl placeholderImage:[UIImage imageNamed:@"loading1"]];
        
    }
    UILabel *titleLable=[[UILabel alloc] init];
    titleLable.textColor=UIColorFromHex(0x666666);
    titleLable.font=[UIFont systemFontOfSize:12];
    titleLable.text=[dict objectForKey:@"name"];
    [cell addSubview:titleLable];
    titleLable.sd_layout
    .leftSpaceToView(bgView,14)
    .topEqualToView(bgView)
    .rightSpaceToView(cell,574)
    .heightIs(30);
    
    UILabel *countLable=[[UILabel alloc] init];
    countLable.textColor=UIColorFromHex(0x666666);
    countLable.font=[UIFont systemFontOfSize:14];
    countLable.textAlignment=NSTextAlignmentLeft;
    countLable.text=[NSString stringWithFormat:@"X%@",[dict objectForKey:@"count"]];
    [cell addSubview:countLable];
    countLable.sd_layout
    .leftSpaceToView(cell,776)
    .topSpaceToView(cell,50)
    .widthIs(60)
    .heightIs(20);
    
    UILabel *priceLable=[[UILabel alloc] init];
    priceLable.textColor=UIColorFromHex(0xf32a00);
    priceLable.font=[UIFont systemFontOfSize:14];
    priceLable.textAlignment=NSTextAlignmentLeft;
    priceLable.text=[NSString stringWithFormat:@"¥%0.2f",[[dict objectForKey:@"price"] floatValue]];
    [cell addSubview:priceLable];
    priceLable.sd_layout
    .leftSpaceToView(cell,520)
    .topSpaceToView(cell,50)
    .widthIs(80)
    .heightIs(20);
    
    UILabel *materialLable=[[UILabel alloc] init];
    materialLable.textColor=UIColorFromHex(0x999999);
    materialLable.font=[UIFont systemFontOfSize:12];
    materialLable.textAlignment=NSTextAlignmentLeft;
    [cell addSubview:materialLable];
    materialLable.sd_layout
    .leftEqualToView(titleLable)
    .topSpaceToView(cell,50)
    .widthIs(400)
    .heightIs(12);
    
    UILabel *color = [[UILabel alloc] init];
    color.textColor=UIColorFromHex(0x999999);
    color.font=[UIFont systemFontOfSize:12];
    color.textAlignment=NSTextAlignmentLeft;
    [cell addSubview:color];
    color.sd_layout
    .leftEqualToView(titleLable)
    .topSpaceToView(materialLable,10)
    .widthIs(400)
    .heightIs(12);
    
    NSDictionary *arrdict=[ToolClass dictionaryWithJsonString:[dict objectForKey:@"attributes"]];
    //  NSLog(@"arrdict=%@",arrdict);
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
            materialLable.text= [NSString stringWithFormat:@"规格：%@mm",[tempArr componentsJoinedByString:@"*"]]; //为分隔符
        }
        if ([key isEqualToString:@"颜色"]) {
            color.text = [NSString stringWithFormat:@"颜色：%@",[arrdict valueForKey:key]];
        }
    }

    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {0,0,0,0};
    return top;
}
//横向间距
- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}
//纵向间距
- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.000001f;
}

@end
