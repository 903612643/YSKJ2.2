//
//  YSKJ_TargetDataView.h
//  YSKJ
//
//  Created by YSKJ on 17/9/1.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_TargetDataView : UIView

typedef void (^selectIndexBlock)(NSInteger selectIndex);

@property (nonatomic, copy) selectIndexBlock selectBlock;

@property (nonatomic, strong)UILabel *totalePrice;

@property (nonatomic, strong)UILabel *finishPrice;

@property (nonatomic ,copy) NSArray *titeleArray;

@property (nonatomic, copy)NSString *totalePriceStr;

@property (nonatomic, copy)NSString *finishPriceStr;

@end
