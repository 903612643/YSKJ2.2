//
//  YSKJ_ OrderFavorableView.h
//  YSKJ
//
//  Created by YSKJ on 17/7/4.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ__OrderFavorableView : UIView

@property (nonatomic,strong) UITextField *discount;

@property (nonatomic,strong) UILabel *naturePrice;

@property (nonatomic,strong) UILabel *disCountPrice;

@property (nonatomic,strong) UILabel *favorablePrice;

@property (nonatomic,strong) UILabel *payPrice;

@property (nonatomic,retain) NSString *naturePriceStr;

@property (nonatomic,retain) NSString *disCountPriceStr;

@property (nonatomic,retain) NSString *favorablePriceStr;

@property (nonatomic,retain) NSString *payPriceStr;

@end
