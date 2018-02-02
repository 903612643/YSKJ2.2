//
//  YSKJ_UTCDataCalss.m
//  YunSungStoreDemo1
//
//  Created by YSKJ on 16/11/2.
//  Copyright © 2016年 YSKJ. All rights reserved.
//

#import "YSKJ_UTCDataCalss.h"

@implementation YSKJ_UTCDataCalss

/**
 *  将 UTC 时间转换为字符串
 *
 *  @param UTC    将 UTC 时间转换为字符串
 *  @param format @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return 字符串
 */
+ (NSString *)utcToDateString:(int)UTC dateFormat:(NSString *)format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:UTC]];
    return dateString;
}

/**
 *  将字符串转换为 UTC 时间
 *
 *  @param date_string 时间字符串
 *  @param format      @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return utc 时间
 */
+ (int)dateFormatToUTC:(NSString *)date_string dateFormat:(NSString*)format {
    
    int utc = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    utc = [[dateFormatter dateFromString:date_string] timeIntervalSince1970];
    return utc;
}


@end
