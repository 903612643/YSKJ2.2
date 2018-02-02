//
//  YSKJ_OrderOperationView.h
//  YSKJ
//
//  Created by YSKJ on 17/9/12.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    
    CustomerLoss = 0,  //客户流失
    StageOfSuccess,   //进入成功阶段
    PayInAdvance,     //提交定金
    PayTheFirst,      //支付首款
    PayTheBalancePayment  //支付尾款
    
}orderType;

@interface YSKJ_OrderOperationView : UIView

typedef void (^filishBlock)(void);

@property (nonatomic, strong)UILabel *titleLab;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UIButton *cancleBut;

@property (nonatomic, strong)UIButton *sureBut;

@property (nonatomic, assign)orderType status;

@property (nonatomic, copy)NSString *projectId;

@property (nonatomic, copy)filishBlock block;

+(void)operationOrderWithText:(NSString*)text type:(orderType)type projectId:(NSString*)projectId filishBlock:(filishBlock)block;

@end
