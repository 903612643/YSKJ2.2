//
//  TownsModel.h
//  BelovedHotel
//
//  Created by 至爱 on 16/11/29.
//  Copyright © 2016年 至爱. All rights reserved.
//

#import "BaseModel.h"
// 区
@interface TownsModel : BaseModel
@property (nonatomic,copy)NSString *geoId;// 城市id
@property (nonatomic,copy)NSString *geoNameLocal;// 城市名字
@property (nonatomic,copy)NSString *geoCodeNumeric;// 城市编码
@end
