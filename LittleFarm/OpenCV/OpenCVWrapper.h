//
//  OpenCVWrapper.h
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "ModelRegistration.hpp"

//REDBOX
@interface redBox : NSObject
{
    @public UIImage* image;
    @public float posX;
    @public float posY;
    @public float posZ;
    @public double confidence;
}
- (id) init;
- (UIImage*) getImage;
- (float) getX;
- (float) getY;
- (float) getZ;
- (double) getConfidence;
- (void) setX : (float)val;
- (void) setY : (float)val;
- (void) setZ : (float)val;
- (void) setConfidence : (float)val;
@end

//BLUEBOX
@interface blueBox : NSObject
{
@public UIImage* image;
@public ModelRegistration* model;
}
- (UIImage*) getImage;
- (ModelRegistration*) getModel;
@end

//Detection
@interface OpenCVDetection : NSObject
- (void) isItWorking;
- (void) setup;
- (redBox*) detectFrame : (CVPixelBufferRef) pixelBuffer;
- (NSString *) currentVersion;
- (UIImage*) makeGreyFromImage:(UIImage *)image;
@end

//Registration
@interface OpenCVRegistration : NSObject
- (void) setup;
- (void) addPoint : (int) x : (int) y : (UIImage*) image;
- (void) update;
- (UIImage*) add2DPoints : (UIImage*) image;
- (UIImage*) computePose : (UIImage*) image;
- (void) nextVertex;
- (int) getNumVertex;
- (BOOL) isRegistrationFinished;
- (redBox*) getCurrentVertex;
- (SCNNode*) SCNNodeOf3DPoints;
@end
