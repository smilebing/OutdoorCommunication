//
//  DaoHangMapVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/3.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "DaoHangMapVC.h"

@interface DaoHangMapVC ()<CLLocationManagerDelegate,MAMapViewDelegate>

    //目的地的坐标
@property    CLLocationCoordinate2D  destCoordinate;
@property    NSDictionary * extMsg;
@property (nonatomic,strong) MAMapView * mapView;

@end

@implementation DaoHangMapVC


- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate extendMsg:(NSDictionary * )extMsg
{
    self = [super initWithNibName:nil bundle:nil];
    self.destCoordinate = locationCoordinate;
    self.extMsg=extMsg;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    _mapView.showsCompass= YES; // 设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 62); //设置指南针位置
    
    _mapView.showsScale= YES;  //设置成NO表示不显示比例尺；YES表示显示比例尺
    
    _mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 62);  //设置比例尺位置
    
    ///把地图添加至view
    [self.view addSubview:_mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = self.destCoordinate;
    pointAnnotation.title = [_extMsg objectForKey:@"title"];
    pointAnnotation.subtitle = [_extMsg objectForKey:@"detail"];
    
    [_mapView addAnnotation:pointAnnotation];

}

#pragma mark - Map Delegate

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = YES;
        annotationView.draggable                    = NO;
        //annotationView.rightCalloutAccessoryView    =self.shareButton;       // annotationView.pinColor                     = [self.annotations indexOfObject:annotation] % 3;
        
        return annotationView;
    }
    
    return nil;
}




@end
