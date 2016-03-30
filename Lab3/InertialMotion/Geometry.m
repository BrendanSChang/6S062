//
//  Geometry.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/28/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "Geometry.h"


GLKMatrix3 NearestRotation(GLKMatrix3 input)
{
    // Heavily modified from code by Luke Lonergan, under the license "Use pfreely".
    double A[9], S[3], U[9], Vt[9];
    
    for (int j=0; j<3; j++)
        for (int i=0; i<3; i++)
            A[j+i*3] = input.m[i+j*3];
    
    // compute singular value decomposition of A in column-major order
    __CLPK_integer iwork[24], n = 3, lwork = -1, info;
    double dwork;
    dgesdd_("A", &n, &n, A, &n, S, U, &n, Vt, &n, &dwork, &lwork, iwork, &info);
    if (info)
        @throw [NSException exceptionWithName:@"MatrixException" reason:@"Error while performing SVD." userInfo:nil];
    lwork = (int)dwork;
    double work[lwork];
    dgesdd_("A", &n, &n, A, &n, S, U, &n, Vt, &n, work, &lwork, iwork, &info);
    if (info)
        @throw [NSException exceptionWithName:@"MatrixException" reason:@"Error while performing SVD." userInfo:nil];
    
    // compute nearest rotation to input
    // we're ignoring a subtlety having to do with the sign of the determinant
    GLKMatrix3 output;
    for (int i=0; i<3; i++)
        for (int j=0; j<3; j++)
            output.m[i*3+j] = Vt[0+i*3] * U[j+0*3] + Vt[1+i*3] * U[j+1*3] + Vt[2+i*3] * U[j+2*3];
    
    return output;
}