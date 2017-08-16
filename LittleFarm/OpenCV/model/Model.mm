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
using namespace std;

@interface Model()
- (std::vector<cv::Point2f>) getPoints2DIn;
- (std::vector<cv::Point2f>) getPoints2DOut;
- (std::vector<cv::Point3f>) getPoints3D;
- (std::vector<cv::KeyPoint>) getKeypoints;
- (int) getNumberOfDescriptors;
- (void) addCorrespondence : (cv::Point2f) point2D : (cv::Point3f) point3D;
- (void) addOutlier : (cv::Point2f) point2D;
- (void) addDescriptor : (cv::Mat) descriptor;
- (void) addKeypoint : (cv::KeyPoint) kp;
- (void) save : (std::string) path;
- (void) load : (std::string) path;
@end

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
    cv::Mat listDescriptors;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self->numCorrespondences = 0;
        self->listKeypoints.clear();
        self->list2DInside.clear();
        self->list2DOutside.clear();
        self->list3DInside.clear();
    }
    
    return self;
}
- (std::vector<cv::Point2f>) getPoints2DIn
{
    return self->list2DInside;
}
- (std::vector<cv::Point2f>) getPoints2DOut
{
    return self->list2DOutside;
}
- (std::vector<cv::Point3f>) getPoints3D
{
    return self->list3DInside;
}
- (std::vector<cv::KeyPoint>) getKeypoints
{
    return self->listKeypoints;
}
- (int) getNumberOfDescriptors
{
    return self->listDescriptors.rows;
}
- (void) addCorrespondence : (cv::Point2f) point2D : (cv::Point3f) point3D
{
    self->list2DInside.push_back(point2D);
    self->list3DInside.push_back(point3D);
    self->numCorrespondences++;
}

- (void) addOutlier : (cv::Point2f) point2D;
{
    self->list2DOutside.push_back(point2D);
}
- (void) addDescriptor : (cv::Mat) descriptor
{
    self->listDescriptors.push_back(descriptor);
}
- (void) addKeypoint : (cv::KeyPoint) keypoint
{
    self->listKeypoints.push_back(keypoint);
}

- (void) load : (std::string) path;
{
    //Conversion of the path
    //NSArray* stringArray = [[NSArray alloc] init];
    //stringArray = [path componentsSeparatedByString:@"."];
    /*
    if(stringArray.count != 2)
    {
        std::cerr << "Error : load - Incorrect path" << std::endl;
        return;
    }
    NSString *newPath = [[NSBundle mainBundle] pathForResource:stringArray[0] ofType:stringArray[1]];
    const char  * _Nullable pathCString = [newPath cStringUsingEncoding:NSUTF8StringEncoding];
     */
    //Get file
    
    cv::Mat points3DMat;
    cv::FileStorage storage (path/*[newPath UTF8String]*/, cv::FileStorage::READ);
    storage["points_3d"] >> points3DMat;
    storage["descriptors"] >> self->listDescriptors;
    points3DMat.copyTo(self->list3DInside);
    
    storage.release();
}
- (void) save : (std::string) path {
    
    cv::Mat points3dmatrix = cv::Mat(self->list3DInside);
    cv::Mat points2dmatrix = cv::Mat(self->list2DInside);
    //cv::Mat keyPointmatrix = cv::Mat(list_keypoints_);
    
    //Conversion of the path
    /*
    NSArray* stringArray = [[NSArray alloc] init];
    stringArray = [path componentsSeparatedByString:@"."];
    if(stringArray.count != 2)
    {
        std::cerr << "Error : save - Incorrect path" << std::endl;
        return;
    }
    NSString *newPath = [[NSBundle mainBundle] pathForResource:stringArray[0] ofType:stringArray[1]];
    
    NSString * documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
    std::cout << [documents UTF8String] << std::endl;
    NSString * filePath = [documents stringByAppendingPathComponent:path];
     */
    //Save file
    cv::FileStorage storage(path/*[filePath UTF8String]*/, cv::FileStorage::WRITE);
    storage << "points_3d" << points3dmatrix;
    storage << "points_2d" << points2dmatrix;
    storage << "keypoints" << self->listKeypoints;
    storage << "descriptors" << self->listDescriptors;
    std::cout << "Saved" << std::endl;
    storage.release();
    
}
- (void) test
{
    cv::Point2f newPointa(4,7);
    cv::Point3f newPointb(4,2,8);
    /*
     NSMutableArray * tab = [NSMutableArray array];
     [tab addObject:@"Wesh"];
     [tab addObject:@"Allo"];
     return tab;
     */
    
}
@end
