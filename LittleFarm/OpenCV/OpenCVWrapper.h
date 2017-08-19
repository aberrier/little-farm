//
//  OpenCVWrapper.h
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
@interface ImgPosPair : NSObject
{
    @public UIImage* image;
    @public float posX;
    @public float posY;
    @public float posZ;
}
- (UIImage*) getImage;
- (float) getX;
- (float) getY;
- (float) getZ;
@end
@interface OpenCVWrapper : NSObject
- (void) isItWorking;
- (void) setupDetection;
- (ImgPosPair*) detectFrame : (CVPixelBufferRef) pixelBuffer;
- (NSString *) currentVersion;
- (UIImage*) makeGreyFromImage:(UIImage *)image;

@end
