//
//  GWImageBrowseView.m
//  GWWebViewPro
//
//  Created by genwei yang on 2017/12/20.
//  Copyright © 2017年 YangGenWei. All rights reserved.
//

#import "GWImageBrowseView.h"
#import <Photos/Photos.h>
#define bottomViewHeight 45

@interface GWImageBrowseView()<UIScrollViewDelegate>
@property (nonatomic,readwrite,strong)UIButton *downloadButton;
@property (nonatomic,readwrite,strong)NSArray *image_list;
@property (nonatomic,readwrite,copy)NSString *selectedImagePath;
@property (nonatomic,readwrite,strong)UIButton *backButton;
@property (nonatomic,readwrite,strong)UIScrollView *scrollView;
@end

@implementation GWImageBrowseView

#pragma mark 快速构建图片浏览
+(instancetype)browseImages:(NSArray *)images
              selectedImagePath:(NSString *)selectedImagePath{
    return [[GWImageBrowseView alloc] initWithFrame:(CGRect){0,0,kSCREENWIDTH,kSCREENHEIGHT}
                                             images:images
                                  selectedImagePath:selectedImagePath];
}

- (instancetype)initWithFrame:(CGRect)frame
                       images:(NSArray *)images
            selectedImagePath:(NSString *)selectedImagePath{
    if(self = [super initWithFrame:frame]){
        self.image_list = images;
        self.selectedImagePath = selectedImagePath;
        [self createSubView];
    }
    return self;
}

#pragma mark 创建子视图
- (void)createSubView{
//    CALayer *topLayer = [CALayer new];
//    [topLayer setBackgroundColor:[UIColor blackColor].CGColor];
//    [topLayer setFrame:(CGRect){0,0,kSCREENWIDTH,kSCREENHEIGHT*0.25}];
//    [self.layer addSublayer:topLayer];
    
//    CALayer *bottomLayer = [CALayer new];
//    [bottomLayer setBackgroundColor:[UIColor blackColor].CGColor];
//    [bottomLayer setFrame:(CGRect){0,marginTop(self.scrollView),kSCREENWIDTH,kSCREENHEIGHT*0.25}];
//    [self.layer addSublayer:bottomLayer];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:(CGRect){0,kSCREENHEIGHT-bottomViewHeight,kSCREENWIDTH,bottomViewHeight}];
    [bottomView setBackgroundColor:hexStrColor(@"#3D3D3D")];
    [bottomView addSubview:self.downloadButton];
    [bottomView addSubview:self.backButton];
    [self addSubview:bottomView];
    

    UIImageView *imageView = nil;
    int imageX = 0;
    for (NSString *imgPath in self.image_list) {
        imageView = [[UIImageView alloc] initWithFrame:(CGRect){kSCREENWIDTH*imageX++,0,kSCREENWIDTH,kSCREENHEIGHT}];
//        [imageView setBackgroundColor:[UIColor whiteColor]];
        [imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        imageView.clipsToBounds  = YES;
       
        [self.scrollView addSubview:imageView];
        [self downloadImageWithPath:imgPath imageView:imageView];
    }
    [self addSubview:self.scrollView];
    
    NSInteger selectedIndex = [self getSelectedImageIndex];
    [self.scrollView setContentOffset:(CGPoint){kSCREENWIDTH*selectedIndex,0}];
}


#pragma mark 加载网络图片
- (void)downloadImageWithPath:(NSString *)imagePath
                    imageView:(UIImageView *)imageView{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"downloadUrl:%@",imagePath);
        NSURL *downloadUrl = [NSURL URLWithString:imagePath];
        NSData *data = [NSData dataWithContentsOfURL:downloadUrl];
        UIImage *image = [UIImage imageWithData:data] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image){
                [SVProgressHUD dismiss];
                [imageView setImage:image];
            }else{
                [SVProgressHUD showInfoWithStatus:@"图片加载失败"];
            }
        });
    });
}

#pragma mark 获取选中的图片下标
- (NSInteger)getSelectedImageIndex{
    int index = 0;
    for (NSString *path in self.image_list) {
        if([path isEqualToString:self.selectedImagePath]){
            return index;
        }
        index++;
    }
    return index;
}

#pragma mark 下载图片
- (void)downLoadButtonAction{
    
    NSInteger index = self.scrollView.contentOffset.x/kSCREENWIDTH;
    UIImageView *imageView = (UIImageView *)self.scrollView.subviews[index];
    UIImage *image = imageView.image;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //写入图片到相册
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success){
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        }
    }];
}

#pragma mark 返回
- (void)backAction{
    [UIView animateWithDuration:0.6 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - getter and setter
- (UIButton *)downloadButton{
    if(!_downloadButton){
        _downloadButton = [[UIButton alloc] initWithFrame:(CGRect){kSCREENWIDTH-40,bottomViewHeight/2-10,20,20}];
        [_downloadButton setBackgroundImage:[PMBTools getBuddleImage:@"download" imageType:@"png"] forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(downLoadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }return _downloadButton;
}

- (UIButton *)backButton{
    if(!_backButton){
        UIImage *image = [UIImage imageNamed:@"back"];
        _backButton = [[UIButton alloc] initWithFrame:(CGRect){15,bottomViewHeight/2-image.size.height/2,image.size.width,image.size.height}];
        [_backButton setBackgroundImage:image forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }return _backButton;
}

- (UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0,0,kSCREENWIDTH,kSCREENHEIGHT-bottomViewHeight-kSafeAreaBottomHeight}];
        [_scrollView setBackgroundColor:[UIColor blackColor]];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.maximumZoomScale = 10;
        [_scrollView setContentSize:(CGSize){kSCREENWIDTH*self.image_list.count,kSCREENHEIGHT*0.5}];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backAction)];
        [_scrollView addGestureRecognizer:tap];
    }return _scrollView;
}

@end

