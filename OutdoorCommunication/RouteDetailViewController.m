//
//  RouteDetailViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/10.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "RouteDetailViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "BMKSportNode.h"

#import "LovePointManage.h"
#import <BmobSDK/Bmob.h>
#import "LoveBMKPointAnnotation.h"
#import "LovePointDetailWithImg.h"

#import "ShareRouteManage.h"

@interface RouteDetailViewController ()<BMKMapViewDelegate,ApplicationTrackDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tableView;
    
    NSMutableArray *sportNodes;//轨迹点
    NSInteger sportNodeNum;//轨迹点数
    BMKPolyline *pathPolyline;
    
    //轨迹记录的总坐标数，用来分页查询
    NSInteger  totalLocation;
    NSInteger  currentPage;
    //缩放flag
    NSInteger setZoom;
    //总距离
    float  distance;
    NSInteger isFirst;
    NSInteger isShared;
    
}


@property (nonatomic,retain)NSString * startTimeStr;
@property(nonatomic,retain)NSString * endTimeStr;
@property (nonatomic,retain)NSDate * startTime;
@property(nonatomic,retain)NSDate * endTime;
@property(nonatomic,copy)NSString * routeName;
@property(nonatomic,strong)NSArray * lovePointArray;
@property(nonatomic,strong)BMKMapView * mapView;
@property(nonatomic)Boolean isOwner;
//用户id
@property (nonatomic,strong)NSString * userID;

//鹰眼服务
@property(nonatomic,strong)BTRACE * traceInstance;


@end




@implementation RouteDetailViewController

//初始化
-(void)setParameters:(NSString *) startTimeStr
          startTime:(NSDate *)startTime
         endTimeStr:(NSString *) endTimeStr
            endTime:(NSDate *)endTime
          routeName:(NSString *)routeName
             userID:(NSString *)userID
             isOwner:(Boolean)isOwner

{
    _startTime=startTime;
    _endTime=endTime;
    _startTimeStr=startTimeStr;
    _endTimeStr=endTimeStr;
    _routeName=routeName;
    _userID=userID;
    _isOwner=isOwner;
    
    NSLog(@"开始时间 %@",startTimeStr);
    NSLog(@"结束时间 %@",endTimeStr);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentPage=1;
    setZoom=0;
    distance=0.0;
    isFirst=1;
    isShared=0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, self.view.frame.size.height-350) style:UITableViewStylePlain];
    tableView.delegate=self;
    tableView.dataSource = self;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1)];
    [self.view addSubview:tableView];
    
    //初始化地图
    _mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
    _mapView.delegate=self;
    [_mapView setZoomLevel:16.f];
    [self.view addSubview:_mapView];
    
    //使用鹰眼SDK第一步必须先实例化BTRACE对象
    _traceInstance =[[BTRACE alloc] initWithAk:TraceAK  mcode: TraceMCODE  serviceId: TraceServiceId entityName: [[EMClient sharedClient]currentUsername ] operationMode: 2];
    //setInterval代表采集周期，packInterval代表打包上传周期
    BOOL intervalSetRet = [_traceInstance setInterval:2 packInterval:2];
    
    if(!intervalSetRet)
    {
        NSLog(@"鹰眼SDK 设置采集周期失败");
    }
    
    if(_isOwner)
    {
        //添加右上角bar item
        UIBarButtonItem *shareRouteItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareRoute)];
        self.navigationItem.rightBarButtonItem=shareRouteItem;
    }
    
    [self getHistoryRouteDetail];
    //在地图上显示轨迹
    [self addRouteToMap:currentPage];

}

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//获取数据
-(void)getHistoryRouteDetail
{
    LovePointManage * manage=[LovePointManage sharedInstance];
    //查找标注点
    [manage searchLovePointInBackground:_userID starTime:_startTimeStr endTime:_endTimeStr completion:^(NSArray *result, NSError *error) {
        if(result&&!error)
        {
            //标注点找到
            _lovePointArray=result;
            //绘制到地图上
            [self addLovePointToMap];
            [tableView reloadData];
        }
    }];
}

//将标注的点添加到地图上
-(void)addLovePointToMap
{
    //NSLog(@"标注点 %lu",(unsigned long)[_lovePointArray count]);
    
    for(BmobObject * object in _lovePointArray)
    {
        NSString * location=[object objectForKey:bmob_LOVE_POINT_LOCATION];
        NSString * description=[object objectForKey:bmob_LOVE_POINT_DESCRIPTION];
        
        BmobFile * bmobImg=(BmobFile *)[object objectForKey:bmob_LOVE_POINT_IMG];
        
        NSInteger flag=0;
        if(location)
        {
            NSDictionary * loc= [location objectFromJSONString];
            //初始化标注
            LoveBMKPointAnnotation * pointAnnotation=[[LoveBMKPointAnnotation alloc]init];
            pointAnnotation.imgURL=bmobImg.url;
            CLLocationCoordinate2D coor;
            coor.latitude=[loc[@"latitude"] doubleValue];
            coor.longitude=[loc[@"longitude"] doubleValue];
            pointAnnotation.coordinate=coor;
            pointAnnotation.title=description;
            [_mapView addAnnotation:pointAnnotation];
            
            //设置地图中心点
            if(flag==0)
            {
                [_mapView setCenterCoordinate:coor];
                
                flag=1;
            }
            
        }
    }
}

//获取轨迹，绘制轨迹
-(void)addRouteToMap:(NSInteger )currentPageIndex
{
    long long tempStartTime = (long long)[_startTime timeIntervalSince1970];
    long long tempEndTime = (long long)[_endTime timeIntervalSince1970];
    
    [[BTRACEAction shared]getTrackHistory:self serviceId:TraceServiceId entityName:_userID startTime:tempStartTime endTime:tempEndTime simpleReturn:0 isProcessed:0 pageSize:100 pageIndex:currentPageIndex];
    
}


//分享轨迹
-(void)shareRoute
{
    if(isFirst==0)
    {
        if(isShared==1)
        {
            [self showAlertView:@"请勿重复分享"];
            return;
        }
        
        [self showHudInView:self.view hint:@"分享中"];
        ShareRouteManage * shareRouteManage=[ShareRouteManage sharedInstance];
        
        [shareRouteManage uploadRoute:_routeName startTime:_startTime endTime:_endTime creater:_userID distance:[NSString stringWithFormat:@"%f",distance] completion:^(BOOL success, NSError *error) {
            [self hideHud];
            if(success)
            {
                isShared=1;
                [self showAlertView:@"分享成功"];
            }
            else
            {
                [self showAlertView:@"分享失败"];
                NSLog(@"%@",error);
            }
            
        }];
        
    }
    else
    {
        [self showAlertView:@"数据加载中"];
    }
}

//显示警告窗口
-(void)showAlertView:(NSString *)msg
{
    [EMAlertView showAlertWithTitle:@"提示" message:msg completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
        
    } cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
}



//开始绘制
- (void)start {
    
    __weak __typeof(self) weakself= self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"准备绘制");
        CLLocationCoordinate2D paths[sportNodeNum];
        for (NSInteger i = 0; i < sportNodeNum; i++) {
            BMKSportNode *node = sportNodes[i];
            paths[i] = node.coordinate;
        }
        
        if(sportNodeNum>0 && setZoom==0)
        {
            setZoom=1;
            //设置地图中心
            [_mapView setCenterCoordinate:paths[sportNodeNum/2]];
        }
        
        
        pathPolyline = [BMKPolyline polylineWithCoordinates: paths count:sportNodeNum];
        if(nil!= pathPolyline)
        {
            [_mapView addOverlay:pathPolyline];
        }
        
    });
    
    
}



#pragma mark ApplicationTrackDelegate

-(void)onGetHistoryTrack:(NSData *)data
{
    
    NSString * result=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",result);
    
    [self initSportNodes:result];
    
    //只有第一次才执行
    if(isFirst==1)
    {
        [self getTotalLocation:result];
        [self getRouteInfo:result];
        isFirst=0;
    }
    
    //判断是否要分页查询
    if(currentPage<= totalLocation/100+1)
    {
        currentPage++;
        [self addRouteToMap:currentPage];
    }
    
    
}

//解析出json 中的 坐标总个数
-(void)getTotalLocation:(NSString *) jsonStr
{
    NSDictionary * dic=[jsonStr objectFromJSONString];
    NSInteger total=[dic[@"total"] integerValue];
    totalLocation=total;
}

//解析出json 中的距离，起始点坐标
-(void)getRouteInfo:(NSString *)jsonStr
{
    NSDictionary * dic=[jsonStr objectFromJSONString];
 
    //获取距离
    float dis=[dic[@"distance"] floatValue];
    distance=dis;
    [tableView reloadData];
    
    //获取起始点位置信息
//    NSDictionary * startPointDic=dic[@"start_point"];
//    NSDictionary * endPointDic=dic[@"end_point"];
//    
//    CLLocationCoordinate2D startPointCoor;
//    startPointCoor.latitude=[startPointDic[@"latitude"] doubleValue];
//    startPointCoor.longitude=[startPointDic[@"longitude"]doubleValue];
//    
//    CLLocationCoordinate2D endPointCoor;
//    endPointCoor.latitude=[endPointDic[@"latitude"] doubleValue];
//    endPointCoor.longitude=[endPointDic[@"longitude"]doubleValue];
//    
//    BMKPointAnnotation * startAnnotation=[[BMKPointAnnotation alloc]init];
//    startAnnotation.coordinate=startPointCoor;
//    startAnnotation.title=@"起点";
//    
//    BMKPointAnnotation * endAnnotation=[[BMKPointAnnotation alloc]init];
//    endAnnotation.coordinate=endPointCoor;
//    endAnnotation.title=@"终点";
//    
   // [_mapView addAnnotation:startAnnotation];
   // [_mapView addAnnotation:endAnnotation];
}


// 当点击annotation view弹出的泡泡时，调用此接口
-(void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
        if([view.annotation isKindOfClass:[LoveBMKPointAnnotation class]])
        {
            //显示图片
            LoveBMKPointAnnotation * point=(LoveBMKPointAnnotation *)view.annotation;
            if(point.imgURL)
            {
                //加载图片
                LovePointDetailWithImg * lovePointDetailWithImgVC=[[LovePointDetailWithImg alloc]init];;
                
                lovePointDetailWithImgVC.imgURL=point.imgURL;
                
                [self.navigationController pushViewController:lovePointDetailWithImgVC animated:YES];
                
            }
            
        }
    else
    {
        //起点和终点的标注
    }
}


- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[LoveBMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    else if([annotation isKindOfClass:[BMKPointAnnotation class]])
    {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotationStartEnd"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        newAnnotationView.draggable=NO;
        return newAnnotationView;
    }
    return nil;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
  
        if (indexPath.row == 0) {
            cell.textLabel.text = @"路书名称";
            cell.detailTextLabel.text=_routeName;
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"用户id";
            cell.detailTextLabel.text=_userID;
            
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"总距离";
            if(distance<1000)
            {
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%.1f m",distance];
            }
            else
            {
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%.1f km",distance/1000.0];
            }
            
        }else if(indexPath.row==3)
        {
            cell.textLabel.text=@"标注点个数";
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",[_lovePointArray count]];
        }
        else if(indexPath.row==3){
            cell.textLabel.text=@"耗时";
            cell.detailTextLabel.text=[self dateTimeDifferenceWithStartTime:_startTimeStr endTime:_endTimeStr];
            
        }else if(indexPath.row==4){
            cell.textLabel.text=@"开始时间";
            cell.detailTextLabel.text=_startTimeStr;
        
        }else if(indexPath.row==5){
            cell.textLabel.text=@"结束时间";
            cell.detailTextLabel.text=_endTimeStr;
        }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


/**
 * 开始到结束的时间差
 */
-(NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value / (24 * 3600)%3600;
    int day = (int)value / (24 * 3600);
    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"%d天%d小时%d分%d秒",day,house,minute,second];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"%d小时%d分%d秒",house,minute,second];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"%d分%d秒",minute,second];
    }else{
        str = [NSString stringWithFormat:@"%d秒",second];
    }
    return str;
}


#pragma mark view 销毁
-(void)viewDidDisappear:(BOOL)animated
{
    //[mapView removeOverlays:mapView.overlays ];
    //[mapView removeAnnotations:mapView.annotations];
}

-(void)dealloc
{
    _traceInstance=nil;
    _mapView.delegate=nil;
    _mapView=nil;
}


@end
