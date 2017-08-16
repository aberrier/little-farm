//
//  Ray.m
//  LittleFarm
//
//  Created by saad on 16/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "Ray.hpp"
#import <iostream>
#import "opencv-headers.h"

@interface Ray()
- (id) init : (cv::Point3f) P0 : (cv::Point3f) P1;
- (cv::Point3f) getP0;
- (cv::Point3f) getP1;
@end
    
@implementation Ray : NSObject
{
    cv::Point3f p0;
    cv::Point3f p1;
}
- (id) init : (cv::Point3f) P0 : (cv::Point3f) P1
{
    self = [super init];
    if (self)
    {
        self->p0 = P0;
        self->p1 = P1;
    }
    return self;
}
- (cv::Point3f) getP0
{
    return self->p0;
}
- (cv::Point3f) getP1
{
    return self->p1;
}
@end

