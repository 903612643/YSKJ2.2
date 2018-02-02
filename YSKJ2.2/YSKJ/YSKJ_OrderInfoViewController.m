//
//  YSKJ_OrderInfoViewController.m
//  YSKJ
//
//  Created by YSKJ on 17/7/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderInfoViewController.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import "YSKJ_OrderTotalPricesView.h"

#import "YSKJ_OrderDoneViewController.h"

#import "YSKJ_OrderPickerWindowView.h"

#import "YSKJ_OrderAddressPickerView.h"

#import "HttpRequestCalss.h"

#import "YSKJ_TipViewCalss.h"

#import "ToolClass.h"

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "NSString+MD5.h"

#import <Qiniu/QiniuSDK.h>

#import "YSKJ_SaveWebImageClass.h"

#import "YSKJ_OrderDetailTableViewHeadView.h"

#import "YSKJ_OrderDetailTableViewFootView.h"

#import "YSKJ_OrderDetailPngTableViewCell.h"

///
#import "ProvinceModel.h"
#import "CityModel.h"
#import "TownsModel.h"

#import "HttpRequestCalss.h"

#define ADDRESSURL @"http://www.5164casa.com/public/js/store/address.json"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define GETTOKEN @"http://"API_DOMAIN@"/sysconfig/gettoken" //得到token

#define ADDORDER @"http://"API_DOMAIN@"/project/add" //新加订货单

#define UPDATEPATH @"http://"API_DOMAIN@"/project/editpdf" //修改订货单路径

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@interface YSKJ_OrderInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate>
{
    UITableView* _tableView,*_orderTableView;
    NSArray *_dataSource;
    UITextView *_textView;
    
    NSArray *_pickerData;
    
    YSKJ_OrderPickerWindowView *_windowView;
    
    YSKJ_OrderAddressPickerView *_addressPickerWindow;
    
    NSString *_checkTypeString,*_pro,*_cityStr,*townStr,*_jsondata;
    
    YSKJ_OrderTotalPricesView *totalPrices;
    
    YSKJ_OrderDetailPngTableViewCell *_cell;
    
    NSDictionary *_notificationInfo;
    

}

//data
@property (strong, nonatomic) NSMutableArray *provinceArr;
@property (strong, nonatomic) NSMutableArray *countryArr;
@property (strong, nonatomic) NSMutableArray *districtArr;


// 最后获取到的对象 省市县
@property (strong, nonatomic)ProvinceModel *pModel;
@property (strong, nonatomic)CityModel *cModel;
@property (strong, nonatomic)TownsModel *tModel;

@property (nonatomic, strong) UITextField *productName;

@property (nonatomic, strong) UITextField *address;

@property (nonatomic, strong) UITextField *userName;

@property (nonatomic, strong) UITextField *userPhone;

@property (nonatomic, strong) UIButton *userBelong;

@property (nonatomic, strong) UIButton *adderssDetail;

@property (nonatomic,strong) NSArray *addressArr; // 解析出来的最外层数组


@end

@implementation YSKJ_OrderInfoViewController

- (NSMutableArray *)provinArr{
    if (!_provinceArr) {
        self.provinceArr = [NSMutableArray array];
    }
    return _provinceArr;
}

- (NSMutableArray *)cArr{
    if (!_countryArr) {
        self.countryArr = [NSMutableArray array];
    }
    return _countryArr;
}
- (NSMutableArray *)tArr{
    if (!_districtArr) {
        self.districtArr = [NSMutableArray array];
    }
    return _districtArr;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:20];
    UIColor *titleColor=UIColorFromHex(0x666666);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes =dic;
    self.navigationController.view.backgroundColor=UIColorFromHex(0xEFEFEF);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromHex(0xd7dee4);
    

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
    
    _jsondata = [self getJsonData];
    
    //用户信息
    NSDictionary *obj1 = @{
                           @"plan_id":@"0",
                           @"title":@"插入一个空的行",
                           @"check":@"0",
                           @"data": @[]
                           };
    [self.orderList addObject:obj1];
    
    int count = 0;
    for (int i = 0; i<self.orderList.count; i++) {
        NSDictionary *dict = self.orderList[i];
        NSArray *dataA = [dict objectForKey:@"data"];
        for (NSDictionary *dcit in dataA) {
            count++;
        }
    }
    
    _orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60*self.orderList.count + 150*count + 600 - 64)];
    _orderTableView.delegate =self;
    _orderTableView.dataSource = self;
    _orderTableView.hidden = YES;
    [self.view addSubview:_orderTableView];
    
    [_orderTableView registerClass:[YSKJ_OrderDetailPngTableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    [self setupTableView];
    
    _dataSource = @[@"项目名称",@"地址",@"",@"客户姓名",@"客户电话",@"客流归属",@"备注"];
    
    totalPrices = [[YSKJ_OrderTotalPricesView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-54-63, self.view.frame.size.width, 54)];
    [totalPrices.placeAnorder setTitle:@"提交审核" forState:UIControlStateNormal];
    totalPrices.placeAnorder.enabled = YES;
    totalPrices.allCheckTitle.hidden = YES;
    totalPrices.checkProduct.hidden = YES;
    totalPrices.produnt.sd_layout
    .leftSpaceToView(totalPrices,16);
    [totalPrices updateLayout];
    totalPrices.productNumber = [self.proNumber integerValue];
    totalPrices.totailPriceStr = self.totailePrice;
    totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xf95f3e);
    [totalPrices.placeAnorder addTarget:self action:@selector(commitCheck) forControlEvents:UIControlEventTouchUpInside];
    
    totalPrices.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:totalPrices];
    
    [self getAddress];

    //监听软键盘事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //添加手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    
}

-(void)tapAction
{
    [_textView resignFirstResponder];
    [self.productName resignFirstResponder];
    [self.address resignFirstResponder];
    [self.userName resignFirstResponder];
    [self.userPhone resignFirstResponder];
}

#pragma mark getjosnData

-(NSString *)getJsonData
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *pidArr = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.orderList.count; i++) {
        
        NSDictionary *dict = self.orderList[i];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        
        if (i!=0) {
            
            [tempDict setObject:[dict objectForKey:@"title"] forKey:@"name"];
            
            NSArray *data = [dict objectForKey:@"data"];
            
            NSMutableArray *tempdataArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *datadict in data) {
                
                [pidArr addObject:[datadict objectForKey:@"id"]];
                
                NSMutableDictionary *tempdataDict = [[NSMutableDictionary alloc] init];
                
                [tempdataDict setObject:[datadict objectForKey:@"id"] forKey:@"pid"];
                
                [tempdataDict setObject:[datadict objectForKey:@"count"] forKey:@"num"];
                
                [tempdataDict setObject:[NSString stringWithFormat:@"%0.2f",[[datadict objectForKey:@"price"] floatValue]*[[datadict objectForKey:@"count"] integerValue]] forKey:@"price"];
                if ([[datadict objectForKey:@"disCount"] floatValue] > 1 && [[datadict objectForKey:@"disCount"] floatValue] < 10 ) {
                    
                    [tempdataDict setObject:[NSString stringWithFormat:@"%0.2f",[[datadict objectForKey:@"price"] floatValue] * [[datadict objectForKey:@"count"] integerValue] * [[datadict objectForKey:@"disCount"] floatValue]/10] forKey:@"real_price"];
                    
                }else{
                    
                    [tempdataDict setObject:[NSString stringWithFormat:@"%0.2f",[[datadict objectForKey:@"price"] floatValue] * [[datadict objectForKey:@"count"] integerValue] + [[datadict objectForKey:@"payMoney"] floatValue]] forKey:@"real_price"];
                }
                
                
                [tempdataDict setObject:[datadict objectForKey:@"name"] forKey:@"name"];
                
                [tempdataDict setObject:[[datadict objectForKey:@"thumb_file"] substringFromIndex:27] forKey:@"thumb_file"];
                
                NSDictionary *arrdict=[ToolClass dictionaryWithJsonString:[datadict objectForKey:@"attributes"]];
                
                if ([arrdict objectForKey:@"color"]) {
                    [tempdataDict setObject:[arrdict objectForKey:@"color"] forKey:@"color"];
                }else{
                    [tempdataDict setObject:@"" forKey:@"color"];
                }
                
                [tempdataDict setObject:[datadict objectForKey:@"editText"] forKey:@"desc"];
                
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
                        self.standardLable .text= [NSString stringWithFormat:@"规格：%@mm",[tempArr componentsJoinedByString:@"*"]]; //为分隔符
                        
                        [tempdataDict setObject:[NSString stringWithFormat:@"%@mm",[tempArr componentsJoinedByString:@"*"]] forKey:@"size"];
                        
                    }
                }
                
                [tempdataArray addObject:tempdataDict];
                
            }

            [tempDict setObject:tempdataArray forKey:@"data"];
            
            [tempArray addObject:tempDict];
  
        }
   
    }
    
    _notificationInfo = @{
                          @"proInfo":pidArr
                          };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:tempArray options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonData=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return jsonData;
}

#pragma mark - 键盘弹出时界面上移及还原

static bool show = NO;

-(void)keyboardWillShow:(NSNotification *) notification{
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyBoardHeight = keyboardRect.size.height;
    
    if (show == YES){
        
        //使视图上移
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = -keyBoardHeight+(54+63+54+60);
        self.view.frame = viewFrame;
    }
}

-(void)keyboardWillHide
{
    //使视图还原
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 63;
    self.view.frame = viewFrame;
    
}


#pragma mark - get address

-(void)getAddress
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hotelcity" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    
     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    self.addressArr = [dict objectForKey:@"data"];
    
    NSMutableArray *pro = [[NSMutableArray alloc] init];
    NSMutableArray *city = [[NSMutableArray alloc] init];
    NSMutableArray *town = [[NSMutableArray alloc] init];
    
    for (NSDictionary *pdict in self.addressArr)
    {
        [pro addObject:[pdict objectForKey:@"province"]];
    }
    
    NSDictionary *cdict = self.addressArr[19];
    
    NSArray *cArr = [cdict objectForKey:@"cityItems"];
    
    for (NSDictionary *dict in cArr) {
        
        [city addObject:[dict objectForKey:@"city"]];
        
    }
    
    NSDictionary *firstCity = cArr[10];
    
    for (NSDictionary *tdict  in [firstCity objectForKey:@"areaItems"]) {
        [town addObject:[tdict objectForKey:@"area"]];
    }
    
    self.provinceArr = pro;
    
    self.countryArr = city;
    
    self.districtArr = town;
    

    
}

#pragma mark UIPickerViewDelegate

//指定pickerview列
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if (pickerView == _addressPickerWindow.pickerView) {
        return 3;
    }else{
        return 1;

    }
}

//指定每个表盘上有几行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (pickerView == _addressPickerWindow.pickerView) {
        
        if (component == 0) {
            
            return self.provinceArr.count;
            
        } else if (component == 1) {
        
            return self.countryArr.count;
            
        } else {
            
            return self.districtArr.count;
        }
        
    }else{
       
        return  _pickerData.count;//根据数组的元素个数返回几行数据
        
    }
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (pickerView == _addressPickerWindow.pickerView) {
        
        if (component == 0) {
            
            UILabel  *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width/3, 30)];
            
            lable.textAlignment = NSTextAlignmentCenter;
            
            lable.text = [self.provinceArr objectAtIndex:row];
            
            lable.font = [UIFont systemFontOfSize:14];         //用label来设置字体大小
            _pro = lable.text;
            if (showAddressPiceker==YES) {
                
                _pro = @"广东省"; _cityStr =@"深圳市"; townStr = @"福田区";
            }
            
             return lable;
            
        }else if (component == 1)
        {
             UILabel  *lable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3, 0.0, self.view.frame.size.width/3, 30)];
            lable.textAlignment = NSTextAlignmentCenter;
            
            lable.text = [self.countryArr objectAtIndex:row];
            
            lable.font = [UIFont systemFontOfSize:14];         //用label来设置字体大小
            _cityStr = lable.text;
            if (showAddressPiceker==YES) {
                
                _pro = @"广东省"; _cityStr =@"深圳市"; townStr = @"福田区";
            }

             return lable;

        }else
        {
            UILabel  *lable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3*2, 0.0, self.view.frame.size.width/3, 30)];
            lable.textAlignment = NSTextAlignmentCenter;
            
            lable.text = [self.districtArr objectAtIndex:row];
            
            lable.font = [UIFont systemFontOfSize:14];         //用label来设置字体大小
            townStr = lable.text;
            if (showAddressPiceker==YES) {
                
                _pro = @"广东省"; _cityStr =@"深圳市"; townStr = @"福田区";
            }

             return lable;
        }
        
    }else{
        
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 30)];
            
            lable.textAlignment = NSTextAlignmentCenter;
            
            
            lable.text = [_pickerData objectAtIndex:row];
            
            
            lable.font = [UIFont systemFontOfSize:14];         //用label来设置字体大小
            
            _checkTypeString = lable.text;
            
            return lable;
        
    }
    
}

static NSInteger indexRow=19;
static bool showAddressPiceker= NO;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == _addressPickerWindow.pickerView) {
        
        showAddressPiceker = NO;

        if (component == 0) {
            
            [self.provinArr removeAllObjects];
            [self.countryArr removeAllObjects];
            [self.districtArr removeAllObjects];
            
            indexRow = row;
            
            NSMutableArray *pro = [[NSMutableArray alloc] init];
            NSMutableArray *city = [[NSMutableArray alloc] init];
            NSMutableArray *town = [[NSMutableArray alloc] init];
            
            NSDictionary *cdict = self.addressArr[row];
            
            _pro = [cdict objectForKey:@"province"];
            
            for (NSDictionary *pdict in self.addressArr)
            {
                [pro addObject:[pdict objectForKey:@"province"]];
            }
            
            NSArray *cArr = [cdict objectForKey:@"cityItems"];
            NSDictionary *firstCity = cArr[0];
            
            for (NSDictionary *citydict in cArr) {
                [city addObject:[citydict objectForKey:@"city"]];
            }
            
            for (NSDictionary *tdict  in [firstCity objectForKey:@"areaItems"]) {
                [town addObject:[tdict objectForKey:@"area"]];
            }
            
            self.provinceArr = pro;
            
            self.countryArr = city;
            
            self.districtArr = town;
            
            [pickerView selectRow:0 inComponent:1 animated:YES];

            [pickerView selectedRowInComponent:1];
            [pickerView reloadComponent:1];
            [pickerView selectedRowInComponent:2];
            [pickerView reloadComponent:2];
  
        }
    
        if (component == 1) {

            [self.districtArr removeAllObjects];
     
            NSDictionary *cdict = self.addressArr[indexRow];
            
            NSMutableArray *town = [[NSMutableArray alloc] init];
            
            NSArray *cArr = [cdict objectForKey:@"cityItems"];
            
            NSDictionary *checkCity = cArr[row];
            
            _cityStr = [checkCity objectForKey:@"city"];
            
            for (NSDictionary *tdict  in [checkCity objectForKey:@"areaItems"]) {
                [town addObject:[tdict objectForKey:@"area"]];
            }
            
            self.districtArr = town;
            
            if (self.districtArr.count==0) {
                townStr = @"";
            }
            
            [pickerView selectedRowInComponent:2];
            [pickerView reloadComponent:2];
            
        }
        
        if (component == 2) {
            
            townStr = self.districtArr[row];
            
        }
        
    }
    
}

-(void)dissmissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)commitCheck
{

    YSKJ_TipViewCalss *tip = [[YSKJ_TipViewCalss alloc] init];
    
    if (self.productName.text.length!=0) {
        
        if (![self.adderssDetail.titleLabel.text isEqualToString:@"请选择地址"]) {
            
            if (self.address.text.length!=0) {
                
                if (self.userName.text.length!=0) {
                    
                    if (self.userPhone.text.length !=0) {
                        
                        if ([ToolClass phone:self.userPhone.text] ==YES) {
                            
                            if (![self.userBelong.titleLabel.text isEqualToString:@"请选择客流归属"]) {
                                
                                [totalPrices.placeAnorder setTitle:@"正在提交" forState:UIControlStateNormal];
                                totalPrices.placeAnorder.enabled = NO;
                                totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xefefef);

                                _orderTableView.hidden = NO;
                                
                                [_orderTableView reloadData];
    

        //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width, _orderTableView.frame.size.height), NO, 0);

        //renderInContext呈现接受者及其子范围到指定的上下文
        [_orderTableView.layer renderInContext:UIGraphicsGetCurrentContext()];

        //返回一个基于当前图形上下文的图片
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();

        //移除栈顶的基于当前位图的图形上下文
        UIGraphicsEndImageContext();
                                
        NSString *key =[NSString stringWithFormat:@"%@/%@",@"projecturl",[self stringKey]];
                                
        [self getToken:[self getDesignPathWithimage:viewImage] key:key];
                                
                                
        HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
        
        NSDictionary *param=
        @{
          @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
          @"price":self.totailePrice,
          @"discountprice":self.discount,
          @"name":self.productName.text,
          @"province":_pro,
          @"city":_cityStr,
          @"district":townStr,
          @"address":self.address.text,
          @"cname":self.userName.text,
          @"cphone":self.userPhone.text,
          @"ctype":self.userBelong.titleLabel.text,
          @"cdesc":_textView.text,
          @"pdata":_jsondata
          };
   
        [requset postHttpDataWithParam:param url:ADDORDER  success:^(NSDictionary *dict, BOOL success) {
            
            NSLog(@"dict=%@",dict);
        
            if ([[dict objectForKey:@"success"] boolValue]==1) {
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_planCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_proCar",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"orderSuccess" object:self userInfo:_notificationInfo];
                
                [totalPrices.placeAnorder setTitle:@"已下单" forState:UIControlStateNormal];
                totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xefefef);
                totalPrices.placeAnorder.enabled = NO;
                
                HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
                
                NSDictionary *param=
                @{
                  @"userid":[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"],
                  @"id":[[dict objectForKey:@"data"] objectForKey:@"id"],
                  @"url":key
                  };
                
                [requset postHttpDataWithParam:param url:UPDATEPATH  success:^(NSDictionary *dict, BOOL success) {
  
                }fail:^(NSError *error) {
   
                }];
                
                YSKJ_OrderDoneViewController *doneVC = [[YSKJ_OrderDoneViewController alloc] init];
                doneVC.orderArray = self.orderArray;
                doneVC.key = key;
                [self.navigationController pushViewController:doneVC animated:YES];
                
            }else{
                
                [totalPrices.placeAnorder setTitle:@"下单" forState:UIControlStateNormal];
                totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xf95f3e);
                totalPrices.placeAnorder.enabled = YES;
                tip.title =@"提交失败";
            }
            
        } fail:^(NSError *error) {
            
            tip.title =@"提交失败";
            [totalPrices.placeAnorder setTitle:@"下单" forState:UIControlStateNormal];
            totalPrices.placeAnorder.backgroundColor = UIColorFromHex(0xf95f3e);
            totalPrices.placeAnorder.enabled = YES;

        }];
                                
                            }else{
                                tip.title =@"请选择客户归属";
                            }
                        }else{
                            tip.title =@"手机号码格式不正确";
                        }
 
                    }else{
                        tip.title = @"请输入电话号码";
                    }
                    
                }else{
                    tip.title = @"请输入客户名称";
                }
                
            }else{
                tip.title = @"请输入街道及楼牌号";
            }
        }else{
            tip.title = @"请选择地址";
        }
        
    }else{

        tip.title = @"请输入项目名称";
    }
    
    
}

-(NSString*)getDesignPathWithimage:(UIImage *)orderImage
{
    
    YSKJ_SaveWebImageClass *save = [[YSKJ_SaveWebImageClass alloc] init];
    [save SaveShopPicFloder:@"design" p_no:@"photo" imageUrl:nil SaveFileName:@"design" SaveFileType:@"png" image:orderImage size:CGSizeMake(orderImage.size.width, orderImage.size.height)];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,@"design",@"photo"];
    
    NSString *fullPath = [imagePath stringByAppendingPathComponent:@"design.png"];
    
    return fullPath;
    
}

#pragma mark 获取token

-(void)getToken:(NSString*)filePath key:(NSString *)key
{
    
    HttpRequestCalss *requset=[[HttpRequestCalss alloc ] init];
    
    NSDictionary *param=
    @{
      @"bucket":@"design"
      };
    
    [requset postHttpDataWithParam:param url:GETTOKEN  success:^(NSDictionary *dict, BOOL success) {
        
        NSDictionary *tokenDict=[dict objectForKey:@"data"];
        
        [self saveToQiniuServer:[tokenDict objectForKey:@"token"] filePath:filePath key:key ];
        
    } fail:^(NSError *error) {
        
    }];
    
}

-(void)saveToQiniuServer:(NSString*)token filePath:(NSString*)filePath key:(NSString *)key
{
    //国内https上传
    BOOL isHttps = TRUE;
    QNZone * httpsZone = [[QNAutoZone alloc] initWithHttps:isHttps dns:nil];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = httpsZone;
    }];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    [upManager putFile:filePath key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if(info.ok)
        {
            NSLog(@"key=%@",key);
            
        }else{
            
        }}option:nil];
    
}

-(NSString *)stringKey
{
    //当前时间
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSArray *changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];//存放十个数，以备随机取
    NSMutableString * getStr = [[NSMutableString alloc] initWithCapacity:9];
    NSString *changeString = [[NSMutableString alloc] initWithCapacity:10];
    for (int i = 0; i<10; i++) {
        NSInteger index = arc4random()%([changeArray count]-1);
        getStr = changeArray[index];
        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr];
    }
    NSString *md5PassStr=[changeString md5String];
    
    NSString *key=[NSString stringWithFormat:@"%@/%@.png",dateStr,[md5PassStr substringToIndex:16]];
    
    return key;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 加载tableView
-(void)setupTableView
{
    _tableView=[[UITableView alloc] init];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _tableView.sd_layout
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .topSpaceToView(self.view,10)
    .bottomSpaceToView(self.view,0);
    
    
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented

{
    if (_tableView == tableView) {
        
        return 1;
        
    }else{
        
        return self.orderList.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tableView == tableView) {
    
        return _dataSource.count;

        
    }else{
        
        NSDictionary *dict=[self.orderList objectAtIndex:section];
        
        NSArray *arr=[dict objectForKey:@"data"];
        
        return arr.count;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView == tableView) {
        
        UITableViewCell *tabCell = [_tableView dequeueReusableCellWithIdentifier:@"cellid"];
        
        if (tabCell == nil) {
            
            tabCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid"];
            
            tabCell.selectionStyle=UITableViewCellSelectionStyleNone;
            tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            
            if (indexPath.row == 1 || indexPath.row == 5) {
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-54, 15, 16, 19)];
                imageView.alpha = 0.6;
                imageView.image = [UIImage imageNamed:@"check"];
                [tabCell addSubview:imageView];
                
            }
            
            if (indexPath.row !=2 && indexPath.row!=6) {
                
                UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(80, 17, 20, 10)];
                tip.text = @"＊";
                tip.font = [UIFont systemFontOfSize:12];
                tip.textColor = UIColorFromHex(0xf32a00);
                [tabCell addSubview:tip];
            }
            
            if (indexPath.row !=6) {
                
                if (indexPath.row == 0) {
                    
                    self.productName = [[UITextField alloc] initWithFrame:CGRectMake(200, 9, 200,30)];
                    self.productName.placeholder = @"请输入项目名称";
                    self.productName.textColor = UIColorFromHex(0x333333);
                    self.productName.delegate = self;
                    self.productName.font = [UIFont systemFontOfSize:14];
                    [tabCell addSubview:self.productName];
                }
                if (indexPath.row == 1) {
                    
                    self.adderssDetail = [[UIButton alloc] initWithFrame:CGRectMake(200, 9, 300, 30)];
                    [self.adderssDetail setTitle:@"请选择地址" forState:UIControlStateNormal];
                    UIColor *titleColor = UIColorFromHex(0x333333);
                    self.adderssDetail.alpha = 0.25;
                    [self.adderssDetail setTitleColor:titleColor forState:UIControlStateNormal];
                    self.adderssDetail.titleLabel.font = [UIFont systemFontOfSize:14];
                    [tabCell addSubview:self.adderssDetail];
                    self.adderssDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [self.adderssDetail addTarget:self action:@selector(adderssDetailAction) forControlEvents:UIControlEventTouchUpInside];
                }
                if (indexPath.row == 2) {
                    
                    self.address = [[UITextField alloc] initWithFrame:CGRectMake(200, 9, 200, 30)];
                    self.address.delegate = self;
                    self.address.placeholder = @"请输入街道及小区楼牌号";
                    self.address.textColor = UIColorFromHex(0x333333);
                    self.address.font = [UIFont systemFontOfSize:14];
                    [tabCell addSubview:self.address];
                }
                if (indexPath.row == 3) {
                    
                    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(200, 9, 200, 30)];
                    self.userName.placeholder = @"请输入客户姓名";
                    self.userName.delegate = self;
                    self.userName.textColor = UIColorFromHex(0x333333);
                    self.userName.font = [UIFont systemFontOfSize:14];
                    [tabCell addSubview:self.userName];
                }
                if (indexPath.row == 4) {
                    
                    self.userPhone = [[UITextField alloc] initWithFrame:CGRectMake(200, 9, 200, 30)];
                    self.userPhone.placeholder = @"请输入电话号码";
                    self.userPhone.delegate = self;
                    self.userPhone.keyboardType = UIKeyboardTypeNumberPad;
                    self.userPhone.textColor = UIColorFromHex(0x333333);
                    self.userPhone.font = [UIFont systemFontOfSize:14];
                    [tabCell addSubview:self.userPhone];
                }
                if (indexPath.row == 5) {
                    
                    self.userBelong = [[UIButton alloc] initWithFrame:CGRectMake(200, 9, 200, 30)];
                    [self.userBelong setTitle:@"请选择客流归属" forState:UIControlStateNormal];
                    self.userBelong.alpha = 0.25;
                    UIColor *titCol = UIColorFromHex(0x333333);
                    [self.userBelong setTitleColor:titCol forState:UIControlStateNormal];
                    self.userBelong.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    self.userBelong.titleLabel.font = [UIFont systemFontOfSize:14];
                    [tabCell addSubview:self.userBelong];
                    [self.userBelong addTarget:self action:@selector(userBelongAction) forControlEvents:UIControlEventTouchUpInside];
                }
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(80, 47, self.view.frame.size.width-80-38, 1)];
                line.backgroundColor = UIColorFromHex(0xd7d7d7);
                [tabCell addSubview:line];
                
 
            }else{
                
                _textView = [[UITextView alloc] initWithFrame:CGRectMake(178, 17, self.view.frame.size.width-178-38, 121)];
                _textView.layer.borderWidth =1;
                _textView.delegate = self;
                _textView.font = [UIFont systemFontOfSize:14];
                _textView.layer.borderColor = UIColorFromHex(0xd8d8d8).CGColor;
                [tabCell addSubview:_textView];
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 158, self.view.frame.size.width, 700-158)];
                view.backgroundColor = UIColorFromHex(0xd6dde3);
                [tabCell addSubview:view];
                
            }
     
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(92, 17, 60, 14)];
            title.text = _dataSource[indexPath.row];
            title.textAlignment = NSTextAlignmentLeft;
            title.font = [UIFont systemFontOfSize:14];
            title.textColor = UIColorFromHex(0x333333);
            [tabCell addSubview:title];
            
        }
        
        return tabCell;

    }else{
        
        
        _cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
        
        _cell.selectionStyle=UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        NSDictionary *dict=[self.orderList objectAtIndex:indexPath.section];

        NSArray *arr=[dict objectForKey:@"data"];

        NSDictionary *obj = arr[indexPath.row];
        
        _cell.url = [obj objectForKey:@"thumb_file"];
        
        _cell.proNameStr = [obj objectForKey:@"name"];
        
        _cell.beizhuLableStr = [obj objectForKey:@"editText"];
        
        NSString *tempStr;
        
        NSInteger disCountInt = [[obj objectForKey:@"disCount"] integerValue];
        
        float disCount = 0.0;

        if (disCountInt != 10 && disCountInt !=0) {
            
            tempStr = [NSString stringWithFormat:@"-¥%0.2f",([[obj objectForKey:@"price"] floatValue] * (1-[[obj objectForKey:@"disCount"] floatValue]/10) * [[obj objectForKey:@"count"] integerValue])];
            
            disCount = 0-([[obj objectForKey:@"price"] floatValue] * (1-[[obj objectForKey:@"disCount"] floatValue]/10) * [[obj objectForKey:@"count"] integerValue]);
            
        }else{
            
            if ([[obj objectForKey:@"payMoney"] floatValue]>=0) {
                
                tempStr = [NSString stringWithFormat:@"¥%0.2f",[[obj objectForKey:@"payMoney"] floatValue]];
                
                disCount = [[obj objectForKey:@"payMoney"] floatValue];
                

            }else if ([[obj objectForKey:@"payMoney"] floatValue] < 0)
            {
                tempStr = [NSString stringWithFormat:@"-¥%0.2f",[[[obj objectForKey:@"payMoney"] substringFromIndex:1] floatValue]];
                
                disCount = 0 - [[[obj objectForKey:@"payMoney"] substringFromIndex:1] floatValue];
            }
            
        }

        _cell.priceArr = @[[NSString stringWithFormat:@"¥%0.2f",[[obj objectForKey:@"price"] floatValue]],[NSString stringWithFormat:@"x%@",[obj objectForKey:@"count"]],[NSString stringWithFormat:@"¥%0.2f",[[obj objectForKey:@"price"] floatValue] * [[obj objectForKey:@"count"] integerValue]],tempStr,[NSString stringWithFormat:@"¥%0.2f",[[obj objectForKey:@"price"] floatValue] * [[obj objectForKey:@"count"] integerValue]+disCount]];
        
        NSDictionary *arrdict=[ToolClass dictionaryWithJsonString:[obj objectForKey:@"attributes"]];
        
        NSArray *allkeys=[arrdict allKeys];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
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
                _cell.standardLableStr = [NSString stringWithFormat:@"规格：%@mm",[tempArr componentsJoinedByString:@"*"]]; //为分隔符
                
                [array addObject:@"有规格"];
            }
        }
        
        if (array.count ==0) {
            
            _cell.beizhuLable.sd_layout
            .topSpaceToView(_cell.proName, 25);
            [_cell.beizhuLable updateLayout];
            
        }
    
        return _cell;
        
    }

}
-(void)adderssDetailAction
{
    [self getAddress];
    
    _addressPickerWindow = [[YSKJ_OrderAddressPickerView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:_addressPickerWindow];
    [_addressPickerWindow.cancle addTarget:self action:@selector(addressPickerwindowCancle) forControlEvents:UIControlEventTouchUpInside];

    
    [_addressPickerWindow.sure addTarget:self action:@selector(addressPickerwindowSure) forControlEvents:UIControlEventTouchUpInside];
    
    _addressPickerWindow.pickerView.dataSource = self;
    _addressPickerWindow.pickerView.delegate = self;
    
    [_addressPickerWindow.pickerView selectRow:19 inComponent:0 animated:YES];
    [_addressPickerWindow.pickerView selectRow:10 inComponent:1 animated:YES];
    [_addressPickerWindow.pickerView selectRow:1 inComponent:2 animated:YES];
    
    showAddressPiceker = YES;
    
    indexRow = 19;

    [self.productName resignFirstResponder];
    [self.address resignFirstResponder];
    [self.userName resignFirstResponder];
    [self.userPhone resignFirstResponder];

}
-(void)userBelongAction
{
    _windowView = [[YSKJ_OrderPickerWindowView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:_windowView];
    
    [_windowView.cancle addTarget:self action:@selector(windowCancle) forControlEvents:UIControlEventTouchUpInside];
    [_windowView.sure addTarget:self action:@selector(windowSure) forControlEvents:UIControlEventTouchUpInside];
    
    _pickerData = @[@"自然",@"邀约",@"渠道",@"多店联动"];
    _windowView.pickerView.dataSource = self;
    _windowView.pickerView.delegate = self;
    
    [self.productName resignFirstResponder];
    [self.address resignFirstResponder];
    [self.userName resignFirstResponder];
    [self.userPhone resignFirstResponder];
    [_textView resignFirstResponder];
    

}

#pragma  mark UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (_orderTableView == tableView) {
        
        //修改数据源
        NSDictionary *dict=[self.orderList objectAtIndex:section];
        
        if (section == 0) {

            YSKJ_OrderDetailTableViewHeadView *head = [[YSKJ_OrderDetailTableViewHeadView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
            
            head.planNameStr = [NSString stringWithFormat:@"项目名称：%@",self.productName.text];
            
            head.userAddressStr = [NSString stringWithFormat:@"地址：%@",[NSString stringWithFormat:@"%@%@",self.adderssDetail.titleLabel.text,self.address.text]];

            //当前时间
            NSDate *date=[NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy 年 M 月 dd 日";
            NSString *dateString = [formatter stringFromDate:date];
            
            head.dateStr = [NSString stringWithFormat:@"订货日期：%@",dateString];
            
            head.usernameAndPhoneStr =  [NSString stringWithFormat:@"客户：%@     电话：%@",self.userName.text,self.userPhone.text];
            
            return head;
            

        }else if ( section == self.orderList.count-1)
        {
      
            NSDictionary *dict = @{
                                   @"priceArr":self.orderArray,
                                   @"proNumber": self.proNumber,
                                   @"totailePrice":self.totailePrice
                                   };
            
            YSKJ_OrderDetailTableViewFootView *foot = [[YSKJ_OrderDetailTableViewFootView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350) withDict:dict];
                        
            return foot;
            
            
        }else{
            

            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width-60, 1)];
            line.backgroundColor = UIColorFromHex(0xd7d7d7);
            [view addSubview:line];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, self.view.frame.size.width-58, 14)];
            title.textAlignment = NSTextAlignmentLeft;
            if ([[dict objectForKey:@"title"] isEqualToString:@"选单品"]) {
                
                title.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
            }else{
                title.text = [NSString stringWithFormat:@"%@  方案",[dict objectForKey:@"title"]];
            }
            
            title.font = [UIFont systemFontOfSize:14];
            title.textColor = UIColorFromHex(0x333333);
            [view addSubview:title];
            
            return view;

        }
    
    }else{
        
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_tableView == tableView) {
        
        if (indexPath.row !=6) {
            
            return 48;
            
        }else{
            return 158;
        }

    }else{
    
        return 150;
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (_tableView==tableView) {
        
        return 0.001;
        
    }else{
        
        if (section == 0) {
            
            return 250;
            
        }else if ( section == self.orderList.count-1)
        {
            return 350;
            
        }else{
            
            return 60;
            
        }
        
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 0.001;
}

-(void)addressPickerwindowCancle
{
    [self.adderssDetail setTitle:@"请选择地址" forState:UIControlStateNormal];
     self.adderssDetail.alpha = 0.25;
    [UIView animateWithDuration:0.3 animations:^{
        
        _addressPickerWindow.view.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.size.height, [UIApplication sharedApplication].keyWindow.size.width, 258);
    }];
    
    [self performSelector:@selector(addressPickeraferAction) withObject:self afterDelay:0.3];

}

-(void)addressPickerwindowSure
{
    [self addressPickerwindowCancle];
    
    self.adderssDetail.alpha = 1;
    
    [self.adderssDetail setTitle:[NSString stringWithFormat:@"%@%@%@",_pro,_cityStr,townStr] forState:UIControlStateNormal];
    
}

-(void)addressPickeraferAction
{
    showAddressPiceker = NO;
    [_addressPickerWindow removeFromSuperview];
}

-(void)windowCancle
{
    [self.userBelong setTitle:@"请选择客流归属" forState:UIControlStateNormal];
    self.userBelong.alpha = 0.25;
    [UIView animateWithDuration:0.3 animations:^{
        
        _windowView.view.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.size.height, [UIApplication sharedApplication].keyWindow.size.width, 258);
    }];
         
    [self performSelector:@selector(aferAction) withObject:self afterDelay:0.3];
    
}
-(void)windowSure
{
    [self.userBelong setTitle:_checkTypeString forState:UIControlStateNormal];
     self.userBelong.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        
        _windowView.view.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.size.height, [UIApplication sharedApplication].keyWindow.size.width, 258);
    }];
    
    [self performSelector:@selector(aferAction) withObject:self afterDelay:0.3];
}
-(void)aferAction
{
    [_windowView removeFromSuperview];
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    CGPoint point = textField.frame.origin;
    CGPoint realLocation = [textField convertPoint:point toView:self.view];
    
    if (realLocation.y>350) {
        show = YES;
    }else{
        show = NO;
    }
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if (_textView == textView){
        
        if (_textView.text.length == 0)
            return YES;
        NSInteger existedLength = _textView.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = _textView.text.length;
        //限制长度
        if (existedLength - selectedLength + replaceLength > 1000) {
            return NO;
        }
        
    }
    if ([text isEqualToString:@"\n"]) {
        
        [_textView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

#pragma mark UITextViewDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CGPoint point = textView.frame.origin;
    CGPoint realLocation = [textView convertPoint:point toView:self.view];
    
    if (realLocation.y>350) {
        
        show = NO;
        
    }else{
        
        show = YES;
    }
    return YES;
}

@end
