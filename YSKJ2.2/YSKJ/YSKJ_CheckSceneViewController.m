//
//  YSKJ_CheckSceneViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/6/19.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_CheckSceneViewController.h"
#import "YSKJ_CheckSceneCollectionViewCell.h"
#import "HttpRequestCalss.h"
#import "YSKJ_CheckSceneModel.h"
#import <MJExtension/MJExtension.h>
#import "ToolClass.h"
#import "YSKJ_ScenePlanViewController.h"
#import "AnimatedGif.h"
#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height


#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器
#define GETFORMATLIST @"http://"API_DOMAIN@"/solution/getformatlist"   //场景列表
#define SPACEBGURL @"http://octjlpudx.qnssl.com/"      //空间背景绝对路径

@interface YSKJ_CheckSceneViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    
}

@property (nonatomic, strong) UICollectionView* collect;

@property (nonatomic, retain) NSMutableArray *dataSource;

@end

@implementation YSKJ_CheckSceneViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title=@"选场景";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    [self setUpCollectionView];
    
    [self getFormatlist];
    
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
    [_collect registerClass:[YSKJ_CheckSceneCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    
    [self.view addSubview:_collect];
}

-(void)getFormatlist
{
    
    UIImageView *imageView = [UIImageView new];
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]];
    imageView= [AnimatedGif getAnimationForGifAtUrl:localUrl];
    [self.view addSubview:imageView];
    imageView.sd_layout
    .centerXEqualToView(imageView.superview)
    .centerYEqualToView(imageView.superview)
    .widthIs(48)
    .heightEqualToWidth();
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    
    [httpRequest postHttpDataWithParam:nil url:GETFORMATLIST success:^(NSDictionary *dict, BOOL success) {
        
        [imageView removeFromSuperview];
        
        self.dataSource = [dict objectForKey:@"data"];
        
        [self.collect reloadData];
        
        
    }fail:^(NSError *error) {
        
        [imageView removeFromSuperview];
        
    }];

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
    
    YSKJ_CheckSceneCollectionViewCell *checkCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    checkCell.layer.cornerRadius = 4;
    checkCell.layer.masksToBounds = YES;
    
    checkCell.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    
    NSArray *dataArr = [dict objectForKey:@"data"];
    
    
    if (dataArr.count!=0) {
        
        NSDictionary *dataDict = dataArr[0];
        
        NSDictionary *dict_info=[ToolClass dictionaryWithJsonString:[dataDict objectForKey:@"data_info"]];
        
        checkCell.url = [NSString stringWithFormat:@"%@/%@",SPACEBGURL,[dict_info objectForKey:@"url"]];
    
    }else{
        
        checkCell.url = @"";
        
    }

    checkCell.title = [dict objectForKey:@"name"];
    
    checkCell.button.tag = 1000+indexPath.row;
    
    [checkCell.button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    
    return checkCell;
}
-(void)action:(UIButton *)sender
{
    for (int i=0; i<self.dataSource.count; i++) {
        if (i==sender.tag-1000) {
            
            NSDictionary *dict = self.dataSource[i];
            
            NSMutableArray *dataArr = [dict objectForKey:@"data"];
            
            YSKJ_ScenePlanViewController *plan = [[YSKJ_ScenePlanViewController alloc] init];
            plan.title = [dict objectForKey:@"name"];
            
            plan.dataSource = dataArr;
            
            [self.navigationController pushViewController:plan animated:YES];

        }
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {16,8,16,8};
    return top;
}




@end
