//
//  SearchBarView.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/31.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "SearchBarView.h"

@implementation SearchBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.bounds.size.height)];
}

@end
