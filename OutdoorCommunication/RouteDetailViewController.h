//
//  RouteDetailViewController.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/10.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteDetailViewController : UIViewController

-(void)setParameters:(NSString *) startTimeStr
          startTime:(NSDate *)startTime
         endTimeStr:(NSString *) endTimeStr
            endTime:(NSDate *)endTime
          routeName:(NSString *)routeName
             userID:(NSString *)userID
             isOwner:(Boolean)isOwner;

@end
