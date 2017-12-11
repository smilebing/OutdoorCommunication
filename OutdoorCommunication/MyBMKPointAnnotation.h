//
//  MyBMKPointAnnotation.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/6.
//  Copyright © 2017年 朱贺. All rights reserved.
//
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>


@interface MyBMKPointAnnotation : BMKPointAnnotation
//群组id
@property(nonatomic,copy) NSString * groupID;
@end
