//
//  YSKJ_OrderProDuctTableViewCell.h
//  YSKJ
//
//  Created by YSKJ on 17/7/28.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderProDuctTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *proName;

@property (nonatomic, strong) UILabel *standardLable;

@property (nonatomic, strong) UILabel *colorLable;

@property (nonatomic, strong) UILabel *desc;

@property (nonatomic, strong) UILabel *price;

@property (nonatomic, strong) UILabel *count;

@property (nonatomic, strong) UILabel *totailPrice;

@property (nonatomic, strong) UILabel *updatePrice;

@property (nonatomic, strong) UILabel *payPrice;

@property (nonatomic, strong) UIButton *proImage;

@property (nonatomic ,retain)NSString *url;

@property (nonatomic ,retain)NSString *proNameStr;

@property (nonatomic ,retain)NSString *standardLableStr;

@property (nonatomic ,retain)NSString *descStr;

@property (nonatomic ,retain)NSString *priceStr;

@property (nonatomic ,retain)NSString *countStr;

@property (nonatomic ,retain)NSString *totailPriceStr;

@property (nonatomic ,retain)NSString *updatePriceStr;

@property (nonatomic ,retain)NSString *payPriceStr;

@end
