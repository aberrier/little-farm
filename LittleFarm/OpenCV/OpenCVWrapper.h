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
<<<<<<< HEAD

- (void) addPoint : (int) x : (int) y : (UIImage* _Nonnull) image;
- (UIImage*_Nonnull) add2DPoints : (UIImage* _Nonnull) image;
- (UIImage* _Nonnull) computePose : (UIImage* _Nonnull) image;
- (SCNNode* _Nonnull) SCNNodeOf3DPoints;

-(void) setScale : (float) scale;

- (void) saveFileAt : (NSString* _Nonnull) path;

=======
- (void) addPoint : (int) x : (int) y : (UIImage*) image;
- (void) update;
- (UIImage*) add2DPoints : (UIImage*) image;
- (UIImage*) computePose : (UIImage*) image;
>>>>>>> parent of 757272e... Optimzation and YAML creation
- (void) nextVertex;
- (int) getNumVertex;
- (BOOL) isRegistrationFinished;
- (redBox*) getCurrentVertex;
- (SCNNode*) SCNNodeOf3DPoints;
@end
