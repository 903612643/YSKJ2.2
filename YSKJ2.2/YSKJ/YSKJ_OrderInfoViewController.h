//
//  YSKJ_OrderInfoViewController.h
//  YSKJ
//
//  Created by YSKJ on 17/7/6.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderInfoViewController : UIViewController

@property (nonatomic,retain) NSMutableArray *orderList;

@property (nonatomic,retain) NSMutableArray *orderArray;

@property (nonatomic,retain) NSString *proNumber;

@property (nonatomic,retain) NSString *totailePrice;

@property (nonatomic,retain) NSString *discount;

@property (nonatomic, strong) UILabel *standardLable;



@end
