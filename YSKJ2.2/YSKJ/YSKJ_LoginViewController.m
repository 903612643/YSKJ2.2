//
//  YSKJ_LoginViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/16.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "YSKJ_LoginViewController.h"
#import "UIView+SDAutoLayout.h"
#import "HttpRequestCalss.h"
#import "YSKJ_CollModelViewController.h"
#import "UIImageView+WebCache.h"
#import "AnimatedGif.h"
#import "ToolClass.h"
#import "YSKJ_ForGetPasswordViewController.h"
#import "YSKJ_TipViewCalss.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器


#define LOGINURL  @"http://"API_DOMAIN@"/login/index"

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@interface YSKJ_LoginViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *compayImage;
    UITextField *usernameText;
    UITextField *passwordText;
    UIButton *loginButton;
    
    UILabel *usernameErrorTip;
    UILabel *passwordErrorTip;
    
    UITableView *_tableView;
    UITableViewCell *tabCell;
    
    UIImageView *_loadImage;
    
    UIView *_alertLoading;
    
    UIButton *dissmiss;
    
    UIView *alert;
}


@end

@implementation YSKJ_LoginViewController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=[UIColor colorWithRed:251/255.0 green:250/255.0 blue:249/255.0 alpha:1.0];
        
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupTableView];

}
-(void)dismissHomeAction
{
    UIImageView *dissmissImage=[tabCell viewWithTag:1000];
    dissmissImage.tag=1000;
    dissmissImage.image=[UIImage imageNamed:@"close1"];
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.05f];
}
-(void)delayMethod
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
-(void)setupTableView
{
    _tableView=[[UITableView alloc] init];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _tableView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

-(void)loginAcito
{
   // [self httpLogin];
    
    if (usernameText.text.length!=0) {
        
        if ([ToolClass phone:usernameText.text]==YES) {        //手机号码格式正确
            
            if (passwordText.text.length!=0) {
                
                if (passwordText.text.length>5) {             //密码小于6位
                    
                    [self httpLogin];
                    
                }else{
                    
                    [self showAlertWithText:@"密码不能小于6位"];
   
                }

            }else{
                
                [self showAlertWithText:@"密码不能为空"];
                
            }
            
        }else{                                             //手机格式不正确
            
            [self showAlertWithText:@"手机格式不正确"];
        
        }

    }else{
        [self showAlertWithText:@"手机号码不能为空"];

    }
    
}
-(void)forgetpasswordAction
{
    YSKJ_ForGetPasswordViewController *forget=[[YSKJ_ForGetPasswordViewController alloc] init];
    forget.title = @"忘记密码";
    [self presentViewController:forget animated:YES completion:nil];
}

- (void)showAlertWithText:(NSString *)text
{
    YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
    tip.title = text;
}
-(void)dissActionremo
{
    [alert removeFromSuperview];
}
- (void)showAlertImage
{
    _alertLoading = [UIView new];
    [[UIApplication sharedApplication].keyWindow addSubview:_alertLoading];
    _alertLoading.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
    _alertLoading.sd_layout
    .centerXEqualToView(_alertLoading.superview)
    .centerYEqualToView(_alertLoading.superview)
    .widthIs(THEWIDTH)
    .heightIs(THEHEIGHT - 60);

    UIImageView *imageView = [UIImageView new];
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]];
    imageView= [AnimatedGif getAnimationForGifAtUrl:localUrl];
    [_alertLoading addSubview:imageView];

    imageView.sd_layout
    .centerXEqualToView(imageView.superview)
    .centerYEqualToView(imageView.superview)
    .widthIs(48)
    .heightEqualToWidth();
    
    
}

-(void)httpLogin
{
    [self showAlertImage];
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    NSDictionary *dict=@{
                         @"mobile":usernameText.text,
                         @"password":passwordText.text
//                         @"mobile":@"13976486922",
//                         @"password":@"WOAINI123456"
                         };
    [httpRequest postHttpDataWithParam:dict url:LOGINURL  success:^(NSDictionary *dict, BOOL success) {
        
        NSDictionary *dataDict=[dict objectForKey:@"data"];
        
        NSLog(@"dict=%@",dict);
        
        if ([[dict objectForKey:@"success"] boolValue]==1) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_alertLoading removeFromSuperview];
            });
            
            NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
            [userdefault setValue:[dataDict objectForKey:@"id"] forKey:@"userId"];
            [userdefault setValue:[dataDict objectForKey:@"name"] forKey:@"username"];
            [userdefault setValue:usernameText.text forKey:@"phone"];
            [userdefault setValue:passwordText.text forKey:@"password"];
            if ([[dataDict objectForKey:@"logo"] isEqualToString:@""]) {
                [userdefault setValue:@"" forKey:@"userlogo"];
            }else{
                [userdefault setValue:[dataDict objectForKey:@"logo"] forKey:@"userlogo"];
            }
            
            [userdefault synchronize];
            
            if (self.fromProductListVC==nil) {
                self.fromProductListVC=@"0";
            }
            
            NSDictionary *dict=@{@"fromProVC":self.fromProductListVC};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginNotification" object:nil userInfo:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationToProDuctCtr" object:nil userInfo:dict];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"badgValueNotification" object:self userInfo:nil];
            
            [self dismissHomeAction];
            
            
        }else if([[dict objectForKey:@"success"] boolValue]==0){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [_alertLoading removeFromSuperview];
                
            });
            if ([dataDict objectForKey:@"message"]) {
                
                if ([[dataDict objectForKey:@"message"] isEqualToString:@"user password error"]) {
                    
                    [self performSelector:@selector(showAlertAction) withObject:self afterDelay:1];
                    
                }else if ([[dataDict objectForKey:@"message"] isEqualToString:@"user no exist"]){
                    [self performSelector:@selector(showAlertAction1) withObject:self afterDelay:1];
                }
            }else{
                [self performSelector:@selector(showAlertAction) withObject:self afterDelay:1];
            }
            
            
        }
        
    } fail:^(NSError *error) {
        
        [self showAlertWithText:@"当前网络不可用"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_alertLoading removeFromSuperview];
            
        });
    }];

}
-(void)showAlertAction
{
    [self showAlertWithText:@"用户名或密码错误"];
}
-(void)showAlertAction1
{
    [self showAlertWithText:@"用户未注册"];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",(long)indexPath.section,(long)indexPath.row];
    tabCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (tabCell == nil) {
        
        tabCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        tabCell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        if (indexPath.row==0) {
            
            UIImageView *loginBg=[UIImageView new];
            loginBg.backgroundColor=[UIColor clearColor];
            loginBg.image=[UIImage imageNamed:@"background"];
            [tabCell addSubview:loginBg];
            loginBg.sd_layout
            .leftSpaceToView(tabCell,0)
            .rightSpaceToView(tabCell,0)
            .topSpaceToView(tabCell,0)
            .bottomSpaceToView(tabCell,0);
            
            UIImageView *dissmissImage=[UIImageView new];
            dissmissImage.tag=1000;
            dissmissImage.image=[UIImage imageNamed:@"close"];
            [tabCell addSubview:dissmissImage];
            dissmissImage.sd_layout
            .rightSpaceToView(tabCell,30)
            .topSpaceToView(tabCell,30)
            .widthIs(25)
            .heightIs(25);
            
            dissmiss=[UIButton buttonWithType:UIButtonTypeCustom];
            [dissmiss addTarget:self action:@selector(dismissHomeAction) forControlEvents: UIControlEventTouchUpInside ];
            [tabCell addSubview:dissmiss];
            dissmiss.sd_layout
            .rightSpaceToView(tabCell,10)
            .topSpaceToView(tabCell,20)
            .widthIs(65)
            .heightIs(65);

            usernameText=[UITextField new];
            usernameText.delegate=self;
            usernameText.placeholder=@"请输入手机号码";
            usernameText.clearButtonMode=UITextFieldViewModeWhileEditing;
            usernameText.borderStyle=UITextBorderStyleRoundedRect;
            usernameText.keyboardType=UIKeyboardTypeNumberPad;
            [tabCell addSubview:usernameText];
            usernameText.sd_layout
            .leftSpaceToView(tabCell,344)
            .rightSpaceToView(tabCell,344)
            .topSpaceToView(tabCell,278)
            .heightIs(44);
            
            passwordText=[UITextField new];
            passwordText.delegate=self;
            passwordText.placeholder=@"请输入密码";
            passwordText.clearButtonMode=UITextFieldViewModeWhileEditing;
            passwordText.borderStyle=UITextBorderStyleRoundedRect;
            passwordText.secureTextEntry = YES;
            [tabCell addSubview:passwordText];
            passwordText.sd_layout
            .leftEqualToView(usernameText)
            .rightEqualToView(usernameText)
            .topSpaceToView(usernameText,24)
            .heightIs(44);
            
            loginButton=[UIButton new];
            loginButton.sd_cornerRadius = @(4);
            [loginButton setTitle:@"登录" forState:UIControlStateNormal];
            loginButton.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
            loginButton.enabled=NO;
            [loginButton addTarget:self action:@selector(loginAcito) forControlEvents:UIControlEventTouchUpInside];
            [tabCell addSubview:loginButton];
            loginButton.sd_layout
            .leftEqualToView(usernameText)
            .rightEqualToView(usernameText)
            .topSpaceToView(passwordText,48)
            .heightIs(44);
            
            compayImage=[UIImageView new];
            compayImage.backgroundColor=[UIColor clearColor];
            compayImage.image=[UIImage imageNamed:@"logo"];
            
            [tabCell addSubview:compayImage];
            compayImage.sd_layout
            .leftSpaceToView(tabCell,439)
            .rightSpaceToView(tabCell,422)
            .topSpaceToView(tabCell,93)
            .bottomSpaceToView(usernameText,125);
            
            UIButton *forgetpasswordButton=[UIButton new];
            [forgetpasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
            forgetpasswordButton.backgroundColor=[UIColor clearColor];
            forgetpasswordButton.titleLabel.font=[UIFont systemFontOfSize:14];
           [forgetpasswordButton addTarget:self action:@selector(forgetpasswordAction) forControlEvents:UIControlEventTouchUpInside];
            forgetpasswordButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
            UIColor *titleCol=UIColorFromHex(0x666666);
            [forgetpasswordButton setTitleColor:titleCol   forState:UIControlStateNormal];
            [forgetpasswordButton setTitleEdgeInsets:UIEdgeInsetsMake(15, 2, 15, 2)];
            [tabCell addSubview:forgetpasswordButton];
            forgetpasswordButton.sd_layout
            .leftSpaceToView(loginButton,-78)
            .widthIs(80)
            .heightIs(44)
            .topSpaceToView(loginButton,15);
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:usernameText];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:passwordText];
            
        }
    }
    
    return tabCell;
    
}
-(void)textChange
{
    if (usernameText.text.length!=0 && passwordText.text.length!=0) {
        loginButton.backgroundColor=UIColorFromHex(0xf39800);
        loginButton.enabled=YES;
    }else{
        loginButton.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        loginButton.enabled=NO;
    }
    
}
#pragma  mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return THEHEIGHT+180;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    [self.view endEditing:YES];
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

#pragma mark UITextFieldDelegate

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    
    if (usernameText==textField) {
        if (string.length == 0)
            return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 11) {
            return NO;
        }
    }
    if (passwordText==textField) {
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


@end
