//
//  CVPoint3F.m
//  LittleFarm
//
//  Created by saad on 14/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CVPoint3F.hpp"
#import "opencv-headers.h"

@implementation CVPoint3F : NSObject
{
    cv::Point3f value;
}
- (id)init
{
    self = [super init];
    return self;
}
- (int)get
{
    return 0;
}


@end
