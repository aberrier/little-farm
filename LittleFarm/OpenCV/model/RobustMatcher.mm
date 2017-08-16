//
//  RobustMatcher.m
//  LittleFarm
//
//  Created by saad on 13/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "RobustMatcher.hpp"
#import <iostream>
#import "opencv-headers.h"

using namespace std;
@interface RobustMatcher()

- (void) setFeatureDetector : (cv::Ptr<cv::FeatureDetector>) detect;

// Set the descriptor extractor
- (void) setDescriptorExtractor : (cv::Ptr<cv::DescriptorExtractor>) desc;

// Set the matcher
- (void) setDescriptorMatcher : (cv::Ptr<cv::DescriptorMatcher>) match;

// Compute the keypoints of an image
- (void) computeKeyPoints : (cv::Mat) image :  (std::vector<cv::KeyPoint>) keypoints;

// Compute the descriptors of an image given its keypoints
- (void) computeDescriptors: (cv::Mat) image : (std::vector<cv::KeyPoint>) keypoints : (cv::Mat) descriptors;

// Set ratio parameter for the ratio test
- (void) setRatio : (float) rat;

// Clear matches for which NN ratio is > than threshold
// return the number of removed points
// (corresponding entries being cleared,
// i.e. size will be 0)
- (int) ratioTest : (std::vector<std::vector<cv::DMatch> >) matches;

// Insert symmetrical matches in symMatches vector
- (void) symmetryTest: (std::vector<std::vector<cv::DMatch> >) matches1
                     :(std::vector<std::vector<cv::DMatch> >) matches2
                     :(std::vector<cv::DMatch>) symMatches;

// Match feature points using ratio and symmetry test
- (void) robustMatch: (cv::Mat) frame :  (std::vector<cv::DMatch>) good_matches
                    :(std::vector<cv::KeyPoint>) keypoints_frame
                    :(cv::Mat) descriptors_model;

// Match feature points using ratio test
- (void) fastRobustMatch : (cv::Mat) frame :  (std::vector<cv::DMatch>) good_matches
                         : (std::vector<cv::KeyPoint>) keypoints_frame
                        : (cv::Mat) descriptors_model;
@end

@implementation RobustMatcher : NSObject
{
    // pointer to the feature point detector object
    cv::Ptr<cv::FeatureDetector> detector;
    // pointer to the feature descriptor extractor object
    cv::Ptr<cv::DescriptorExtractor> extractor;
    // pointer to the matcher object
    cv::Ptr<cv::DescriptorMatcher> matcher;
    // max ratio between 1st and 2nd NN
    float ratio;
}

- (id) init
{
    self = [super init];
    self->ratio=0.8;
    // ORB is the default feature
    self->detector = cv::ORB::create();
    self->extractor = cv::ORB::create();
    
    // BruteFroce matcher with Norm Hamming is the default matcher
    self->matcher = cv::makePtr<cv::BFMatcher>((int)cv::NORM_HAMMING, false);
    return self;
}
- (void) setFeatureDetector : (cv::Ptr<cv::FeatureDetector>) detect
{
    self->detector=detect;
}

// Set the descriptor extractor
- (void) setDescriptorExtractor : (cv::Ptr<cv::DescriptorExtractor>) desc
{
    self->extractor = desc;
}

// Set the matcher
- (void) setDescriptorMatcher : (cv::Ptr<cv::DescriptorMatcher>) match
{
    self->matcher = match;
}

// Compute the keypoints of an image
- (void) computeKeyPoints : (cv::Mat) image :  (std::vector<cv::KeyPoint>) keypoints
{
    self->detector->detect(image, keypoints);
}

// Compute the descriptors of an image given its keypoints
- (void) computeDescriptors: (cv::Mat) image : (std::vector<cv::KeyPoint>) keypoints : (cv::Mat) descriptors
{
    self->extractor->compute(image, keypoints, descriptors);
}

// Set ratio parameter for the ratio test
- (void) setRatio : (float) rat
{
    self->ratio = rat;
}

// Clear matches for which NN ratio is > than threshold
// return the number of removed points
// (corresponding entries being cleared,
// i.e. size will be 0)
- (int) ratioTest : (std::vector<std::vector<cv::DMatch> >) matches
{
    int removed = 0;
    // for all matches
    for ( std::vector<std::vector<cv::DMatch> >::iterator
         matchIterator= matches.begin(); matchIterator!= matches.end(); ++matchIterator)
    {
        // if 2 NN has been identified
        if (matchIterator->size() > 1)
        {
            // check distance ratio
            if ((*matchIterator)[0].distance / (*matchIterator)[1].distance > ratio)
            {
                matchIterator->clear(); // remove match
                removed++;
            }
        }
        else
        { // does not have 2 neighbours
            matchIterator->clear(); // remove match
            removed++;
        }
    }
    return removed;
}

// Insert symmetrical matches in symMatches vector
- (void) symmetryTest: (std::vector<std::vector<cv::DMatch> >) matches1
                     :(std::vector<std::vector<cv::DMatch> >) matches2
                     :(std::vector<cv::DMatch>) symMatches
{
    // for all matches image 1 -> image 2
    for (std::vector<std::vector<cv::DMatch> >::const_iterator
         matchIterator1 = matches1.begin(); matchIterator1 != matches1.end(); ++matchIterator1)
    {
        
        // ignore deleted matches
        if (matchIterator1->empty() || matchIterator1->size() < 2)
            continue;
        
        // for all matches image 2 -> image 1
        for (std::vector<std::vector<cv::DMatch> >::const_iterator
             matchIterator2 = matches2.begin(); matchIterator2 != matches2.end(); ++matchIterator2)
        {
            // ignore deleted matches
            if (matchIterator2->empty() || matchIterator2->size() < 2)
                continue;
            
            // Match symmetry test
            if ((*matchIterator1)[0].queryIdx ==
                (*matchIterator2)[0].trainIdx &&
                (*matchIterator2)[0].queryIdx ==
                (*matchIterator1)[0].trainIdx)
            {
                // add symmetrical match
                symMatches.push_back(
                                     cv::DMatch((*matchIterator1)[0].queryIdx,
                                                (*matchIterator1)[0].trainIdx,
                                                (*matchIterator1)[0].distance));
                break; // next match in image 1 -> image 2
            }
        }
    }
}

// Match feature points using ratio and symmetry test
- (void) robustMatch: (cv::Mat) frame :  (std::vector<cv::DMatch>) good_matches
                    :(std::vector<cv::KeyPoint>) keypoints_frame
                    :(cv::Mat) descriptors_model
{
    // 1a. Detection of the ORB features
    [self computeKeyPoints : frame : keypoints_frame];
    
    // 1b. Extraction of the ORB descriptors
    cv::Mat descriptors_frame;
    [self computeDescriptors : frame : keypoints_frame : descriptors_frame];
    
    // 2. Match the two image descriptors
    std::vector<std::vector<cv::DMatch> > matches12, matches21;
    
    // 2a. From image 1 to image 2
    self->matcher->knnMatch(descriptors_frame, descriptors_model, matches12, 2); // return 2 nearest neighbours
    
    // 2b. From image 2 to image 1
    self->matcher->knnMatch(descriptors_model, descriptors_frame, matches21, 2); // return 2 nearest neighbours
    
    // 3. Remove matches for which NN ratio is > than threshold
    // clean image 1 -> image 2 matches
    [self ratioTest : matches12];
    // clean image 2 -> image 1 matches
    [self ratioTest : matches21];
    
    // 4. Remove non-symmetrical matches
    [self symmetryTest : matches12 : matches21 : good_matches ];
}

// Match feature points using ratio test
- (void) fastRobustMatch : (cv::Mat) frame :  (std::vector<cv::DMatch>) good_matches
                         : (std::vector<cv::KeyPoint>) keypoints_frame
                         : (cv::Mat) descriptors_model
{
    good_matches.clear();
    // 1a. Detection of the ORB features
    [self computeKeyPoints : frame : keypoints_frame];
    // 1b. Extraction of the ORB descriptors
    cv::Mat descriptors_frame;
    [self computeDescriptors : frame : keypoints_frame : descriptors_frame];
    // 2. Match the two image descriptors
    std::vector<std::vector<cv::DMatch> > matches;
    self->matcher->knnMatch(descriptors_frame, descriptors_model, matches, 2);
    // 3. Remove matches for which NN ratio is > than threshold
    [self ratioTest : matches];
    // 4. Fill good matches container
    for ( std::vector<std::vector<cv::DMatch> >::iterator
         matchIterator= matches.begin(); matchIterator!= matches.end(); ++matchIterator)
    {
        if (!matchIterator->empty()) good_matches.push_back((*matchIterator)[0]);
    }
}


@end
