//
//  OpenCVWrapper.h
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
- (void) isItWorking;
- (void) setupDetection;
- (UIImage*) detectFrame : (CVPixelBufferRef) pixelBuffer;
- (NSString *) currentVersion;
- (UIImage*) makeGreyFromImage:(UIImage *)image;

@end
