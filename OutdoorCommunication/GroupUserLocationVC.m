//
//  GroupUserLocationVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "GroupUserLocationVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "UserLocationManage.h"
#import <BmobSDK/Bmob.h>

#import "SafeBMKPointAnnotation.h"
#import "TimeOutBMKPointAnnotation.h"
#import "OutOfRangeBMKPointAnnotation.h"

#import "WarningDistanceManage.h"
#import "SetWarningDistanceVC.h"

#define SAFE_RANGE 150.0

@interface GroupUserLocationVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    NSThread * refreshUserLocThread;
    NSString * groupID;
}
@property(nonatomic ,strong) BMKMapView * mapView;
@property(nonatomic,strong)BMKLocationService * locService;
@property(nonatomic,strong)BMKCircle * circle;
@end

@implementation GroupUserLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    //添加左上角bar item
    UIBarButtonItem *setDistance = [[UIBarButtonItem alloc] initWithTitle:@"设置预警距离" style:UIBarButtonItemStylePlain target:self action:@selector(setSafeDistance)];
    self.navigationItem.rightBarButtonItem =setDistance;
    

    
    _mapView=[[BMKMapView alloc]initWithFrame:self.view.frame];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    
    _mapView.delegate=self;
    
    _mapView.userTrackingMode=BMKUserTrackingModeFollow;
    
    [_mapView setZoomLevel:18];
    [self.view addSubview:_mapView];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    
    //地图上的圆形
    _circle=[BMKCircle circleWithCenterCoordinate:[_locService userLocation].location.coordinate radius:[WarningDistanceManage getDistance]];
    [_mapView addOverlay:_circle];
    
    refreshUserLocThread=[[NSThread alloc]initWithTarget:self selector:@selector(loadGroupUerLocation) object:nil];
    [refreshUserLocThread start];
}

-(void)setGroupID:(NSString *)currentGroupID
{
    groupID=currentGroupID;
}

#pragma mark 定位Delegate
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_circle setCoordinate: userLocation.location.coordinate];
    [_mapView updateLocationData:userLocation];
}


//获取好友位置
-(void)loadGroupUerLocation
{
    if(groupID==nil)
    {
        NSLog(@"群组id为空");
        return;
    }
    
    
    //获取群组中成员
    EMError *error = nil;
    EMGroup * group= [[EMClient sharedClient].groupManager fetchGroupInfo:groupID includeMembersList:YES error:
                      &error];
    
    if (!error) {
        //NSLog(@"获取群组中成员成功");
    }
    else
    {
        NSLog(@"获取群成员失败 %@",error);
        return;
    }
    
    
    while(true)
    {
        //判断线程是否停止
        if([[NSThread currentThread ]isCancelled])
        {
            [NSThread exit];
        }

        NSLog(@"获取好友位置");
       
        UserLocationManage * userLocManage=[UserLocationManage sharedInstance];
        [userLocManage searchGroupUserLocation:group.members completion:^(NSArray *result, NSError *error) {
            if(error)
            {
                NSLog(@"查找群组成员位置出错%@",error);
                
            }
            else
            {
                //将查找到的坐标，绘制到地图上
                [self addPointToMap:result];
            }
        }];
        
        
        //间隔60秒
        [NSThread sleepForTimeInterval:60];
        
    }
}

//添加坐标到地图上
-(void)addPointToMap:(NSArray *) pointArray
{
    
    [_mapView removeAnnotation:_mapView.annotations];
    
    for(BmobObject * object in pointArray)
    {
        NSString * locStr= [object objectForKey:bmob_USER_LOCATION_LOCATION];
        NSString * updateTime=[object objectForKey:bmob_USER_LOCATION_UPDATED_AT];
        NSString * username=[object objectForKey:bmob_USER_LOCATION_USERNAME];
        
        
       
        //不添加自己
        //if(![username isEqualToString:[[EMClient sharedClient]currentUsername]] && ![self timeOut:updateTime])
        if(![username isEqualToString:[[EMClient sharedClient]currentUsername]])
        {
            //获取位置
            NSDictionary * loc= [locStr objectFromJSONString];
            
            double latitude=[loc[@"latitude"] doubleValue];
            double longitude=[loc[@"longitude"] doubleValue];
            CLLocationCoordinate2D coor;
            coor.latitude=latitude;
            coor.longitude=longitude;
            
            if([self timeOut:updateTime])
            {
                //超时的点
                TimeOutBMKPointAnnotation * timeOutPoint=[[TimeOutBMKPointAnnotation alloc]init];
                timeOutPoint.coordinate=coor;
                timeOutPoint.title=username;
                [_mapView addAnnotation:timeOutPoint];
            }
            else
            {
                //都是在线用户，判断距离
                double distance= (double)[self getPointDestance:longitude latitude:latitude];
                if(distance>[WarningDistanceManage getDistance])
                {
                    //超出安全距离
                    OutOfRangeBMKPointAnnotation * outOfRangePoint=[[OutOfRangeBMKPointAnnotation alloc]init];
                    outOfRangePoint.coordinate=coor;
                    outOfRangePoint.title=username;
                    [_mapView addAnnotation:outOfRangePoint];
                }
                else
                {
                    SafeBMKPointAnnotation * savePoint=[[SafeBMKPointAnnotation alloc]init];
                    savePoint.coordinate=coor;
                    savePoint.title=username;
                    [_mapView addAnnotation:savePoint];
                }
            
            }
            
            
            //初始化标注
//            BMKPointAnnotation * pointAnnotation=[[BMKPointAnnotation alloc]init];
//
//            pointAnnotation.coordinate=coor;
//            pointAnnotation.title=username;
//            [_mapView addAnnotation:pointAnnotation];
        }
        
    }
}


// 添加大头针的重写
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[SafeBMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"safeAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorGreen;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    else if ([annotation isKindOfClass:[OutOfRangeBMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"outOfRangeAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    else   if ([annotation isKindOfClass:[TimeOutBMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TimeOutAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}


//根据overlay生成对应的View
//地图的红圈
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        BMKCircleView *circleView = [[BMKCircleView alloc] initWithCircle:overlay];
        circleView.strokeColor = [UIColor redColor];
        circleView.lineWidth = 1.0;
        return circleView;
    }
    return nil;
}


/**
 * 开始到结束的时间差
 */
-(Boolean)timeOut:(NSString *)updateTime{
    NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
    [dateFor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * updateTimeDate=[dateFor dateFromString:updateTime];
    NSDate * nowDate=[NSDate date];
    
    NSTimeInterval startTime = [updateTimeDate timeIntervalSince1970]*1;
    NSTimeInterval endTime = [nowDate timeIntervalSince1970]*1;
   
    NSTimeInterval value = endTime-startTime;
    
    
    int second = (int)value;//秒
    if(second >= 60*10)
    {
        return true;
    }
        return false;
}

//设置安全距离
-(void)setSafeDistance
{
            SetWarningDistanceVC * setVc= [UIStoryboard storyboardWithName:@"SetWarningDistance" bundle:[NSBundle mainBundle]].instantiateInitialViewController;
    
    [self.navigationController pushViewController:setVc animated:YES];
}

//判断坐标距离
-(CLLocationDistance )getPointDestance:(double)longitude
                                latitude:(double)latitude
{
    CLLocation * currentLoc=[[CLLocation alloc]initWithLatitude:_locService.userLocation.location.coordinate.latitude longitude:_locService.userLocation.location.coordinate.longitude];
   
    CLLocation * friendLoc=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    CLLocationDistance  distance= [currentLoc distanceFromLocation:friendLoc];
    
    return distance;
}


-(void)viewWillAppear:(BOOL)animated
{
    [_circle setRadius:[WarningDistanceManage getDistance]];

//    if(nil!=_circle)
//    {
//        //地图上的圆形
//        _circle=[BMKCircle circleWithCenterCoordinate:[_locService userLocation].location.coordinate radius:[WarningDistanceManage getDistance]];
//        [_mapView addOverlay:_circle];
//        NSLog(@"设置距离");
//    }
//    else
//    {
////        [_mapView removeOverlay:_circle];
////        
////        //地图上的圆形
////        _circle=[BMKCircle circleWithCenterCoordinate:[_locService userLocation].location.coordinate radius:[WarningDistanceManage getDistance]];
////        [_mapView addOverlay:_circle];
//        NSLog(@"二次设置距离");
//    }
}







-(void)viewWillDisappear:(BOOL)animated
{
    [refreshUserLocThread cancel];
    _mapView.delegate=nil;
    _locService.delegate=nil;
}

-(void)dealloc
{
    NSLog(@"groupUserLocationVC dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
