//
//  ToolClass.h
//  YSKJ
//
//  Created by YSKJ on 16/12/14.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolClass : NSObject

+(BOOL)phone:(NSString *)phoneStr;
+(BOOL)JudgeTheillegalCharacter:(NSString *)content;
//json解析字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//json解析数组
+ (NSArray *)arrayWithJsonString:(NSString *)jsonString;
//字典解析json
+ (NSString *)stringWithDict:(NSDictionary *)dict;
+(NSString *)removeUnescapedCharacter:(NSString *)inputStr;

+ (NSString *)utcToDateString:(int)UTC dateFormat:(NSString *)format;

+ (int)dateFormatToUTC:(NSString *)date_string dateFormat:(NSString*)format;

@end
