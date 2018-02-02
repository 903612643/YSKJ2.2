//
//  YSKJ_ProjectPlanCollectionViewCell.h
//  YSKJ
//
//  Created by YSKJ on 17/6/20.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_ProjectPlanCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIButton *delButton;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;

@end
