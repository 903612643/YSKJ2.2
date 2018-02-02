//
//  YSKJ_FuritureInfoViewController.h
//  YSKJ
//
//  Created by YSKJ on 16/11/14.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_FuritureInfoViewController : UIViewController
{
    NSDictionary *_productInfo;
}

@property (nonatomic,retain)NSString *proDuctId;

@property (nonatomic,strong)UILabel *borLable;

@property (nonatomic,strong)UIButton *subtract;

@property (nonatomic,strong)UIButton *addProduct;

@end
