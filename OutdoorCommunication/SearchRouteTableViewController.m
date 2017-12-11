//
//  SearchRouteTableViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/6/1.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "SearchRouteTableViewController.h"
#import "RouteDetailViewController.h"
#import "QRSearchInputView.h"
#import <BmobSDK/Bmob.h>

@interface SearchRouteTableViewController ()<QRSearchInputViewDelegate>
{
    NSMutableArray * shareRouteArray;
    NSMutableArray * tempRouteArray;
}
@property(nonatomic,strong) QRSearchInputView * inputView;

@end

@implementation SearchRouteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView=self.inputView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(instancetype)initWithArray:(NSMutableArray * )array
{
    self=[super init];
    if(self)
    {
        shareRouteArray=array;
        tempRouteArray=[[NSMutableArray alloc]init];
        //tempRouteArray=array;
    }
    return self;
}

//更新数据
-(void)updateResource
{
    [self.tableView reloadData];
}


//搜索框
- (QRSearchInputView *)inputView{
    
    if (nil == _inputView) {
        
        _inputView = [[[NSBundle mainBundle] loadNibNamed:@"QRSearchInputView" owner:self options:nil] lastObject];
        _inputView.delegate = self;
        _inputView.backgroundColor = [UIColor clearColor];
        _inputView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    }
    
    return _inputView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [tempRouteArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    //将本地的赛事信息填写到table中
    BmobObject * object=[tempRouteArray objectAtIndex:indexPath.row];
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
    BmobObject * object=[tempRouteArray objectAtIndex:indexPath.row];
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



#pragma mark 搜索框Delegate
//取消搜索
- (void)searchInputView:(QRSearchInputView *)searchInputView didClickedCacelButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

//停止输入
- (void)searchInputViewEndInput:(QRSearchInputView *)searchInputView
{
    NSString * keyWord=searchInputView.keyWord;
    NSLog(@"%@",keyWord);
    
    [tempRouteArray removeAllObjects];
    
    //遍历数组，判断
    for (BmobObject * object in shareRouteArray) {
        NSString * routeName=[object objectForKey:bmob_SHARE_ROUTE_NAME];
        if([routeName containsString:keyWord])
        {
            [tempRouteArray addObject:object];
            NSLog(@"%@",routeName);
        }
    }
    
    NSLog(@"%lu",(unsigned long)tempRouteArray.count);
    //更新数据
    [self updateResource];
    
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
