//
//  RobustMatcher.h
//  LittleFarm
//
//  Created by saad on 13/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#ifndef RobustMatcher_h
#define RobustMatcher_h

#import <UIKit/UIKit.h>
namespace cv
{
    class Mat;
    class KeyPoint;
    class DMatch;
}
@interface RobustMatcher : NSObject

- (id) init;

@end
#endif /* RobustMatcher_h */
