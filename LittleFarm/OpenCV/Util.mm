//
//  Util.m
//  LittleFarm
//
//  Created by saad on 16/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "Util.hpp"

#import <iostream>
#import <sstream>

#import "opencv-headers.h"

using namespace std;

@interface Util()

@end

@implementation Util : NSObject
+ (int) StringToInt : (NSString*) Text
{
    std::string cppText = [Text UTF8String];
    std::istringstream ss(cppText);
    int result;
    return ss >> result ? result : 0;
}

+ (NSString*) FloatToString : (float) Number
{
    std::ostringstream ss;
    ss << Number;
    return [NSString stringWithCString:ss.str().c_str() encoding:[NSString defaultCStringEncoding]];
}
@end
