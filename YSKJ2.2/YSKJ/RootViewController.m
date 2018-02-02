
//
//  RootViewController.m
//  YanHong
//
//  Created by Mr.yang on 15/12/1.
//  Copyright © 2015年 anbaoxing. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "YSKJ_PersonCenterViewController.h"
#import "YSKJ_CheckOneViewController.h"
#import "RootViewCtrModel.h"
#import "YJKJ_ProDuctTogetherViewController.h"
#import <MJExtension/MJExtension.h>
#import "YSKJ_CheckSceneViewController.h"
#import "YSKJ_OrderViewController.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]


@interface RootViewController ()
{
    YSKJ_OrderViewController *order;
}

@end

@implementation RootViewController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.delegate=self;
    
    RootViewCtrModel *model=[[RootViewCtrModel alloc] init];
    model.title1=@"选场景";
    model.title2=@"选单品";
    model.title3=@"做搭配";
    model.title4=@"订货单";
    model.title5=@"个人中心";
    model.selectimage1=@[@"scene1",@"product1",@"together1",@"buyer1",@"private1"];
    model.selectimage2=@[@"scene2",@"product2",@"together2",@"buyer2",@"private2"];
    
    
    YSKJ_CheckSceneViewController *CheckScene=[[YSKJ_CheckSceneViewController alloc] init];
    CheckScene.title=model.title1;
    UIImage* selectScene = [UIImage imageNamed:model.selectimage2[0]];
    selectScene = [selectScene imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *CheckSceneItem=[[UITabBarItem alloc] initWithTitle:model.title1 image:[UIImage imageNamed:model.selectimage1[0]] selectedImage:selectScene];
    CheckScene.tabBarItem=CheckSceneItem;
    UINavigationController *CheckSceneNavi=[[UINavigationController alloc] initWithRootViewController:CheckScene];
    
    YSKJ_CheckOneViewController *CheckOne=[[YSKJ_CheckOneViewController alloc] init];
    CheckOne.title=model.title2;
    UIImage* selectedImage3 = [UIImage imageNamed:model.selectimage2[1]];
    selectedImage3 = [selectedImage3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *CheckOneItem=[[UITabBarItem alloc] initWithTitle:model.title2 image:[UIImage imageNamed:model.selectimage1[1]] selectedImage:selectedImage3];
    CheckOne.tabBarItem=CheckOneItem;
    UINavigationController *CheckOneNavi=[[UINavigationController alloc] initWithRootViewController:CheckOne];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize=CGSizeMake(240, 240);
    YJKJ_ProDuctTogetherViewController *Together=[[YJKJ_ProDuctTogetherViewController alloc] init];
    Together.title=model.title3;
    UIImage* selectedImage4 = [UIImage imageNamed:model.selectimage2[2]];
    selectedImage4 = [selectedImage4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *midmanItem=[[UITabBarItem alloc] initWithTitle:model.title3 image:[UIImage imageNamed:model.selectimage1[2]] selectedImage:selectedImage4];
    Together.tabBarItem=midmanItem;
    UINavigationController *PushTogetherNavi=[[UINavigationController alloc] initWithRootViewController:Together];
    
    UICollectionViewFlowLayout *orderLayout = [[UICollectionViewFlowLayout alloc]init];
    orderLayout.itemSize=CGSizeMake(240, 240);
    order=[[YSKJ_OrderViewController alloc] init];
    order.title=model.title4;
    UIImage* orderselectedImage = [UIImage imageNamed:model.selectimage2[3]];
    orderselectedImage = [orderselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *orderItem=[[UITabBarItem alloc] initWithTitle:model.title4 image:[UIImage imageNamed:model.selectimage1[3]] selectedImage:orderselectedImage];
    order.tabBarItem=orderItem;
    UINavigationController *orderTogetherNavi=[[UINavigationController alloc] initWithRootViewController:order];

    
    YSKJ_PersonCenterViewController *PersonCenter=[[YSKJ_PersonCenterViewController alloc] init];
    PersonCenter.title=model.title5;
    UIImage* selectedImage2 = [UIImage imageNamed:model.selectimage2[4]];
    selectedImage2= [selectedImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *PersonCenterItem=[[UITabBarItem alloc] initWithTitle:model.title5 image:[UIImage imageNamed:model.selectimage1[4]] selectedImage:selectedImage2];
    PersonCenter.tabBarItem=PersonCenterItem;
    UINavigationController *PersonCenterNavi=[[UINavigationController alloc] initWithRootViewController:PersonCenter];
    
    _allitem= @[CheckSceneNavi,CheckOneNavi,PushTogetherNavi,orderTogetherNavi,PersonCenterNavi];
    
    [self setViewControllers:_allitem];
    
    //设置分栏风格
     self.tabBar.barStyle=UIBarStyleDefault ;
    
    //设置选中颜色
    self.tabBar.tintColor = UIColorFromHex(0xf39800);
    

    [self setSelectedIndex:1];
    
    //self.tabBar.barTintColor=[UIColor redColor];
    
    [self getDadgValue];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(badgValueNotificationAction) name:@"badgValueNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationToProDuctCtr) name:@"notificationToProDuctCtr" object:nil];
 
}

-(void)getDadgValue
{
    //得到方案本地数组
    NSMutableArray *array1 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]];
    
    int count1 = 0;
    
    for (NSDictionary *dict in array1) {
        NSArray *arr1 = [dict objectForKey:@"data"];
        for (NSDictionary *dataDict in arr1) {
            NSLog(@"count=%@",[dataDict objectForKey:@"count"]);
            count1 += [[dataDict objectForKey:@"count"] intValue];
        }
    }
    
    //得到单品本地数组
    NSMutableArray *array2 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]];
    
    int count2=0;
    
    for (NSDictionary *dict in array2) {
        
        NSArray *arr2 = [dict objectForKey:@"data"];
        for (NSDictionary *dataDict in arr2) {
            count2 += [[dataDict objectForKey:@"count"] intValue];
        }
    }
    if (count1+count2 != 0) {
        
        if (count1+count2>=100) {
            order.tabBarItem.badgeValue = [NSString stringWithFormat:@"99+"];
        }else{
            order.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",count1+count2];
        }
        
    }else{
        order.tabBarItem.badgeValue = 0;
    }
    
}

-(void)badgValueNotificationAction
{
    [self getDadgValue];
}

-(void)notificationToProDuctCtr
{
    order.tabBarItem.badgeValue = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

@end
