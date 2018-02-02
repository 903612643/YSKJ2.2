//
//  YSKJ_OrderTotalPricesView.h
//  YSKJ
//
//  Created by YSKJ on 17/7/4.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderTotalPricesView : UIView


@property (nonatomic, strong) UIButton *checkProduct;

@property (nonatomic, strong) UILabel *allCheckTitle;

@property (nonatomic, strong) UIButton *placeAnorder;

@property (nonatomic, strong) UILabel *produnt;

@property (nonatomic, strong) UILabel *totalPrice;

@property (nonatomic, assign) NSInteger categoryNumber;

@property (nonatomic, assign) NSInteger productNumber;

@property (nonatomic, copy) NSString *totailPriceStr;


@end
