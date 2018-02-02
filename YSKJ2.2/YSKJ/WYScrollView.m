

#import "WYScrollView.h"
#import "UIImageView+WebCache.h"
#import <SDAutoLayout/UIView+SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1];

#define pageSize 36

//获得RGB颜色
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)

#define pageColor RGB(67, 199, 176)

/** 滚动宽度*/
#define ScrollWidth self.frame.size.width

/** 滚动高度*/
#define ScrollHeight self.frame.size.height

@interface WYScrollView () <UIScrollViewDelegate>

@property (nonatomic, copy) NSArray *imageArray;

@end

@implementation WYScrollView
{

    __weak  UIScrollView *_scrollView;
    
    __weak  UIPageControl *_PageControl;
    
    /** 当前显示的是第几个*/
    NSInteger _currentIndex;
    
    /** 图片个数*/
    NSInteger _MaxImageCount;
    
    /** 是否是网络图片*/
    BOOL _isNetworkImage;
    
    UIImageView *subCenterimageView;
    UIImageView *subleftimageView;
    UIImageView *subrightimageView;
    
    NSTimer *_timer;
    
}

#pragma mark - 本地图片

-(instancetype)initWithFrame:(CGRect)frame WithLocalImages:(NSArray *)imageArray
{
    if (imageArray.count < 2 ) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if ( self) {
        
        _isNetworkImage = NO;
        
        /** 创建滚动view*/
        [self createScrollView];
        
        /** 加入本地image*/
        [self setImageArray:imageArray];
        
        /** 设置数量*/
        [self setMaxImageCount:_imageArray.count];
    }
    
    return self;
}

#pragma mark - 网络图片

-(instancetype)initWithFrame:(CGRect)frame WithNetImages:(NSArray *)imageArray
{
    if (imageArray.count < 2 ) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if ( self) {
        
        _isNetworkImage = YES;
        
        /** 创建滚动view*/
        [self createScrollView];
        
        /** 加入本地image*/
        [self setImageArray:imageArray];
        
        /** 设置数量*/
        [self setMaxImageCount:_imageArray.count];
    }
    
    return self;
}

#pragma mark - 设置数量

-(void)setMaxImageCount:(NSInteger)MaxImageCount
{
    _MaxImageCount = MaxImageCount;
    
     /** 复用imageView初始化*/
    [self initImageView];
    
    /** pageControl*/
    [self createPageControl];
    
    /** 定时器*/
    [self setUpTimer];
    
    /** 初始化图片位置*/
   
    [self changeImageLeft:_MaxImageCount-1 center:0 right:1];
    
}

- (void)createScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:scrollView];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    
    /** 复用，创建三个*/
    scrollView.contentSize = CGSizeMake(ScrollWidth * 3, 0);
    
    /** 设置滚动延时时间*/
    _AutoScrollDelay = 0;
    
    /** 开始显示的是第一个   前一个是最后一个   后一个是第二张*/
    _currentIndex = 0;
    
    _scrollView = scrollView;
}

-(void)setImageArray:(NSArray *)imageArray
{
    //如果是网络
    if (_isNetworkImage)
    {
        _imageArray = [imageArray copy];
        
    }else {

        _imageArray = [imageArray copy];
        
    }
}

- (void)initImageView {
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,ScrollWidth, ScrollHeight)];
    subleftimageView=[UIImageView new];
    [leftView addSubview:subleftimageView];
    subleftimageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(20, 20, 20, 20));
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(ScrollWidth, 0,ScrollWidth, ScrollHeight)];
    subCenterimageView=[UIImageView new];
    [centerView addSubview:subCenterimageView];
    subCenterimageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(20, 20, 20, 20));
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(ScrollWidth * 2, 0,ScrollWidth, ScrollHeight)];
    subrightimageView=[UIImageView new];
    [rightView addSubview:subrightimageView];
    subrightimageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(20, 20, 20, 20));
    
    [_scrollView addSubview:leftView];
    [_scrollView addSubview:centerView];
    [_scrollView addSubview:rightView];
    
}

//点击事件
- (void)imageViewDidTap
{
    [self.netDelagate didSelectedNetImageAtIndex:_currentIndex];
    [self.localDelagate didSelectedLocalImageAtIndex:_currentIndex];
}

-(void)createPageControl
{
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,ScrollHeight + pageSize,ScrollWidth, 8)];
    
    //设置页面指示器的颜色
    pageControl.pageIndicatorTintColor = [[UIColor grayColor]colorWithAlphaComponent:0.35] ;
    //设置当前页面指示器的颜色
    pageControl.currentPageIndicatorTintColor =UIColorFromHex(0xf39800) ;
    pageControl.numberOfPages = _MaxImageCount;
    pageControl.currentPage = 0;
    
    [self addSubview:pageControl];
    
    _PageControl = pageControl;
}

#pragma mark - 定时器

- (void)setUpTimer
{
    if (_AutoScrollDelay < 0.5) return;//太快了
    
    _timer = [NSTimer timerWithTimeInterval:_AutoScrollDelay target:self selector:@selector(scorll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)scorll
{
    NSLog(@"dsjfklasdfksdfl;sdfjs;dfk");
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x +ScrollWidth, 0) animated:YES];
}

#pragma mark - 给复用的imageView赋值

- (void)changeImageLeft:(NSInteger)LeftIndex center:(NSInteger)centerIndex right:(NSInteger)rightIndex
{
    if (_isNetworkImage)
    {
        NSURL *leftUrl=[NSURL URLWithString:_imageArray[LeftIndex]];
        [self upDataLayoutViewUrl:leftUrl subView:subleftimageView];
        
        
        NSURL *centerUrl=[NSURL URLWithString:_imageArray[centerIndex]];
        [self upDataLayoutViewUrl:centerUrl subView:subCenterimageView];
        
        
        NSURL *rigUrl=[NSURL URLWithString:_imageArray[rightIndex]];
        [self upDataLayoutViewUrl:rigUrl subView:subrightimageView];
        
    }else
    {
        
        [self upDataLocalLayoutSubView:subleftimageView picStr:_imageArray[LeftIndex]];
        [self upDataLocalLayoutSubView:subCenterimageView picStr:_imageArray[centerIndex]];
        [self upDataLocalLayoutSubView:subrightimageView picStr:_imageArray[rightIndex]];
        
    }
    
    [_scrollView setContentOffset:CGPointMake(ScrollWidth, 0)];
}
//本地图片等比例缩放
-(void)upDataLocalLayoutSubView:(UIImageView *)subView picStr:(NSString*)picStr
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSArray  *picArr= [picStr componentsSeparatedByString:@"/"];
    
    NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",path,picArr[0],picArr[1]];
    
    NSString *fullPath = [imagePath stringByAppendingPathComponent:picArr[2]];
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fullPath];

    float supViewW=subView.superview.frame.size.width;
    
    if (image.size.width>=image.size.height) {
        
        float scaleW=supViewW/image.size.width;
        float top=(supViewW-image.size.height*scaleW)/2;
        float bot=top;
        
        float lef=(supViewW-image.size.width*scaleW)/2;
        float rig=lef;
        
        subView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(top, lef, bot, rig));
        [subView updateLayout];
        
        
    }else{
        
        float scaleH=supViewW/image.size.height;
        float top=(supViewW-image.size.height*scaleH)/2;
        float bot=top;
        
        float lef=(supViewW-image.size.width*scaleH)/2;
        float rig=lef;
        
        subView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(top, lef, bot, rig));
        [subView updateLayout];
        
    }
    subView.image=image;
}
//网络图片等比例缩放
-(void)upDataLayoutViewUrl:(NSURL *)url subView:(UIImageView *)subView
{
    //获取网络图片的Size
    [subView sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        float supViewW=subView.superview.frame.size.width;
        
        if (image.size.width>0 && image.size.height>0) {
            
            if (image.size.width>=image.size.height) {
                
                float scaleW=supViewW/image.size.width;
                float top=(supViewW-image.size.height*scaleW)/2;
                float bot=top;
                
                float lef=(supViewW-image.size.width*scaleW)/2;
                float rig=lef;
                
                subView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(top, lef, bot, rig));
                [subView updateLayout];
                
                
            }else{
                
                float scaleH=supViewW/image.size.height;
                float top=(supViewW-image.size.height*scaleH)/2;
                float bot=top;
                
                float lef=(supViewW-image.size.width*scaleH)/2;
                float rig=lef;
                
                subView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(top, lef, bot, rig));
                [subView updateLayout];
            }

        }
 
    }];
}

#pragma mark - 滚动代理

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self setUpTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)removeTimer
{
    if (_timer == nil) return;
    [_timer invalidate];
    _timer = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //开始滚动，判断位置，然后替换复用的三张图
    [self changeImageWithOffset:scrollView.contentOffset.x];
}

- (void)changeImageWithOffset:(CGFloat)offsetX
{
    if (offsetX >= ScrollWidth * 2)
    {
        _currentIndex++;
        
        if (_currentIndex == _MaxImageCount-1)
        {
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:0];
            
        }else if (_currentIndex == _MaxImageCount)
        {
            
            _currentIndex = 0;
            
            [self changeImageLeft:_MaxImageCount-1 center:0 right:1];
            
        }else
        {
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:_currentIndex+1];
        }
        _PageControl.currentPage = _currentIndex;
        
    }
    
    if (offsetX <= 0)
    {
        _currentIndex--;
        
        if (_currentIndex == 0) {
            
            [self changeImageLeft:_MaxImageCount-1 center:0 right:1];
            
        }else if (_currentIndex == -1) {
            
            _currentIndex = _MaxImageCount-1;
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:0];
            
        }else {
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:_currentIndex+1];
        }
        
        _PageControl.currentPage = _currentIndex;
    }
    
}

-(void)dealloc
{
    
    [self removeTimer];
}

#pragma mark - set方法，设置间隔时间

- (void)setAutoScrollDelay:(NSTimeInterval)AutoScrollDelay
{
    _AutoScrollDelay = AutoScrollDelay;
    
  //  [self removeTimer];
  //   [self setUpTimer];
}



@end