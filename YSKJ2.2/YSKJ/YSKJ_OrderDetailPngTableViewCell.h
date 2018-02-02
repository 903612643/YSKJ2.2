//
//  YSKJ_OrderDetailPngTableViewCell.h
//  YSKJ
//
//  Created by YSKJ on 17/8/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_OrderDetailPngCollectionViewCell.h"

@interface YSKJ_OrderDetailPngTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *_collect;
}


@property (nonatomic, strong) UIButton *productImage;

@property (nonatomic, strong) UILabel *proName;

@property (nonatomic, strong) UILabel *standardLable;

@property (nonatomic, strong) UILabel *beizhuLable;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *proNameStr;

@property (nonatomic, copy) NSString *standardLableStr;

@property (nonatomic, copy) NSString *beizhuLableStr;

@property (nonatomic, copy) NSArray *priceArr;




@end
