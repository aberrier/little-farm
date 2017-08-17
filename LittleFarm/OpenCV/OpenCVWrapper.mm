//
//  OpenCVWrapper.m
//  LittleFarm
//
//  Created by saad on 31/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "OpenCVWrapper.h"
#import "opencv-headers.h"

//Headers of Objective C class
#import "Model.hpp"
#import "Mesh.hpp"
#import "RobustMatcher.hpp"
#import "PnPProblem.hpp"
#import "CVSWriter.hpp"
#import "CVSReader.hpp"
#import "Util.hpp"
//C++ headers
#import <iostream>
#import <fstream>
#import <sstream>

using namespace std;



/********************** MODEL ****************************/
 
 //MODEL
 
 @interface Model()
 - (std::vector<cv::Point2f>) getPoints2DIn;
 - (std::vector<cv::Point2f>) getPoints2DOut;
 - (std::vector<cv::Point3f>) getPoints3D;
 - (std::vector<cv::KeyPoint>) getKeypoints;
 - (cv::Mat) getDescriptors;
 - (int) getNumberOfDescriptors;
 - (void) addCorrespondence : (cv::Point2f&) point2D : (cv::Point3f&) point3D;
 - (void) addOutlier : (cv::Point2f&) point2D;
 - (void) addDescriptor : (cv::Mat&) descriptor;
 - (void) addKeypoint : (cv::KeyPoint&) kp;
 - (void) save : (std::string) path;
 - (void) load : (std::string) path;
 @end
 
 @implementation Model
 {
 int numCorrespondences;
 /** The list of 2D points on the model surface */
std::vector<cv::KeyPoint> listKeypoints;
/** The list of 2D points on the model surface */
std::vector<cv::Point2f> list2DInside;
/** The list of 2D points outside the model surface */
std::vector<cv::Point2f> list2DOutside;
/** The list of 3D points on the model surface */
std::vector<cv::Point3f> list3DInside;
/** The list of 2D points descriptors */
cv::Mat listDescriptors;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self->numCorrespondences = 0;
        self->listKeypoints.clear();
        self->list2DInside.clear();
        self->list2DOutside.clear();
        self->list3DInside.clear();
    }
    
    return self;
}
- (cv::Mat) getDescriptors
{
    return self->listDescriptors;
}
- (std::vector<cv::Point2f>) getPoints2DIn
{
    return self->list2DInside;
}
- (std::vector<cv::Point2f>) getPoints2DOut
{
    return self->list2DOutside;
}
- (std::vector<cv::Point3f>) getPoints3D
{
    return self->list3DInside;
}
- (std::vector<cv::KeyPoint>) getKeypoints
{
    return self->listKeypoints;
}
- (int) getNumberOfDescriptors
{
    return self->listDescriptors.rows;
}
- (void) addCorrespondence : (cv::Point2f&) point2D : (cv::Point3f&) point3D
{
    self->list2DInside.push_back(point2D);
    self->list3DInside.push_back(point3D);
    self->numCorrespondences++;
}

- (void) addOutlier : (cv::Point2f&) point2D;
{
    self->list2DOutside.push_back(point2D);
}
- (void) addDescriptor : (cv::Mat&) descriptor
{
    self->listDescriptors.push_back(descriptor);
}
- (void) addKeypoint : (cv::KeyPoint&) keypoint
{
    self->listKeypoints.push_back(keypoint);
}

- (void) load : (std::string) path;
{
    //Conversion of the path
    //NSArray* stringArray = [[NSArray alloc] init];
    //stringArray = [path componentsSeparatedByString:@"."];
    /*
     if(stringArray.count != 2)
     {
     std::cerr << "Error : load - Incorrect path" << std::endl;
     return;
     }
     NSString *newPath = [[NSBundle mainBundle] pathForResource:stringArray[0] ofType:stringArray[1]];
     const char  * _Nullable pathCString = [newPath cStringUsingEncoding:NSUTF8StringEncoding];
     */
    //Get file
    
    cv::Mat points3DMat;
    cv::FileStorage storage (path/*[newPath UTF8String]*/, cv::FileStorage::READ);
    storage["points_3d"] >> points3DMat;
    storage["descriptors"] >> self->listDescriptors;
    points3DMat.copyTo(self->list3DInside);
    
    storage.release();
}
- (void) save : (std::string) path {
    
    cv::Mat points3dmatrix = cv::Mat(self->list3DInside);
    cv::Mat points2dmatrix = cv::Mat(self->list2DInside);
    //cv::Mat keyPointmatrix = cv::Mat(list_keypoints_);
    
    //Conversion of the path
    /*
     NSArray* stringArray = [[NSArray alloc] init];
     stringArray = [path componentsSeparatedByString:@"."];
     if(stringArray.count != 2)
     {
     std::cerr << "Error : save - Incorrect path" << std::endl;
     return;
     }
     NSString *newPath = [[NSBundle mainBundle] pathForResource:stringArray[0] ofType:stringArray[1]];
     
     NSString * documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
     std::cout << [documents UTF8String] << std::endl;
     NSString * filePath = [documents stringByAppendingPathComponent:path];
     */
    //Save file
    cv::FileStorage storage(path/*[filePath UTF8String]*/, cv::FileStorage::WRITE);
    storage << "points_3d" << points3dmatrix;
    storage << "points_2d" << points2dmatrix;
    storage << "keypoints" << self->listKeypoints;
    storage << "descriptors" << self->listDescriptors;
    std::cout << "Saved" << std::endl;
    storage.release();
    
    }
    - (void) test
    {
        cv::Point2f newPointa(4,7);
        cv::Point3f newPointb(4,2,8);
        /*
         NSMutableArray * tab = [NSMutableArray array];
         [tab addObject:@"Wesh"];
         [tab addObject:@"Allo"];
         return tab;
         */
        
    }
    @end
    
//ROBUSTMATCHER
@interface RobustMatcher()

- (void) setFeatureDetector : (cv::Ptr<cv::FeatureDetector>&) detect;

// Set the descriptor extractor
- (void) setDescriptorExtractor : (cv::Ptr<cv::DescriptorExtractor>&) desc;

// Set the matcher
- (void) setDescriptorMatcher : (cv::Ptr<cv::DescriptorMatcher>&) match;

// Compute the keypoints of an image
- (void) computeKeyPoints : (cv::Mat&) image :  (std::vector<cv::KeyPoint>&) keypoints;

// Compute the descriptors of an image given its keypoints
- (void) computeDescriptors: (cv::Mat&) image : (std::vector<cv::KeyPoint>&) keypoints : (cv::Mat&) descriptors;

// Set ratio parameter for the ratio test
- (void) setRatio : (float) rat;

// Clear matches for which NN ratio is > than threshold
// return the number of removed points
// (corresponding entries being cleared,
// i.e. size will be 0)
- (int) ratioTest : (std::vector<std::vector<cv::DMatch> >&) matches;

// Insert symmetrical matches in symMatches vector
- (void) symmetryTest: (std::vector<std::vector<cv::DMatch> >&) matches1
                     :(std::vector<std::vector<cv::DMatch> >&) matches2
                     :(std::vector<cv::DMatch>&) symMatches;

// Match feature points using ratio and symmetry test
- (void) robustMatch: (cv::Mat&) frame :  (std::vector<cv::DMatch>&) good_matches
                    :(std::vector<cv::KeyPoint>&) keypoints_frame
                    :(cv::Mat&) descriptors_model;

// Match feature points using ratio test
- (void) fastRobustMatch : (cv::Mat&) frame :  (std::vector<cv::DMatch>&) good_matches
                         : (std::vector<cv::KeyPoint>&) keypoints_frame
                         : (cv::Mat&) descriptors_model;
@end

@implementation RobustMatcher
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
- (void) setFeatureDetector : (cv::Ptr<cv::FeatureDetector>&) detect
{
    self->detector=detect;
}

// Set the descriptor extractor
- (void) setDescriptorExtractor : (cv::Ptr<cv::DescriptorExtractor>&) desc
{
    self->extractor = desc;
}

// Set the matcher
- (void) setDescriptorMatcher : (cv::Ptr<cv::DescriptorMatcher>&) match
{
    self->matcher = match;
}

// Compute the keypoints of an image
- (void) computeKeyPoints : (cv::Mat&) image :  (std::vector<cv::KeyPoint>&) keypoints
{
    self->detector->detect(image, keypoints);
}

// Compute the descriptors of an image given its keypoints
- (void) computeDescriptors: (cv::Mat&) image : (std::vector<cv::KeyPoint>&) keypoints : (cv::Mat&) descriptors
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
- (int) ratioTest : (std::vector<std::vector<cv::DMatch> >&) matches
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
- (void) symmetryTest: (std::vector<std::vector<cv::DMatch> >&) matches1
                     :(std::vector<std::vector<cv::DMatch> >&) matches2
                     :(std::vector<cv::DMatch>&) symMatches
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
- (void) robustMatch: (cv::Mat&) frame :  (std::vector<cv::DMatch>&) good_matches
                    :(std::vector<cv::KeyPoint>&) keypoints_frame
                    :(cv::Mat&) descriptors_model
{
    // 1a. Detection of the ORB features
    [self computeKeyPoints : frame : keypoints_frame];
    
    // 1b. Extraction of the ORB descriptors
    cv::Mat descriptors_frame;
    //If the camera views is completly dark, the descriptor frame can be empty and lead to a crash
    if(!descriptors_frame.isContinuous())
    {
        std::cout << "Can't find any descriptors on camera. It can be obstructed." << std::endl;
        good_matches.clear();
        return;
    }
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
- (void) fastRobustMatch : (cv::Mat&) frame :  (std::vector<cv::DMatch>&) good_matches
                         : (std::vector<cv::KeyPoint>&) keypoints_frame
                         : (cv::Mat&) descriptors_model
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
//CVSREADER

@interface CVSReader()
- (id) init : (string) path : (char) separator;

/**
 * Read a plane text file with .ply format
 *
 * @param list_vertex - The container of the vertices list of the mesh
 * @param list_triangle - The container of the triangles list of the mesh
 * @return
 */
- (void) readPLY : (vector<cv::Point3f>&) listVertex : (vector<vector<int> >&) listTriangles;
@end

@implementation CVSReader
{
    /** The current stream file for the reader */
    ifstream file;
    /** The separator character between words for each line */
    char separator;
}
- (id) init : (string) path : (char) separator
{
    self = [super init];
    if (self)
    {
        self->file.open(path.c_str(), ifstream::in);
        self->separator = separator;
    }
    return self;
}

- (void) readPLY : (vector<cv::Point3f>&) listVertex : (vector<vector<int> >&) listTriangles
{
    std::string line, tmp_str, n;
    int num_vertex = 0, num_triangles = 0;
    int count = 0;
    bool end_header = false;
    bool end_vertex = false;
    
    // Read the whole *.ply file
    while (getline(file, line)) {
        stringstream liness(line);
        
        // read header
        if(!end_header)
        {
            getline(liness, tmp_str, separator);
            if( tmp_str == "element" )
            {
                getline(liness, tmp_str, separator);
                getline(liness, n);
                if(tmp_str == "vertex") num_vertex = [Util StringToInt:[NSString stringWithCString:n.c_str() encoding:[NSString defaultCStringEncoding]]];
                if(tmp_str == "face") num_triangles = [Util StringToInt:[NSString stringWithCString:n.c_str() encoding:[NSString defaultCStringEncoding]]];
            }
            stringstream corrector(tmp_str);
            getline(corrector, tmp_str, '\n');
            if(tmp_str == "end_header") end_header = true;
        }
        
        // read file content
        else if(end_header)
        {
            // read vertex and add into 'list_vertex'
            if(!end_vertex && count < num_vertex)
            {
                string x, y, z;
                getline(liness, x, separator);
                getline(liness, y, separator);
                getline(liness, z);
                
                cv::Point3f tmp_p;
                tmp_p.x = (float)[Util StringToInt:[NSString stringWithCString:x.c_str() encoding:[NSString defaultCStringEncoding]]];;
                tmp_p.y = (float)[Util StringToInt:[NSString stringWithCString:y.c_str() encoding:[NSString defaultCStringEncoding]]];
                tmp_p.z = (float)[Util StringToInt:[NSString stringWithCString:z.c_str() encoding:[NSString defaultCStringEncoding]]];
                listVertex.push_back(tmp_p);
                
                count++;
                if(count == num_vertex)
                {
                    count = 0;
                    end_vertex = !end_vertex;
                }
            }
            // read faces and add into 'list_triangles'
            else if(end_vertex  && count < num_triangles)
            {
                string num_pts_per_face, id0, id1, id2;
                getline(liness, num_pts_per_face, separator);
                getline(liness, id0, separator);
                getline(liness, id1, separator);
                getline(liness, id2);
                
                std::vector<int> tmp_triangle(3);
                tmp_triangle[0] = [Util StringToInt:[NSString stringWithCString:id0.c_str() encoding:[NSString defaultCStringEncoding]]];
                tmp_triangle[1] = [Util StringToInt:[NSString stringWithCString:id1.c_str() encoding:[NSString defaultCStringEncoding]]];
                tmp_triangle[2] = [Util StringToInt:[NSString stringWithCString:id2.c_str() encoding:[NSString defaultCStringEncoding]]];
                listTriangles.push_back(tmp_triangle);
                
                count++;
            }
        }
    }
}

@end

//CVSWRITER
@interface CVSWriter()

- (id) init : (string) path : (string) separator;
- (void) writeXYZ : (vector<cv::Point3f>&) list_points3d;
- (void) writeUVXYZ : (vector<cv::Point3f>&) list_points3d : (vector<cv::Point2f>&) list_points2d : (cv::Mat&) descriptors;

@end

@implementation CVSWriter
{
    ofstream file;
    string separator;
    bool isFirstTerm;
}

- (id) init : (string) path : (string) separator
{
    self = [super init];
    if (self)
    {
        self->file.open(path.c_str(), ofstream::out);
        self->isFirstTerm = true;
        self->separator = separator;
    }
    return self;
}
- (void) writeXYZ : (vector<cv::Point3f>&) list_points3d
{
    string x, y, z;
    for(unsigned int i = 0; i < list_points3d.size(); ++i)
    {
        x = [[Util FloatToString:list_points3d[i].x] UTF8String];
        y = [[Util FloatToString:list_points3d[i].y] UTF8String];
        z = [[Util FloatToString:list_points3d[i].z] UTF8String];
        
        file << x << separator << y << separator << z << std::endl;
    }
}
- (void) writeUVXYZ : (vector<cv::Point3f>&) list_points3d : (vector<cv::Point2f>&) list_points2d : (cv::Mat&) descriptors
{
    string u, v, x, y, z, descriptor_str;
    for(unsigned int i = 0; i < list_points3d.size(); ++i)
    {
        u = [[Util FloatToString:list_points2d[i].x] UTF8String];
        v = [[Util FloatToString:list_points2d[i].x] UTF8String];
        x = [[Util FloatToString:list_points3d[i].x] UTF8String];
        y = [[Util FloatToString:list_points3d[i].y] UTF8String];
        z = [[Util FloatToString:list_points3d[i].x] UTF8String];
        
        file << u << separator << v << separator << x << separator << y << separator << z;
        
        for(int j = 0; j < 32; ++j)
        {
            descriptor_str = [[Util FloatToString:descriptors.at<float>(i,j)] UTF8String];
            file << separator << descriptor_str;
        }
        file << std::endl;
    }
}
@end
//MESH, RAY AND TRIANGLE
@interface Mesh()
- (std::vector<std::vector<int> >) getTrianglesList;
- (cv::Point3f) getVertex : (int) pos;
- (int) getNumVertices;
- (void) load : (std::string) path_file;
@end

@implementation Mesh
{
    /** The identification number of the mesh */
    int id_;
    /** The current number of vertices in the mesh */
    int numVertexs;
    /** The current number of triangles in the mesh */
    int numTriangles;
    /* The list of triangles of the mesh */
    std::vector<cv::Point3f> listVertex;
    /* The list of triangles of the mesh */
    std::vector<std::vector<int> > listTriangles;
}
-(id) init
{
    self = [super init];
    if (self)
    {
        self->listVertex.clear();
        self->listTriangles.clear();
        self->id_=0;
        self->numVertexs=0;
        self->numTriangles=0;
    }
    return self;
}
- (std::vector<std::vector<int> >) getTrianglesList
{
    return self->listTriangles;
}
- (cv::Point3f) getVertex : (int) pos
{
    if(pos >= self->listVertex.size())
    {
        std::cout << "Error - getVertex : Position out of reach." << std::endl;
        return cv::Point3f(0,0,0);
    }
    return self->listVertex[pos];
    
}
- (int) getNumVertices
{
    return self->numVertexs;
}
- (void) load : (std::string) path_file
{
    // Create the reader
    CVSReader* csvReader = [[CVSReader alloc] init : path_file : ' '];
    
    // Clear previous data
    listVertex.clear();
    listTriangles.clear();
    
    // Read from .ply file
    [csvReader readPLY:listVertex :listTriangles];
    
    // Update mesh attributes
    numVertexs = (int)listVertex.size();
    numTriangles = (int)listTriangles.size();
}
@end

@interface Triangle()
- (id) init : (int) id_ : (cv::Point3f) V0 : (cv::Point3f) V1 : (cv::Point3f) V2;
- (cv::Point3f) getV0;
- (cv::Point3f) getV1;
- (cv::Point3f) getV2;

@end

@implementation Triangle
{
    /** The identifier number of the triangle */
    int id_;
    /** The three vertices that defines the triangle */
    cv::Point3f v0, v1, v2;
}
- (id) init : (int) id_ : (cv::Point3f) V0 : (cv::Point3f) V1 : (cv::Point3f) V2
{
    self = [super init];
    if(self)
    {
        self->id_ = id_;
        self->v0 = V0;
        self->v1 = V1;
        self->v2 = V2;
    }
    return self;
}
- (cv::Point3f) getV0
{
    return self->v0;
}
- (cv::Point3f) getV1
{
    return self->v1;
}
- (cv::Point3f) getV2
{
    return self->v2;
}
@end


@interface Ray()
- (id) init : (cv::Point3f) P0 : (cv::Point3f) P1;
- (cv::Point3f) getP0;
- (cv::Point3f) getP1;
@end

@implementation Ray
{
    cv::Point3f p0;
    cv::Point3f p1;
}
- (id) init : (cv::Point3f) P0 : (cv::Point3f) P1
{
    self = [super init];
    if (self)
    {
        self->p0 = P0;
        self->p1 = P1;
    }
    return self;
}
- (cv::Point3f) getP0
{
    return self->p0;
}
- (cv::Point3f) getP1
{
    return self->p1;
}
@end


// PnPPROBLEM
@interface PnPProblem()

- (id) init : (NSMutableArray*) param;

- (BOOL) backproject2DPoint : (Mesh*) mesh : (cv::Point2f&) point2d : (cv::Point3f&) point3d;
- (BOOL) intersectMollerTrumbore : (Ray*) R : (Triangle*) T : (double*) out_;
- (std::vector<cv::Point2f>) verifyPoints : (Mesh *) mesh;
- (cv::Point2f) backproject3DPoint : (cv::Point3f&) point3d;
- (BOOL) estimatePose : (std::vector<cv::Point3f>&) listPoints3d : (std::vector<cv::Point2f>&) listPoints2d :  (int) flags;
- (void) estimatePoseRANSAC : (std::vector<cv::Point3f>&) listPoints3d : (std::vector<cv::Point2f>&) listPoints2d
                            : (int) flags
                            : (cv::Mat&) inliers
                            : (int) iterationsCount : (float) reprojectionError : (double) confidence;

- (cv::Mat) getAMatrix;
- (cv::Mat) getRMatrix;
- (cv::Mat) getTMatrix;
- (cv::Mat) getPMatrix;

- (void) setPMatrix : (cv::Mat&) R_matrix : (cv::Mat&) t_matrix;

// Functions for Möller–Trumbore intersection algorithm
- (cv::Point3f) CROSS : (cv::Point3f) v1 :  (cv::Point3f) v2;
- (double) DOT : (cv::Point3f) v1 :  (cv::Point3f) v2;
- (cv::Point3f) SUB : (cv::Point3f) v1 : (cv::Point3f) v2;
- (cv::Point3f) getNearest3DPoint : (std::vector<cv::Point3f>) pointsList : (cv::Point3f) origin;
@end

@implementation PnPProblem
{
    /** The calibration matrix */
    cv::Mat AMatrix;
    /** The computed rotation matrix */
    cv::Mat RMatrix;
    /** The computed translation matrix */
    cv::Mat TMatrix;
    /** The computed projection matrix */
    cv::Mat PMatrix;
}
- (id) init : (NSMutableArray< NSNumber* >*) param
{
    self = [super init];
    if(self)
    {
        self->AMatrix = cv::Mat::zeros(3, 3, CV_64FC1);   // intrinsic camera parameters
        self->AMatrix.at<double>(0, 0) = [param[0] doubleValue];       //      [ fx   0  cx ]
        self->AMatrix.at<double>(1, 1) = [param[1] doubleValue];       //      [  0  fy  cy ]
        self->AMatrix.at<double>(0, 2) = [param[2] doubleValue];      //      [  0   0   1 ]
        self->AMatrix.at<double>(1, 2) = [param[3] doubleValue];
        self->AMatrix.at<double>(2, 2) = 1;
        self->RMatrix = cv::Mat::zeros(3, 3, CV_64FC1);   // rotation matrix
        self->TMatrix = cv::Mat::zeros(3, 1, CV_64FC1);   // translation matrix
        self->PMatrix = cv::Mat::zeros(3, 4, CV_64FC1);   // rotation-translation matrix
    }
    return self;
}

- (BOOL) backproject2DPoint : (Mesh*) mesh : (cv::Point2f&) point2d : (cv::Point3f&) point3d
{
    // Triangles list of the object mesh
    std::vector<std::vector<int> > triangles_list = [mesh getTrianglesList];
    
    double lambda = 8;
    double u = point2d.x;
    double v = point2d.y;
    
    // Point in vector form
    cv::Mat point2d_vec = cv::Mat::ones(3, 1, CV_64F); // 3x1
    point2d_vec.at<double>(0) = u * lambda;
    point2d_vec.at<double>(1) = v * lambda;
    point2d_vec.at<double>(2) = lambda;
    
    // Point in camera coordinates
    cv::Mat X_c = AMatrix.inv() * point2d_vec ; // 3x1
    
    // Point in world coordinates
    cv::Mat X_w = RMatrix.inv() * ( X_c - TMatrix ); // 3x1
    
    // Center of projection
    cv::Mat C_op = cv::Mat(RMatrix.inv()).mul(-1) * TMatrix; // 3x1
    
    // Ray direction vector
    cv::Mat ray = X_w - C_op; // 3x1
    ray = ray / cv::norm(ray); // 3x1
    
    // Set up Ray
    Ray * R = [[Ray alloc] init : (cv::Point3f)C_op : (cv::Point3f)ray];
    
    // A vector to store the intersections found
    std::vector<cv::Point3f> intersections_list;
    
    // Loop for all the triangles and check the intersection
    for (unsigned int i = 0; i < triangles_list.size(); i++)
    {
        cv::Point3f V0 = [mesh getVertex : triangles_list[i][0]];
        cv::Point3f V1 = [mesh getVertex : triangles_list[i][1]];
        cv::Point3f V2 = [mesh getVertex : triangles_list[i][2]];
        
        Triangle * T = [[Triangle alloc] init : i : V0 : V1 : V2];
        
        double out;
        if([self intersectMollerTrumbore : R : T : &out])
        {
            cv::Point3f tmp_pt = [R getP0] + out*[R getP1]; // P = O + t*D
            intersections_list.push_back(tmp_pt);
        }
    }
    
    // If there are intersection, find the nearest one
    if (!intersections_list.empty())
    {
        point3d = [self getNearest3DPoint : intersections_list : [R getP0]];
        return true;
    }
    else
    {
        return false;
    }
}
- (BOOL) intersectMollerTrumbore : (Ray*) Ra : (Triangle*) Tri : (double*) out_
{
    const double EPSILON = 0.000001;
    
    cv::Point3f e1, e2;
    cv::Point3f P, Q, T;
    double det, inv_det, u, v;
    double t;
    
    cv::Point3f V1 = [Tri getV0];  // Triangle vertices
    cv::Point3f V2 = [Tri getV1];
    cv::Point3f V3 = [Tri getV2];
    
    cv::Point3f O = [Ra getP0]; // Ray origin
    cv::Point3f D = [Ra getP1]; // Ray direction
    
    //Find vectors for two edges sharing V1
    e1 = [self SUB : V2 : V1];
    e2 = [self SUB : V3 : V1];
    
    // Begin calculation determinant - also used to calculate U parameter
    P = [self CROSS : D : e2];
    
    // If determinant is near zero, ray lie in plane of triangle
    det = [self DOT : e1 : P];
    
    //NOT CULLING
    if(det > -EPSILON && det < EPSILON) return false;
    inv_det = 1.f / det;
    
    //calculate distance from V1 to ray origin
    T = [self SUB : O : V1];
    
    //Calculate u parameter and test bound
    u = [self DOT : T : P] * inv_det;
    
    //The intersection lies outside of the triangle
    if(u < 0.f || u > 1.f) return false;
    
    //Prepare to test v parameter
    Q = [self CROSS : T : e1];
    
    //Calculate V parameter and test bound
    v = [self DOT : D : Q] * inv_det;
    
    //The intersection lies outside of the triangle
    if(v < 0.f || u + v  > 1.f) return false;
    
    t = [self DOT : e2 : Q] * inv_det;
    
    if(t > EPSILON)   //ray intersection
    {
        *out_ = t;
        return true;
    }
    
    // No hit, no win
    return false;
}
- (std::vector<cv::Point2f>) verifyPoints : (Mesh *) mesh
{
    std::vector<cv::Point2f> verified_points_2d;
    for( int i = 0; i < [mesh getNumVertices]; i++)
    {
        cv::Point3f point3d = [mesh getVertex : i];
        cv::Point2f point2d = [self backproject3DPoint : point3d];
        verified_points_2d.push_back(point2d);
    }
    
    return verified_points_2d;
}
- (cv::Point2f) backproject3DPoint : (cv::Point3f&) point3d
{
    // 3D point vector [x y z 1]'
    cv::Mat point3d_vec = cv::Mat(4, 1, CV_64FC1);
    point3d_vec.at<double>(0) = point3d.x;
    point3d_vec.at<double>(1) = point3d.y;
    point3d_vec.at<double>(2) = point3d.z;
    point3d_vec.at<double>(3) = 1;
    
    // 2D point vector [u v 1]'
    cv::Mat point2d_vec = cv::Mat(4, 1, CV_64FC1);
    point2d_vec = AMatrix * PMatrix * point3d_vec;
    
    // Normalization of [u v]'
    cv::Point2f point2d;
    point2d.x = (float)(point2d_vec.at<double>(0) / point2d_vec.at<double>(2));
    point2d.y = (float)(point2d_vec.at<double>(1) / point2d_vec.at<double>(2));
    
    return point2d;
}
- (BOOL) estimatePose : (std::vector<cv::Point3f>&) listPoints3d : (std::vector<cv::Point2f>&) listPoints2d :  (int) flags
{
    cv::Mat distCoeffs = cv::Mat::zeros(4, 1, CV_64FC1);
    cv::Mat rvec = cv::Mat::zeros(3, 1, CV_64FC1);
    cv::Mat tvec = cv::Mat::zeros(3, 1, CV_64FC1);
    
    bool useExtrinsicGuess = false;
    
    // Pose estimation
    bool correspondence = cv::solvePnP( listPoints3d, listPoints2d, AMatrix, distCoeffs, rvec, tvec,
                                       useExtrinsicGuess, flags);
    
    // Transforms Rotation Vector to Matrix
    Rodrigues(rvec,RMatrix);
    TMatrix = tvec;
    
    // Set projection matrix
    [self setPMatrix : RMatrix : TMatrix];
     
     return correspondence;
     }
     - (void) estimatePoseRANSAC : (std::vector<cv::Point3f>&) listPoints3d : (std::vector<cv::Point2f>&) listPoints2d
     : (int) flags
     : (cv::Mat&) inliers
     : (int) iterationsCount : (float) reprojectionError : (double) confidence
     {
         cv::Mat distCoeffs = cv::Mat::zeros(4, 1, CV_64FC1);  // vector of distortion coefficients
         cv::Mat rvec = cv::Mat::zeros(3, 1, CV_64FC1);          // output rotation vector
         cv::Mat tvec = cv::Mat::zeros(3, 1, CV_64FC1);    // output translation vector
         
         
         bool useExtrinsicGuess = false;   // if true the function uses the provided rvec and tvec values as
         // initial approximations of the rotation and translation vectors
         
         //to input array
         cv::InputArray inputArray(listPoints3d);
         cv::Mat mat = inputArray.getMat();
         cv::Mat matDirect = cv::Mat(listPoints3d);
         cv::solvePnPRansac( listPoints3d, listPoints2d, AMatrix, distCoeffs, rvec, tvec,
                            useExtrinsicGuess, iterationsCount, reprojectionError, confidence,
                            inliers, flags );
         Rodrigues(rvec,RMatrix);      // converts Rotation Vector to Matrix
         TMatrix = tvec;       // set translation matrix
         [self setPMatrix : RMatrix : TMatrix]; // set rotation-translation matrix
     }
     
     - (cv::Mat) getAMatrix
     {
         return self->AMatrix;
     }
     - (cv::Mat) getRMatrix
     {
         return self->RMatrix;
     }
     - (cv::Mat) getTMatrix
     {
         return self->TMatrix;
     }
     - (cv::Mat) getPMatrix
     {
         return self->PMatrix;
     }
     - (void) setPMatrix : (cv::Mat&) R_matrix : (cv::Mat&) t_matrix
     {
         
     }
     // Functions for Möller–Trumbore intersection algorithm
     - (cv::Point3f) CROSS : (cv::Point3f) v1 :  (cv::Point3f) v2
     {
         cv::Point3f tmp_p;
         tmp_p.x =  v1.y*v2.z - v1.z*v2.y;
         tmp_p.y =  v1.z*v2.x - v1.x*v2.z;
         tmp_p.z =  v1.x*v2.y - v1.y*v2.x;
         return tmp_p;
     }
     - (double) DOT : (cv::Point3f) v1 :  (cv::Point3f) v2
     {
         return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
     }
     - (cv::Point3f) SUB : (cv::Point3f) v1 : (cv::Point3f) v2
     {
         cv::Point3f tmp_p;
         tmp_p.x =  v1.x - v2.x;
         tmp_p.y =  v1.y - v2.y;
         tmp_p.z =  v1.z - v2.z;
         return tmp_p;
     }
     - (cv::Point3f) getNearest3DPoint : (std::vector<cv::Point3f>) pointsList : (cv::Point3f) origin
     {
         cv::Point3f p1 = pointsList[0];
         cv::Point3f p2 = pointsList[1];
         
         double d1 = std::sqrt( std::pow(p1.x-origin.x, 2) + std::pow(p1.y-origin.y, 2) + std::pow(p1.z-origin.z, 2) );
         double d2 = std::sqrt( std::pow(p2.x-origin.x, 2) + std::pow(p2.y-origin.y, 2) + std::pow(p2.z-origin.z, 2) );
         
         return (d1 < d2 ? p1 :  p2);
     }
 @end
     
///UTIL.H
@interface Util()

// Draw a text with the frame ratio
+ (void) drawConfidence : (cv::Mat) image : (double) confidence : (cv::Scalar) color;
// Draw a text with the question point
+ (void) drawQuestion: (cv::Mat) image : (cv::Point3f) point : (cv::Scalar) color;
//Draw the position
+ (void) drawPosition : (cv::Mat) image : (cv::Mat) transformMatrix : (cv::Scalar) color;
@end

@implementation Util
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
+ (NSString*) IntToString : (int) Number
{
    std::ostringstream ss;
    ss << Number;
    return [NSString stringWithCString:ss.str().c_str() encoding:[NSString defaultCStringEncoding]];
}
// Draw a text with the frame ratio
+ (void) drawConfidence : (cv::Mat) image : (double) confidence : (cv::Scalar) color
{
    // For text
    int fontFace = cv::FONT_ITALIC;
    double fontScale = 0.75;
    int thickness_font = 2;
    
    std::string conf_str = [[self IntToString : (int)confidence] UTF8String];
    std::string text = conf_str + " %";
    cv::putText(image, text, cv::Point(500,75), fontFace, fontScale, color, thickness_font, 8);
}
// Draw a text with the question point
+ (void) drawQuestion: (cv::Mat) image : (cv::Point3f) point : (cv::Scalar) color
{
    // For text
    int fontFace = cv::FONT_ITALIC;
    double fontScale = 0.75;
    int thickness_font = 2;
    
    std::string x = [[self IntToString : (int)point.x ] UTF8String];
    std::string y = [[self IntToString : (int)point.y ] UTF8String];
    std::string z = [[self IntToString : (int)point.z ] UTF8String];
    
    std::string text = " Where is point (" + x + ","  + y + "," + z + ") ?";
    cv::putText(image, text, cv::Point(25,50), fontFace, fontScale, color, thickness_font, 8);
}
+ (void) drawPosition : (cv::Mat) image : (cv::Mat) transformMatrix : (cv::Scalar) color
{
    int fontFace = cv::FONT_ITALIC;
    double fontScale = 0.75;
    int thickness_font = 2;
    
    cv::Mat originVector = cv::Mat::zeros(4, 1, CV_64FC1);
    cv::Mat newVector = transformMatrix * originVector;
    std::ostringstream strs;
    strs << " Position at ("
    << newVector.at<double>(0, 0)
    << ","
    << newVector.at<double>(1, 0)
    << ","
    << newVector.at<double>(2, 0)
    << ")";
    std::string text = strs.str();
    cv::putText(image, text, cv::Point(25,100), fontFace, fontScale, color, thickness_font, 8);
}
@end








//************** OPENCVWRAPPER **********/

@interface OpenCVWrapper()
- (void) initKalmanFilter :(cv::KalmanFilter&) KF : (int) nStates : (int) nMeasurements : (int) nInputs : (double) dt;

@end

@implementation OpenCVWrapper
{
    
    //Model object
    Model * model;
    //Mesh object
    Mesh * mesh;
    
    RobustMatcher * rmatcher;
    
    cv::Ptr<cv::FeatureDetector> orb;
    cv::Ptr<cv::flann::IndexParams> indexParams;
    cv::Ptr<cv::flann::SearchParams> searchParams;
    cv::Ptr<cv::DescriptorMatcher> matcher;
    cv::KalmanFilter KF;
    cv::Mat measurements;
    BOOL good_measurement;
    
    vector<cv::Point3f> list_points3d_model;
    cv::Mat descriptors_model;
    cv::VideoCapture cap;
    
    PnPProblem * pnp_detection;
    PnPProblem * pnp_detection_est;
    
    
    
}
- (void) initKalmanFilter :(cv::KalmanFilter&) KF : (int) nStates : (int) nMeasurements : (int) nInputs : (double) dt
{
    KF.init(nStates, nMeasurements, nInputs, CV_64F);                 // init Kalman Filter
    
    cv::setIdentity(KF.processNoiseCov, cv::Scalar::all(1e-5));       // set process noise
    cv::setIdentity(KF.measurementNoiseCov, cv::Scalar::all(1e-2));   // set measurement noise
    cv::setIdentity(KF.errorCovPost, cv::Scalar::all(1));             // error covariance
    
    
    /** DYNAMIC MODEL **/
    
    //  [1 0 0 dt  0  0 dt2   0   0 0 0 0  0  0  0   0   0   0]
    //  [0 1 0  0 dt  0   0 dt2   0 0 0 0  0  0  0   0   0   0]
    //  [0 0 1  0  0 dt   0   0 dt2 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  1  0  0  dt   0   0 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  0  1  0   0  dt   0 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  0  0  1   0   0  dt 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  0  0  0   1   0   0 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  0  0  0   0   1   0 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  0  0  0   0   0   1 0 0 0  0  0  0   0   0   0]
    //  [0 0 0  0  0  0   0   0   0 1 0 0 dt  0  0 dt2   0   0]
    //  [0 0 0  0  0  0   0   0   0 0 1 0  0 dt  0   0 dt2   0]
    //  [0 0 0  0  0  0   0   0   0 0 0 1  0  0 dt   0   0 dt2]
    //  [0 0 0  0  0  0   0   0   0 0 0 0  1  0  0  dt   0   0]
    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  1  0   0  dt   0]
    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  1   0   0  dt]
    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   1   0   0]
    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   0   1   0]
    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   0   0   1]
    
    // position
    KF.transitionMatrix.at<double>(0,3) = dt;
    KF.transitionMatrix.at<double>(1,4) = dt;
    KF.transitionMatrix.at<double>(2,5) = dt;
    KF.transitionMatrix.at<double>(3,6) = dt;
    KF.transitionMatrix.at<double>(4,7) = dt;
    KF.transitionMatrix.at<double>(5,8) = dt;
    KF.transitionMatrix.at<double>(0,6) = 0.5*pow(dt,2);
    KF.transitionMatrix.at<double>(1,7) = 0.5*pow(dt,2);
    KF.transitionMatrix.at<double>(2,8) = 0.5*pow(dt,2);
    
    // orientation
    KF.transitionMatrix.at<double>(9,12) = dt;
    KF.transitionMatrix.at<double>(10,13) = dt;
    KF.transitionMatrix.at<double>(11,14) = dt;
    KF.transitionMatrix.at<double>(12,15) = dt;
    KF.transitionMatrix.at<double>(13,16) = dt;
    KF.transitionMatrix.at<double>(14,17) = dt;
    KF.transitionMatrix.at<double>(9,15) = 0.5*pow(dt,2);
    KF.transitionMatrix.at<double>(10,16) = 0.5*pow(dt,2);
    KF.transitionMatrix.at<double>(11,17) = 0.5*pow(dt,2);
    
    
    /** MEASUREMENT MODEL **/
    
    //  [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    //  [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    //  [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    //  [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0]
    //  [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0]
    //  [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0]
    
    KF.measurementMatrix.at<double>(0,0) = 1;  // x
    KF.measurementMatrix.at<double>(1,1) = 1;  // y
    KF.measurementMatrix.at<double>(2,2) = 1;  // z
    KF.measurementMatrix.at<double>(3,9) = 1;  // roll
    KF.measurementMatrix.at<double>(4,10) = 1; // pitch
    KF.measurementMatrix.at<double>(5,11) = 1; // yaw
}
- (void) setupDetection
{
    ///*******************PARAMETERS******************///
    float ratioTest = 0.70f;
    
    int nStates = 18;            // the number of states
    int nMeasurements = 6;       // the number of measured states
    int nInputs = 0;             // the number of control actions
    double dt = 0.125;           // time between measurements (1/FPS)
    
    ///OnePlus 3T Camera
    double f = 29;                           // focal length in mm
    double sx = 54.4, sy = 17.0;             // sensor size
    double width = 3280, height = 2464;        // image size (in px ?)
    NSMutableArray< NSNumber* > * params_WEBCAM = [NSMutableArray arrayWithObjects:
                                                   [NSNumber numberWithFloat : width*f/sx],
                                                   [NSNumber numberWithFloat : height*f/sy],
                                                   [NSNumber numberWithFloat : width/2],
                                                   [NSNumber numberWithFloat : height/2],
                                                   nil];
    ///**************************///
    
    std::string ymlReadPath =  [[[NSBundle mainBundle] pathForResource: @"ORB" ofType: @"yml"] UTF8String];
    std::string plyReadPath =  [[[NSBundle mainBundle] pathForResource: @"mesh" ofType: @"ply"] UTF8String];
    
    self->pnp_detection = [[PnPProblem alloc] init:params_WEBCAM];
    self->pnp_detection_est = [[PnPProblem alloc] init:params_WEBCAM];
    
    self->model = [[Model alloc] init];
    [self->model load:ymlReadPath]; // load a 3D textured object model
    
    self->mesh = [[Mesh alloc] init];                 // instantiate Mesh object
    [self->mesh load:plyReadPath];
    
    self->rmatcher = [[RobustMatcher alloc] init];                                                     // instantiate RobustMatcher
    
    self->orb = cv::ORB::create();
    
    [self->rmatcher setFeatureDetector : orb];                                      // set feature detector
    [self->rmatcher setDescriptorExtractor : orb];                                 // set descriptor extractor
    
    indexParams = cv::makePtr<cv::flann::LshIndexParams>(6, 12, 1); // instantiate LSH index parameters
    searchParams = cv::makePtr<cv::flann::SearchParams>(50);       // instantiate flann search parameters
    
    // instantiate FlannBased matcher
    cv::Ptr<cv::DescriptorMatcher> matcher = cv::makePtr<cv::FlannBasedMatcher>(indexParams, searchParams);
    [rmatcher setDescriptorMatcher : matcher];                                                         // set matcher
    [rmatcher setRatio : ratioTest]; // set ratio test parameter
    
    
    
    [self initKalmanFilter : self->KF : nStates : nMeasurements : nInputs : dt];    // init function
    self->measurements = cv::Mat(nMeasurements, 1, CV_64F);
    measurements.setTo(cv::Scalar(0));
    good_measurement = false;
    
    
    // Get the MODEL INFO
    self->list_points3d_model = [model getPoints3D];  // list with model 3D coordinates
    self->descriptors_model = [model getDescriptors];                  // list with descriptors of each 3D coordinate
    
    
}
- (UIImage*) detectFrame : (CVPixelBufferRef) pixelBuffer
{
    //Convert pixelBuffer to cv::Mat
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer),CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *uiImage = [UIImage imageWithCGImage: videoImage];
    CGImageRelease(videoImage);
    cv::Mat imageMat;
    UIImageToMat(uiImage, imageMat);
    transpose(imageMat,imageMat);
    cv::flip(imageMat, imageMat, 1);
    
    //Transform the cv::Mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    return MatToUIImage(grayMat);
}
- (void) isItWorking {
    //Model * newModel = [[Model alloc] init];
}
- (NSString*) currentVersion
{
    return [NSString stringWithFormat:@"Opencv Version %s",CV_VERSION];
}

- (UIImage*) makeGreyFromImage:(UIImage *)image
{
    //Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    //If the image was already grayscale, return it
    if(imageMat.channels() == 1) return image;
    
    //Transform the cv::Mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    return MatToUIImage(grayMat);
    
}

@end
