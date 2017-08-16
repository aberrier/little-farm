//
//  OpenCVWrapper.m
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "OpenCVWrapper.h"
#import "opencv-headers.h"

//Headers of Objective C class
#import "Model.hpp"
#import "RobustMatcher.hpp"
#import "PnPProblem.hpp"
#import "CVSWriter.hpp"
#import "CVSReader.hpp"

//C++ headers
#import <iostream>


@implementation OpenCVWrapper

using namespace std;
- (void) isItWorking {
    Model * newModel = [[Model alloc] init];
}
- (NSString*) currentVersion
{
    return [NSString stringWithFormat:@"Opencv Version %s",CV_VERSION];
}

- (UIImage*) makeGreyFromImage:(UIImage *)image
{
    //Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    //If the image was already grayscale, return it
    if(imageMat.channels() == 1) return image;
    
    //Transform the cv::Mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    return MatToUIImage(grayMat);
    
}

@end


/*************** MODEL ****************************
 
 //MODEL
 

