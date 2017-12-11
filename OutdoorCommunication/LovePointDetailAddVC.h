//
//  LovePointDetailAddVC.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/8.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LovePointDetailAddVC : UIViewController
//@property(nonatomic) CLLocationCoordinate2D location;
@property(nonatomic,strong) UIBarButtonItem * saveBtn;

@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

@property (weak, nonatomic) IBOutlet UIButton *imgButton1;

-(void)setLocation:(CLLocationCoordinate2D) loc;
@end
