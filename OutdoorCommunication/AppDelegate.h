//
//  AppDelegate.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/9.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <UIKit/UIKit.h>
#import <BaiduTraceSDK/BaiduTraceSDK.h>

#import "MainTabBarViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property(strong,nonatomic) BMKMapManager* mapManager;


@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) MainTabBarViewController *mainTabBarController;

@end



