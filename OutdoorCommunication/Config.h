//
//  Config.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/9.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define APP_KEY @"1182161114115254#outdoorchat";

//60s 从服务器获取一次好友的位置
#define GetUserLocTime  15;

//百度鹰眼服务
#define TraceServiceId 139468
#define TraceAK @"rWlhsuOsaqNef7vDDoQlEtP2vAOkG7Gr"
#define TraceMCODE @"cn.lovebing.OutdoorCommunication"
#define TraceEPSILON 0.0001


//百度 LBS
#define LBS_NearByPoepleURL @"http://api.map.baidu.com/geodata/v3/poi/list"
#define LBS_ak @"b0KQhoL6f4vu09oromv2ZyzR32fG2nEZ"
#define LBS_geotable_id @"167430"

//百度 LBS 逆地址编码
#define LBS_cloudrgc_url @"http://api.map.baidu.com/cloudrgc/v1"
//创建数据
#define LBS_create_point_url @"http://api.map.baidu.com/geodata/v3/poi/create"
//删除数据
#define LBS_DELETE_POINT_URL @"http://api.map.baidu.com/geodata/v3/poi/delete"

#define Str_network_error @"网络出错,请稍后重试"


#define bmob_HISTORY_ROUTE @"historyRoute"
#define bmob_HISTORY_ROUTE_OBJECT_ID @"objectId"
#define bmob_HISTORY_ROUTE_USERNAME @"username"
#define bmob_HISTORY_ROUTE_START_TIME @"startTime"
#define bmob_HISTORY_ROUTE_END_TIME @"endTime"
#define bmob_HISTORY_ROUTE_HISTORY_ROUTE_NAME @"historyRouteName"


#define bmob_LOVE_POINT @"lovePoint"
#define bmob_LOVE_POINT_USERNAME @"username"
#define bmob_LOVE_POINT_LOCATION @"location"
#define bmob_LOVE_POINT_IMG @"img"
#define bmob_LOVE_POINT_CREATED_AT @"createdAt"
#define bmob_LOVE_POINT_DESCRIPTION @"description"

#define bmob_SHARE_ROUTE @"shareRoute"
#define bmob_SHARE_ROUTE_NAME @"routeName"
#define bmob_SHARE_ROUTE_USERNAME @"username"
#define bmob_SHARE_ROUTE_START_TIME @"startTime"
#define bmob_SHARE_ROUTE_END_TIME @"endTime"
#define bmob_SHARE_ROUTE_DISTANCE @"distance"
#define bmob_SHARE_ROUTE_OBJECT_ID @"objectId"


#define bmob_USER_LOCATION @"userLocation"
#define bmob_USER_LOCATION_USERNAME @"username"
#define bmob_USER_LOCATION_OBJECT_ID @"objectId"
#define bmob_USER_LOCATION_GROUP_ID @"groupID"
#define bmob_USER_LOCATION_UPDATED_AT @"updatedAt"
#define bmob_USER_LOCATION_CREATED_AT @"createdAt"
#define bmob_USER_LOCATION_LOCATION @"location"


#endif /* Config_h */
