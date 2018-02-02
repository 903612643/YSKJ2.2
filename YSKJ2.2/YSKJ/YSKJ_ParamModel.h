//
//  YSKJ_ParamModel.h
//  YSKJ
//
//  Created by YSKJ on 17/6/14.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_ParamModel : NSObject

//http://www.5164casa.com/api/saas/store/list?cateid=1&page=3&order=sale_amount&ordername=desc&keyword=&style=&space=&category=&source=&pagenum=20

@property (nonatomic, copy) NSString *cateid;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, copy) NSString *order;
@property (nonatomic, copy) NSString *ordername;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *style;
@property (nonatomic, copy) NSString *space;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *pagenum;


@end
