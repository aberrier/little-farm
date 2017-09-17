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
- (id) init;
- (BOOL) isSetuped;
- (void) setFilePaths : (NSString*) yml : (NSString*) ply;
- (void) loadCameraParameters : (const double[]) params;
- (void) loadDistorsionParameters : (const double[]) params;
- (void) setup;

- (redBox*) detectOnPixelBuffer : (CVPixelBufferRef) pixelBuffer;
- (CGRect) detect2DBoundingBoxOnPixelBuffer : (CVPixelBufferRef) pixelBuffer;
- (double) getTimeInterval;
- (void) setTimeInterval : (double) val;


@end

//Registration
@interface OpenCVRegistration : NSObject
- (id ) init;
- (BOOL) isSetuped;
- (void) setFilePath : (NSString*) ply;
- (void) loadCameraParameters : (const double[] ) params;
- (void) loadDistorsionParameters : (const double[]) params;
- (void) setup;

- (void) addPoint : (int) x : (int) y : (UIImage*) image;
- (UIImage*) add2DPoints : (UIImage*) image;
- (UIImage*) computePose : (UIImage*) image;
- (SCNNode*) SCNNodeOf3DPoints;

-(void) setScale : (float) scale;

- (void) saveFileAt : (NSString*) path;

- (void) nextVertex;
- (int) getNumVertex;
- (int) getVertexIndex;
- (BOOL) isRegistrationFinished;
- (redBox*) getCurrentVertex;

@end
