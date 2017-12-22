//
//  GWRootViewController.m
//  GWWebViewPro
//
//  Created by genwei yang on 2017/12/20.
//  Copyright © 2017年 YangGenWei. All rights reserved.
//

#import "GWRootViewController.h"
#import "GWImageBrowseView.h"
#import "GWWebView.h"

@interface GWRootViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic,readwrite,strong)GWImageBrowseView *imageBrowseView;
@property (nonatomic,readwrite,strong)NSMutableArray *image_list;
@end

@implementation GWRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.image_list = [NSMutableArray array];
    NSString *htmlURL = @"http://www.jianshu.com/p/058671d37f4d";
    GWWebView *webView = [GWWebView createNormalWithFrame:(CGRect){0,64,kSCREENWIDTH,kSCREENHEIGHT}];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:htmlURL]];
    [webView loadRequest:request];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    [self.view addSubview:webView];
    
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    static  NSString * const imagesJS =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [webView evaluateJavaScript:imagesJS completionHandler:nil];
    [webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSArray *urlArray = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"+"]];
        //里面如果有空的需要过滤掉
        if(self.image_list.count==0){
            for (NSString *tempURL in urlArray) {
                if(!kStringIsEmpty(tempURL)){
                    [self.image_list addObject:tempURL];
                }
            }
        }
    }];
    
    [webView evaluateJavaScript:@"function registerImageClickAction(){\
     var imgs = document.getElementsByTagName('img');\
     for(var i=0;i<imgs.length;i++){\
     imgs[i].customIndex = i;\
     imgs[i].onclick=function(){\
     window.location.href=''+this.src;\
     }\
     }\
     }" completionHandler:nil];
    
    [webView evaluateJavaScript:@"registerImageClickAction();"completionHandler:nil];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //如果是跳转一个新页面
    if (navigationAction.targetFrame.request != nil) {
        NSString *selectedImgURL = navigationAction.request.URL.absoluteString;
        self.imageBrowseView = [GWImageBrowseView browseImages:self.image_list selectedImagePath:selectedImgURL];
        [self.view addSubview:self.imageBrowseView];
         decisionHandler(WKNavigationActionPolicyCancel);
    }else{
       decisionHandler(WKNavigationActionPolicyAllow);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
