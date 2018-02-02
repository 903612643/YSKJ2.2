//
//  YSKJ_OrderNaviBarView.h
//  YSKJ
//
//  Created by YSKJ on 17/9/11.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_OrderNaviBarView : UIView

@property (nonatomic ,copy) NSArray *titeleArray;

typedef void (^selectIndexBlock)(NSInteger selectIndex);

@property (nonatomic, copy) selectIndexBlock selectBlock;

@end
