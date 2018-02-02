//
//  YSKJ_OrderViewController.h
//  YSKJ
//
//  Created by YSKJ on 17/7/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderViewController : UIViewController

@property (nonatomic, copy) NSString *identification;

@property (nonatomic, assign) NSInteger categoryNumber;

@property (nonatomic, assign) NSInteger productNumber;

@property (nonatomic, copy) NSString *totailsPrice;

@property (nonatomic, strong) UIButton *checkProduct;

@property (nonatomic, strong) UIButton *productImage;

@property (nonatomic, strong) UILabel *productName;

@property (nonatomic, strong) UILabel *standardLable;

@property (nonatomic, strong) UILabel *colorLable;

@property (nonatomic, strong) UILabel *price;

@property (nonatomic, strong) UILabel *borLable;

@property (nonatomic, strong) UILabel *countPrice;

@property (nonatomic, strong) UITextField *discount;

@property (nonatomic, strong) UIView *draggingView;

@property (nonatomic,strong)UIButton *subtract;

@property (nonatomic,strong)UIButton *addProduct;

@property (nonatomic, strong) UITextField *discountMoney;

@property (nonatomic, strong) UILabel *payPrice;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UILabel *editText;

@property (nonatomic, strong) UITextField *editTextField;

@property (nonatomic, strong) UIButton *editSure;

@property (nonatomic, strong) UIButton *editCancle;

@property (nonatomic, strong) UIButton *editUpdateText;

@end
