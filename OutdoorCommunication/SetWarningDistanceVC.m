//
//  SetWarningDistanceVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/27.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "SetWarningDistanceVC.h"
#import "WarningDistanceManage.h"

@interface SetWarningDistanceVC ()

@property (weak, nonatomic) IBOutlet UILabel *distace_label;
@property (weak, nonatomic) IBOutlet UISlider *distaceSlider;
@end

@implementation SetWarningDistanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _distaceSlider.value=[WarningDistanceManage getDistance];
        _distace_label.text=[NSString stringWithFormat:@"安全距离%ld米",(long)[WarningDistanceManage getDistance]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)distaneChange:(id)sender {
    _distace_label.text=[NSString stringWithFormat:@"安全距离%d米",(int)_distaceSlider.value];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [WarningDistanceManage setDestance:(int)_distaceSlider.value];
}


@end
