//
//  Model.m
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "Model.hpp"
#import <iostream>
#import "opencv-headers.h"
#import "CVPoint2F.hpp"
#import "CVPoint3F.hpp"
using namespace std;

@implementation Model : NSObject
{
    int numCorrespondences;
    /** The list of 2D points on the model surface */
    std::vector<cv::KeyPoint> listKeypoints;
    /** The list of 2D points on the model surface */
    std::vector<cv::Point2f> list2DInside;
    /** The list of 2D points outside the model surface */
    std::vector<cv::Point2f> list2DOutside;
    /** The list of 3D points on the model surface */
    std::vector<cv::Point3f> list3DInside;
    /** The list of 2D points descriptors */
    std::vector<cv::Point2f> listDescriptors;
}

-(id) init
{
    self = [super init];
    self->numCorrespondences = 0;
    self->listKeypoints.clear();
    self->list2DInside.clear();
    self->list2DOutside.clear();
    self->list3DInside.clear();
    self->listDescriptors.clear();
    return self;
}

- (int) getNumberOfDescriptors
{
    return self->numCorrespondences;
}
- (void) addCorrespondence : (cv::Mat) a :(cv::Mat) b
{
    std::vector<float> array;
    cv::Point2f point2D;
    cv::Point3f point3D;
    if(a.isContinuous())
    {
        
        point2D.x=a.at<double>(0,0);
        point2D.y=a.at<double>(1,0);
    }
    if(b.isContinuous())
    {
        array.assign(a.datastart, b.dataend);
        point3D.x=b.at<double>(0,0);
        point3D.y=b.at<double>(1,0);
        point3D.z=b.at<double>(2,0);
    }
    std::cout << "A : " << point2D.x << " - " << point2D.y << std::endl;
    std::cout << "B : " << point3D.x << " - " << point3D.y << " - " << point3D.z << std::endl;
    self->list2DInside.push_back(point2D);
    self->list3DInside.push_back(point3D);
    self->numCorrespondences++;
}
- (void) test
{
    cv::Point2f newPointa(4,7);
    cv::Point3f newPointb(4,2,8);
    cv::Mat mata;
    cv::Mat matb;
    mata = cv::Mat::zeros(2, 1, CV_64FC1);
    mata.at<double>(0,0) = newPointa.x;
    mata.at<double>(1,0) = newPointa.y;
    
    matb = cv::Mat::zeros(3, 1, CV_64FC1);
    matb.at<double>(0,0) = newPointb.x;
    matb.at<double>(1,0) = newPointb.y;
    matb.at<double>(2,0) = newPointb.z;
    std::cout << "matA: " << mata.at<double>(0,0) << " - " << mata.at<double>(1,0) << std::endl;
    [self addCorrespondence:mata :matb];
}
- (void) addOutside
{
    
}
- (void) addDescriptor
{
    
}
- (void) addKeypoint
{
    
}

- (NSMutableArray *) save {
    NSMutableArray * tab = [NSMutableArray array];
    [tab addObject:@"Wesh"];
    [tab addObject:@"Allo"];
    return tab;
}
@end
