//
//  YSKJ_TitleView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/29.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_TitleView : UIView

typedef void (^selectIndexBlock)(NSInteger selectIndex);

@property (nonatomic, copy) selectIndexBlock indexBlock;

@property (nonatomic, assign) NSInteger selectIndex;

@end
