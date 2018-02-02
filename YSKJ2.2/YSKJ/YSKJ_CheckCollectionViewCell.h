//
//  YSKJ_CheckCollectionViewCell.h
//  YSKJ
//
//  Created by YSKJ on 17/6/13.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_CheckCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic)UIButton *button;
@property (strong, nonatomic)UILabel *titleLable;
@property (strong, nonatomic)UILabel *priceLable;

@property (copy, nonatomic)NSString *url;
@property (copy, nonatomic)NSString *title;
@property (copy, nonatomic)NSString *price;


@end
