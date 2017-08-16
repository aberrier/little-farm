//
//  PnPProblem.m
//  LittleFarm
//
//  Created by saad on 13/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "PnPProblem.hpp"
#import <iostream>
#import "opencv-headers.h"
#import "Mesh.hpp"

using namespace std;
@interface PnPProblem()

- (id) init : (NSMutableArray*) param;

- (BOOL) backproject2DPoint : (Mesh*) mesh : (cv::Point2f) point2d : (cv::Point3f) point3d;
- (BOOL) intersectMollerTrumbore : (Ray*) R : (Triangle*) T : (double*) out_;
- (std::vector<cv::Point2f>) verifyPoints : (Mesh *) mesh;
- (cv::Point2f) backproject3DPoint : (cv::Point3f) point3d;
- (BOOL) estimatePose : (std::vector<cv::Point3f>) listPoints3d : (std::vector<cv::Point2f>) listPoints2d :  (int) flags;
- (void) estimatePoseRANSAC : (std::vector<cv::Point3f>) listPoints3d : (std::vector<cv::Point2f>) listPoints2d
                            : (int) flags
                            : (cv::Mat) inliers
                            : (int) iterationsCount : (float) reprojectionError : (double) confidence;

- (cv::Mat) getAMatrix;
- (cv::Mat) getRMatrix;
- (cv::Mat) getTMatrix;
- (cv::Mat) getPMatrix;

- (void) setPMatrix : (cv::Mat) R_matrix : (cv::Mat) t_matrix;

// Functions for Möller–Trumbore intersection algorithm
- (cv::Point3f) CROSS : (cv::Point3f) v1 :  (cv::Point3f) v2;
- (double) DOT : (cv::Point3f) v1 :  (cv::Point3f) v2;
- (cv::Point3f) SUB : (cv::Point3f) v1 : (cv::Point3f) v2;
- (cv::Point3f) getNearest3DPoint : (std::vector<cv::Point3f>) pointsList : (cv::Point3f) origin;
@end

@implementation PnPProblem : NSObject
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

- (BOOL) backproject2DPoint : (Mesh*) mesh : (cv::Point2f) point2d : (cv::Point3f) point3d
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
- (BOOL) estimatePose : (std::vector<cv::Point3f>) listPoints3d : (std::vector<cv::Point2f>) listPoints2d :  (int) flags
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
    [self setPMatrix(RMatrix, TMatrix);
     
     return correspondence;
     }
     - (void) estimatePoseRANSAC : (std::vector<cv::Point3f>) listPoints3d : (std::vector<cv::Point2f>) listPoints2d
     : (int) flags
     : (cv::Mat) inliers
     : (int) iterationsCount : (float) reprojectionError : (double) confidence
    {
        cv::Mat distCoeffs = cv::Mat::zeros(4, 1, CV_64FC1);  // vector of distortion coefficients
        cv::Mat rvec = cv::Mat::zeros(3, 1, CV_64FC1);          // output rotation vector
        cv::Mat tvec = cv::Mat::zeros(3, 1, CV_64FC1);    // output translation vector
        
        
        bool useExtrinsicGuess = false;   // if true the function uses the provided rvec and tvec values as
        // initial approximations of the rotation and translation vectors
        
        //to input array
        cv::InputArray inputArray(list_points3d);
        cv::Mat mat = inputArray.getMat();
        cv::Mat matDirect = cv::Mat(list_points3d);
        cv::solvePnPRansac( list_points3d, list_points2d, _A_matrix, distCoeffs, rvec, tvec,
                           useExtrinsicGuess, iterationsCount, reprojectionError, confidence,
                           inliers, flags );
        Rodrigues(rvec,_R_matrix);      // converts Rotation Vector to Matrix
        _t_matrix = tvec;       // set translation matrix
        this->set_P_matrix(_R_matrix, _t_matrix); // set rotation-translation matrix
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
        return->TMatrix;
    }
     - (cv::Mat) getPMatrix
    {
        return->PMatrix;
    }
     - (void) setPMatrix : (cv::Mat) R_matrix : (cv::Mat) t_matrix
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
     
