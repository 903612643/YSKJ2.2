//
//  YSKJ_MyPerformanceView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_SaleKlineView.h"

@interface YSKJ_SalesReportView : UIView
{
    YSKJ_SaleKlineView *saleKlineView;
}

@property (nonatomic, copy)NSArray *array;

@end
