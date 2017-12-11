//
//  HistoryRouteModel.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/2.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryRouteModel : NSObject
@property (nonatomic,assign) NSInteger * status;
@property(nonatomic,copy) NSString * message;
@property(nonatomic,assign)NSInteger * total;
@property(nonatomic,assign)NSInteger * size;
@property(nonatomic,copy)NSString * entity_name;
@property(nonatomic,assign)NSInteger * distance;
@property(nonatomic,assign)NSInteger *toll_distance;
@property(nonatomic,strong)NSDictionary * start_point;


+(instancetype)initWithData:(NSData *)jsonData;
@end
