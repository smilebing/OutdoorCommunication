//
//  MyLocationService.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/12.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface MyLocationService : NSObject<BMKLocationServiceDelegate>

//单例
+ (instancetype)sharedInstance;

//初始化参数
-(void)initParameter;

//开始长传位置信息
-(void)starUploadLocService;

//停止上传位置信息
-(void)stopUploadLocService;
@end
