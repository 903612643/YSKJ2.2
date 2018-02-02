//
//  YSKJ_CollModelViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/17.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//
#import "YSKJ_CollModelViewController.h"
#import "YSKJ_LabelLayout.h"
#import "YSKJ_CollectionViewCell.h"
#import "UIView+SDAutoLayout.h"
#import "HttpRequestCalss.h"
#import "YSKJ_LoginViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YSKJ_TipViewCalss.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define ADDLABLE @"http://"API_DOMAIN@"/store/addfavlabel" //新建标签

#define SUREADD @"http://"API_DOMAIN@"/store/addfav" //对商品添加标签

#define  GETLABLE @"http://"API_DOMAIN@"/store/getfavlabel"    //获取标签

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1];

@interface YSKJ_CollModelViewController() <UICollectionViewDataSource,UICollectionViewDelegate,YSKJ_LabelLayoutDelegate,UITextFieldDelegate>
{
    YSKJ_CollectionViewCell* cell;
    
    NSMutableArray *categoryArray;
    
    NSMutableArray *lableArray;
    
    NSMutableArray  *sureArray;    //选择标签数组
    
    UIView *alert;
}

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) UITextField* textField;
@property (nonatomic, weak) UILabel* lable;

@end

@implementation YSKJ_CollModelViewController

static NSString* identifier = @"cell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title=@"收藏";
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    
    //得到标签
    [self httpGetLable];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor=[UIColor colorWithRed:251/255.0 green:250/255.0 blue:249/255.0 alpha:1.0];
    
     categoryArray = [[NSMutableArray alloc] init];
    
     sureArray = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissmodelAction:)];
    UIColor *butco=UIColorFromHex(0xf32a00);
    [barButton setTintColor:butco];
    self.navigationItem.leftBarButtonItem=barButton;
    
    UIBarButtonItem *sureButton=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureAction)];
    [sureButton setTintColor:butco];
    self.navigationItem.rightBarButtonItem=sureButton;
    
    YSKJ_LabelLayout* layout = [[YSKJ_LabelLayout alloc] init];
    layout.panding = 14;
    layout.rowPanding = 14;
    layout.delegate = self;
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10,50, self.view.size.width/2, 510) collectionViewLayout:layout];
    collectionView.scrollEnabled = NO;
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerNib:[UINib nibWithNibName:@"YSKJ_CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:collectionView];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag=1000;
    button.enabled=NO;
    [button addTarget:self action:@selector(addLable) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=UIColorFromHex(0xefefef);
    button.layer.cornerRadius=4;
    button.layer.masksToBounds=YES;
    [self.view addSubview:button];
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.sd_layout
    .rightSpaceToView(self.view,10)
    .topSpaceToView(self.view,10)
    .widthIs(60)
    .heightIs(30);
    
    UITextField* textField = [[UITextField alloc] init];
    self.textField = textField;
    self.textField.delegate=self;
    textField.placeholder = @"请输入标签";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textField];
    textField.sd_layout
    .leftSpaceToView(self.view,10)
    .topSpaceToView(self.view,10)
    .heightIs(30)
    .rightSpaceToView(button,10);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:self.textField];
    
}

-(void)textChange
{
    if (self.textField.text.length!=0) {
        UIButton *addButton=[self.view viewWithTag:1000];
        addButton.backgroundColor=UIColorFromHex(0xf39800);
        addButton.enabled=YES;
    }else{
        UIButton *addButton=[self.view viewWithTag:1000];
        addButton.backgroundColor=UIColorFromHex(0xefefef);
        addButton.enabled=NO;
    }
}

#pragma mark 获取标签httpGetLable
-(void)httpGetLable
{
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         
                         @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                         
                         };
    [httpRequest postHttpDataWithParam:dict url:GETLABLE success:^(NSDictionary *dict, BOOL success) {
        
        self.titles=[dict objectForKey:@"data"];
        [self.collectionView reloadData];
        
    } fail:^(NSError *error) {
        
    }];
}
#pragma mark Action

-(void)sureAction
{
    [sureArray removeAllObjects];
    
    for (UIView *subView in [self.collectionView subviews]) {
        for (UIView *thesubView in [subView subviews]) {
            for (UILabel *lable in [thesubView subviews]) {
                
                if (lable.textColor==[UIColor orangeColor]) {
                    
                    [sureArray addObject:lable.text];
                }
            }
        }
    }

    if (sureArray.count!=0) {            //有选
    
        //数组转为json格式
        NSData *data=[NSJSONSerialization dataWithJSONObject:sureArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonlabel=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
        NSDictionary *dict=@{
                             @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                             @"label":jsonlabel,
                             @"product_id":self.shopId
                             };
        
        [httpRequest postHttpDataWithParam:dict url:SUREADD success:^(NSDictionary *dict, BOOL success) {
            
            if ([[dict objectForKey:@"success"] boolValue]==1) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"modelCtrNotification" object:self userInfo:nil];
                
                [self performSelector:@selector(dissmissAction) withObject:self afterDelay:0.8];
                
            }
   
        } fail:^(NSError *error) {
            
        }];

    }else{
        [self showAlertWithText:@"请选择标签"];
    }
    
}
-(void)dissmissAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)dismissmodelAction:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)addLable{
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]!=nil) {
        
            [categoryArray removeAllObjects];
            [categoryArray addObject:self.textField.text];
            
            for (unsigned i = 0; i < categoryArray.count; i++){
                
                if ([self.titles containsObject:[categoryArray objectAtIndex:i]] == NO){
                    
                    [self addLableHttpData];     //新建标签
                    
                    [self.titles addObject:[categoryArray objectAtIndex:i]];
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.titles.count-1  inSection:0]]];
                    
                }else{
                    
                    // 开启动画
                    [UIView animateWithDuration:1 animations:^{
    
                        [self.textField resignFirstResponder];

                    }];
                    
                    [self showAlertWithText:@"标签已存在"];

                }
            }
      }

}

-(void)addLableHttpData
{
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                         @"name":self.textField.text,
                         };
    [httpRequest postHttpDataWithParam:dict url:ADDLABLE success:^(NSDictionary *dict, BOOL success) {
        
        [self showAlertWithText:@"添加成功"];
        
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark alert
- (void)showAlertWithText:(NSString *)text
{
    YSKJ_TipViewCalss *tipView=[[YSKJ_TipViewCalss alloc] init];
    tipView.title = text;
    
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
    return self.titles.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.label.tag=2000+indexPath.row;
   
    cell.label.layer.cornerRadius=12;
    cell.label.layer.masksToBounds=YES;
    UIColor *lablCo=UIColorFromHex(0x666666);
    cell.label.layer.borderColor = lablCo.CGColor;
    cell.label.layer.borderWidth = 1;
    cell.label.textColor=lablCo;
    
    
    [cell setTitle:self.titles[indexPath.item]];
    
    return cell;
}

static bool ischeck=NO;
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    for (UIView *subView in [self.collectionView subviews]) {
        for (UIView *thesubView in [subView subviews]) {
            for (UILabel *lable in [thesubView subviews]) {
                //NSLog(@"lable=%@",lable);
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
 
}
#pragma mark UITextFieldDelegate

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
   
    if (string.length == 0)
        return YES;
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength > 30) {
        return NO;
    }
    
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
