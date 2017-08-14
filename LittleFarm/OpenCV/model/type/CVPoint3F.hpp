//
//  CVPoint3F.h
//  LittleFarm
//
//  Created by saad on 14/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#ifndef CVPoint3F_h
#define CVPoint3F_h

#import <UIKit/UIKit.h>
namespace cv
{
    class Point2;
}
@interface CVPoint3F : NSObject

- (id) init;
- (cv::Point2)get;
@end
#endif /* CVPoint3F_h */
