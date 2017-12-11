//
//  QRJMainTabBarViewController.h
//  NewIT
//
//  Created by Alfa on 16/7/27.
//  Copyright © 2016年 alfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface MainTabBarViewController : UITabBarController
{
    EMConnectionState _connectionState;

}
- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)setupUnreadMessageCount;

- (void)networkChanged:(EMConnectionState)connectionState;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)didReceiveUserNotification:(UNNotification *)notification;

- (void)playSoundAndVibration;

- (void)showNotificationWithMessage:(EMMessage *)message;

@end
