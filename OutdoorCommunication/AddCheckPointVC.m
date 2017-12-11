//
//  AddCheckPointVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/20.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "AddCheckPointVC.h"
#import <MAMapKit/MAMapKit.h>
#import "EMAlertView.h"
#import "RaceManager.h"

@interface AddCheckPointVC ()<MAMapViewDelegate>
{
    NSMutableArray * pointsArray;
}
@property NSString * objectID;
@property MAMapView * mapView;
@end

@implementation AddCheckPointVC


- (instancetype)initWithObjectID:(NSString *)objectID {
    if (self = [super init]) {
        NSLog(@"%@", objectID);
        if(objectID==nil)
        {
            self.objectID=@"ab95d2fb4e";
        }
        else
        {
            self.objectID=objectID;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    //添加右上角bar item
    UIBarButtonItem *createRaceItem = [[UIBarButtonItem alloc]
                                       initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(popAction)];
    
    UIBarButtonItem * addPointItem=[[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addPointAction)];
    
    UIBarButtonItem * decreasePointItem=[[UIBarButtonItem alloc]initWithTitle:@"减少" style:UIBarButtonItemStylePlain target:self action:@selector(decreasePointAction)];
    
    self.navigationItem.rightBarButtonItems=@[createRaceItem,decreasePointItem,addPointItem];

    
    //初始化检查点字典
    pointsArray=[[NSMutableArray alloc]init];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];

    
    self.mapView.delegate = self;
    

    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self.view addSubview:_mapView];
   
    
}


//增加检查点
-(void)addPointAction
{
    NSLog(@"add");
    MAUserLocation * userLoc= [_mapView userLocation];
    if(userLoc!=nil)
    {
        NSLog(@"获取到位置");
        NSString * count=[NSString stringWithFormat:@"%lu",(unsigned long)pointsArray.count+1] ;
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = userLoc.coordinate;
        pointAnnotation.title =count;
        pointAnnotation.subtitle = @"检查点";
        
        [pointsArray addObject:pointAnnotation];
        //[pointsDictionary setValue:pointAnnotation forKey:count];
        [_mapView addAnnotation:pointAnnotation];
    }
}

//减少检查点
-(void)decreasePointAction
{
    NSLog(@"decrease");
    MAPointAnnotation *pointAnnotation=[pointsArray lastObject];
    if(pointAnnotation!=nil)
    {
        [_mapView removeAnnotation:pointAnnotation];
        [pointsArray removeLastObject];
        NSLog(@"remove point");
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//上传信息，pop掉目前所有的vc 返回到最初的界面
-(void)popAction
{
    if(pointsArray.count<=0)
    {
        //没有添加检查点
        [EMAlertView showAlertWithTitle:@"警告" message:@"请添加检查点" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            return ;
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
    }
    [self hideHud];
    [self showHudInView:self.view hint:@"正在上传"];
    
    //将点转换成类似于json格式
    NSMutableDictionary * allDic=[[NSMutableDictionary alloc]init];
    for(int i=1;i<=pointsArray.count;i++)
    {
        MAPointAnnotation *pointAnnotation = [pointsArray objectAtIndex:i-1];
        
        NSMutableDictionary * tempDic=[[NSMutableDictionary alloc]init];
        
        
        [tempDic setValue:[NSString stringWithFormat:@"%f",pointAnnotation.coordinate.latitude]  forKey:@"latitude"];
        
        [tempDic setValue:[NSString stringWithFormat:@"%f",pointAnnotation.coordinate.latitude] forKey:@"longititude"];
        
        [allDic setObject:tempDic forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    
    //上传数据到服务端
    RaceManager * raceManager=[RaceManager  sharedInstance];
    [raceManager editCheckPoints:self.objectID checkPoints:allDic completion:^(BOOL success, NSError *error) {
        //关闭上传进度
        [self hideHud];
        
        if(success)
        {
            [EMAlertView showAlertWithTitle:@"信息" message:@"修改成功" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                //关闭当前页面，pop到最初界面
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        }
        else
        {
            [EMAlertView showAlertWithTitle:@"信息" message:@"修改失败" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
               
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        }
    }];
    
}

#pragma mark mapView代理

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}


@end
