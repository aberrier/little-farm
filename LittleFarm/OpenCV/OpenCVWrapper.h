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
- (NSString *) currentVersion;
- (UIImage *) makeGrayFromImage : (UIImage *)image;

@end
