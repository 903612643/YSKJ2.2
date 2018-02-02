//
//  YSKJ_InfoModel.h
//  YSKJ
//
//  Created by YSKJ on 16/11/21.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_InfoModel : NSObject

@property (nonatomic,copy)NSString *p_no;
@property (nonatomic,copy)NSString *type_no;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *category_id;
@property (nonatomic,copy)NSString *market_price;
@property (nonatomic,copy)NSString *price;
@property (nonatomic,copy)NSString *thumb_file;
@property (nonatomic,copy)NSArray *desc_img;
@property (nonatomic,copy)NSString *attributes;
@property (nonatomic,copy)NSString *desc_model;
@property (nonatomic,copy)NSString *isFav;
@property (nonatomic,copy)NSArray *other_good;

@end
