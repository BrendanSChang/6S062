//
//  GLSLProgram.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

// This struct describes a field in the in-memory structure used to represent a vertex.
typedef struct {
    GLuint indx;
    GLint size;
    GLboolean normalized;
    char name[64];
} attribute;

// This struct describes a global variable used by the shader
typedef struct {
    GLuint indx;
    char name[64];
} uniform;

// Minimal shader compilation and management.
@interface GLSLProgram : NSObject

- (instancetype)initWithResource:(NSString *)resource attributes:(const attribute *)attributes
                        uniforms:(const uniform *)uniforms;
- (void)tearDownGL;
- (void)use;
- (void)setMatrix4:(GLKMatrix4)value forUniform:(GLuint)indx;
- (void)setMatrix3:(GLKMatrix3)value forUniform:(GLuint)indx;
- (void)setFloat:(GLfloat)value forUniform:(GLuint)indx;

@end