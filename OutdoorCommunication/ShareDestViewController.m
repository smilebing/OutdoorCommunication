//
//  ShareDestViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/30.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "ShareDestViewController.h"

@interface ShareDestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *deatilTextView;

@end

@implementation ShareDestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _deatilTextView.layer.borderWidth=1;
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
