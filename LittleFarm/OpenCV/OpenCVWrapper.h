//
//  OpenCVWrapper.h
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
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
@interface OpenCVWrapper : NSObject
- (void) isItWorking;
- (void) setupDetection;
- (redBox*) detectFrame : (CVPixelBufferRef) pixelBuffer;
- (NSString *) currentVersion;
- (UIImage*) makeGreyFromImage:(UIImage *)image;

@end
