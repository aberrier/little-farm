 //
//  Model.h
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#ifndef Model_h
#define Model_h

#import <UIKit/UIKit.h>
#import "CVPoint3F.hpp"
#import "CVPoint2F.hpp"
namespace cv
{
    class Mat;
    class KeyPoint;
    //class Point3f;
    //class Point2f;
}

@interface Model : NSObject

- (int) getNumberOfDescriptors;
- (void) addCorrespondence : (cv::Mat) a : (cv::Mat) b;
- (void) addOutside;
- (void) addDescriptor;
- (void) addKeypoint;

- (NSMutableArray *) save;
- (id) init;
- (void) test;
@end

#endif /* Model_h */
