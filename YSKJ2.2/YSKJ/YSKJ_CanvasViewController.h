//
//  YSKJ_CanvasViewController.h
//  YSKJ
//
//  Created by YSKJ on 16/12/1.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_CanvasDictionaryKey.h"

#import "YSKJ_FavProductCollectionViewCell.h"

#import "YSKJ_ProDuctModel.h"

#import "ToolClass.h"

#import "YSKJ_TipViewCalss.h"

#import "YSKJ_ProDetaileViewController.h"

#import "YSKJ_CanvasParamModel.h"

#import <Qiniu/QiniuSDK.h>

#import "NSString+MD5.h"

#import "AnimatedGif.h"

#import "YSKJ_setUpProductInCanvas.h"

#import "YSKJ_CanvasnavigationView.h"

#import "YSKJ_CanvasSediBarView.h"

#import "YSKJ_CanvasTransfromView.h"

#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <AGGeometryKit/AGGeometryKit.h>

#import <POPAnimatableProperty+AGGeometryKit.h>

#import <pop/POP.h>

#import <SDWebImage/UIButton+WebCache.h>

#import <MJExtension/MJExtension.h>

#import "YSKJ_SaveWebImageClass.h"

#import "YSKJ_ProductViewDetail.h"

typedef NS_ENUM(NSInteger,AddProDuctType) {
    AddStroeProDuct     = 1,
    AddSpaceBgProDuct   = 2,
    CopyState           = 3,
    PanStroeProDuct     = 4,
};

typedef NS_ENUM(NSInteger,operationType) {
    copy             = 2001,
    transformation   = 2002,
    mirroring        = 2003,
    delete           = 2004,
    lock             = 2005,
    stick            = 2006,
    moveup           = 2007,
    movedown         = 2008,
    bottom           = 2009,
    sure             = 2010,
    cancel           = 2011,
    
};

@interface YSKJ_CanvasViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate,DatabaseManagerDelegate,YSKJ_LabelLayoutDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIButton  *canasView,*theFilterCanbutton,*proDuctFilterCanclebutton,*picSubView,*checkButton,*addPicButton,*spaceFilterButton,*_panButton;
    
    UIView *proDuctFilterView,*_alertLoading,*coverView,*tempView,*thefilterView, *picModlelineView,*_panView;
    
    YSKJ_ProductViewDetail *picModleView;
    
    //变形控制点中心坐标映射到tempView上并创建View
    UIView *controlLeftTopView,*controlRightTopView,*controlBottomLeftView,*controlBottomRightView,*tempControlLeftTopView,*tempControlRightTopView,*tempControlBottomLeftView,*tempControlBottomRightView;
    //矩形框中心坐标映射到tempView上并创建View
    UIView *borderLeftTopView,*borderRightTopView,*borderBottomLeftView,*borderBottomRightView,*tempborderLeftTopView,*tempborderRightTopView,*tempborderBottomLeftView,*tempborderBottomRightView;
    
    NSString *_page,*_lable,*_style,*_type;
    
    YSKJ_CollectionViewCell* custCell;         //标签列表Cell
    
    NSMutableArray  *sureArray,*thearray,*arrUrl,*arrMod,
    *arr;    //选择标签数组
    
    NSString *dbDescModlePicStr;           //数据库3d图片字符串
    
    UILabel *productTitle,*productPrice,*productTexture;
    
    UIImage *tempImage;    //相册的原图
    
    UITableView *categoryTableView,*filterTableView;
    
    UITableViewCell *cateCell,*filterCell;
    
    //商品列表服务器请求参数
    NSString *_cateid,*_page1,*_order,*_ordername,*_keyword,*_style1,*_space,*_category,*_source,*_spagenum;
    
    NSMutableArray *_styleArray,*_spaceArray,*_categoryArray,*_brandArray,*_sourceArray,*categoryArray;
    
    //上拉下拉按钮
    UIButton *styleButton,*spaceButton,*categoryButton,*brandButton,*souresButton;
    
    //风格;空间;品类;品牌;资源父视图
    UIView *styleViewBgm,*spaceViewBgm,*categoryViewBgm,*brandViewBgm,*soureViewBgm;
    
    //选中风格数组;选中空间数组;选中品类数;选中资源数组;
    NSMutableArray *_selectStyleArray,*_selectSpaceArray,*_selectCategoryArray,*_selectSouresArray;
    
    NSTimer *Timer;            //每隔5秒自动保存方案一次
    
    CAShapeLayer *shapelayer;         //矩形框
    
    YSKJ_CanvasnavigationView *naviView;
    
    YSKJ_CanvasSediBarView *proDuctPopView;
    
    YSKJ_CanvasTransfromView *transformView;
    
}

@property (nonatomic, retain) NSMutableArray *lineArr;  //商品在线数组;

@property (nonatomic, retain) NSArray *dbDataArr;  //数据库数组;

@property (nonatomic, retain) NSMutableArray *addDataArr;  //上拉下拉数组

@property (nonatomic, strong) NSMutableArray* titles;       //标签数组

@property (nonatomic, strong) NSMutableArray* spaceArray;       //标签数组

@property (nonatomic, strong) NSMutableArray* spaceLableArray;     //空间背景分类数组

@property (nonatomic, strong) NSMutableArray* proDuctArray;     //商城数组

@property (nonatomic, strong) UICollectionView* proDuctColletionView;

@property (nonatomic, strong) UICollectionView* lablecollectionView;

@property (nonatomic, strong) UICollectionView* spaceCollectionView;

@property (nonatomic, strong) UICollectionView* spaceLableCollectionView;

@property (nonatomic, strong) UICollectionView* addProductCollectionView;

@property (nonatomic, assign) BOOL isProDuctColletionView;  //标记来自列表的数据源

@property (nonatomic,retain) NSString *projectName;

@property (nonatomic,retain) NSString *planName;

@property (nonatomic, copy) NSString* bgId;     //空间背景数组


@end
