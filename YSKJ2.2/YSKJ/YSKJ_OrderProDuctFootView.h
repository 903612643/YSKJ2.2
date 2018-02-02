//
//  YSKJ_OrderProDuctFootView.h
//  YSKJ
//
//  Created by YSKJ on 17/7/31.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderProDuctFootView : UIView

@property (nonatomic, strong) UILabel *pay;

@property (nonatomic, retain) NSString *payStr;

-(instancetype)initWithFrame:(CGRect)frame priceArr:(NSArray *)priceArr;

@end
