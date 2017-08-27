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
- (id _Nonnull ) init;
- (UIImage* _Nonnull) getImage;
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
- (UIImage* _Nonnull) getImage;
- (ModelRegistration* _Nonnull) getModel;
@end

//Detection
@interface OpenCVDetection : NSObject
- (id _Nonnull) init;
- (BOOL) isSetuped;
- (void) setFilePaths : (NSString* _Nonnull) yml : (NSString* _Nonnull) ply;
- (void) loadCameraParameters : (const double[]) params;
- (void) loadDistorsionParameters : (const double[]) params;
- (void) setup;

- (redBox* _Nonnull) detectOnPixelBuffer : (CVPixelBufferRef) pixelBuffer;
- (double) getTimeInterval;
- (void) setTimeInterval : (double) val;
@end

//Registration
@interface OpenCVRegistration : NSObject
- (id _Nonnull) init;
- (BOOL) isSetuped;
- (void) setFilePath : (NSString* _Nonnull) ply;
- (void) loadCameraParameters : (const double[] ) params;
- (void) loadDistorsionParameters : (const double[]) params;
- (void) setup;

- (void) addPoint : (int) x : (int) y : (UIImage* _Nonnull) image;
- (UIImage*_Nonnull) add2DPoints : (UIImage* _Nonnull) image;
- (UIImage* _Nonnull) computePose : (UIImage* _Nonnull) image;
- (SCNNode* _Nonnull) SCNNodeOf3DPoints;

-(void) setScale : (float) scale;

- (void) saveFileAt : (NSString* _Nonnull) path;

- (void) nextVertex;
- (int) getNumVertex;
- (int) getVertexIndex;
- (BOOL) isRegistrationFinished;
- (redBox* _Nonnull) getCurrentVertex;

@end
