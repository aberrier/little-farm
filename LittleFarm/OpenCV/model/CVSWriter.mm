//
//  CVSWriter.m
//  LittleFarm
//
//  Created by saad on 13/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

#import "CVSWriter.hpp"
#import <iostream>
#import <fstream>
#import "opencv-headers.h"
#import "Util.hpp"
using namespace std;
@interface CVSWriter()
- (id) init : (string) path : (char) separator;

/**
 * Read a plane text file with .ply format
 *
 * @param list_vertex - The container of the vertices list of the mesh
 * @param list_triangle - The container of the triangles list of the mesh
 * @return
 */
- (void) readPLY : (vector<cv::Point3f>) listVertex : (vector<vector<int> >) listTriangles;
@end
@implementation CVSWriter : NSObject
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

- (void) readPLY : (vector<cv::Point3f>) listVertex : (vector<vector<int> >) listTriangles
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
