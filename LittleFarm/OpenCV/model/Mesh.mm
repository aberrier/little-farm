//
//  Mesh.m
//  LittleFarm
//
//  Created by saad on 13/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//


#import "Mesh.hpp"
#import <iostream>
#import "opencv-headers.h"
#import "CVSReader.hpp"
//#import "CVSReader.mm"

using namespace std;
@interface Mesh()
- (std::vector<std::vector<int> >) getTrianglesList;
- (cv::Point3f) getVertex : (int) pos;
- (int) getNumVertices;
- (void) load : (std::string) path_file;
@end

@implementation Mesh : NSObject
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
    CVSReader* csvReader = [[CVSReader alloc] init : [NSString stringWithCString:path_file.c_str() encoding:[NSString defaultCStringEncoding]] : ' '];
    
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

