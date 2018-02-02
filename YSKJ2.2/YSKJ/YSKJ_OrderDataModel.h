//
//  YSKJ_OrderDataModel.h
//  YSKJ
//
//  Created by YSKJ on 17/7/31.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_OrderDataModel : NSObject

//color = "";
//desc = "";
//name = "\U6cd5\U5f0f\U5e03\U827a\U4f11\U95f2\U6905";
//num = 1;
//pid = 10376;
//price = "19435.00";
//"real_price" = "19435.00";
//size = "W700*D800*H1190mm";
//"thumb_file" = "store/x24007/1.png";

@property (nonatomic,retain) NSString *color;
@property (nonatomic,retain) NSString *desc;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *num;
@property (nonatomic,retain) NSString *pid;
@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *real_price;
@property (nonatomic,retain) NSString *size;
@property (nonatomic,retain) NSString *thumb_file;

@end
