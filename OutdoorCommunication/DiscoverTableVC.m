//
//  DiscoverTableVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/14.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "DiscoverTableVC.h"
#import "MJRefresh.h"
#import "ShareRouteManage.h"
#import <BmobSDK/Bmob.h>
#import "RouteDetailViewController.h"
#import "SearchBarView.h"
#import "SearchRouteTableViewController.h"

@interface DiscoverTableVC ()
{
    ShareRouteManage * shareRouteManage;
    NSMutableArray * shareRouteArray;
}


@end

@implementation DiscoverTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //轨迹管理
    shareRouteManage=[ShareRouteManage sharedInstance];
    
   //更新本地数据库
    [self updateResource];
   
    //下拉刷新
    __weak DiscoverTableVC *weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf tableViewDidTriggerHeaderRefresh];
    }];
    self.tableView.mj_header.accessibilityIdentifier = @"refresh_header";
    
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchRoute)];
    self.navigationItem.rightBarButtonItem=searchItem;
    
}




//view显示
-(void)viewWillAppear:(BOOL)animated
{
    //刷新数据
    //[self updateResource];
}



//更新数据
-(void)updateResource
{
    [self hideHud];
    [self showHudInView:self.view hint:@"加载中"];
    
    [shareRouteManage searchAllShareRoute:^(NSArray *result, NSError *error) {
        [self hideHud];
        if(result&&!error)
        {
            shareRouteArray=[NSMutableArray arrayWithArray:result];
            [self.tableView reloadData];
        }
        else
        {
            [self showHint:@"加载失败，稍候重试"];
        }
    }];
    
    //停止刷新
    [self.tableView.mj_header endRefreshing];

}

//下拉刷新的selector
-(void)tableViewDidTriggerHeaderRefresh
{
    [self updateResource];
}

//搜索路书
-(void)searchRoute
{
    SearchRouteTableViewController * searchView=[[SearchRouteTableViewController alloc]initWithArray:shareRouteArray];
    searchView.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:searchView animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [shareRouteArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    //将本地的赛事信息填写到table中
    BmobObject * object=[shareRouteArray objectAtIndex:indexPath.row];
    NSString * routeName= [object objectForKey:bmob_SHARE_ROUTE_NAME];
    NSString * distance=[object objectForKey:bmob_SHARE_ROUTE_DISTANCE];
    
    
    float dis=[distance floatValue];
    
    cell.textLabel.text=routeName;
    if(dis<1000)
    {
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.1f m",dis];
    }
    else
    {
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.1f km",dis/1000.0];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BmobObject * object=[shareRouteArray objectAtIndex:indexPath.row];
    NSString * username=[object objectForKey:bmob_SHARE_ROUTE_USERNAME];
    NSDate * startTime=[object objectForKey:bmob_SHARE_ROUTE_START_TIME];
    NSDate * endTime=[object objectForKey:bmob_SHARE_ROUTE_END_TIME];
    NSString * routeName=[object objectForKey:bmob_SHARE_ROUTE_NAME];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startTimeStr = [dateFormatter stringFromDate:startTime];
    NSString *endTimeStr = [dateFormatter stringFromDate:endTime];
    
    //显示轨迹的详细信息
    
    RouteDetailViewController * routeDetailVC=[[RouteDetailViewController alloc]init];
    [routeDetailVC setParameters:startTimeStr startTime:startTime endTimeStr:endTimeStr endTime:endTime routeName:routeName userID:username isOwner:NO];
    routeDetailVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:routeDetailVC animated:YES];
}



@end
