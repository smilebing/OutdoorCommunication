//
//  DaoHangMapVC.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/3.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>


@interface DaoHangMapVC : UIViewController
@property (nonatomic, assign) id<EMLocationViewDelegate> delegate;

//传入坐标和扩展信息
- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate extendMsg:(NSDictionary * )extMsg ;
@end
