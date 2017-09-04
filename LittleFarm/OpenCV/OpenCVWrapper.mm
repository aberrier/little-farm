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
#import "ModelRegistration.hpp"
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
- (void) addDescriptor : (cv::Mat) descriptor;
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
- (void) addDescriptor : (cv::Mat) descriptor
{
    self->listDescriptors.push_back(descriptor);
}
- (void) addKeypoint : (cv::KeyPoint&) keypoint
{
    self->listKeypoints.push_back(keypoint);
}

- (void) load : (std::string) path;
{
    cv::Mat points3DMat;
    cv::FileStorage storage (path, cv::FileStorage::READ);
    storage["points_3d"] >> points3DMat;
    storage["descriptors"] >> self->listDescriptors;
    //std::cout << "****\n" << storage.releaseAndGetString() << "****\n"  << std::endl;
    points3DMat.copyTo(self->list3DInside);
    
    storage.release();
}
- (void) save : (std::string) path {
    
    
    cv::Mat points3dmatrix = cv::Mat(self->list3DInside);
    cv::Mat points2dmatrix = cv::Mat(self->list2DInside);
    /*
    cv::Mat keyPointmatrix = cv::Mat(self->listKeypoints);
    //Displayu debug
    std::ostringstream strs;
    strs << "points_3d" << points3dmatrix;
    strs << "points_2d" << points2dmatrix;
    strs << "keypoints" << keyPointmatrix;
    strs << "descriptors" << self->listDescriptors;
     std::cout << std::endl << std::endl << "YAML FILE" << std::endl << strs.str() << std::endl << "***" << std::endl;
     */
    cv::FileStorage storage(path, cv::FileStorage::WRITE);
    storage << "points_3d" << points3dmatrix;
    storage << "points_2d" << points2dmatrix;
    storage << "keypoints" << self->listKeypoints;
    storage << "descriptors" << self->listDescriptors;
    storage.release();
    
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
    [self computeDescriptors : frame : keypoints_frame : descriptors_frame];
    //If the camera views is completly dark, the descriptor frame can be empty and lead to a crash
    if(!descriptors_frame.isContinuous())
    {
        std::cout << "Can't find any descriptors on camera. It can be obstructed." << std::endl;
        good_matches.clear();
        return;
    }
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
            //Correction of different line-return between platforms
            std::string tmp_str2 = tmp_str.substr(0,tmp_str.size()-1);
            if(tmp_str == "end_header" || tmp_str2 =="end_header") end_header = true;
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
    unsigned int hash = [[NSNumber numberWithUnsignedInteger:[self hash]] intValue];
    std::string prf = "[";
    prf += std::to_string(hash);
    prf += "] : ";
    std::cout <<  prf << "Mesh loaded with " << numVertexs << " vertex and " << numTriangles << " triangles." << std::endl;
    for(int i = 0; i < listVertex.size() ; i++)
    {
        cv::Point3f a = listVertex.at(i);
        //std::cout << prf << "Point(" << a.x << "," << a.y << "," << a.z << ")" << std::endl;
    }
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
- (cv::Point2f) backproject3DPoint : (cv::Point3f) point3d;
- (BOOL) estimatePose : (std::vector<cv::Point3f>&) listPoints3d : (std::vector<cv::Point2f>&) listPoints2d :  (int) flags;
- (void) estimatePoseRANSAC : (std::vector<cv::Point3f>&) listPoints3d : (std::vector<cv::Point2f>&) listPoints2d
                            : (int) flags
                            : (cv::Mat&) inliers
                            : (int) iterationsCount : (float) reprojectionError : (double) confidence;

- (cv::Mat) getAMatrix;
- (cv::Mat) getRMatrix;
- (cv::Mat) getTMatrix;
- (cv::Mat) getPMatrix;
- (void) addDistorsionParameters : (NSMutableArray*) param;
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
    /** The calibration distorsion matrix */
    cv::Mat DMatrix;
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
        self->AMatrix.at<double>(0, 0) = [param[0] doubleValue];       //      [ fx(0)   0  cx(2) ]
        self->AMatrix.at<double>(0, 1) = 0;
        self->AMatrix.at<double>(0, 2) = [param[2] doubleValue];
        self->AMatrix.at<double>(1, 0) = 0;
        self->AMatrix.at<double>(1, 1) = [param[4] doubleValue];
        self->AMatrix.at<double>(1, 2) = [param[5] doubleValue];
        self->AMatrix.at<double>(2, 0) = 0;       //      [  0  fy(1)  cy(3) ]
        self->AMatrix.at<double>(2, 1) = 0;      //      [  0   0   1 ]
        self->AMatrix.at<double>(2, 2) = 1;
        self->DMatrix = cv::Mat::zeros(5, 1, CV_64FC1);
        self->RMatrix = cv::Mat::zeros(3, 3, CV_64FC1);   // rotation matrix
        self->TMatrix = cv::Mat::zeros(3, 1, CV_64FC1);   // translation matrix
        self->PMatrix = cv::Mat::zeros(3, 4, CV_64FC1);   // rotation-translation matrix
    }
    return self;
}
- (void) addDistorsionParameters : (NSMutableArray*) param
{
    self->DMatrix.at<double>(0,0) = [param[0] doubleValue];
    self->DMatrix.at<double>(1,0) = [param[1] doubleValue];
    self->DMatrix.at<double>(2,0) = [param[2] doubleValue];
    self->DMatrix.at<double>(3,0) = [param[3] doubleValue];
    self->DMatrix.at<double>(4,0) = [param[4] doubleValue];
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
- (cv::Point2f) backproject3DPoint : (cv::Point3f) point3d
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
    cv::Mat rvec = cv::Mat::zeros(3, 1, CV_64FC1);
    cv::Mat tvec = cv::Mat::zeros(3, 1, CV_64FC1);
    bool useExtrinsicGuess = false;
    
    //Data analyze
    /*
    cout << "listPoint2D : " << endl << "***" << endl;
    for(cv::Point2f pt : listPoints2d)
    {
        std::cout << "(" << pt.x << "," << pt.y << ")" << endl;
    }
    cout << "***" << endl;
    cout << "listPoint3D : " << endl << "***" << endl;
    for(cv::Point3f pt : listPoints3d)
    {
        std::cout << "(" << pt.x << "," << pt.y << "," << pt.z << ")" << endl;
    }
    cout << "***" << endl;
    cout << "A matrix" << endl << "***" << AMatrix << endl << "***" << endl;
    cout << "distCoeffs" << endl << "***" << distCoeffs << endl << "***" << endl;
    cout << "rvec" << endl << "***" << rvec << endl << "***" << endl;
    cout << "tvec" << endl << "***" << tvec << endl << "***" << endl;
    cout << "useExtrinsicGuess :" << useExtrinsicGuess << endl;
    cout << "flags : " << flags << endl;
    */
    // Pose estimation
    bool correspondence = cv::solvePnP( listPoints3d, listPoints2d, AMatrix, DMatrix, rvec, tvec,
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
    cv::solvePnPRansac( listPoints3d, listPoints2d, AMatrix, DMatrix, rvec, tvec,
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
    PMatrix.at<double>(0,0) = RMatrix.at<double>(0,0);
    PMatrix.at<double>(0,1) = RMatrix.at<double>(0,1);
    PMatrix.at<double>(0,2) = RMatrix.at<double>(0,2);
    PMatrix.at<double>(1,0) = RMatrix.at<double>(1,0);
    PMatrix.at<double>(1,1) = RMatrix.at<double>(1,1);
    PMatrix.at<double>(1,2) = RMatrix.at<double>(1,2);
    PMatrix.at<double>(2,0) = RMatrix.at<double>(2,0);
    PMatrix.at<double>(2,1) = RMatrix.at<double>(2,1);
    PMatrix.at<double>(2,2) = RMatrix.at<double>(2,2);
    PMatrix.at<double>(0,3) = TMatrix.at<double>(0);
    PMatrix.at<double>(1,3) = TMatrix.at<double>(1);
    PMatrix.at<double>(2,3) = TMatrix.at<double>(2);
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
// Draw the points and the coordinates
+ (void) drawPoints : (cv::Mat) image :  (std::vector<cv::Point2f> &) list_points_2d : (std::vector<cv::Point3f> &) list_points_3d : (cv::Scalar) color;
// Draw only the 2D points
+ (void) draw2DPoints : (cv::Mat) image : (std::vector<cv::Point2f>&) list_points : (cv::Scalar) color;
// Draw the object mesh
+ (void) drawObjectMesh : (cv::Mat) image :  (Mesh *) mesh : (PnPProblem *) pnpProblem : (cv::Scalar) color;
// Draw the 3D coordinate axes
+ (void) draw3DCoordinateAxes :(cv::Mat) image : (std::vector<cv::Point2f> &)list_points2d;

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
    originVector.at<double>(3,0)=1;
    cv::Mat newVector = transformMatrix * originVector;
    if(newVector.at<double>(0, 0) != 0 && newVector.at<double>(1, 0) != 0 && newVector.at<double>(2, 0) != 0)
    {
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
}
// Draw only the 2D points
+ (void) draw2DPoints : (cv::Mat) image : (std::vector<cv::Point2f>&) list_points : (cv::Scalar) color
{
    // For circles
    int lineType = 8;
    int radius = 4;
    for( size_t i = 0; i < list_points.size(); i++)
    {
        cv::Point2f point_2d = list_points[i];
        
        // Draw Selected points
        cv::circle(image, point_2d, radius, color, -1, lineType );
    }
}
// Draw the points and the coordinates
+ (void) drawPoints : (cv::Mat) image :  (std::vector<cv::Point2f> &) list_points_2d : (std::vector<cv::Point3f> &) list_points_3d : (cv::Scalar) color
{
    // For text
    int fontFace = cv::FONT_ITALIC;
    double fontScale = 0.75;
    int thickness_font = 2;
    
    // For circles
    int lineType = 8;
    int radius = 4;
    
    for (unsigned int i = 0; i < list_points_2d.size(); ++i)
    {
        cv::Point2f point_2d = list_points_2d[i];
        cv::Point3f point_3d = list_points_3d[i];
        
        // Draw Selected points
        cv::circle(image, point_2d, radius, color, -1, lineType );
        
        std::string idx = [[Util IntToString:i+1] UTF8String];
        std::string x = [[Util IntToString:(int)point_3d.x] UTF8String];
        std::string y = [[Util IntToString:(int)point_3d.y] UTF8String];
        std::string z = [[Util IntToString:(int)point_3d.z] UTF8String];
        std::string text = "P" + idx + " (" + x + "," + y + "," + z +")";
        
        point_2d.x = point_2d.x + 10;
        point_2d.y = point_2d.y - 10;
        cv::putText(image, text, point_2d, fontFace, fontScale*0.5, color, thickness_font, 8);
    }
}
// Draw the object mesh
+ (void) drawObjectMesh : (cv::Mat) image :  (Mesh *) mesh : (PnPProblem *) pnpProblem : (cv::Scalar) color
{
    std::vector<std::vector<int> > list_triangles = [mesh getTrianglesList];
    for( size_t i = 0; i < list_triangles.size(); i++)
    {
        std::vector<int> tmp_triangle = list_triangles.at(i);
        
        cv::Point3f point_3d_0 = [mesh getVertex : tmp_triangle[0]];
        cv::Point3f point_3d_1 = [mesh getVertex : tmp_triangle[1]];
        cv::Point3f point_3d_2 = [mesh getVertex : tmp_triangle[2]];
        cv::Point2f point_2d_0 = [pnpProblem backproject3DPoint : point_3d_0];
        cv::Point2f point_2d_1 = [pnpProblem backproject3DPoint : point_3d_1];
        cv::Point2f point_2d_2 = [pnpProblem backproject3DPoint : point_3d_2];
        cv::line(image, point_2d_0, point_2d_1, color, 1);
        cv::line(image, point_2d_1, point_2d_2, color, 1);
        cv::line(image, point_2d_2, point_2d_0, color, 1);
    }
}
// Draw the 3D coordinate axes
+ (void) draw3DCoordinateAxes :(cv::Mat) image : (std::vector<cv::Point2f> &)list_points2d
{
    // For circles
    int lineType = 8;
    int radius = 4;
    
    cv::Scalar red(0, 0, 255);
    cv::Scalar green(0,255,0);
    cv::Scalar blue(255,0,0);
    cv::Scalar black(0,0,0);
    
    cv::Point2i origin = list_points2d[0];
    cv::Point2i pointX = list_points2d[1];
    cv::Point2i pointY = list_points2d[2];
    cv::Point2i pointZ = list_points2d[3];
    
    [Util drawArrow : image : origin : pointX : red : 9 : 2];
    [Util drawArrow : image : origin : pointY : blue : 9 : 2];
    [Util drawArrow : image : origin : pointZ : green : 9 : 2];
    cv::circle(image, origin, radius/2, black, -1, lineType );
    
}
// Draw an arrow into the image
+ (void) drawArrow : (cv::Mat) image : (cv::Point2i) p : (cv::Point2i) q : (cv::Scalar) color : (int) arrowMagnitude : (int) thickness
{
    int line_type=8;
    int shift=0;
    
    //Draw the principle line
    cv::line(image, p, q, color, thickness, line_type, shift);
    const double PI = CV_PI;
    //compute the angle alpha
    double angle = atan2((double)p.y-q.y, (double)p.x-q.x);
    //compute the coordinates of the first segment
    p.x = (int) ( q.x +  arrowMagnitude * cos(angle + PI/4));
    p.y = (int) ( q.y +  arrowMagnitude * sin(angle + PI/4));
    //Draw the first segment
    cv::line(image, p, q, color, thickness, line_type, shift);
    //compute the coordinates of the second segment
    p.x = (int) ( q.x +  arrowMagnitude * cos(angle - PI/4));
    p.y = (int) ( q.y +  arrowMagnitude * sin(angle - PI/4));
    //Draw the second segment
    cv::line(image, p, q, color, thickness, line_type, shift);
}
// Draw a text with the number of entered points
+ (void) drawText : (cv::Mat) image : (std::string) text : (cv::Scalar) color
{
    // For text
    int fontFace = cv::FONT_ITALIC;
    double fontScale = 0.75;
    int thickness_font = 2;
    
    cv::putText(image, text, cv::Point(25,50), fontFace, fontScale, color, thickness_font, 8);
}

// Draw a text with the number of entered points
+ (void) drawText2 : (cv::Mat) image : (std::string) text : (cv::Scalar) color
{
    // For text
    int fontFace = cv::FONT_ITALIC;
    double fontScale = 0.75;
    int thickness_font = 2;
    
    cv::putText(image, text, cv::Point(25,75), fontFace, fontScale, color, thickness_font, 8);
}

@end

//BLUEBOX
@implementation blueBox
-(id) init
{
    self = [super init];
    if(self)
    {
        self->image = [[UIImage alloc] init];
        self->model = [[ModelRegistration alloc] init];
    }
    return self;
    
}
- (UIImage*) getImage
{
    return self->image;
}
- (ModelRegistration*) getModel
{
    return self->model;
}
- (void) setImage : (UIImage*) val
{
    self->image = [val mutableCopy];
    
}
- (void) setModel_shallow  :(ModelRegistration*) val
{
    self->model = [val mutableCopy];
}
@end

///REDBOX
@implementation redBox
-(id) init
{
    self = [super init];
    if(self)
    {
        self->image = [[UIImage alloc] init];
        self->posX = 0;
        self->posY = 0;
        self->posZ = 0;
        self->confidence = -1;
    }
    return self;
    
}
- (UIImage*) getImage
{
    return self->image;
}
- (float) getX
{
    return self->posX;
}
- (float) getY
{
    return self->posY;
}
- (float) getZ
{
    return self->posZ;
}
- (double) getConfidence
{
    return self->confidence;
}
- (void) setX : (float)val
{
    self->posX = val;
}
- (void) setY : (float)val
{
    self->posY = val;
}
- (void) setZ : (float)val
{
    self->posZ = val;
}
- (void) setConfidence : (float)val
{
    self->confidence = val;
}
@end
///MODELREGISTRATION
@interface ModelRegistration()
{
    /** The current number of registered points */
    int nRegistrations;
    /** The total number of points to register */
    int maxRegistrations;
    /** The list of 2D points to register the model */
    std::vector<cv::Point2f> listPoints2D;
    /** The list of 3D points to register the model */
    std::vector<cv::Point3f> listPoints3D;
}
- (std::vector<cv::Point2f>) getPoints2D;
- (std::vector<cv::Point3f>) getPoints3D;
- (int) getNumMax;
- (int) getNumRegist;

- (BOOL) isRegistrable;
- (void) registerPoint : (cv::Point2f &) point2d : (cv::Point3f &)point3d;
- (void) reset;

@end
@implementation ModelRegistration
-(id) init
{
    self = [super init];
    if (self)
    {
        self->nRegistrations = 0;
        self->maxRegistrations = 0;
    }
    return self;
}
- (std::vector<cv::Point2f>) getPoints2D
{
    return self->listPoints2D;
}
- (std::vector<cv::Point3f>) getPoints3D
{
    return self->listPoints3D;
}
- (int) getNumMax
{
    return self->maxRegistrations;
}
- (int) getNumRegist
{
    return self->nRegistrations;
}

- (BOOL) isRegistrable
{
    return self->nRegistrations < self->maxRegistrations;
}
- (void) registerPoint : (cv::Point2f &) point2d : (cv::Point3f &)point3d
{
    // add correspondence at the end of the vector
    self->listPoints2D.push_back(point2d);
    self->listPoints3D.push_back(point3d);
    self->nRegistrations++;
}
- (void) reset
{
    self->nRegistrations = 0;
    self-> maxRegistrations = 0;
    self->listPoints2D.clear();
    self->listPoints3D.clear();
}
@end

//************** OPENCVREGISTRATION**********/
@interface OpenCVRegistration()

@end

@implementation OpenCVRegistration
{
    ModelRegistration* registration;
    Model* model;
    Mesh* mesh;
    PnPProblem* pnpRegistration;
    RobustMatcher* rmatcher;
    int numKeyPoints;
    // Some basic colors
    cv::Scalar red;
    cv::Scalar green;
    cv::Scalar blue;
    cv::Scalar yellow;
    
    float scale;
    //Dictionnary of ModelRegistration for
    NSMutableDictionary<NSNumber* , ModelRegistration*> * dic;
    
    //loop variables
    BOOL endRegistration;
    int vertexIndex;
    cv::Point3d currentPoint;
    
    //Parameters
    BOOL setuped;
    NSMutableArray< NSNumber* > * paramsCAM;
    NSMutableArray< NSNumber* > * paramsDistorsion;
    std::string plyReadPath;
}
- (id)  init
{
    self = [super init];
    if (self)
    {
        setuped = false;
        scale = 1;
        ///Default camera parameters
        double f = 42;                           // focal length in mm
        double sx = 5, sy = 4;             // sensor size
        double width = 4032, height = 3024;        // image size (in px ?)
        paramsCAM = [NSMutableArray arrayWithObjects:
                     [NSNumber numberWithDouble : width*f/sx],
                     [NSNumber numberWithDouble : height*f/sy],
                     [NSNumber numberWithDouble: width/2],
                     [NSNumber numberWithDouble : height/2],
                     nil];
        paramsDistorsion = [NSMutableArray arrayWithObjects:
                             [NSNumber numberWithDouble : 0],
                             [NSNumber numberWithDouble : 0],
                             [NSNumber numberWithDouble: 0],
                             [NSNumber numberWithDouble : 0],
                             [NSNumber numberWithDouble : 0],
                             nil];
        std::string plyReadPath =  "";
    }
    return self;
}
- (BOOL) isSetuped
{
    return setuped;
}
- (void) setFilePath :  (NSString*) ply
{
    plyReadPath = [ply UTF8String];
}
- (void) loadCameraParameters : (const double[]) params
{
    [paramsCAM removeAllObjects];
    paramsCAM = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithDouble: params[0]],
                 [NSNumber numberWithDouble: params[1]],
                 [NSNumber numberWithDouble: params[2]],
                 [NSNumber numberWithDouble : params[3]],
                 [NSNumber numberWithDouble : params[4]],
                 [NSNumber numberWithDouble : params[5]],
                 [NSNumber numberWithDouble : params[6]],
                 [NSNumber numberWithDouble : params[7]],
                 [NSNumber numberWithDouble : params[8]],
                 
                 nil];
    
}
- (void) loadDistorsionParameters : (const double[]) params
{
    [paramsDistorsion removeAllObjects];
    paramsDistorsion = [NSMutableArray arrayWithObjects:
                         [NSNumber numberWithDouble: params[0]],
                         [NSNumber numberWithDouble: params[1]],
                         [NSNumber numberWithDouble: params[2]],
                         [NSNumber numberWithDouble : params[3]],
                         [NSNumber numberWithDouble : params[4]],
                         nil];
    
}
- (void) setup
{
    ///*******************PARAMETERS******************///
    
    // set parameters
    numKeyPoints = 10000;
    
    ///**************************///
    vertexIndex = 0;
    endRegistration = false;
    
    ///Instantiate objects
    model = [[Model alloc] init];
    mesh = [[Mesh alloc] init];
    pnpRegistration = [[PnPProblem alloc] init:paramsCAM];
    [pnpRegistration addDistorsionParameters:paramsDistorsion];
    
    // load a mesh given the *.ply file path
    [mesh load : plyReadPath];
    currentPoint = cv::Point3d([mesh getVertex:0]);
    //Instantiate robust matcher: detector, extractor, matcher
    rmatcher = [[RobustMatcher alloc] init];
    cv::Ptr<cv::FeatureDetector> detector = cv::ORB::create(numKeyPoints);
    [rmatcher setFeatureDetector : detector];
    
    // Some basic colors
    red = cv::Scalar(0, 0, 255);
    green = cv::Scalar(0,255,0);
    blue = cv::Scalar(255,0,0);
    yellow = cv::Scalar(0,255,255);
    
    
    self->dic = [[NSMutableDictionary alloc] init];
    
    
}
- (void) addPoint : (int) x : (int) y : (UIImage*) image
{
    NSNumber * key = [NSNumber numberWithUnsignedInteger:[image hash]];
    ModelRegistration * mr = [self->dic objectForKey : key];
    if(mr == nil)
    {
        mr = [[ModelRegistration alloc] init];
        [self->dic setObject:mr forKey:key];
        
    }
    cv::Point2f point2D = cv::Point2f(x,y);
    cv::Point3f point3D = [mesh getVertex:vertexIndex];
    [mr registerPoint: point2D : point3D];
    [self nextVertex];
    
}
- (void) nextVertex
{
    
    if(vertexIndex < [mesh getNumVertices]-1 && !endRegistration)
    {
        vertexIndex++;
        currentPoint = cv::Point3d([mesh getVertex:vertexIndex]);
    }
    else
    {
        endRegistration=true;
    }
}
- (int) getVertexIndex
{
    return vertexIndex;
}
- (void) saveFileAt : (NSString*) path
{
    [model save:[path UTF8String]];
}
- (UIImage*) computePose : (UIImage*) image
{
    NSNumber * key = [NSNumber numberWithUnsignedInteger:[image hash]];
    ModelRegistration * mr = [self->dic objectForKey : key];
    if(mr == nil)
    {
        //std::cout << "key : " << [[key stringValue] UTF8String] << std::endl;
        mr = [[ModelRegistration alloc] init];
        [self->dic setObject:mr forKey:key];
        
    }
    // The list of registered points
    vector<cv::Point2f> listPoints2D = [mr getPoints2D];
    vector<cv::Point3f> listPoints3D = [mr getPoints3D];
    cv::Mat imageMat;
    cv::Mat displayMat;
    UIImageToMat(image, imageMat);
    
    // Estimate pose given the registered points
    bool isCorrespondence = [pnpRegistration estimatePose:listPoints3D :listPoints2D :cv::SOLVEPNP_ITERATIVE];
    if (isCorrespondence)
    {
        cout << "Correspondence found" << endl;
        
        // Compute all the 2D points of the mesh to verify the algorithm and draw it
        vector<cv::Point2f> listPoints2DMesh = [pnpRegistration verifyPoints:mesh];
        //[Util draw2DPoints:displayMat :listPoints2DMesh :green];
        
    } else {
        cout << "Correspondence not found" << endl << endl;
    }
    
    /** COMPUTE 3D of the image Keypoints **/
    
    // Containers for keypoints and descriptors of the model
    vector<cv::KeyPoint> keypointsModel;
    cv::Mat descriptors;
    
    // Compute keypoints and descriptors
    [rmatcher computeKeyPoints : imageMat : keypointsModel];
    [rmatcher computeDescriptors : imageMat : keypointsModel : descriptors];
    
    // Check if keypoints are on the surface of the registration image and add to the model
    for (unsigned int i = 0; i < keypointsModel.size(); ++i) {
        cv::Point2f point2d(keypointsModel[i].pt);
        cv::Point3f point3d;
        bool onSurface = [pnpRegistration backproject2DPoint : mesh : point2d : point3d];
        if (onSurface)
        {
            [model addCorrespondence : point2d : point3d];
            [model addDescriptor : descriptors.row(i)];
            [model addKeypoint : keypointsModel[i]];
        }
        else
        {
            [model addOutlier : point2d];
        }
    }
    // Out image
   UIImageToMat(image, displayMat);
    
    // The list of the points2d of the model
    vector<cv::Point2f> listPointsIn = [model getPoints2DIn];
    vector<cv::Point2f> listPointsOut = [model getPoints2DOut];
    
    // Draw some debug text
    std::cout << "There are " << listPointsIn.size() << " inliers" << std::endl;
    std::cout << "There are " << listPointsOut.size() << " outliers" << std::endl;
    
    
    // Draw the object mesh
    [Util drawObjectMesh:displayMat :mesh :pnpRegistration :blue];
    
    // Draw found keypoints depending on if are or not on the surface
    [Util draw2DPoints : displayMat : listPointsIn : green];
    [Util draw2DPoints : displayMat : listPointsOut : red];
    
    UIImage* newImage = [[UIImage alloc] init];

    newImage = MatToUIImage(displayMat);
    return newImage;
    
    
}
- (UIImage*) add2DPoints : (UIImage*) image
{
    NSNumber * key = [NSNumber numberWithUnsignedInteger:[image hash]];
    ModelRegistration * mr = [self->dic objectForKey : key];
    if(mr == nil)
    {
        //std::cout << "key : " << [[key stringValue] UTF8String] << std::endl;
        mr = [[ModelRegistration alloc] init];
        [self->dic setObject:mr forKey:key];
        return image;
    }
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    vector<cv::Point2f> point2DList = [mr getPoints2D];
    vector<cv::Point3f> point3DList = [mr getPoints3D];
    [Util drawPoints:imageMat :point2DList :point3DList :red];
    UIImage* newImage = [[UIImage alloc] init];
    newImage = MatToUIImage(imageMat);
    return newImage;
    
}
- (redBox*) getCurrentVertex
{
    redBox* newPoint = [[redBox alloc] init];
    cv::Point3d point3D = [mesh getVertex:vertexIndex];
    [newPoint setX:point3D.x];
    [newPoint setY:point3D.y];
    [newPoint setZ:point3D.z];
    return newPoint;
}
- (int) getNumVertex
{
    return [mesh getNumVertices];
}
- (BOOL) isRegistrationFinished
{
    return self->endRegistration;
}
- (SCNNode*) SCNNodeOf3DPoints
{
    SCNNode* newNode = [[SCNNode alloc] init];
    //Get points already placed
    for(NSNumber* key in dic)
    {
        ModelRegistration* currentModel = [dic objectForKey:key];
        vector<cv::Point3f> point3DList = [currentModel getPoints3D];
        for(int i=0; i<point3DList.size() ;i++)
        {
            SCNSphere * g = [SCNSphere sphereWithRadius:0.1*scale];
            SCNNode* node = [SCNNode nodeWithGeometry:g];
            [g.firstMaterial.diffuse setContents:[UIColor blueColor]];
            node.position = SCNVector3Make(point3DList.at(i).x, point3DList.at(i).y, point3DList.at(i).z);
            [newNode addChildNode:node];
        }
            
    }
    //Get point that have to be placed
    SCNSphere * g = [SCNSphere sphereWithRadius:0.1*scale];
    SCNNode* node = [SCNNode nodeWithGeometry:g];
    [g.firstMaterial.diffuse setContents:[UIColor redColor]];
    cv::Point3f currentPoint = [mesh getVertex:vertexIndex];
    node.position = SCNVector3Make(currentPoint.x, currentPoint.y, currentPoint.z);
    [newNode addChildNode:node];
    
    
    return newNode;
}
- (void) setScale : (float) scale
{
    self->scale=scale;
}
@end

//************** OPENCVWDETECTION **********/

@interface OpenCVDetection()
- (void) initKalmanFilter :(cv::KalmanFilter&) KF : (int) nStates : (int) nMeasurements : (int) nInputs : (double) dt;
- (void) updateKalmanFilter : (cv::KalmanFilter &) KF : (cv::Mat &) measurement : (cv::Mat &) translation_estimated : (cv::Mat &) rotation_estimated;
- (void) fillMeasurements: (cv::Mat &) measurements : (cv::Mat &) translation_measured : (cv::Mat &)rotation_measured;
- (cv::Mat) euler2rot : (cv::Mat) vec3F;
- (cv::Mat) rot2euler : (cv::Mat) mat;
- (cv::Mat) convertPosMatrixToPosVec : (cv::Mat)pMat;
@end

@implementation OpenCVDetection
{
    
    BOOL setuped;
    //Model object
    Model * model;
    //Mesh object
    Mesh * mesh;
    //Frame
    cv::Mat frameVis;
    RobustMatcher * rmatcher;
    
    cv::Ptr<cv::FeatureDetector> orb;
    cv::Ptr<cv::flann::IndexParams> indexParams;
    cv::Ptr<cv::flann::SearchParams> searchParams;
    cv::Ptr<cv::DescriptorMatcher> matcher;
    cv::KalmanFilter KF;
    cv::Mat measurements;
    BOOL goodMeasurement;
    
    vector<cv::Point3f> listPoints3DModel;
    cv::Mat descriptors_model;
    cv::VideoCapture cap;
    
    PnPProblem * pnpDetection;
    PnPProblem * pnpDetectionEst;
    
    // Some basic colors
    cv::Scalar red, green , blue , yellow;
    
    //Parameters
    // Robust Matcher parameters
    int numKeyPoints ;      // number of detected keypoints
    float ratioTest;          // ratio test
    BOOL fast_match;      // fastRobustMatch() or robustMatch()
    
    // RANSAC parameters
    int iterationsCount;      // number of Ransac iterations.
    float reprojectionError;  // maximum allowed distance to consider it an inlier.
    double confidence;        // ransac successful confidence.
    
    // Kalman Filter parameters
    int minInliersKalman;    // Kalman threshold updating
    int nStates;            // the number of states
    int nMeasurements;       // the number of measured states
    int nInputs;             // the number of control actions
    double dt;           // time between measurements (1/FPS)
    
    // PnP parameters
    int pnpMethod;
    
    //Camera parameters
    NSMutableArray< NSNumber* > * paramsCAM;
    NSMutableArray< NSNumber* > * paramsDistorsion;
    std::string ymlReadPath;
    std::string plyReadPath;
}
- (id) init;
{
    self = [super init];
    if (self)
    {
        setuped = false;
        ///Default camera parameters
        double f = 42;                           // focal length in mm
        double sx = 5, sy = 4;             // sensor size
        double width = 4032, height = 3024;        // image size (in px ?)
        paramsCAM = [NSMutableArray arrayWithObjects:
                                                   [NSNumber numberWithDouble : width*f/sx],
                                                   [NSNumber numberWithDouble : height*f/sy],
                                                   [NSNumber numberWithDouble: width/2],
                                                   [NSNumber numberWithDouble : height/2],
                                                   nil];
        paramsDistorsion = [NSMutableArray arrayWithObjects:
                     [NSNumber numberWithDouble : 0],
                     [NSNumber numberWithDouble : 0],
                     [NSNumber numberWithDouble: 0],
                     [NSNumber numberWithDouble : 0],
                     [NSNumber numberWithDouble : 0],
                     nil];
        ymlReadPath =  "";
        plyReadPath =  "";
    }
    return self;
}
- (void) setFilePaths : (NSString*) yml : (NSString*) ply
{
    ymlReadPath = [yml UTF8String];
    plyReadPath = [ply UTF8String];
}
- (void) loadCameraParameters : (const double[]) params
{
    [paramsCAM removeAllObjects];
    paramsCAM = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithDouble: params[0]],
                 [NSNumber numberWithDouble: params[1]],
                 [NSNumber numberWithDouble: params[2]],
                 [NSNumber numberWithDouble : params[3]],
                 [NSNumber numberWithDouble : params[4]],
                 [NSNumber numberWithDouble : params[5]],
                 [NSNumber numberWithDouble : params[6]],
                 [NSNumber numberWithDouble : params[7]],
                 [NSNumber numberWithDouble : params[8]],
                 
                 nil];
    
}
- (void) loadDistorsionParameters : (const double[]) params
{
    [paramsDistorsion removeAllObjects];
    paramsDistorsion = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithDouble: params[0]],
                 [NSNumber numberWithDouble: params[1]],
                 [NSNumber numberWithDouble: params[2]],
                 [NSNumber numberWithDouble : params[3]],
                 [NSNumber numberWithDouble : params[4]],
                 nil];
    
}
- (BOOL) isSetuped
{
    return setuped;
}
- (void) setup
{
    ///*******************PARAMETERS******************///
    float ratioTest = 0.70f;
    
    int nStates = 18;            // the number of states
    int nMeasurements = 6;       // the number of measured states
    int nInputs = 0;             // the number of control actions
    double dt = 0.125;           // time between measurements (1/FPS)
    
    
    // Robust Matcher parameters
    numKeyPoints = 2000;      // number of detected keypoints
    ratioTest = 0.70f;          // ratio test
    fast_match = true;       // fastRobustMatch() or robustMatch()
    
    // RANSAC parameters
    iterationsCount = 500;      // number of Ransac iterations.
    reprojectionError = 2.0;  // maximum allowed distance to consider it an inlier.
    confidence = 0.95;        // ransac successful confidence.
    
    // Kalman Filter parameters
    minInliersKalman = 30;    // Kalman threshold updating
    
    // PnP parameters
    pnpMethod = cv::SOLVEPNP_ITERATIVE;
    ///**************************///
    
    // Some basic colors
    red = cv::Scalar(0, 0, 255);
    green = cv::Scalar(0,255,0);
    blue = cv::Scalar(255,0,0);
    yellow = cv::Scalar(0,255,255);
    
    self->pnpDetection = [[PnPProblem alloc] init:paramsCAM];
    self->pnpDetectionEst = [[PnPProblem alloc] init:paramsCAM];
    [pnpDetection addDistorsionParameters:paramsDistorsion];
    [pnpDetectionEst addDistorsionParameters:paramsDistorsion];
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
    goodMeasurement = false;
    
    
    // Get the MODEL INFO
    self->listPoints3DModel = [model getPoints3D];  // list with model 3D coordinates
    self->descriptors_model = [model getDescriptors];                  // list with descriptors of each 3D coordinate
    setuped = true;
    
}
- (redBox*) detectOnPixelBuffer : (CVPixelBufferRef) pixelBuffer
{
    // -- Step 0: Convert pixelBuffer to cv::Mat
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer),CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *uiImage = [UIImage imageWithCGImage: videoImage];
    CGImageRelease(videoImage);
    cv::Mat imageMat;
    UIImageToMat(uiImage, imageMat);
    transpose(imageMat,imageMat);
    cv::flip(imageMat, imageMat, 1);
    
    
    frameVis = imageMat.clone();    // refresh visualisation frame
    
    // -- Step 1: Robust matching between model descriptors and scene descriptors
    
    vector<cv::DMatch> goodMatches;       // to obtain the 3D points of the model
    vector<cv::KeyPoint> keypointsScene;  // to obtain the 2D points of the scene
    if(fast_match)
    {
        [rmatcher fastRobustMatch : imageMat : goodMatches : keypointsScene : descriptors_model];
    }
    else
    {
        [rmatcher robustMatch : imageMat : goodMatches : keypointsScene : descriptors_model];
    }
    // -- Step 2: Find out the 2D/3D correspondences
    
    vector<cv::Point3f> listPoints3DModelMatch; // container for the model 3D coordinates found in the scene
    vector<cv::Point2f> listPoints2DSceneMatch; // container for the model 2D coordinates found in the scene
    
    
    for(unsigned int match_index = 0; match_index < goodMatches.size(); ++match_index)
    {
        cv::Point3f point3DModel = listPoints3DModel[ goodMatches[match_index].trainIdx ];  // 3D point from model
        cv::Point2f point2DScene = keypointsScene[ goodMatches[match_index].queryIdx ].pt; // 2D point from the scene
        listPoints3DModelMatch.push_back(point3DModel);         // add 3D point
        listPoints2DSceneMatch.push_back(point2DScene);         // add 2D point
    }
    
    // Draw outliers
    [Util draw2DPoints : frameVis : listPoints2DSceneMatch : red];
    
    
    cv::Mat inliersIdx;
    vector<cv::Point2f> listPoints2DInliers;
    
    
    if(goodMatches.size() > 4) // Matches < 4, then RANSAC crashes
    {
        // -- Step 3: Estimate the pose using RANSAC approach
        [pnpDetection estimatePoseRANSAC : listPoints3DModelMatch : listPoints2DSceneMatch
                                          : pnpMethod : inliersIdx
                                          : iterationsCount : reprojectionError : confidence];
        
        // -- Step 4: Catch the inliers keypoints to draw
        for(int inliersIndex = 0; inliersIndex < inliersIdx.rows; ++inliersIndex)
        {
            int n = inliersIdx.at<int>(inliersIndex);         // i-inlier
            cv::Point2f point2d = listPoints2DSceneMatch[n]; // i-inlier point 2D
            listPoints2DInliers.push_back(point2d);           // add i-inlier to list
        }
        // Draw inliers points 2D
        [Util draw2DPoints : frameVis : listPoints2DInliers : blue];
        
        // -- Step 5: Kalman Filter
        goodMeasurement = false;
        // GOOD MEASUREMENT
        if(inliersIdx.rows >= minInliersKalman)
        {
            
            // Get the measured translation
            cv::Mat translationMeasured(3, 1, CV_64F);
            translationMeasured = [pnpDetection getTMatrix];
            
            // Get the measured rotation
            cv::Mat rotationMeasured(3, 3, CV_64F);
            rotationMeasured = [pnpDetection getRMatrix];
            
            // fill the measurements vector
            [self fillMeasurements : measurements : translationMeasured : rotationMeasured ];
            
            goodMeasurement = true;
            
        }
        // Instantiate estimated translation and rotation
        cv::Mat translationEstimated(3, 1, CV_64F);
        cv::Mat rotationEstimated(3, 3, CV_64F);
        
        // update the Kalman filter with good measurements
        [self updateKalmanFilter : KF : measurements : translationEstimated : rotationEstimated];
        
        
        // -- Step 6: Set estimated projection matrix
        [pnpDetectionEst setPMatrix : rotationEstimated : translationEstimated];
    }
    ///-- Step X : POSITION
    [Util drawPosition : frameVis : [pnpDetection getPMatrix] : red];
    
    // -- Step X: Draw pose
    if(goodMeasurement)
    {
        [Util drawObjectMesh : frameVis : mesh : pnpDetection : green ];  // draw current pose
    }
    else
    {
        [Util drawObjectMesh : frameVis : mesh : pnpDetectionEst : yellow]; // draw estimated pose
    }
    
    vector<cv::Point2f> posePoints2D;
    posePoints2D.push_back([pnpDetectionEst backproject3DPoint : cv::Point3f(0,0,0)]);  // axis center
    posePoints2D.push_back([pnpDetectionEst backproject3DPoint : cv::Point3f(1,0,0)]);  // axis x
    posePoints2D.push_back([pnpDetectionEst backproject3DPoint : cv::Point3f(0,1,0)]);  // axis y
    posePoints2D.push_back([pnpDetectionEst backproject3DPoint : cv::Point3f(0,0,1)]);  // axis z
    [Util draw3DCoordinateAxes : frameVis : posePoints2D];           // draw axes
    
    
    double detectionRatio = ((double)inliersIdx.rows/(double)goodMatches.size())*100;
    [Util drawConfidence : frameVis : detectionRatio : yellow ];
    
    // -- Step X: Draw some debugging text
    
    // Draw some debug text
    int inliers_int = inliersIdx.rows;
    int outliers_int = (int)goodMatches.size() - inliers_int;
    string inliers_str = [[Util IntToString : inliers_int] UTF8String];
    string outliers_str = [[Util IntToString : outliers_int] UTF8String];
    string n = [[Util IntToString : (int)goodMatches.size()] UTF8String];
    string text = "Found " + inliers_str + " of " + n + " matches";
    string text2 = "Inliers: " + inliers_str + " - Outliers: " + outliers_str;
    
    [Util drawText : frameVis : text : green];
    [Util drawText2 : frameVis : text2 : red];
    
    //-- Step FINAL : Return data
    redBox* data = [[redBox alloc] init];
    cv::Mat posVec = [self convertPosMatrixToPosVec:[pnpDetection getPMatrix]];
    data->posX=posVec.at<double>(0);
    data->posY=posVec.at<double>(1);
    data->posZ=posVec.at<double>(2);
    data->image = MatToUIImage(frameVis);
    data->confidence = goodMatches.size()==0 ? 0 : detectionRatio;
    return data;
}
-(double) getTimeInterval
{
    return dt;
}
-(void) setTimeInterval : (double) val
{
    dt = val;
}
- (cv::Mat) convertPosMatrixToPosVec : (cv::Mat)pMat
{
    cv::Mat originVector = cv::Mat::zeros(4, 1, CV_64FC1);
    originVector.at<double>(3,0)=1;
    cv::Mat newVector = pMat * originVector;
    return newVector;
}
- (void) initKalmanFilter :(cv::KalmanFilter&) KF : (int) nStates : (int) nMeasurements : (int) nInputs : (double) dt
{
    
    KF.init(nStates, nMeasurements, nInputs, CV_64F);                 // init Kalman Filter
    
    setIdentity(KF.processNoiseCov, cv::Scalar::all(1e-5));       // set process noise
    setIdentity(KF.measurementNoiseCov, cv::Scalar::all(1e-2));   // set measurement noise
    setIdentity(KF.errorCovPost, cv::Scalar::all(1));             // error covariance
    
    
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

/**********************************************************************************************************/
- (void) updateKalmanFilter : (cv::KalmanFilter &) KF : (cv::Mat &) measurement : (cv::Mat &) translation_estimated : (cv::Mat &) rotation_estimated
{
    
    // First predict, to update the internal statePre variable
    cv::Mat prediction = KF.predict();
    
    // The "correct" phase that is going to use the predicted value and our measurement
    cv::Mat estimated = KF.correct(measurement);
    
    // Estimated translation
    translation_estimated.at<double>(0) = estimated.at<double>(0);
    translation_estimated.at<double>(1) = estimated.at<double>(1);
    translation_estimated.at<double>(2) = estimated.at<double>(2);
    
    // Estimated euler angles
    cv::Mat eulers_estimated(3, 1, CV_64F);
    eulers_estimated.at<double>(0) = estimated.at<double>(9);
    eulers_estimated.at<double>(1) = estimated.at<double>(10);
    eulers_estimated.at<double>(2) = estimated.at<double>(11);
    
    // Convert estimated quaternion to rotation matrix
    rotation_estimated =[self euler2rot : eulers_estimated];
    
}

/**********************************************************************************************************/
- (void) fillMeasurements: (cv::Mat &) measurements : (cv::Mat &) translation_measured : (cv::Mat &)rotation_measured
{
    // Convert rotation matrix to euler angles
    cv::Mat measured_eulers(3, 1, CV_64F);
    measured_eulers = [self rot2euler : rotation_measured];
    
    // Set measurement to predict
    measurements.at<double>(0) = translation_measured.at<double>(0); // x
    measurements.at<double>(1) = translation_measured.at<double>(1); // y
    measurements.at<double>(2) = translation_measured.at<double>(2); // z
    measurements.at<double>(3) = measured_eulers.at<double>(0);      // roll
    measurements.at<double>(4) = measured_eulers.at<double>(1);      // pitch
    measurements.at<double>(5) = measured_eulers.at<double>(2);      // yaw
}

- (cv::Mat) euler2rot : (cv::Mat) vec3F
{
    if(vec3F.rows != 3 && vec3F.cols!=1)
    {
        std::cerr << "euler2rot - Input is not a vec3F." << std::endl;
        return cv::Mat::zeros(3, 1, CV_64F);
    }
    //RX
    cv::Mat Rx = cv::Mat::zeros(3, 3, CV_64F);
    Rx.at<double>(0,0) = 1;
    Rx.at<double>(0,1) = 0;
    Rx.at<double>(0,2) = 0;
    
    Rx.at<double>(1,0) = 0;
    Rx.at<double>(1,1) = cos(vec3F.at<double>(0,0));
    Rx.at<double>(1,2) = -sin(vec3F.at<double>(0,0));
    
    Rx.at<double>(2,0) = 0;
    Rx.at<double>(2,1) = sin(vec3F.at<double>(0,0));
    Rx.at<double>(2,2) = cos(vec3F.at<double>(0,0));
    //RY
    cv::Mat Ry = cv::Mat::zeros(3, 3, CV_64F);
    Ry.at<double>(0,0) = cos(vec3F.at<double>(1,0));
    Ry.at<double>(0,1) = 0;
    Ry.at<double>(0,2) = sin(vec3F.at<double>(1,0));
    
    Ry.at<double>(1,0) = 0;
    Ry.at<double>(1,1) = 1;
    Ry.at<double>(1,2) = 0;
    
    Ry.at<double>(2,0) = -sin(vec3F.at<double>(1,0));
    Ry.at<double>(2,1) = 0;
    Ry.at<double>(2,2) = cos(vec3F.at<double>(1,0));
    //RZ
    cv::Mat Rz = cv::Mat::zeros(3, 3, CV_64F);
    Rz.at<double>(0,0) = cos(vec3F.at<double>(2,0));
    Rz.at<double>(0,1) = -sin(vec3F.at<double>(2,0));
    Rz.at<double>(0,2) = 0;
    
    Rz.at<double>(1,0) = sin(vec3F.at<double>(2,0));
    Rz.at<double>(1,1) = cos(vec3F.at<double>(2,0));
    Rz.at<double>(1,2) = 0;
    
    Rz.at<double>(2,0) = 0;
    Rz.at<double>(2,1) = 0;
    Rz.at<double>(2,2) = 1;
    
    cv::Mat R = Rz * Ry * Rz;
    return R;
    
}
- (cv::Mat) rot2euler : (cv::Mat) mat
{
    // Checks if a matrix is a valid rotation matrix.
    cv::Mat vec3F = cv::Mat::zeros(3, 1, CV_64F);
    cv::Mat Rt;
    transpose(mat, Rt);
    cv::Mat shouldBeIdentity = Rt * mat;
    cv::Mat I = cv::Mat::eye(3,3, shouldBeIdentity.type());
    
    if(norm(I, shouldBeIdentity) < 1e-6)
    {
        float sy = sqrt(mat.at<double>(0,0) * mat.at<double>(0,0) +  mat.at<double>(1,0) * mat.at<double>(1,0) );
        
        bool singular = sy < 1e-6; // If
        
        float x, y, z;
        if (!singular)
        {
            x = atan2(mat.at<double>(2,1) , mat.at<double>(2,2));
            y = atan2(-mat.at<double>(2,0), sy);
            z = atan2(mat.at<double>(1,0), mat.at<double>(0,0));
        }
        else
        {
            x = atan2(-mat.at<double>(1,2), mat.at<double>(1,1));
            y = atan2(-mat.at<double>(2,0), sy);
            z = 0;
        }
        
        vec3F.at<double>(0,0) = x;
        vec3F.at<double>(1,0) = y;
        vec3F.at<double>(2,0) = z;
    }
    else
    {
        std::cerr << "rot2euler - Input is not a rotation matrix." << std::endl;
        
    }
    return vec3F;
    
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

