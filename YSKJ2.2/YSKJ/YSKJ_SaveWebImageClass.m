//
//  YSKJ_SaveWebImageClass.m
//  YSKJ
//
//  Created by YSKJ on 17/2/10.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_SaveWebImageClass.h"

@implementation YSKJ_SaveWebImageClass

//保存图片  图片文件夹名：shopfloder   图片地址：imageUrl 保存图片名称：imageName 保存图片类型：type
-(void)SaveShopPicFloder:(NSString*)allPicFloder p_no:(NSString *)shopfloder imageUrl:(NSString *)imageUrl SaveFileName:(NSString *)imageName SaveFileType:(NSString *)type image:(UIImage*)image size:(CGSize)size
{
    //用于保存图片的路径
    NSString *PathShopPic= [self PicPath:allPicFloder p_no:shopfloder];
    
    //Get Image From URL
    UIImage * imageFromURL;    //url为nil直接传image,否则传网络图片
    if (imageUrl==nil) {
        //对图片进行裁剪
        imageFromURL = [self imageWithImageSimple:image scaledToSize:CGSizeMake(size.width, size.height)];
    }else{
        imageFromURL = [self getImageFromURL:imageUrl];

    }
    //Save Image to Directory
    [self saveImage:imageFromURL withFileName:imageName ofType:type inDirectory:PathShopPic];
    
}

//绝对路径
-(NSString *)pathDocument
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return path;
    
}

//图片文件路径 ：绝对路径+商品文件夹+图片资源
-(NSString *)PicPath:(NSString *)allPicFloder p_no:(NSString *)shopfloder
{
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *PathShopPic = [NSString stringWithFormat:@"%@/%@/%@",[self pathDocument],allPicFloder,shopfloder];
    
   // NSLog(@"PathShopPic=%@",PathShopPic);
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:PathShopPic]) {
        
        [fileManager createDirectoryAtPath:PathShopPic withIntermediateDirectories:YES attributes:nil error:nil];
        
    }else{
        //  NSLog(@"有这个文件了");
    }
    
    return PathShopPic;
    
}

//从网络下载图片
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    // NSLog(@"执行图片下载函数");
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

//将图片保存到本地
-(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath
{
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        //ALog(@"Image Save Failed\\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        NSLog(@"文件后缀不认识");
    }
    
}

//裁剪成300*300像素的图片
- ( UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:( CGSize )newSize
{
    UIGraphicsBeginImageContext (newSize);
    
    [image drawInRect : CGRectMake ( 0 , 0 ,newSize. width ,newSize. height )];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext ();
    
    // End the context
    
    UIGraphicsEndImageContext ();
    
    // Return the new image.
    return newImage;
}


@end
