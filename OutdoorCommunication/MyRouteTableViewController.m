//
//  MyRouteTableViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/9.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "MyRouteTableViewController.h"
#import "HistoryRouteManage.h"
#import "LovePointManage.h"
#import "RouteDetailViewController.h"

@interface MyRouteTableViewController ()
@property(nonatomic,strong)NSArray * routeArray;
@end

@implementation MyRouteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadHistoryRoute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_routeArray count];
}


//刷新
-(void)reloadHistoryRoute
{
    [self hideHud];
    [self showHudInView:self.view hint:@"加载中"];
    
    HistoryRouteManage * manage=[HistoryRouteManage sharedInstance];
    [manage searchAllHistoryRoute:^(NSArray *result, NSError *error) {
        [self hideHud];
        if(result&&!error)
        {
            _routeArray=[self sortRoute:result];
            [self.tableView reloadData];
        }
        else
        {
            [self showHint:@"加载失败，请重试"];
        }
    }];
    
    
}


//获取过滤过的轨迹信息，开始，结束时间，名称
-(NSArray *)sortRoute:(NSArray * )sourceArray
{
    NSMutableArray * pureArray=[[NSMutableArray alloc]init];
    for(BmobObject * object in sourceArray)
    {
        NSDate * endTime=[object objectForKey:bmob_HISTORY_ROUTE_END_TIME];
        if(endTime!=nil)
        {
            [pureArray addObject:object];
        }
    }
    
    return [pureArray copy];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    BmobObject * object=_routeArray[indexPath.row];
    NSDate * startTime=  [object objectForKey:bmob_HISTORY_ROUTE_START_TIME];
    
    NSDate * endTime=[object objectForKey:bmob_HISTORY_ROUTE_END_TIME];
    
    NSString * name=[object objectForKey:bmob_HISTORY_ROUTE_HISTORY_ROUTE_NAME];
    
    //NSLog(@"%@",startTime);
    //NSLog(@"%@",endTime);
    
    
    if(startTime!=nil && endTime!=nil)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:startTime];
        cell.textLabel.text=name;
        cell.detailTextLabel.text=strDate;
    }
    
    return cell;
}

//选中轨迹
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BmobObject * object=_routeArray[indexPath.row];
    NSDate * startTime=  [object objectForKey:bmob_HISTORY_ROUTE_START_TIME];
    NSDate * endTime=[object objectForKey:bmob_HISTORY_ROUTE_END_TIME];
    NSString * routeName=[object objectForKey:bmob_HISTORY_ROUTE_HISTORY_ROUTE_NAME];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startTimeStr = [dateFormatter stringFromDate:startTime];
    NSString *endTimeStr = [dateFormatter stringFromDate:endTime];
    
    //显示轨迹的详细信息
    
    RouteDetailViewController * routeDetailVC=[[RouteDetailViewController alloc]init];
    [routeDetailVC setParameters:startTimeStr startTime:startTime endTimeStr:endTimeStr endTime:endTime routeName:routeName userID:[[EMClient sharedClient]currentUsername] isOwner:YES];
    routeDetailVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:routeDetailVC animated:YES];
    
}

//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showHudInView:self.view hint:@"删除中"];
    
    //[tableView setEditing:NO animated:YES];
    BmobObject * object= [_routeArray objectAtIndex:indexPath.row];
    NSString * objectID=[object objectForKey:bmob_HISTORY_ROUTE_OBJECT_ID];
    BmobObject * deleteObject=[BmobObject objectWithoutDataWithClassName:bmob_HISTORY_ROUTE objectId:objectID];
    
    [deleteObject deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        [self hideHud];
        if(isSuccessful)
        {
            [self showHint:@"删除成功"];
            //成功
            //重新加载数据
            [self reloadHistoryRoute];
        }
        else
        {
            [self showHint:@"删除失败"];
            NSLog(@"删除历史轨迹失败%@",error);
        }
    }];
}

//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
