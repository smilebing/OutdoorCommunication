//
//  MyLocationService.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/12.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "MyLocationService.h"
#import "UserLocationManage.h"

static MyLocationService *sharedInstance = nil;


@implementation MyLocationService
{
    BMKLocationService * locService;
    NSThread * uploadThread;
}

//单例
+ (instancetype)sharedInstance{
    if(nil==sharedInstance)
    {
        sharedInstance=[[MyLocationService alloc]init];
    }
    return sharedInstance;
}

//初始化参数
-(void)initParameter
{
    if(uploadThread==nil)
    {
        uploadThread=[[NSThread alloc]initWithTarget:self selector:@selector(upload) object:nil];
    }
    
    if(locService==nil)
    {
        locService=[[BMKLocationService alloc]init];
        locService.delegate=self;
        [locService startUserLocationService];
    }
 }



//开始长传位置信息
-(void)starUploadLocService
{
    [uploadThread start];
}

//停止上传位置信息
-(void)stopUploadLocService
{
    if(nil!=locService)
    {
        [locService stopUserLocationService];
    }
    [uploadThread cancel];
    uploadThread=nil;
}


//循环上传位置
-(void)upload
{
    while (true) {
        
        //判断线程是否停止
        if([[NSThread currentThread ]isCancelled])
        {
            [NSThread exit];
        }

        BMKUserLocation * userLoc= [locService userLocation];
        UserLocationManage * locManage=[UserLocationManage sharedInstance];
        
        
        if(userLoc.location.coordinate.longitude==0 && userLoc.location.coordinate.latitude==0)
        {
            NSLog(@"排除未定位的坐标");
            [NSThread sleepForTimeInterval:30];
            continue;
        }
        
        //构造位置信息json
        NSNumber *longitude=[NSNumber numberWithDouble: userLoc.location.coordinate.longitude];
        NSNumber * latitude=[NSNumber numberWithDouble: userLoc.location.coordinate.latitude];
        
        
        NSDictionary * loc=@{@"longitude":longitude,
                             @"latitude":latitude};
        NSString * locStr= [loc JSONString];
        
        
        //上传
        [locManage uploadUserLocation:[[EMClient sharedClient] currentUsername ] location:locStr completion:^(BOOL success, NSError *error) {
            if(!success)
            {
                NSLog(@"上传用户位置信息出错：%@",error);
            }
            else
            {
                //NSLog(@"位置上报成功");
            }
        }];
        
        //间隔30秒
        [NSThread sleepForTimeInterval:30];
 
    }

}

@end
