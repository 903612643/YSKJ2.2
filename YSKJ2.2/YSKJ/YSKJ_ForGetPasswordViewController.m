//
//  YSKJ_ForGetPasswordViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/1/13.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_ForGetPasswordViewController.h"
#import "UIView+SDAutoLayout.h"
#import "HttpRequestCalss.h"
#import "UIImageView+WebCache.h"
#import "AnimatedGif.h"
#import "ToolClass.h"

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define GETCODE @"http://"API_DOMAIN@"/user/getphonecode" //获取验证码
#define VERIFYCODE @"http://"API_DOMAIN@"/user/checkphonecode"   //验证验证码
#define FORGETPASSWORD @"http://"API_DOMAIN@"/user/editpassword"  //忘记密码-修改密码

@interface YSKJ_ForGetPasswordViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *compayImage;
    UITextField *usernameText;
    UITextField *verificationCode;
    UIButton *setPassWord;
    UIButton *getCodeButton;
    
    UITextField *newPassword;
    UIButton *sureSetButton;
    
    UILabel *usernameErrorTip;
    UILabel *passwordErrorTip;
    
    UITableView *_tableView;
    UITableViewCell *tabCell;
    
    UIImageView *_loadImage;
    
    UIView *_alertLoading;
    
    UIButton *dissmiss;
    
    UIView *alert;
    
    NSTimer *theTimer;
}


@end

@implementation YSKJ_ForGetPasswordViewController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    setSuccess=NO;
    [_tableView reloadData];
}
-(void)viewDidDisappear:(BOOL)animated
{
    
    [theTimer invalidate];
    waitTimes=60;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
static bool setSuccess=NO;
-(void)setPassWordAction
{
        if ([ToolClass phone:usernameText.text]==YES) {        //手机号码格式正确
            [self showAlertImage];
            
                HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
                NSDictionary *dict=@{
                                     @"mobile":usernameText.text,
                                     @"phonecode":verificationCode.text
                                     };
                [httpRequest postHttpDataWithParam:dict url:VERIFYCODE  success:^(NSDictionary *dict, BOOL success) {
                    NSLog(@"dict=%@",dict);
                    
                    [_alertLoading removeFromSuperview];
                    
                    if ([[[dict objectForKey:@"data"] objectForKey:@"message"] isEqualToString:@"phonecode error"]) {
                        [self showAlertWithText:@"验证码错误"];
                        
                    }else{
                        setSuccess=YES;
                        [_tableView reloadData];
                    }
    
                } fail:^(NSError *error) {
                    [self showAlertWithText:@"网络错误"];
                    [_alertLoading removeFromSuperview];
                }];

            }else{                                             //手机格式不正确
            
            [self showAlertWithText:@"手机格式不正确"];
            
        }
    
}
-(void)getCodeAction
{
    if (usernameText.text.length!=0) {
        if ([ToolClass phone:usernameText.text]==YES) {        //手机号码格式正确
            
            //开启定时器倒数60秒
            getCodeButton.enabled=YES;
            getCodeButton.backgroundColor=UIColorFromHex(0xdfdfdf);
            theTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitCodeActionTimer:) userInfo:nil repeats:YES];
            
            HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
            NSDictionary *dict=@{
                                 @"mobile":usernameText.text,
                                 };
            [httpRequest postHttpDataWithParam:dict url:GETCODE  success:^(NSDictionary *dict, BOOL success) {
                
                NSLog(@"dict=%@",dict);

            } fail:^(NSError *error) {
                
            }];

            
        }else{                                             //手机格式不正确
            
            [self showAlertWithText:@"手机格式不正确"];
            
        }

    }else{
        [self showAlertWithText:@"手机号码不能为空"];
    }
}
static int waitTimes=60;
-(void)waitCodeActionTimer:(NSTimer*)timer
{
    waitTimes--;
    if (waitTimes!=-1) {
        [getCodeButton setTitle:[NSString stringWithFormat:@"请等待%d秒",waitTimes] forState:UIControlStateNormal];
    }else{
        waitTimes=60;
        [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        getCodeButton.backgroundColor=[UIColor whiteColor];
        getCodeButton.enabled=YES;
        [theTimer invalidate];
    }
    
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
            usernameText.font=[UIFont systemFontOfSize:14];
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
            
            verificationCode=[UITextField new];
            verificationCode.delegate=self;
            verificationCode.placeholder=@"请输入验证码";
            verificationCode.font=[UIFont systemFontOfSize:14];
            verificationCode.textAlignment=NSTextAlignmentCenter;
            verificationCode.clearButtonMode=UITextFieldViewModeWhileEditing;
            verificationCode.borderStyle=UITextBorderStyleRoundedRect;
            [tabCell addSubview:verificationCode];
            verificationCode.sd_layout
            .leftEqualToView(usernameText)
            .widthIs(120)
            .topSpaceToView(usernameText,24)
            .heightIs(44);
            
            getCodeButton=[UIButton new];
            getCodeButton.sd_cornerRadius = @(4);
            getCodeButton.enabled=YES;
            UIColor *titleCol=UIColorFromHex(0x999999);
            [getCodeButton setTitleColor:titleCol forState:UIControlStateNormal];
            [getCodeButton setTitle:@"获取短信验证码" forState:UIControlStateNormal];
            getCodeButton.titleLabel.font=[UIFont systemFontOfSize:14];
            getCodeButton.backgroundColor=UIColorFromHex(0xffffff);
            [getCodeButton addTarget:self action:@selector(getCodeAction) forControlEvents:UIControlEventTouchUpInside];
            [tabCell addSubview:getCodeButton];
            getCodeButton.sd_layout
            .rightEqualToView(usernameText)
            .widthIs(120)
            .topSpaceToView(usernameText,24)
            .heightIs(44);
            
            setPassWord=[UIButton new];
            setPassWord.sd_cornerRadius = @(4);
            [setPassWord setTitle:@"设置新密码" forState:UIControlStateNormal];
            setPassWord.titleLabel.font=[UIFont systemFontOfSize:20];
            setPassWord.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
            setPassWord.enabled=NO;
           [setPassWord addTarget:self action:@selector(setPassWordAction) forControlEvents:UIControlEventTouchUpInside];
            [tabCell addSubview:setPassWord];
            setPassWord.sd_layout
            .leftEqualToView(usernameText)
            .rightEqualToView(usernameText)
            .topSpaceToView(verificationCode,48)
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
            
            UILabel *titleLable=[UILabel new];
            titleLable.text=self.title;
            titleLable.textAlignment=NSTextAlignmentCenter;
            titleLable.font=[UIFont systemFontOfSize:20];
            titleLable.textColor=UIColorFromHex(0x333333);
            [tabCell addSubview:titleLable];
            titleLable.sd_layout
            .topSpaceToView(tabCell,190)
            .leftSpaceToView(tabCell,(THEWIDTH-100)/2)
            .heightIs(20)
            .rightSpaceToView(tabCell,(THEWIDTH-100)/2);
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:usernameText];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:verificationCode];
            
            
        }
    }
    
    if (setSuccess==YES) {
        
        usernameText.hidden=YES;
        verificationCode.hidden=YES;
        getCodeButton.hidden=YES;
        setPassWord.hidden=YES;
        
        newPassword=[UITextField new];
        newPassword.delegate=self;
        newPassword.font=[UIFont systemFontOfSize:14];
        newPassword.placeholder=@"请输入新密码";
        newPassword.clearButtonMode=UITextFieldViewModeWhileEditing;
        newPassword.borderStyle=UITextBorderStyleRoundedRect;
        newPassword.keyboardType=UIKeyboardTypeNumberPad;
        [tabCell addSubview:newPassword];
        newPassword.sd_layout
        .leftSpaceToView(tabCell,344)
        .rightSpaceToView(tabCell,344)
        .topSpaceToView(tabCell,278)
        .heightIs(44);
        
        sureSetButton=[UIButton new];
        sureSetButton.sd_cornerRadius = @(4);
        [sureSetButton setTitle:@"确认" forState:UIControlStateNormal];
        sureSetButton.titleLabel.font=[UIFont systemFontOfSize:20];
        sureSetButton.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        sureSetButton.enabled=NO;
        [sureSetButton addTarget:self action:@selector(setNewPassWordAction) forControlEvents:UIControlEventTouchUpInside];
        [tabCell addSubview:sureSetButton];
        sureSetButton.sd_layout
        .leftEqualToView(newPassword)
        .rightEqualToView(newPassword)
        .topSpaceToView(newPassword,48)
        .heightIs(44);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPasswordChange) name:UITextFieldTextDidChangeNotification object:newPassword];

    }
    
    return tabCell;
    
}
-(void)setNewPassWordAction
{
    if (newPassword.text.length>=6) {
        
        HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
        NSDictionary *dict=@{
                             @"mobile":usernameText.text,
                             @"phonecode":verificationCode.text,
                             @"password":newPassword.text
                             };
        NSLog(@"dict=%@",dict);
        [httpRequest postHttpDataWithParam:dict url:FORGETPASSWORD  success:^(NSDictionary *dict, BOOL success) {
            
            NSLog(@"dict=%@",dict);
            if ([[dict objectForKey:@"success"] boolValue]==1) {
                [self showAlertWithText:@"设置成功"];
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }else{
                [self showAlertWithText:@"设置失败"];
            }
            
        } fail:^(NSError *error) {
            
        }];
        
        
    }else{
        [self showAlertWithText:@"密码为6-16字符"];
    }
}
-(void)newPasswordChange
{
    if (newPassword.text.length!=0) {
        sureSetButton.backgroundColor=UIColorFromHex(0xf39800);
        sureSetButton.enabled=YES;
    }else{
        sureSetButton.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        sureSetButton.enabled=NO;
    }
}

-(void)textChange
{
    if (usernameText.text.length!=0 && verificationCode.text.length!=0) {
        setPassWord.backgroundColor=UIColorFromHex(0xf39800);
        setPassWord.enabled=YES;
    }else{
        setPassWord.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        setPassWord.enabled=NO;
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
    if (verificationCode==textField) {
        if (string.length == 0)
            return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 4) {
            return NO;
        }
    }
    
    return YES;
}
- (void)showAlertWithText:(NSString *)text
{
    alert = [UIView new];
    alert.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    UILabel *label = [UILabel new];
    label.text = text;
    label.textAlignment=NSTextAlignmentCenter;
    label.backgroundColor=[UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [alert addSubview:label];
    
    label.sd_layout
    .leftSpaceToView(alert, 20)
    .rightSpaceToView(alert, 20)
    .topSpaceToView(alert, 130)
    .autoHeightRatio(0);
    
    UIImageView *imageView = [UIImageView new];
    imageView.image=[UIImage imageNamed:@"notice"];
    [alert addSubview:imageView];
    imageView.sd_layout
    .bottomSpaceToView(label,24)
    .rightSpaceToView(alert,126)
    .widthIs(48)
    .heightEqualToWidth();
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
    
    alert.sd_layout
    .centerXEqualToView(alert.superview)
    .centerYEqualToView(alert.superview)
    .widthIs(300)
    .heightIs(200);
    
    alert.sd_cornerRadius = @(5);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        alert.alpha=0.4;
        [self performSelector:@selector(dissActionremo) withObject:self afterDelay:0.1];
    });
    
}
-(void)dissActionremo
{
    [alert removeFromSuperview];
}
- (void)showAlertImage
{
    _alertLoading = [UIView new];
    _alertLoading.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
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
    .widthIs(48)
    .heightEqualToWidth();
    
    [[UIApplication sharedApplication].keyWindow addSubview:_alertLoading];
    
}

@end
