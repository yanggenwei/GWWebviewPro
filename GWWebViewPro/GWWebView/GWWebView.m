//
//  GWWebView.m
//  GWWebViewPro
//
//  Created by genwei yang on 2017/12/19.
//  Copyright © 2017年 YangGenWei. All rights reserved.
//

#import "GWWebView.h"
@interface GWWebView()
@property (nonatomic,readwrite,strong)UIProgressView *progressView;
@end

@implementation GWWebView

+ (instancetype)createNormalWithFrame:(CGRect)frame{
    return [[GWWebView alloc] initWithFrame:frame configuration:[self wkWebConfig]];
}

+ (WKWebViewConfiguration *)wkWebConfig{
    
    
    WKWebViewConfiguration *config  = [[WKWebViewConfiguration alloc]init];
    //设置进程池
    WKProcessPool * pool = [[WKProcessPool alloc]init];
    config.processPool = pool;
    //进行偏好设置
    WKPreferences * preference = [[WKPreferences alloc]init];
    //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
    preference.minimumFontSize = 10 ;
    //设置是否支持javaScript 默认是支持的
    preference.javaScriptEnabled = YES;
    //设置是否允许不经过用户交互由javaScript自动打开窗口
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preference;
    //设置是否将网页内容全部加载到内存后再渲染
    config.suppressesIncrementalRendering = YES;
    //设置缓存策略
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];

    return config;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.scrollView.contentInset = UIEdgeInsetsMake(-0, 0, 0, 0);
        }
        self.progressView.transform = CGAffineTransformMakeScale(1.0f,0.5f);
        [self addSubview:self.progressView];
        [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration{
    if(self = [super initWithFrame:frame configuration:configuration]){
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.scrollView.contentInset = UIEdgeInsetsMake(-0, 0, 0, 0);
        }
        self.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.5f);
        [self addSubview:self.progressView];
        [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.estimatedProgress;
        if (self.progressView.progress == 1) {
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.5f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.progressView.alpha = 0;
                }];
            }];
        }
    }
}

- (UIProgressView *)progressView{
    if(!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:(CGRect){0,0,kSCREENWIDTH,0.5}];
        CGAffineTransform transform = CGAffineTransformMakeScale(0.5f, 0.5f);
        _progressView.transform = transform;//设定宽高
        [_progressView setTrackTintColor:hexStrColor(@"#FAFAFA")];
    }return _progressView;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"estimatedProgress"];
}
@end
