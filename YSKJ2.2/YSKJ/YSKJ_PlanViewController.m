//
//  YSKJ_PlanViewController.m
//  YSKJ
//
//  Created by 羊德元 on 2016/12/3.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_PlanViewController.h"
#import <SDAutoLayout/UIView+SDAutoLayout.h>
#import "HttpRequestCalss.h"
#import "ToolClass.h"
#import "YSKJ_TipViewCalss.h"
#import <MJRefresh/MJRefresh.h>
#import "YSKJ_CanvasLoading.h"

#define API_DOMAIN @"www.5164casa.com/api/saas" //正式服务器

#define ADDPROPLAN @"http://"API_DOMAIN@"/solution/add" //新增方案

#define ADDPROJECTLABLE @"http://"API_DOMAIN@"/solution/addfavlabel" //新建项目标签

#define GETPROJECTLABLE @"http://"API_DOMAIN@"/solution/getfavlabel" //得到项目标签

#define UPDATEPLAN @"http://"API_DOMAIN@"/solution/edit" //修改方案


#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface YSKJ_PlanViewController ()<UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
    UIAlertController *alert;
    
    UITextField *_projectTextField;
    
    UITableView *_tableView;
    
    UIButton *_addProjectButton;
    
    UIBarButtonItem *sureButton,*barButton;
    
    NSInteger _currentCell;
    
    UIView *corssView1, *corssView2;

}

@property (nonatomic,copy)NSMutableArray *dataSource;

@end

@implementation YSKJ_PlanViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{
                          NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor
                          };
    self.navigationController.navigationBar.titleTextAttributes =dic;
    
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    barButton=[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissmodelAction)];
    UIColor *butco=UIColorFromHex(0xf32a00);
    [barButton setTintColor:butco];
    self.navigationItem.leftBarButtonItem=barButton;
    
    sureButton=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    [sureButton setTintColor:[UIColor grayColor]];
    sureButton.enabled = NO;
    self.navigationItem.rightBarButtonItem=sureButton;
    
    NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:plan_key];
    
    _projectName = [localData objectForKey:@"projectName"];
    _planName = [localData objectForKey:@"planName"];
    
    _projectTextField=[UITextField new];
    _projectTextField.delegate=self;
    _projectTextField.placeholder = @"请输入方案名称";
    _projectTextField.text = _planName;
    _projectTextField.font = [UIFont systemFontOfSize:16];
    _projectTextField.borderStyle=UITextBorderStyleRoundedRect;
    [self.view addSubview:_projectTextField];
    _projectTextField.sd_layout
    .leftSpaceToView(self.view,16)
    .rightSpaceToView(self.view,16)
    .topSpaceToView(self.view,15)
    .heightIs(30);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:_projectTextField];
    
    _addProjectButton=[UIButton new];
    [_addProjectButton setTitle:@"+添加项目" forState:UIControlStateNormal];
    [_addProjectButton addTarget:self action:@selector(addProjectLable) forControlEvents:UIControlEventTouchUpInside];
    _addProjectButton.titleLabel.font=[UIFont systemFontOfSize:14];
    UIColor *titCol =UIColorFromHex(0xf39800);
    [_addProjectButton setTitleColor:titCol forState:UIControlStateNormal];
    _addProjectButton.sd_cornerRadius = @(2);
    [self.view addSubview:_addProjectButton];
    _addProjectButton.sd_layout
    .leftSpaceToView(self.view,16)
    .bottomSpaceToView(self.view,30)
    .widthIs(80)
    .heightIs(20);
    
    corssView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 264, THEHEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:corssView1];
    corssView2 = [[UIView alloc] initWithFrame:CGRectMake(THEWIDTH-264, 0, 264, THEHEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:corssView2];
    
    UITapGestureRecognizer *singleTapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [corssView1 addGestureRecognizer:singleTapGestureRecognizer1];
    
    
    UITapGestureRecognizer *singleTapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [corssView2 addGestureRecognizer:singleTapGestureRecognizer2];
    
    [self setUpTableView];
    
    [self getProjectLableList];
    
    //下拉刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
    
}
-(void)singleTap:(UITapGestureRecognizer*)tap
{
    [_projectTextField resignFirstResponder];
}

-(void)loadNewTopic
{
    [self getProjectLableList];
}

-(void)setUpTableView
{
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView  setSeparatorColor:UIColorFromHex(0xefefef)];
    [self.view addSubview:_tableView];
    _tableView.sd_layout
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .topSpaceToView(self.view,60)
    .bottomSpaceToView(self.view,80);
    
}

-(void)textChange
{
    if (_addProjectButton.selected == NO) {
        
        if (_projectTextField.text.length!=0) {
            
            [sureButton setTintColor:UIColorFromHex(0xf32a00)];
            sureButton.enabled=YES;
            
        }else{
            
            [sureButton setTintColor:[UIColor grayColor]];
            sureButton.enabled=NO;
            
        }

    }else{
      
        if (_projectTextField.text.length!=0) {
            UIColor *butco=UIColorFromHex(0xf32a00);
            [sureButton setTintColor:butco];
            sureButton.enabled=YES;
        }else{
            [sureButton setTintColor:[UIColor grayColor]];
            sureButton.enabled=NO;
        }

    }
}

#pragma mark getProjectList

-(void)getProjectLableList
{
    self.dataSource =nil;
    
    NSDictionary *param=@{
                          @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]
                          };
    
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    [requset postHttpDataWithParam:param url:GETPROJECTLABLE  success:^(NSDictionary *dict, BOOL success) {
        
        if ([[dict objectForKey:@"success"] integerValue] == 1) {
            
            self.dataSource = [dict objectForKey:@"data"];
            
            for (int i=0; i<self.dataSource.count; i++) {
                
                NSString *str = self.dataSource[i];
            
                if ([str isEqualToString:_projectName]) {
                    _currentCell = i;
                    
                }
            }
    
            [_tableView reloadData];
            
            if (self.dataSource.count!=0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    
                });
            }
            
            [_tableView.mj_header endRefreshing];
            
        }
        
    } fail:^(NSError *error) {
    
        [_tableView.mj_header endRefreshing];
        
    }];
    
}

-(void)returnAction
{
    _addProjectButton.selected = NO;
    
    _projectTextField.placeholder = @"请输入方案名称";
    
     _projectTextField.text = _planName;
    
    _tableView.hidden = NO;
    
    _addProjectButton.hidden = NO;
    
    barButton=[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissmodelAction)];
    UIColor *butco=UIColorFromHex(0xf32a00);
    [barButton setTintColor:butco];
    self.navigationItem.leftBarButtonItem=barButton;
    
    if (_projectTextField.text.length!=0 && _projectName.length!=0) {
        
        [sureButton setTintColor:UIColorFromHex(0xf32a00)];
        
        sureButton.enabled=YES;
    }
    
}

#pragma mark getProjectLable

-(void)addProjectLable
{
    _addProjectButton.selected = YES;
    
    _projectTextField.placeholder = @"请输入项目名称";
    
    _projectTextField.text = nil;
    
    barButton=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(returnAction)];
    UIColor *butco=UIColorFromHex(0xf32a00);
    [barButton setTintColor:butco];
    self.navigationItem.leftBarButtonItem=barButton;
    
    sureButton.enabled = NO;
    [sureButton setTintColor:[UIColor grayColor]];
    
    _tableView.hidden = YES;
    _addProjectButton.hidden = YES;

}

#pragma mark UITableViewDataSource

//让分割线左对齐
-(void)viewDidLayoutSubviews {
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
   UITableViewCell *tabCell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    
    if (tabCell == nil) {
        
        tabCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid"];
        
        tabCell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        tabCell.textLabel.font = [UIFont systemFontOfSize:16];
        
    }
    
    if ([self.dataSource[indexPath.row] isEqualToString:_projectName]) {
        
        tabCell.textLabel.textColor = UIColorFromHex(0xf39800);
        
        if (_planName.length!=0) {
            
            [sureButton setTintColor:UIColorFromHex(0xf32a00)];
             sureButton.enabled=YES;
            
        }else{
            
            [sureButton setTintColor:[UIColor grayColor]];
             sureButton.enabled = NO;

        }
        
    }else{
        
        tabCell.textLabel.textColor = UIColorFromHex(0x666666);
    }
    
    tabCell.textLabel.text = self.dataSource[indexPath.row];
    
    return tabCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray *visibleIndexPaths = [tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *ip in visibleIndexPaths) {
        
        UITableViewCell *clearCell = [tableView cellForRowAtIndexPath:ip];
        clearCell.textLabel.textColor = UIColorFromHex(0x666666);
        
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.textColor = UIColorFromHex(0xf39800);
    
    _projectName = cell.textLabel.text;
    
    if (_projectName.length!=0 && _projectTextField.text.length !=0) {
        
        [sureButton setTintColor:UIColorFromHex(0xf32a00)];
        sureButton.enabled=YES;
        
    }else{
        
        [sureButton setTintColor:[UIColor grayColor]];
        sureButton.enabled = NO;
        
    }
    
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 25)];
    view.backgroundColor = UIColorFromHex(0xefefef);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 4.5, view.frame.size.width-16, 16)];
    title.text = @"请选择一个项目";
    title.textColor = UIColorFromHex(0x999999);
    title.font = [UIFont systemFontOfSize:12];
    [view addSubview:title];
    return view;
}

-(void)dismissmodelAction
{
    [corssView1 removeFromSuperview];
    [corssView2 removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationDissMiss" object:self userInfo:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)commitAction
{
    if (_addProjectButton.selected == YES) {
        
        [sureButton setTintColor:[UIColor grayColor]];
        sureButton.enabled = NO;
        
        NSDictionary *param=@{
                              @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                              @"name":_projectTextField.text
                              };
        
        HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
        
        [requset postHttpDataWithParam:param url:ADDPROJECTLABLE  success:^(NSDictionary *dict, BOOL success) {
            
            if ([[dict objectForKey:@"success"] integerValue] == 1) {
                
                _projectName = _projectTextField.text;
                
                _projectTextField.text = _planName;
                
                [self getProjectLableList];
                
                [self alterView:@"添加成功！"];
                
                _tableView.hidden = NO;
                _addProjectButton.hidden = NO;
        
                [sureButton setTintColor:UIColorFromHex(0xf32a00)];
                sureButton.enabled=YES;
                
                barButton=[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissmodelAction)];
                UIColor *butco=UIColorFromHex(0xf32a00);
                [barButton setTintColor:butco];
                self.navigationItem.leftBarButtonItem=barButton;
                
                _addProjectButton.selected = NO;

            }else{
                
                if ([[[dict objectForKey:@"data"] objectForKey:@"message"] isEqualToString:@"repeat name"]) {
                    
                    [self alterView:@"项目已存在！"];
                    
                    [sureButton setTintColor:UIColorFromHex(0xf32a00)];
                    sureButton.enabled=YES;
                    
                }
            }

        } fail:^(NSError *error) {
            
        }];
    
    }else{
        
        [YSKJ_CanvasLoading showNotificationViewWithText:@"正在保存..." loadType:loading];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            _addProjectButton.backgroundColor=UIColorFromHex(0xf39800);
            _addProjectButton.enabled=YES;
            [corssView1 removeFromSuperview];
            [corssView2 removeFromSuperview];
            
        }];
        
        NSString *plan_key =  [NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
        
        NSDictionary *localData = [[NSUserDefaults standardUserDefaults] objectForKey:plan_key];
        
        
        if (self.operatingMode == YES) {
    
            NSDictionary *param=@{
                                  @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                  @"data_value":[localData objectForKey:@"data_value"],
                                  @"sname":_projectTextField.text,
                                  @"position":_projectName
                                  };
            
            HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
            
            [requset postHttpDataWithParam:param url:ADDPROPLAN  success:^(NSDictionary *dict, BOOL success) {
                
                if ([[dict objectForKey:@"success"] boolValue]==1) {

                    //这里改动了type，添加方案id，保存成功时回到修改状态
                    NSDictionary *planData=@{
                                             @"data_value":[localData objectForKey:@"data_value"],
                                             @"type":@"open",
                                             @"planId":[[dict objectForKey:@"data"] objectForKey:@"id"],
                                             @"projectName":[localData objectForKey:@"projectName"],
                                             @"planName":[localData objectForKey:@"planName"]
                                             };
                    
                    [[NSUserDefaults standardUserDefaults] setObject:planData forKey:[NSString stringWithFormat:@"%@_plan",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];

                }
                
                NSDictionary *userInfo =@{
                                          @"planName":_projectTextField.text,
                                          @"proJectName":_projectName
                                          };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationPlanList" object:self userInfo:userInfo];
                
            } fail:^(NSError *error) {

            }];
            
            
        }else{
            
            NSDictionary *param=@{
                                  @"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                  @"id":[localData objectForKey:@"planId"],
                                  @"data_value":[localData objectForKey:@"data_value"],
                                  @"sname":_projectTextField.text,
                                  @"position":_projectName
                                  };
            
            HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
            
            [requset postHttpDataWithParam:param url:UPDATEPLAN success:^(NSDictionary *dict, BOOL success) {
                
                if ([[dict objectForKey:@"success"] boolValue]==1) {
             
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                        [corssView1 removeFromSuperview];
                        [corssView2 removeFromSuperview];
                        
                    }];
                    
                    NSDictionary *userInfo =@{
                                              @"planName":_projectTextField.text,
                                              @"proJectName":_projectName
                                              };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationPlanList" object:self userInfo:userInfo];
    
                }
                
            } fail:^(NSError *error) {
                
            }];
            
            
        }

        
    }
    
    
}



#pragma mark UITextFieldDelegate

//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_projectTextField resignFirstResponder];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    
    if (_projectTextField==textField) {
        if (string.length == 0)
            return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 16) {
            return NO;
        }
    }
    
    return YES;
}

#pragma 弹出提示

-(void)alterView:(NSString *)string
{
    YSKJ_TipViewCalss *tipView=[[YSKJ_TipViewCalss alloc] init];
    tipView.title = string;
    
}


@end
