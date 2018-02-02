//
//  YSKJ_OrderDoneView.h
//  YSKJ
//
//  Created by YSKJ on 17/7/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderDoneView : UIView

-(instancetype)initWithFrame:(CGRect)frame priceArray:(NSArray*)titleArray;

@property (nonatomic,strong) UIButton *selectOrder;

@end
