//
//  CVSReader.m
//  LittleFarm
//
//  Created by saad on 13/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "CVSReader.hpp"
#import <iostream>
#import <fstream>
#import "Util.hpp"
#import "opencv-headers.h"

using namespace std;
@interface CVSReader()

- (id) init : (string) path : (string) separator;
- (void) writeXYZ : (vector<cv::Point3f>) list_points3d;
- (void) writeUVXYZ : (vector<cv::Point3f>) list_points3d : (vector<cv::Point2f>) list_points2d : (cv::Mat) descriptors;

@end
@implementation CVSReader : NSObject
{
    ofstream file;
    string separator;
    bool isFirstTerm;
}

- (id) init : (string) path : (string) separator
{
    self = [super init];
    if (self)
    {
        self->file.open(path.c_str(), ofstream::out);
        self->isFirstTerm = true;
        self->separator = separator;
    }
    return self;
}
- (void) writeXYZ : (vector<cv::Point3f>) list_points3d
{
    string x, y, z;
    for(unsigned int i = 0; i < list_points3d.size(); ++i)
    {
        x = [[Util FloatToString:list_points3d[i].x] UTF8String];
        y = [[Util FloatToString:list_points3d[i].y] UTF8String];
        z = [[Util FloatToString:list_points3d[i].z] UTF8String];
        
        file << x << separator << y << separator << z << std::endl;
    }
}
- (void) writeUVXYZ : (vector<cv::Point3f>) list_points3d : (vector<cv::Point2f>) list_points2d : (cv::Mat) descriptors
{
    string u, v, x, y, z, descriptor_str;
    for(unsigned int i = 0; i < list_points3d.size(); ++i)
    {
        u = [[Util FloatToString:list_points2d[i].x] UTF8String];
        v = [[Util FloatToString:list_points2d[i].x] UTF8String];
        x = [[Util FloatToString:list_points3d[i].x] UTF8String];
        y = [[Util FloatToString:list_points3d[i].y] UTF8String];
        z = [[Util FloatToString:list_points3d[i].x] UTF8String];
        
        file << u << separator << v << separator << x << separator << y << separator << z;
        
        for(int j = 0; j < 32; ++j)
        {
            descriptor_str = [[Util FloatToString:descriptors.at<float>(i,j)] UTF8String];
            file << separator << descriptor_str;
        }
        file << std::endl;
    }
}
@end

