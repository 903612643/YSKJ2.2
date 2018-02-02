//
//  YSKJ_UTCDataCalss.h
//  YunSungStoreDemo1
//
//  Created by YSKJ on 16/11/2.
//  Copyright © 2016年 YSKJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_UTCDataCalss : NSObject

/**
 *  将 UTC 时间转换为字符串
 *
 *  @param UTC    utc时间
 *  @param format 如格式 @"yyyy-MM-dd HH:mm:ss Z"
 *
 *  @return 格式化的字符串
 */
+ (NSString *)utcToDateString:(int)UTC dateFormat:(NSString *)format;

/**
 *  将字符串转换为 UTC 时间
 *
 *  @param date_string 时间字符串
 *  @param format      @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return utc 时间
 */
+ (int)dateFormatToUTC:(NSString *)date_string dateFormat:(NSString*)format;

@end
