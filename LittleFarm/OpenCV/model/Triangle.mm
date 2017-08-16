//
//  Triangle.m
//  LittleFarm
//
//  Created by saad on 16/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "Triangle.hpp"
#import <iostream>
#import "opencv-headers.h"

@interface Triangle()
- (id) init : (int) id_ : (cv::Point3f) V0 : (cv::Point3f) V1 : (cv::Point3f) V2;
- (cv::Point3f) getV0;
- (cv::Point3f) getV1;
- (cv::Point3f) getV2;

@end

@implementation Triangle : NSObject
{
    /** The identifier number of the triangle */
    int id_;
    /** The three vertices that defines the triangle */
    cv::Point3f v0, v1, v2;
}
- (id) init : (int) id_ : (cv::Point3f) V0 : (cv::Point3f) V1 : (cv::Point3f) V2
{
    self = [super init];
    if(self)
    {
        self->id_ = id_;
        self->v0 = V0;
        self->v1 = V1;
        self->v2 = V2;
    }
    return self;
}
- (cv::Point3f) getV0
{
    return self->v0;
}
- (cv::Point3f) getV1
{
    return self->v1;
}
- (cv::Point3f) getV2
{
    return self->v2;
}
@end

