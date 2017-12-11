//
//  MainMapViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/23.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "MainMapViewController.h"
#import "AnnotationViewController.h"
#import "ShareDestViewController.h"
#import "Config.h"
#import "JSONKit.h"
#import "CreateGroupViewController.h"

#import "MyBMKPinAnnotationView.h"
#import "MyBMKPointAnnotation.h"
#import "PublicGroupDetailViewController.h"
#import "LoveBMKPointAnnotation.h"
#import "LovePointDetailAddVC.h"
#import "ProfileTableVC.h"
#import "HistoryRouteManage.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "BMKSportNode.h"

//#import "MyLocationService.h"



// 自定义BMKAnnotationView，用于显示运动者
@interface SportAnnotationView : BMKAnnotationView

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SportAnnotationView

@synthesize imageView = _imageView;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView.image = [UIImage imageNamed:@"sportarrow.png"];
        [self addSubview:_imageView];
    }
    return self;
}

@end




@interface MainMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,ApplicationTrackDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    BMKPointAnnotation* pointAnnotation;
    
    BMKPolyline * pathPolyline;
    BMKPointAnnotation *sportAnnotation;
    SportAnnotationView *sportAnnotationView;
    
    
    NSMutableArray *sportNodes;//轨迹点
    NSInteger sportNodeNum;//轨迹点数
    NSInteger currentIndex;//当前结点
    NSThread * getHistoryRouteThread;
    
    UIButton * loveBtn;//添加标记点的button
    UIButton * clearScreenBtn;//清除屏幕上的大头针
    
}
@property(nonatomic,strong)UIButton * shareButton;
@property(nonatomic, strong)BMKMapView * mapView;
@property(nonatomic,strong)BMKLocationService * locService;
@property(nonatomic,strong)BTRACE * traceInstance;
@property(nonatomic,strong)UIBarButtonItem *addItem;

// 用于网络请求的Session对象
@property (nonatomic, strong) AFHTTPSessionManager *session;
@end


@implementation MainMapViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化Session对象
    self.session = [AFHTTPSessionManager manager];
    // 设置请求接口回来的时候支持什么类型的数据
    self.session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
    
    
    //获取用户名
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    
    //使用鹰眼SDK第一步必须先实例化BTRACE对象
    _traceInstance =[[BTRACE alloc] initWithAk:TraceAK  mcode: TraceMCODE  serviceId: TraceServiceId entityName: loginUsername operationMode: 2];
    //setInterval代表采集周期，packInterval代表打包上传周期
    BOOL intervalSetRet = [_traceInstance setInterval:2 packInterval:2];
    
    if(!intervalSetRet)
    {
        NSLog(@"鹰眼SDK 设置采集周期失败");
    }
    
    
    //添加左上角bar item
    UIBarButtonItem *findFriendItme = [[UIBarButtonItem alloc] initWithTitle:@"附近的群组" style:UIBarButtonItemStylePlain target:self action:@selector(searchNearByPeople)];
    self.navigationItem.leftBarButtonItem=findFriendItme;
    
    
    //添加右上角bar item
    _addItem = [[UIBarButtonItem alloc] initWithTitle:@"记录轨迹" style:UIBarButtonItemStylePlain target:self action:@selector(recodeRoute)];
    self.navigationItem.rightBarButtonItem=_addItem;
    
    
    
    ///初始化地图
    _mapView=[[BMKMapView alloc]initWithFrame:self.view.frame];
    _mapView.showsUserLocation=YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    
    
    ///把地图添加至view
    [self.view addSubview:_mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode=BMKUserTrackingModeFollow;
    
    
    //初始化BMKLocationService
    //_locService=[[MyLocationService sharedInstance]getLocService];
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    
    
    //大头针右边的分享按钮
    self.shareButton=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [self.shareButton addTarget:self action:@selector(shareEvent) forControlEvents:UIControlEventTouchUpInside];
    
    getHistoryRouteThread=[[NSThread alloc]initWithTarget:self selector:@selector(searchHistoryTrace) object:nil];
    
    
    
    //添加清除button
    clearScreenBtn =[UIButton buttonWithType:UIButtonTypeSystem];
    clearScreenBtn.frame=CGRectMake(30.0, CGRectGetMaxY(_mapView.frame) - 90, 35.0, 35.0);
    [clearScreenBtn setImage:[UIImage imageNamed:@"清除"] forState:UIControlStateNormal];
    [clearScreenBtn addTarget:self action:@selector(clearScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:clearScreenBtn];
    
    //添加喜欢button
    loveBtn =[UIButton buttonWithType:UIButtonTypeSystem];
    loveBtn.frame=CGRectMake(80.0, CGRectGetMaxY(_mapView.frame) - 90, 35.0, 35.0);
    UIImage * loveImage=[UIImage imageNamed:@"喜欢"];
    loveImage=[loveImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [loveBtn setImage:loveImage forState:UIControlStateNormal];
    [loveBtn addTarget:self action:@selector(addLovePoint) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    loveBtn.hidden=YES;
    [self.view addSubview:loveBtn];
    
    
    //NSThread * uploadThread=[[NSThread alloc]initWithTarget:self selector:@selector(uploadLocToServer) object:nil];
    //[uploadThread start];
    
    //NSThread * getLocThread=[[NSThread alloc]initWithTarget:self selector:@selector(getUserLoc) object:nil];
    //[getLocThread start];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_mapView updateLocationData:userLocation];
}


#pragma mark item 方法
//记录轨迹
-(void)recodeRoute
{
    if([_addItem.title isEqual:@"记录轨迹"])
    {
        [EMAlertView showAlertWithTitle:@"提示" message:@"即将进行轨迹记录" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            if(buttonIndex==1)
            {
                //创建轨迹记录到bmob
                HistoryRouteManage * historyRouteManage=[HistoryRouteManage sharedInstance];
                [historyRouteManage uploadStartTimeInBackground:[NSDate date] completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        //轨迹记录上传成功
                        //开始进行轨迹记录
                        //开始追踪，异步执行
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [[BTRACEAction shared] startTrace:self trace:_traceInstance];
                        });
                        
                        if(getHistoryRouteThread==nil)
                        {
                                getHistoryRouteThread=[[NSThread alloc]initWithTarget:self selector:@selector(searchHistoryTrace) object:nil];
                        }
                        //绘制轨迹
                        [getHistoryRouteThread start];
                        
                        _addItem.title=@"停止记录";
                        loveBtn.hidden=NO;
                        
                    }
                    else
                    {
                        [self showErrorAlert:Str_network_error];
                    }
                }];
                
                
            }
            
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil ];
        
    }
    else if([_addItem.title isEqual:@"停止记录"])
    {
        [EMAlertView showAlertWithTitle:@"提示" message:@"即将停止轨迹记录" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            if(buttonIndex==1)
            {
                UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入名称" preferredStyle:UIAlertControllerStyleAlert];
                __weak typeof(alertControl) wAlert = alertControl;
                
                [alertControl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    // 点击确定按钮的时候, 会调用这个block
                    [self showHudInView:self.mapView hint:@"停止中"];
                    
                    NSString * routeName=  [wAlert.textFields.firstObject text];
                    
                    //防止名称为空
                    if([routeName isEqualToString:@""])
                    {
                        routeName=@"未命名";
                    }
                    
                    HistoryRouteManage * historyRouteManage=[HistoryRouteManage sharedInstance];
                    [historyRouteManage uploadEndTimeInBackground:[NSDate date] historyRouteName:routeName completion:^(BOOL success, NSError *error) {
                        if(success)
                        {
                            NSLog(@"停止追踪");
                            //结束轨迹追踪
                            [[BTRACEAction shared] stopTrace:self trace:_traceInstance];
                            
                            
                            //停止绘制轨迹
                            [getHistoryRouteThread cancel];
                            getHistoryRouteThread=nil;
                            
                            _addItem.title=@"记录轨迹";
                            loveBtn.hidden=YES;
                            
                            [self hideHud];
                        }
                        else
                        {
                            [self hideHud];

                            [EMAlertView showAlertWithTitle:@"提示" message:@"停止失败，请重试" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                                
                            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
                            NSLog(@"%@",error);
                        }
                    }];
                    
                    
                }]];
                
                [alertControl addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    
                }];
                
                [self presentViewController:alertControl animated:YES completion:nil];
                
                
                
                
            }
            
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil ];
        
        
    }
    
    
}


#pragma mark 在地图上添加大头针目的地
-(void)addPointAnnotation:(double) latitude longtitude:(double)longtitude title:(NSString *) title subtitle:(NSString *)subtitle groupID:(NSString * )groupID
{
    
    NSLog(@"添加标记");
    CLLocationCoordinate2D  location=CLLocationCoordinate2DMake(latitude, longtitude);
    
    MyBMKPointAnnotation * myPoint=[[MyBMKPointAnnotation alloc]init];
    myPoint.coordinate=location;
    myPoint.title=title;
    myPoint.subtitle=subtitle;
    myPoint.groupID=groupID;
    
    [_mapView addAnnotation:myPoint];
    
}

-(void)testSearchHistoryTrace
{
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    
    
    //    [[BTRACEAction shared]getTrackHistory:self serviceId:TraceServiceId entityName:loginUsername startTime:1493683200 endTime:1493737200 simpleReturn:0 isProcessed:1 processOption: @"need_denoise=1,need_vacuate=1,need_mapmatch=0" supplementMode: @"driving" sortType: 0 pageSize:0 pageIndex:0];
    
    
    long long currentTime = (long long)[[NSDate date] timeIntervalSince1970];
    
    long long mystartTime=currentTime-1500;
    
    
    [[BTRACEAction shared]getTrackHistory:self serviceId:TraceServiceId entityName:loginUsername startTime:mystartTime endTime:currentTime simpleReturn:0 isProcessed:0 pageSize:0 pageIndex:0];
}

//查找历史轨迹
-(void)searchHistoryTrace
{
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    
    long long lastEndtime=(long long)[[NSDate date] timeIntervalSince1970];
    
    while(true)
    {
        
        long long currentTime = (long long)[[NSDate date] timeIntervalSince1970];
        
        if(currentTime-lastEndtime<5)
        {
            [NSThread sleepForTimeInterval:10];
            continue;
        }
        //NSLog(@"current:%@",currentTime); //时间戳的值时间戳转时间的方法
        
        [[BTRACEAction shared]getTrackHistory:self serviceId:TraceServiceId entityName:loginUsername startTime:currentTime-15 endTime:currentTime simpleReturn:0 isProcessed:0 pageSize:0 pageIndex:0];
        
        lastEndtime=currentTime;
        
        //[[BTRACEAction shared]getTrackHistory:self serviceId:TraceServiceId entityName:loginUsername startTime:currentTime-16 endTime:currentTime simpleReturn:0 isProcessed:1 processOption: @"need_denoise=1,need_vacuate=1,need_mapmatch=0" supplementMode: @"driving" sortType: 0 pageSize:0 pageIndex:0];
        [NSThread sleepForTimeInterval:10];
        
        if([[NSThread currentThread ]isCancelled])
        {
            [NSThread exit];
        }
        
    }
    
    
}

#pragma mark button target

//清除地图上的大头针
-(void)clearScreen
{
    [_mapView removeAnnotations:_mapView.annotations];
}

//轨迹记录过程中添加喜欢
-(void)addLovePoint
{
    //获取当前位置
    LoveBMKPointAnnotation *  lovePoint=[[LoveBMKPointAnnotation alloc]init];
    lovePoint.coordinate=[_locService.userLocation location].coordinate;
    lovePoint.title=@"喜欢";
    [_mapView addAnnotation:lovePoint];
}


//查找附近的人
-(void)searchNearByPeople
{
    //移除地图上大头针
    [self removeAllAnnotationPoint];
    NSLog(@"查找附近的人");
    
    NSDictionary *parameters = @{@"geotable_id":LBS_geotable_id ,
                                 @"ak":LBS_ak,
                                 @"time":[NSDate date]};
    
    // 参数1: get请求的网址
    // 参数2: 拼接参数
    // 参数3: 当前的进度
    // 参数4: 请求成功
    // 参数5: 请求失败
    [self hideHud];
    [self showHudInView:self.mapView hint:@"加载中"];
    [self.session GET:LBS_NearByPoepleURL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self hideHud];
        NSLog(@"%@",task.currentRequest);
        
        NSLog(@"%@",responseObject);
        if(responseObject==nil)
        {
            return ;
        }
        
        //解析json
        NSDictionary *sumPointsDic = responseObject;
        
        if(sumPointsDic[@"status"])
        {
            NSInteger status=[sumPointsDic[@"status"] integerValue];
            if(status!=0)
            {
                //请求出错
                [self showErrorAlert:Str_network_error];
                return;
            }
            else
            {
                NSInteger  total= [sumPointsDic [@"total"] integerValue];
                if(total<=0)
                {
                    [EMAlertView showAlertWithTitle:@"提示" message:@"附近没有组织" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                        
                    } cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    return;
                }
                
                NSArray * pointsArray= [sumPointsDic objectForKey: @"pois"];
                for(int i=0;i<pointsArray.count;i++)
                {
                    //        {"title":"\u5e7f\u897f\u6842\u6797\u56fd\u5bb6\u68ee\u6797\u516c\u56ed","location":[110.244535,25.234142],"city":"\u6842\u6797\u5e02","create_time":"2017-05-03 19:50:59","geotable_id":167430,"address":"\u5e7f\u897f\u58ee\u65cf\u81ea\u6cbb\u533a\u6842\u6797\u5e02\u8c61\u5c71\u533a","tags":"20170503","province":"\u5e7f\u897f\u58ee\u65cf\u81ea\u6cbb\u533a","district":"\u8c61\u5c71\u533a","chatID":1111,"gcj_location":[110.23797122212,25.228331457617],"city_id":142,"id":2088293497}
                    
                    NSDictionary * eachPointDic=[pointsArray objectAtIndex:i];
                    NSArray * location=eachPointDic[@"location"];
                    if(location.count>0)
                    {
                        NSString * title=eachPointDic[@"title"];
                        NSString * subTitle=eachPointDic[@"address"];
                        NSString * groupID=eachPointDic[@"tags"];
                        double latitude= [[location objectAtIndex:1] doubleValue];
                        double longtitude=[[location objectAtIndex:0] doubleValue];
                        //获取坐标
                        //绘制大头针
                        [self addPointAnnotation:latitude longtitude:longtitude title:title subtitle:subTitle groupID:groupID];
                        
                    }
                    
                }
                
            }
            
        }
        else
        {
            //请求出错
            [self showErrorAlert:Str_network_error];
            return;
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hideHud];
        //显示网络错误
        [self showErrorAlert:Str_network_error];
    }];
    
    
    
}


//分享
-(void)shareEvent
{
    UIStoryboard * shareStoryboard=[UIStoryboard storyboardWithName:@"ShareDest" bundle:nil];
    UIViewController * shareVC=[shareStoryboard instantiateViewControllerWithIdentifier:@"share"];
    shareVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:shareVC animated:YES];
}


//移除地图上大头针
-(void)removeAllAnnotationPoint
{
    [_mapView removeAnnotations:_mapView.annotations];
}

#pragma mark 显示错误信息
//显示网络错误的警告窗口
-(void)showErrorAlert:(NSString * )title
{
    [self hideHud];
    [EMAlertView showAlertWithTitle:@"提示" message:title completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
        
    } cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
}

#pragma mark 轨迹绘制
//初始化轨迹点
- (void)initSportNodes :(NSString * )jsonResult
{
    sportNodes = [[NSMutableArray alloc] init];
    
    if (jsonResult) {
        NSDictionary *allDic = [jsonResult objectFromJSONString];
        
        if(allDic[@"points"])
        {
            NSArray * pointsArrsy= allDic[@"points"];
            if(pointsArrsy.count==0)
            {
                return;
            }
            for(NSDictionary * eachPointDic in pointsArrsy)
            {
                NSArray * location=eachPointDic[@"location"];
                
                BMKSportNode *sportNode = [[BMKSportNode alloc] init];
                
                sportNode.coordinate = CLLocationCoordinate2DMake([[location objectAtIndex:1] doubleValue],[[location objectAtIndex:0] doubleValue]);
                
                sportNode.angle = [eachPointDic[@"direction"] doubleValue];
                sportNode.distance = [eachPointDic[@"radius"] doubleValue];
                sportNode.speed = [eachPointDic[@"speed"] doubleValue];
                [sportNodes addObject:sportNode];
            }
        }
    }
    
    
    sportNodeNum = sportNodes.count;
    
    [self start];
    //[self running];
}



//开始
- (void)start {
    
    
    __weak __typeof(self) weakself= self;
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"准备绘制");
        CLLocationCoordinate2D paths[sportNodeNum];
        for (NSInteger i = 0; i < sportNodeNum; i++) {
            BMKSportNode *node = sportNodes[i];
            paths[i] = node.coordinate;
        }
        pathPolyline = [BMKPolyline polylineWithCoordinates: paths count:sportNodeNum];
        if(nil!= pathPolyline)
        {
            [_mapView addOverlay:pathPolyline];
        }
        
        //        sportAnnotation = [[BMKPointAnnotation alloc]init];
        //        sportAnnotation.coordinate =paths[0];
        //        sportAnnotation.title = @"test";
        //        [_mapView addAnnotation:sportAnnotation];
    });
    
    
    currentIndex = 0;
}

//runing
- (void)running {
    BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];
    sportAnnotationView.imageView.transform = CGAffineTransformMakeRotation(node.angle);
    [UIView animateWithDuration:node.distance/node.speed animations:^{
        currentIndex++;
        BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];
        sportAnnotation.coordinate = node.coordinate;
    } completion:^(BOOL finished) {
        [self running];
    }];
}





#pragma mark - 地图 Delegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    //[self start];
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    //[self running];
}

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolygon class]])
    {
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0.5 blue:0.0 alpha:0.6];
        polygonView.lineWidth = 3.0;
        return polygonView;
    }
    else if([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView * polylineView=[[BMKPolylineView alloc]initWithOverlay:overlay];
        polylineView.strokeColor=[[UIColor alloc] initWithRed:0.0 green:0.5 blue:0.0 alpha:0.6];
        polylineView.lineWidth=3.0;
        return polylineView;
    }
    return nil;
}



- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //用户喜欢的标记
    if([annotation isKindOfClass:[LoveBMKPointAnnotation class]])
    {
        BMKPinAnnotationView * lovePointView=[[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"loveAnnotation"];
        lovePointView.pinColor=BMKPinAnnotationColorRed;
        lovePointView.animatesDrop=YES;
        lovePointView.draggable=YES;//允许拖拽
        return lovePointView;
    }
    
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        BMKPinAnnotationView * testView=[[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        testView.pinColor=BMKPinAnnotationColorPurple;
        testView.animatesDrop=YES;
        testView.draggable=NO;
        
        return testView;
    }
    
    
    
    return nil;
}


// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    if([view.annotation isKindOfClass:[MyBMKPointAnnotation class]])
    {
        [self hideHud];
        [self showHudInView:self.mapView hint:@"加载中"];
        //群组大头针
        MyBMKPointAnnotation * point= view.annotation;
        NSLog(@"%@",point.groupID);
        if([point.groupID isEqualToString:@""])
        {
            [self showErrorAlert:Str_network_error];
            return;
        }
        
        PublicGroupDetailViewController * groupDetailVC=[[PublicGroupDetailViewController alloc]initWithGroupId:point.groupID];
        groupDetailVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:groupDetailVC animated:YES];
        
    }
    else if([view.annotation isKindOfClass:[LoveBMKPointAnnotation class]])
    {
        //跳转到增加界面
        
        LovePointDetailAddVC * lovePointVC= [UIStoryboard storyboardWithName:@"LovePointDetailAdd" bundle:[NSBundle mainBundle]].instantiateInitialViewController;
        lovePointVC.hidesBottomBarWhenPushed=YES;
        [lovePointVC  setLocation:[view.annotation coordinate]];
        [self.navigationController pushViewController:lovePointVC animated:YES];
    }
    else
    {
        //普通大头针
        BMKPointAnnotation * point=(BMKPointAnnotation *) view.annotation;
        if([point.title isEqualToString:@"我的位置"])
        {
            //在所在位置创建群组
            [EMAlertView showAlertWithTitle:@"提示" message:@"是否在此处创建群组？" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                if(buttonIndex==1)
                {
                    [self hideHud];
                    [self showHudInView:self.mapView hint:@"加载中"];
                    //获取当前位置
                    BMKUserLocation * currentLocation= [_locService userLocation];
                    
                    NSNumber * latitude= [NSNumber numberWithDouble:currentLocation.location.coordinate.latitude];
                    NSNumber * longitude= [NSNumber numberWithDouble:currentLocation.location.coordinate.longitude ];
                    NSString * finalURL=[NSString stringWithFormat:@"%@?geotable_id=%@&location=%@,%@&ak=%@",LBS_cloudrgc_url,LBS_geotable_id,latitude,longitude,LBS_ak];
                    
                    
                    // 参数1: get请求的网址
                    // 参数2: 拼接参数
                    // 参数3: 当前的进度
                    // 参数4: 请求成功
                    // 参数5: 请求失败
                    [self.session GET:finalURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        //获取成功
                        [self hideHud];
                        NSDictionary * dic=responseObject;
                        NSLog(@"%@",dic);
                        
                        if(dic[@"status"])
                        {
                            NSInteger status=[dic[@"status"] integerValue];
                            if(status!=0)
                            {
                                //请求出错
                                [self showErrorAlert:Str_network_error];
                                return;
                            }
                        }
                        else
                        {
                            //请求出错
                            [self showErrorAlert:Str_network_error];
                            return;
                        }
                        
                        NSString * address=dic[@"formatted_address"];
                        NSString * description=dic[@"recommended_location_description"];
                        
                        
                        //创建群组
                        CreateGroupViewController * creatGroupVC = [[CreateGroupViewController alloc] initWithDetail:address subTitle:description location:currentLocation.location.coordinate];
                        creatGroupVC.hidesBottomBarWhenPushed=YES;
                        [self.navigationController pushViewController:creatGroupVC animated:YES];
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        //网络出错
                        [self showErrorAlert:Str_network_error];
                    }];
                    
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        }
    }
    
    
    
    
    
}



#pragma mark ApplicationTrackDelegate

-(void)onGetHistoryTrack:(NSData *)data
{
    
    NSString * result=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",result);
    [self initSportNodes:result];
    
}


#pragma mark -dealloc
-(void)dealloc
{
    if(_traceInstance!=nil)
    {
        //结束轨迹追踪
        [[BTRACEAction shared] stopTrace:self trace:_traceInstance];
        
    }
    _mapView.delegate=nil;
    _mapView=nil;
    NSLog(@"main map view dealloc");
}

-(void)viewWillAppear:(BOOL)animated
{
    [self hideHud];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

@end


