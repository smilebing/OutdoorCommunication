//
//  LovePointDetailWithImg.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/10.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "LovePointDetailWithImg.h"

@interface LovePointDetailWithImg ()
{
    UIImageView * imageView;
}
@end

@implementation LovePointDetailWithImg

- (void)viewDidLoad {
    [super viewDidLoad];

    imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:imageView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showHudInView:self.view hint:@"加载中"];
    [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_imgURL]]]];
    [self hideHud];
}

@end
