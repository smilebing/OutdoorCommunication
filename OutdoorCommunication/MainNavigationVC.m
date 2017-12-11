//
//  MainNavigationVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/10.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "MainNavigationVC.h"
#import "MainTabBarViewController.h"
#import "EaseUI.h"

@interface MainNavigationVC ()

@end

@implementation MainNavigationVC



- (void)viewDidLoad {
    [super viewDidLoad];
   //wo
    //[self setupNavigationBar];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigationBar{
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.352 green:0.114 blue:0.944 alpha:1.000]];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[UIFont boldSystemFontOfSize:15.0], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}


@end
