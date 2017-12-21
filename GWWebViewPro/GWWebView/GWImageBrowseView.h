//
//  GWImageBrowseView.h
//  GWWebViewPro
//
//  Created by genwei yang on 2017/12/20.
//  Copyright © 2017年 YangGenWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWImageBrowseView : UIView


/**
 快速构建图片浏览器

 @param images 图片列表（储存图片下载地址）
 @param selectedImagePath 图片地址
 @return <#return value description#>
 */
+ (instancetype)browseImages:(NSArray *)images
               selectedImagePath:(NSString *)selectedImagePath;

@end
