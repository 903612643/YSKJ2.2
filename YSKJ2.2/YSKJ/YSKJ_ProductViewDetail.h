//
//  YSKJ_ProductViewDetail.h
//  YSKJ
//
//  Created by YSKJ on 17/9/14.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_PicCollectionViewCell.h"

@interface YSKJ_ProductViewDetail : UIView<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSArray *_list;
    NSArray *_picArr;
    NSInteger _selectIndex;
}

@property (nonatomic ,strong) UILabel *productTitle;

@property (nonatomic ,strong) UILabel *productPrice;

@property (nonatomic ,strong) UILabel *productTexture;

@property (nonatomic, strong) UICollectionView *collect;

@property (nonatomic, strong) YSKJ_PicCollectionViewCell *proImageCell;

@property (nonatomic,strong) NSDictionary *obj;

@property (nonatomic,strong) NSString *picStr;



@end
