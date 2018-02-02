//
//  YSKJ_SaveWebImageClass.h
//  YSKJ
//
//  Created by YSKJ on 17/2/10.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YSKJ_SaveWebImageClass : NSObject

//保存图片  图片文件夹名：shopfloder   图片地址：imageUrl 保存图片名称：imageName 保存图片类型：type
-(void)SaveShopPicFloder:(NSString*)allPicFloder p_no:(NSString *)shopfloder imageUrl:(NSString *)imageUrl SaveFileName:(NSString *)imageName SaveFileType:(NSString *)type image:(UIImage*)image size:(CGSize)size;

//将所下载的图片保存到本地
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;


@end
