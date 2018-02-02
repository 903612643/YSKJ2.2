//
//  YSKJ_OrderDetailTableViewCell.h
//  YSKJ
//
//  Created by YSKJ on 17/7/27.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSKJ_OrderListCollectionViewCell.h"

@interface YSKJ_OrderDetailTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSArray *_list;
    UICollectionView *_collect;
}

@property (nonatomic,strong) UILabel *date;

@property (nonatomic,strong) UILabel *name;

@property (nonatomic,strong) UIButton *faceImage;

@property (nonatomic,strong) UILabel *number;

@property (nonatomic,strong) UILabel *totailePrice;

@property (nonatomic,strong) UILabel *waitPass;

@property (nonatomic,strong) UIImageView *arrowsImage;

@property (nonatomic,strong) NSDictionary *obj;

@property (nonatomic,retain) NSString *nameStr;

@property (nonatomic,retain) NSString *dateStr;

@property (nonatomic,retain) NSString *numberStr;

@property (nonatomic,retain) NSString *totailePriceStr;

@property (nonatomic,retain) NSString *waitPassStr;

@property (nonatomic,strong) UIButton *button;

@property (nonatomic,strong) UIImageView *orderCancleLogo;

@property (nonatomic,strong) UIView *line;

@property (nonatomic,strong) UIButton *leftBut;

@property (nonatomic,strong) UIButton *rightBut;

@property (nonatomic,assign) float width;


@end
