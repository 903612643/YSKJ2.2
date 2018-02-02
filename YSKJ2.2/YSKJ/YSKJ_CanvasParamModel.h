//
//  YSKJ_CanvasParamModel.h
//  YSKJ
//
//  Created by YSKJ on 17/6/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_CanvasParamModel : NSObject

/*
 NSDictionary *dict=@{@"x":x,
 @"y":y,
 @"w":w,
 @"h":h,
 @"url":urlStr,
 @"imageTag":imageTag,
 @"pro_id":proid,
 @"picModle":picModStr,
 @"mirror":mirror,
 @"centerX":centerX,
 @"centerY":centerY,
 @"rotate":rotate,
 @"pattern":pattern,
 @"lineW":lineW,
 @"contorlPoint":contorlPointArray,
 @"netW":netW,
 @"netH":netH,
 @"lockState":lockState,
 @"borderPoint":bordePoint
 };
 */

@property (nonatomic ,copy) NSString *x;
@property (nonatomic ,copy) NSString *y;
@property (nonatomic ,copy) NSString *w;
@property (nonatomic ,copy) NSString *h;
@property (nonatomic ,copy) NSString *url;
@property (nonatomic ,copy) NSString *imageTag;
@property (nonatomic ,copy) NSString *pro_id;
@property (nonatomic ,copy) NSString *picModle;
@property (nonatomic ,copy) NSString *mirror;
@property (nonatomic ,copy) NSString *centerX;
@property (nonatomic ,copy) NSString *centerY;
@property (nonatomic ,copy) NSString *rotate;
@property (nonatomic ,copy) NSString *pattern;
@property (nonatomic ,copy) NSString *lineW;
@property (nonatomic ,copy) NSMutableArray *contorlPoint;
@property (nonatomic ,copy) NSString *netW;
@property (nonatomic ,copy) NSString *netH;
@property (nonatomic ,copy) NSString *lockState;
@property (nonatomic ,copy) NSMutableArray *borderPoint;


@end
