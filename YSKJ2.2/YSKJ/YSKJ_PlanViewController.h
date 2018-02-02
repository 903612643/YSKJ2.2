//
//  YSKJ_PlanViewController.h
//  YSKJ
//
//  Created by 羊德元 on 2016/12/3.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_PlanViewController : UIViewController
{
    NSString *_planName;
    
    NSString *_projectName;
}

@property (nonatomic,retain) NSMutableArray *proDuctArray;

@property (nonatomic,retain) NSMutableDictionary *param;

@property (nonatomic,getter=operatingMode) BOOL operatingMode; // default is YES Add An Plan. if NO, Update An Plan.


@end
