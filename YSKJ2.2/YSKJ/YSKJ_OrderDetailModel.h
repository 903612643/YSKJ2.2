//
//  YSKJ_OrderDetailModel.h
//  YSKJ
//
//  Created by YSKJ on 17/7/28.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_OrderDetailModel : NSObject

//"user_id": 91,
//"last_time": 1501209869,
//"data_info":
//"id": 191,
//"name": "买一件",
//"create_time": 1501209868,
//"status2": "无",
//"status": "意向确认",
//"sale_time": 0,
//"pay_info": "{}",
//"price": "19435"

@property (nonatomic,retain) NSString *user_id;
@property (nonatomic,retain) NSString *last_time;
@property (nonatomic,retain) NSDictionary *data_info;
@property (nonatomic,retain) NSString *projectId;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *create_time;
@property (nonatomic,retain) NSString *status2;
@property (nonatomic,retain) NSString *status;
@property (nonatomic,retain) NSString *sale_time;
@property (nonatomic,retain) NSString *pay_info;
@property (nonatomic,retain) NSString *price;



@end
