//
//  CVPoint2F.m
//  LittleFarm
//
//  Created by saad on 14/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CVPoint2F.hpp"
#import "opencv-headers.h"

@implementation CVPoint2F : NSObject
{
    cv::Point2f value;
}
@end
