//
//  YSKJ_FuritureInfoViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/14.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_FuritureInfoViewController.h"
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "YSKJ_CollModelViewController.h"
#import "HttpRequestCalss.h"
#import "YSKJ_InfoModel.h"
#import "YSKJ_LoginViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "ToolClass.h"
#import "WYScrollView.h"
#import "DatabaseManager.h"
#import <MJExtension/MJExtension.h>
#import "YSKJ_TipViewCalss.h"

#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define DETAIL @"http://"API_DOMAIN@"/store/detail"  //商品详情

#define  GETLABLE @"http://"API_DOMAIN@"/store/getfavlabel"    //获取标签

#define  DELETELABLE @"http://"API_DOMAIN@"/store/delfav"    //取消收藏，即对商品删除标签

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1];

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface YSKJ_FuritureInfoViewController ()<UITableViewDataSource,UITableViewDelegate,DatabaseManagerDelegate>
{
    UITableView *_tableView;
    
    UITableViewCell *tabCell;
    
    UIImageView *imageView;  //图片
    
    UILabel *title;  //标题
    
    UILabel *price; //价格
    
    UILabel *thelabel;
    
    UILabel *type;      //款式
    UIButton *collection;//收藏按钮
    
    CGFloat _widthRatio;     //收藏View占父View的比例
    CGFloat _widthRatio1;     //收藏View占父View的比例
    
    UILabel *attributelable;//家具属性
    
    UIWebView *htmlWebView;
    
    NSArray *arrPic;             //商品详情，图片
    
    YSKJ_InfoModel *model;
    
    BOOL isFav;                //是否收藏
    
    UIScrollView *_scrollView;
    
    DatabaseManager *databasemang;
    
    NSString *_dataString;
    
    NSDictionary *dictDetail;
    
    NSString *productId;
    
   
    
}

@end

@implementation YSKJ_FuritureInfoViewController
-(void)dissmissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title=@"选单品";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
  
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
    
    
    [self getProDuctDetail];

}

#pragma mark 获取商品详情

-(void)getProDuctDetail
{
        //得到通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificAction) name:@"loginNotification" object:nil];
        
        //得到通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelCtrNotification) name:@"modelCtrNotification" object:nil];

        HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
        NSString *userId;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
            userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        }else{
            userId=@"";
        }
    
     NSDictionary *dict=@{
                             @"id":self.proDuctId,
                             @"userid":userId,
                             };
   //  NSLog(@"dict=%@",dict);
    
        [httpRequest postHttpDataWithParam:dict url:DETAIL success:^(NSDictionary *dict, BOOL success) {
            
            _productInfo = [dict objectForKey:@"data"];
            
            [_productInfo setValue:[_productInfo objectForKey:@"price"] forKey:@"payMoney"];
            
            NSLog(@"_productInfo=%@",_productInfo);
            
            //以下key为订货单做准备
            [_productInfo setValue:@"1" forKey:@"check"];
            
            [_productInfo setValue:@"0" forKey:@"disCountNum"];
            
            [_productInfo setValue:@"0" forKey:@"disCountMoney"];
            
            [_productInfo setValue:@"0" forKey:@"payMoney"];
            
            [_productInfo setValue:@"10" forKey:@"disCount"];
            
            [_productInfo setValue:@"0" forKey:@"edit"];
            
            [_productInfo setValue:@"" forKey:@"editText"];
            
            //使用模型
            model=[YSKJ_InfoModel mj_objectWithKeyValues:[dict objectForKey:@"data"]];

            databasemang=[[DatabaseManager alloc]init];
            databasemang.delegate=self;
            [databasemang openDatabase];
            
            productId = [[dict objectForKey:@"data"] objectForKey:@"id"];
            
            [databasemang getOneProDuctDataTableName:@"yskj_proDuctTable" with:[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"] objectForKey:@"id"]] getStr:@"desc_model"];
            
            //添加tableview
            [self setupTableView];
            
            //商品详情
            arrPic= [ToolClass arrayWithJsonString:[[dict objectForKey:@"data"]  objectForKey:@"desc_img"]];
            
            
        } fail:^(NSError *error) {
        }];

}
#pragma mark 加载tableView

-(void)setupTableView
{
    _tableView=[[UITableView alloc] init];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _tableView.sd_layout
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .topSpaceToView(self.view,0)
    .bottomSpaceToView(self.view,0);
    
}
#pragma mark 加载scrollView

-(void)createNetScrollView:(UIView *)view array:(NSArray*)array
{
    /** 设置网络scrollView的Frame及所需图片*/
    WYScrollView *WYNetScrollView = [[WYScrollView alloc]initWithFrame:CGRectMake(10, 10, view.frame.size.width-20, view.frame.size.height-20) WithNetImages:array];
    
    /** 设置占位图*/
    WYNetScrollView.placeholderImage = [UIImage imageNamed:@"loading1"];
    
    /** 添加到当前View上*/
    [view addSubview:WYNetScrollView];
    
}

-(void)createLocalScrollView:(UIView *)view array:(NSArray*)array
{
    
    /** 设置本地scrollView的Frame及所需图片*/
    WYScrollView *WYLocalScrollView = [[WYScrollView alloc]initWithFrame:CGRectMake(10, 10, view.frame.size.width-20, view.frame.size.height-20) WithLocalImages:array];
    
    /** 添加到当前View上*/
    [view addSubview:WYLocalScrollView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

//得到通知
-(void)notificAction
{
    if (boolTag == YES) {
        
        boolTag = NO;
        
        YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
        tip.title = @"加入订货单成功";
        [_productInfo setValue:self.borLable.text forKey:@"count"];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"addProductToCar"] !=nil) {
            
            //得到本地数组
            NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"addProductToCar"]];
            
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
            
            BOOL containsPoint=NO;
            BOOL boolremove = NO;
            
            for (NSDictionary *dict in array) {
                
                if ([[_productInfo objectForKey:@"id"] intValue] == [[dict objectForKey:@"id"] intValue]) {
                    
                    [dict setValue:[NSString stringWithFormat:@"%ld",[[dict objectForKey:@"count"] integerValue]+[self.borLable.text intValue]] forKey:@"count"];

                    boolremove = YES;
                    
                }else{
                    
                    if (containsPoint==NO) {
                        
                        [temp addObject:_productInfo];
                        
                        containsPoint=YES;
                    }
                    
                }
                
            }
            
            if (boolremove == YES) {
                [temp removeLastObject];
            }
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:temp] forKey:@"addProductToCar"];
            
        }else{
            
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_productInfo, nil];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:@"addProductToCar"];
            
        }
        
        [[NSUserDefaults standardUserDefaults ] synchronize];
        
    }
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSString *userId;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
        userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    }else{
        userId=@"";
    }
    NSDictionary *dict=@{
                         @"id":productId,
                         @"userid":userId,
                         };
    [httpRequest postHttpDataWithParam:dict url:DETAIL success:^(NSDictionary *dict, BOOL success) {
        NSDictionary *infoDict=[dict objectForKey:@"data"];
        if ([[infoDict objectForKey:@"isFav"] isEqualToString:@"Y"]) {
            [collection setTitle:@"取消收藏" forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"Y" forKey:@"userIsFav"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            isFav=YES;
            
        }else
        {
            if (boolTag == YES) {
                
                [self performSelector:@selector(afterAction) withObject:self afterDelay:1];
            }
            
            
        }
        
    } fail:^(NSError *error) {
    }];
    
}
-(void)afterAction
{
    YSKJ_CollModelViewController *coll=[[YSKJ_CollModelViewController alloc] init];
    UINavigationController *naviModel=[[UINavigationController alloc] initWithRootViewController:coll];
    coll.shopId=productId;
    //模态风格
    naviModel.modalPresentationStyle= UIModalPresentationFormSheet;
    [self presentViewController:naviModel animated:YES completion:^{
    }];
    [collection setTitle:@"收藏" forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults]setObject:@"N" forKey:@"userIsFav"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}
-(void)modelCtrNotification
{
    isFav=YES;
    [collection setTitle:@"取消收藏" forState:UIControlStateNormal];
}

//创建html页面
-(void)createHtml
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSString *saveFileName = @"Detail.html";
    
    NSString *filepath = [path stringByAppendingPathComponent:saveFileName];
    
    NSMutableString *htmlstring=[[NSMutableString alloc]initWithFormat:@"<body>"];
    
    for (NSString *picStr in arrPic) {
        NSString *str;
        if (model.thumb_file.length>30) {
            //使用网络图片
            str=[NSString stringWithFormat:@"<img width='%f' src='%@/%@'>",THEWIDTH-30,PICURL,picStr];
        }else{
            //使用本地图片
            str=[NSString stringWithFormat:@"<img width='%f' src='file://%@/%@'>",THEWIDTH-30,path,picStr];
        }
        [htmlstring appendString:str];
    }
    [htmlstring appendString:@"</body>"];
    
    
    [htmlstring  writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    htmlWebView=[UIWebView new];
    htmlWebView.backgroundColor=[UIColor clearColor];
    htmlWebView.scrollView.delegate=self;
    
    [tabCell addSubview:htmlWebView];
    htmlWebView.sd_layout
    .leftSpaceToView(tabCell,10)
    .rightSpaceToView(tabCell,10)
    .topSpaceToView(tabCell,10)
    .bottomSpaceToView(tabCell,10);
    [htmlWebView loadHTMLString:htmlstring baseURL:nil];
    
}
-(void)collectionAction
{
    if (isFav==YES) {     //已收藏
        
        UIAlertController *alterCtr=[UIAlertController alertControllerWithTitle:@"您是否要取消收藏吗？" message:@"取消收藏后商品将不再收藏列表" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sure=[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //取消收藏
            [self deleteColl];

        }];
        
        UIAlertAction *dissmiss=[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alterCtr addAction:sure];
        [alterCtr addAction:dissmiss];
        
        [self presentViewController:alterCtr animated:YES completion:^{
            
        }];
        
        
        
    }else{
        //如果登录
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
            
            YSKJ_CollModelViewController *coll=[[YSKJ_CollModelViewController alloc] init];
            UINavigationController *naviModel=[[UINavigationController alloc] initWithRootViewController:coll];
            coll.shopId=productId;
            //模态风格
            naviModel.modalPresentationStyle= UIModalPresentationFormSheet;
            [self presentViewController:naviModel animated:YES completion:^{
            }];
            
        }else{
            YSKJ_LoginViewController *log=[[YSKJ_LoginViewController alloc] init];
            [self presentViewController:log animated:YES completion:nil];
            
        }
    }
}

static bool boolTag = NO;

-(void)addProToCar
{
    //如果登录
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
        
        YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
        tip.title = @"加入订货单成功";
        [_productInfo setValue:self.borLable.text forKey:@"count"];
        
        if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys containsObject:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]) {
            // unarchive the value here

            
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]];
            
            
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[array[0] objectForKey:@"data"]];
            
            BOOL containsPoint=NO;
            BOOL boolremove = NO;
            
            NSMutableArray *proTempArray = [[NSMutableArray alloc] initWithArray:temp];
            
            for (NSDictionary *dict in proTempArray) {
                
                if ([[_productInfo objectForKey:@"id"] intValue] == [[dict objectForKey:@"id"] intValue]) {
                    
                    [dict setValue:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"count"] integerValue]+[self.borLable.text intValue]] forKey:@"count"];
                    
                    boolremove = YES;

 
                }else{
                    
                    if (containsPoint==NO) {
                        
                        [temp addObject:_productInfo];
                        
                        containsPoint=YES;
                        
                    }
                }

            }
            
            
            if (boolremove == YES && temp.count>1) {
                [temp removeLastObject];
            }
            
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];

            NSDictionary *obj = @{
                                  @"plan_id":@"0",
                                  @"title":@"选单品",
                                  @"check":@"1",
                                  @"data": temp
                                  };
            
            [tempArray addObject:obj];
             
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            [def setObject:[NSKeyedArchiver archivedDataWithRootObject:tempArray] forKey:[NSString stringWithFormat:@"%@_proCar",[def objectForKey:@"userId"]]];
            
            [def synchronize];

             

        }else{
            
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            [def removeObjectForKey:[NSString stringWithFormat:@"%@_proCar",[def objectForKey:@"userId"]]];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_productInfo, nil];
            
            NSDictionary *obj = @{
                                   @"plan_id":@"0",
                                   @"title":@"选单品",
                                   @"check":@"1",
                                   @"data": array
                                   };
            
            [tempArray addObject:obj];

            [def setObject:[NSKeyedArchiver archivedDataWithRootObject:tempArray] forKey:[NSString stringWithFormat:@"%@_proCar",[def objectForKey:@"userId"]]];
            
            [def synchronize];

            
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
        
    }else{
        
        boolTag = YES;
        YSKJ_LoginViewController *log=[[YSKJ_LoginViewController alloc] init];
        [self presentViewController:log animated:YES completion:nil];
        
    }

}
-(void)subtractAction
{
    int  count = [self.borLable.text intValue];
    count --;
    self.borLable.text = [NSString stringWithFormat:@"%d",count];
    if (count==1) {
        self.subtract.enabled = NO;
        UIColor *titleC = UIColorFromHex(0xd8d8d8);
        [self.subtract setTitleColor:titleC forState:UIControlStateNormal];
    }
}
-(void)addCount:(UIButton*)sender
{
    int  count = [self.borLable.text intValue];
    count ++;
    self.borLable.text = [NSString stringWithFormat:@"%d",count];
    self.subtract.enabled = YES;
    UIColor *titleC = UIColorFromHex(0x333333);
    [self.subtract setTitleColor:titleC forState:UIControlStateNormal];
    
}
//取消收藏
-(void)deleteColl
{
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         @"userid":[[NSUserDefaults standardUserDefaults ] objectForKey:@"userId"],
                         @"product_id":productId
                         };
    [httpRequest postHttpDataWithParam:dict url:DELETELABLE success:^(NSDictionary *dict, BOOL success) {
        
        [collection setTitle:@"收藏" forState:UIControlStateNormal];
        isFav=NO;
        
        
    } fail:^(NSError *error) {
    
    }];
    
}

-(void)checkImageAction:(UIButton *)sender
{
    if ([self.proDuctId integerValue]!=sender.tag) {
        YSKJ_FuritureInfoViewController *fur=[[YSKJ_FuritureInfoViewController alloc] init];
        fur.proDuctId=[NSString stringWithFormat:@"%ld",(long)sender.tag];
        [self.navigationController pushViewController:fur animated:YES];
    }
}

#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",(long)indexPath.section,(long)indexPath.row];
    tabCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (tabCell == nil) {
    
        
        tabCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        tabCell.selectionStyle=UITableViewCellSelectionStyleNone;
        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        
        if (indexPath.row==0) {
            
          //  NSLog(@"other_good=%@",model.other_good);
            
            tabCell.backgroundColor=[UIColor whiteColor];
            UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(8, 8, THEWIDTH-520, THEHEIGHT-220-70)];
            UIColor *col=UIColorFromHex(0x999999);
            bgView.layer.borderColor=col.CGColor;
            bgView.layer.borderWidth=1;
            bgView.backgroundColor=[UIColor clearColor];
            [tabCell addSubview:bgView];

            NSArray *dbModel=[[NSArray alloc] init];
            if (_dataString.length!=0) {
                dbModel=[ToolClass arrayWithJsonString:_dataString];
               // NSLog(@"dbModel=%@",dbModel);
            }
            if (dbModel.count>1) {        //商品存在于数据库
                
                [self createLocalScrollView:bgView array:dbModel];

            }else{
                
                NSArray *desc_model=[ToolClass arrayWithJsonString:model.desc_model];
                NSMutableArray *tempDesc=[[NSMutableArray alloc] init];
                for (NSString *desc_modelStr in desc_model) {
                    [tempDesc addObject:[NSString stringWithFormat:@"%@/%@",PICURL,desc_modelStr]];
                }
                if (tempDesc.count>1) {
                    
                    [self createNetScrollView:bgView array:tempDesc];
                    
                }else{
                    
                    UIView *subView=[[UIView alloc] init];
                    subView.backgroundColor=[UIColor clearColor];
                    [tabCell addSubview:subView];
                    subView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(18, 18,75, 525));
                    
                    imageView=[UIImageView new];
                    imageView.backgroundColor=[UIColor clearColor];
                    [subView addSubview:imageView];
                    NSString *picStr=model.thumb_file;
                    
                    
                  //  NSURL *imagUrl;
                    if (picStr.length<25) {
                        
                        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
                        NSArray  *picArr= [picStr componentsSeparatedByString:@"/"];
                        
                        
                        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,picArr[1],picArr[2]];
                        
                        
                        NSString *fullPath = [imagePath stringByAppendingPathComponent:picArr[3]];
                        
                        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
                    
                        float imageW=THEWIDTH-548;
                        
                        
                        float scaleW;
                        if (savedImage.size.width>=savedImage.size.height) {
                            scaleW=imageW/savedImage.size.width;
                        }else{
                            scaleW=imageW/savedImage.size.height;
                        }
                        
                        imageView.sd_layout
                        .centerXEqualToView(subView)
                        .centerYEqualToView(subView)
                        .widthIs(scaleW*(savedImage.size.width))
                        .heightIs(scaleW*(savedImage.size.height));
                        
                        
                        imageView.image=savedImage;
                        

                    }else{
                        
                        [imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            
                            float imageW=THEWIDTH-548;

                            float scaleW;
                            if (image.size.width>=image.size.height) {
                                scaleW=imageW/image.size.width;
                            }else{
                                scaleW=imageW/image.size.height;
                            }
                            
                            imageView.sd_layout
                            .centerXEqualToView(subView)
                            .centerYEqualToView(subView)
                            .widthIs(scaleW*(image.size.width))
                            .heightIs(scaleW*(image.size.height));
                            
                            
                        }];
                        
                        [imageView sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"loading1"]];
                    }
                    
                }
                
            }
            title=[UILabel new];
            title.backgroundColor=[UIColor clearColor];
            title.textColor=UIColorFromHex(0x333333);
            title.font=[UIFont systemFontOfSize:20];
            title.text=model.name;
            [tabCell addSubview:title];
            title.sd_layout
            .leftSpaceToView(bgView,16)
            .topSpaceToView(tabCell,10)
            .rightSpaceToView(tabCell,10)
            .autoHeightRatio(0);
            
            price=[UILabel new];
            price.font=[UIFont systemFontOfSize:36];
            price.backgroundColor=[UIColor clearColor];
            price.textColor=UIColorFromHex(0xf32a00);
            NSString *priceStr=[NSString stringWithFormat:@"¥%@",model.price];
            if (priceStr.length>3) {
                NSInteger inde=priceStr.length-3;
                NSRange ranges = {inde,0};
                NSString *subStr = [priceStr stringByReplacingCharactersInRange:ranges withString:@","];
                price.text=subStr;
            }else{
                price.text=priceStr;
            }
            [tabCell addSubview:price];
            price.sd_layout
            .leftSpaceToView(bgView,16)
            .topSpaceToView(tabCell,68)
            .widthIs(180)
            .heightIs(36);
            
            type=[UILabel new];
            type.backgroundColor=[UIColor clearColor];
            type.text=@"款式";
            type.font=[UIFont systemFontOfSize:20];
            type.textColor=UIColorFromHex(0x666666);
            [tabCell addSubview:type];
            type.sd_layout
            .leftEqualToView(price)
            .topSpaceToView(price,10)
            .widthIs(60)
            .heightIs(40);
            
            for (int i=0; i<model.other_good.count; i++) {
                
                NSDictionary *dict=model.other_good[i];
                UIButton *bgview=[UIButton new];
                bgview.tag=[[dict objectForKey:@"id"] integerValue];
                [bgview addTarget:self action:@selector(checkImageAction:) forControlEvents:UIControlEventTouchUpInside];
                [tabCell addSubview:bgview];
                
                bgview.sd_layout
                .leftSpaceToView(type,10+44*i+20*(i-1))
                .topEqualToView(type)
                .widthIs(44)
                .heightEqualToWidth();
                UIColor *color;
                if ([[dict objectForKey:@"id"] integerValue] ==[productId integerValue]) {
                    color=UIColorFromHex(0xf39800);
                }else{
                    color=UIColorFromHex(0xd8d8d8);
                }
                bgview.layer.borderColor = color.CGColor;
                bgview.layer.borderWidth = 1;
                
                UIView *bgView=[UIView new];
                [bgview addSubview:bgView];
                bgView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(2, 2, 2, 2));
                
                UIButton *imageButton=[UIButton new];
                imageButton.tag=[[dict objectForKey:@"id"] integerValue];
                imageButton.backgroundColor=[UIColor clearColor];
                [imageButton addTarget:self action:@selector(checkImageAction:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:imageButton];
        
                [imageButton.imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[dict objectForKey:@"thumb_file"]]placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

                    float imageW=44;

                    float scaleW;
                    if (image.size.width>=image.size.height) {
                        scaleW=imageW/image.size.width;
                    }else{
                        scaleW=imageW/image.size.height;
                    }
                    imageButton.sd_layout
                    .centerXEqualToView(bgView)
                    .centerYEqualToView(bgView)
                    .widthIs(scaleW*(image.size.width))
                    .heightIs(scaleW*(image.size.height));
                   
                }];
        
                [imageButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[dict objectForKey:@"thumb_file"]] forState:UIControlStateNormal];
                
            }
            
                //attributes属性
                NSDictionary *dict= [ToolClass dictionaryWithJsonString:model.attributes];
                NSArray *arr=[dict allKeys];
            
                UILabel *pinpai=[UILabel new];
                pinpai.backgroundColor=[UIColor clearColor];
                pinpai.font=[UIFont systemFontOfSize:20];
                for (NSString * Str in arr) {
                    if ([Str isEqualToString:@"品牌"]) {
                        pinpai.text= [NSString stringWithFormat:@"%@：%@",Str,[dict objectForKey:Str]];
                    }
                }
                pinpai.textColor=UIColorFromHex(0x666666);
                [tabCell addSubview:pinpai];
                pinpai.sd_layout
                .leftEqualToView(price)
                .topSpaceToView(type,20)
                .rightSpaceToView(tabCell,10)
                .heightIs(40);
                
                NSMutableArray *attArr=[[NSMutableArray alloc] init];
                
                for (int i=0 ;i<arr.count;i++) {
                    NSString *str=arr[i];
                    NSLog(@"str=%@",str);
                    
                    if ([str isEqualToString:@"颜色"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"yanse"];
                        [attArr addObject:arrDict];
                        
                    }
                    if ([str isEqualToString:@"材质"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"caizhi"];
                        [attArr addObject:arrDict];
                    }
                    if ([str isEqualToString:@"规格"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"guige"];
                        [attArr addObject:arrDict];
                    }
                    if ([str isEqualToString:@"尺寸"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"chixun"];
                        [attArr addObject:arrDict];
                    }
                    
                    
                }
                
                UILabel *attLable;
                for (int i=0;i<attArr.count;i++) {
                    NSDictionary *theattdict=attArr[i];
                    attLable=[UILabel new];
                    attLable.font=[UIFont systemFontOfSize:20];
                    attLable.textColor=UIColorFromHex(0x666666);
                    [tabCell addSubview:attLable];
                    if ([theattdict objectForKey:@"yanse"]) {
                        attLable.text= [NSString stringWithFormat:@"颜色：%@",[theattdict objectForKey:@"yanse"]]; //为分隔符
                    }
                    
                    if ([theattdict objectForKey:@"caizhi"]) {
                        NSArray *array=[theattdict objectForKey:@"caizhi"];
                        attLable.text= [NSString stringWithFormat:@"材质：%@",[array componentsJoinedByString:@"+"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"guige"])
                    {
                        NSDictionary *dict1=[theattdict objectForKey:@"guige"];
                        NSArray *array1=[dict1 allKeys];
                        NSMutableArray *array2=[[NSMutableArray alloc] init];
                        
                        for (NSString *str in array1) {
                            NSString *value = [dict1 objectForKey:str];
                            NSString *subStr=[NSString stringWithFormat:@"%@%@",str,value];
                            [array2 addObject:subStr];
                        }
                        
                        if (array2.count==3) {
                            
                            [array2 exchangeObjectAtIndex:0 withObjectAtIndex:2];
                            [array2 exchangeObjectAtIndex:1 withObjectAtIndex:2];
                        }

                        attLable.text= [NSString stringWithFormat:@"规格：%@mm",[array2 componentsJoinedByString:@"*"]]; //为分隔符
                        
                    }
                    if ([theattdict objectForKey:@"chixun"]) {
                        attLable.text= [NSString stringWithFormat:@"尺寸：%@",[theattdict objectForKey:@"chixun"]]; //为分隔符
                        
                    }
                    attLable.sd_layout
                    .leftEqualToView(pinpai)
                    .rightSpaceToView(tabCell,10)
                    .topSpaceToView(pinpai,30*i+20*(i+1))
                    .heightIs(30);
                    
                }
                UIColor *color = UIColorFromHex(0xd8d8d8);
                self.borLable = [UILabel new];
                [tabCell addSubview:self.borLable];
                self.borLable.sd_layout
                .leftSpaceToView(bgView,73)
                .widthIs(100)
                .topSpaceToView(attLable,20)
                .heightIs(30);
                self.borLable.layer.borderColor = color.CGColor;
                self.borLable.layer.borderWidth = 1;
                self.borLable.font = [UIFont systemFontOfSize:14];
                self.borLable.textAlignment = NSTextAlignmentCenter;
                self.borLable.text = @"1";
                self.borLable.textColor = UIColorFromHex(0x333333);
            
                UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(30, 0, 1, 30)];
                line1.backgroundColor = UIColorFromHex(0xd8d8d8);
                [self.borLable addSubview:line1];
                
                UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(68, 0, 1, 30)];
                line2.backgroundColor = UIColorFromHex(0xd8d8d8);
                [self.borLable addSubview:line2];
            
                self.subtract=[UIButton new];
                [tabCell addSubview:self.subtract];
                self.subtract.sd_layout
                .leftSpaceToView(bgView,66)
                .widthIs(44)
                .heightEqualToWidth()
                .topSpaceToView(self.borLable,-37);
                self.subtract.backgroundColor=[UIColor clearColor];
                self.subtract.enabled = NO;
                [self.subtract setTitle:@"—" forState:UIControlStateNormal];
                [self.subtract addTarget:self action:@selector(subtractAction) forControlEvents:UIControlEventTouchUpInside];
                UIColor *titlec=UIColorFromHex(0xd8d8d8);
                self.subtract.titleLabel.font = [UIFont systemFontOfSize:14];
                [self.subtract setTitleColor:titlec forState:UIControlStateNormal];
            
            
                self.addProduct=[UIButton new];
                [tabCell addSubview:self.addProduct];
                self.addProduct.sd_layout
                .leftSpaceToView(bgView,66+70)
                .widthIs(44)
                .heightEqualToWidth()
                .topSpaceToView(self.borLable,-37);
                self.addProduct.backgroundColor = [UIColor clearColor];
                [self.addProduct setTitle:@"+" forState:UIControlStateNormal];
            [self.addProduct addTarget:self action:@selector(addCount:) forControlEvents:UIControlEventTouchUpInside];
                UIColor *addtitlec=UIColorFromHex(0x333333);
                self.addProduct.titleEdgeInsets = UIEdgeInsetsMake(3, 3, 5, 5);
                self.addProduct.titleLabel.font = [UIFont systemFontOfSize:26];
                [self.addProduct setTitleColor:addtitlec forState:UIControlStateNormal];
            

                collection=[UIButton new];
                collection.backgroundColor=[UIColor clearColor];
                [collection addTarget:self action:@selector(collectionAction) forControlEvents:UIControlEventTouchUpInside];
                collection.titleLabel.font = [UIFont systemFontOfSize:20];
                UIColor *collcolor=UIColorFromHex(0xf39800);
                [collection setTitleColor:collcolor forState:UIControlStateNormal];
                collection.layer.borderColor = collcolor.CGColor;
                collection.layer.borderWidth = 1;
                [tabCell addSubview:collection];
                collection.sd_layout
                .leftEqualToView(type)
                .topSpaceToView(self.borLable,20)
                .widthIs(108)
                .heightIs(44);
            
                if ([model.isFav isEqualToString:@"Y"]) {
                    [collection setTitle:@"取消收藏" forState:UIControlStateNormal];
                    [[NSUserDefaults standardUserDefaults]setObject:@"Y" forKey:@"userIsFav"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    isFav=YES;
                }else
                {
                    [collection setTitle:@"收藏" forState:UIControlStateNormal];
                    [[NSUserDefaults standardUserDefaults]setObject:@"N" forKey:@"userIsFav"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    isFav=NO;
                }
            
            UIButton *addCar=[UIButton new];
            addCar.backgroundColor=[UIColor clearColor];
            [addCar setTitle:@"加入订货单" forState:UIControlStateNormal];
            [addCar addTarget:self action:@selector(addProToCar) forControlEvents:UIControlEventTouchUpInside];
            UIColor *bgcol=UIColorFromHex(0xf39800);
            addCar.titleLabel.font = [UIFont systemFontOfSize:20];
            [addCar setTitleColor:collcolor forState:UIControlStateNormal];
            addCar.backgroundColor = bgcol;
            [addCar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [tabCell addSubview:addCar];
            addCar.sd_layout
            .leftSpaceToView(collection,16)
            .topSpaceToView(self.borLable,20)
            .widthIs(216)
            .heightIs(44);

            
        }else if (indexPath.row==1)
        {
            
              tabCell.backgroundColor=UIColorFromHex(0xefefef);
                //attributes属性
                NSDictionary *dict= [ToolClass dictionaryWithJsonString:model.attributes];
                NSLog(@"dict=%@",dict);
                NSArray *arr=[dict allKeys];
                
                UILabel *shopTitle=[UILabel new];
                shopTitle.backgroundColor=[UIColor clearColor];
                shopTitle.font=[UIFont systemFontOfSize:14];
                shopTitle.textColor=UIColorFromHex(0x666666);
                shopTitle.text=[NSString stringWithFormat:@"商品名称：%@",model.name];
                [tabCell addSubview:shopTitle];
                shopTitle.sd_layout
                .leftSpaceToView(tabCell,20)
                .rightSpaceToView(tabCell,10)
                .topSpaceToView(tabCell,0)
                .heightIs(30);
                
                UIView *attSupView=[UIView new];
                attSupView.backgroundColor=[UIColor clearColor];
                [tabCell addSubview:attSupView];
                attSupView.sd_layout
                .leftSpaceToView(tabCell,10)
                .topSpaceToView(shopTitle,-5)
                .rightSpaceToView(tabCell,10);
                
                NSMutableArray *attArr=[[NSMutableArray alloc] init];
                for (int i=0 ;i<arr.count;i++) {
                    NSString *str=arr[i];
                    NSLog(@"str=%@",str);
                    
                    if ([str isEqualToString:@"规格"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"guige"];
                        [attArr addObject:arrDict];
                    }
                    
                    if ([str isEqualToString:@"颜色"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"yanse"];
                        [attArr addObject:arrDict];
                        
                    }
                    if ([str isEqualToString:@"品类"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"pinlei"];
                        [attArr addObject:arrDict];
                        
                    }
                    if ([str isEqualToString:@"材质"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"caizhi"];
                        [attArr addObject:arrDict];
                    }
                    if ([str isEqualToString:@"品牌"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"pinpai"];
                        [attArr addObject:arrDict];
                    }
                    if ([str isEqualToString:@"空间"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"kongjian"];
                        [attArr addObject:arrDict];
                    }if ([str isEqualToString:@"风格"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"fenge"];
                        [attArr addObject:arrDict];
                    }
                    if ([str isEqualToString:@"尺寸"]) {
                        NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                        [arrDict setValue:[dict objectForKey:str] forKey:@"chixun"];
                        [attArr addObject:arrDict];
                    }
                    
                    
                }
                
                NSMutableDictionary *arrDict=[[NSMutableDictionary alloc] init];
                [arrDict setValue:model.p_no forKey:@"p_no"];
                [attArr insertObject:arrDict atIndex:0];

               // NSLog(@"attArr=%@",attArr);
                
                NSMutableArray *temp=[NSMutableArray new];
                
                for (int i = 0; i < attArr.count; i++) {
                    
                    NSDictionary *theattdict=attArr[i];
                    attributelable = [UILabel new];
                    attributelable.font=[UIFont systemFontOfSize:14];
                    attributelable.backgroundColor = [UIColor clearColor];
                    attributelable.textColor=UIColorFromHex(0x666666);
                    [attSupView addSubview:attributelable];
                    attributelable.sd_layout.autoHeightRatio(0.05);
                    
                    if ([theattdict objectForKey:@"p_no"]) {
                        attributelable.text= [NSString stringWithFormat:@"商品编号：%@",[theattdict objectForKey:@"p_no"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"yanse"]) {
                        //attributelable.text= [NSString stringWithFormat:@"颜色：%@",[theattdict objectForKey:@"yanse"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"caizhi"]) {
                        NSArray *array=[theattdict objectForKey:@"caizhi"];
                        attributelable.text= [NSString stringWithFormat:@"材质：%@",[array componentsJoinedByString:@"+"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"guige"])
                    {
                        NSDictionary *dict1=[theattdict objectForKey:@"guige"];
                        NSArray *array1=[dict1 allKeys];
                        NSMutableArray *array2=[[NSMutableArray alloc] init];
                        
                        for (NSString *str in array1) {
                            NSString *value = [dict1 objectForKey:str];
                            NSString *subStr=[NSString stringWithFormat:@"%@%@",str,value];
                            [array2 addObject:subStr];
                        }
                        if (array2.count==3) {
                            [array2 exchangeObjectAtIndex:0 withObjectAtIndex:2];
                            [array2 exchangeObjectAtIndex:1 withObjectAtIndex:2];
                        }
                        attributelable.text= [NSString stringWithFormat:@"规格：%@mm",[array2 componentsJoinedByString:@"*"]]; //为分隔符
                        
                    }
                    if ([theattdict objectForKey:@"chixun"]) {
                        attributelable.text= [NSString stringWithFormat:@"尺寸：%@",[theattdict objectForKey:@"chixun"]]; //为分隔符
                        
                    }
                    if ([theattdict objectForKey:@"pinpai"]) {
                        attributelable.text= [NSString stringWithFormat:@"品牌：%@",[theattdict objectForKey:@"pinpai"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"pinlei"]) {
                        attributelable.text= [NSString stringWithFormat:@"品类：%@",[theattdict objectForKey:@"pinlei"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"kongjian"]) {
                        NSArray *array=[theattdict objectForKey:@"kongjian"];
                        attributelable.text= [NSString stringWithFormat:@"空间：%@",[array componentsJoinedByString:@"+"]]; //为分隔符
                    }
                    if ([theattdict objectForKey:@"fenge"]) {
                        NSArray *array=[theattdict objectForKey:@"fenge"];
                        attributelable.text= [NSString stringWithFormat:@"风格：%@",[array componentsJoinedByString:@"+"]]; //为分隔符
                    }
                    
                    [temp addObject:attributelable];
                    
                    
                }
                // 关键步骤：设置类似collectionView的展示效果
                [attSupView setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:3 verticalMargin:10 horizontalMargin:10 verticalEdgeInset:10 horizontalEdgeInset:10];
    
        }else if(indexPath.row==2){
        
            
            [self createHtml];
            
        }
        
    }
    
    return tabCell;
}
#pragma  mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (_tableView.contentOffset.y>200) {
        [UIView animateWithDuration:0.8 animations:^{
            
            //隐藏
            [_tableView setContentOffset:CGPointMake(0,660) animated:NO];
            
        }];
    }
    if (htmlWebView.scrollView.contentOffset.y<-10.0) {
        
        [UIView animateWithDuration:0.8 animations:^{
            
            //隐藏
            [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
        }];
        
    }
    
}

#pragma  mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row==0) {
        
        return THEHEIGHT-220;
        
    }else if (indexPath.row==1){
        
        return 110;
        
    }else{
        return THEHEIGHT;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.001;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 0.001;
}


#pragma mark DatabaseManagerDelegate

-(void)readDataBaseData:(NSArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    
}
// 获取某个表的某一条数据
-(void)readOneDataBaseData:(NSString *)dataString withDatabaseMan:(DatabaseManager *)readDataCalss
{
    _dataString=dataString;
    
    
    
}
-(void)numData:(int)num withDatabaseMan:(DatabaseManager *)readDataCalss;
{
    
}

@end
