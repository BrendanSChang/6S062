//
//  Ribbon.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "Ribbon.h"
#import <OpenGLES/ES2/glext.h>
#import "GLSLProgram.h"

#pragma mark OpenGLES Geometry
// Declare how ribbon geometry is stored in memory (used by GLSLProgram in sync with shaders).

enum attribute_index {
    ATTRIB_VERTEX, ATTRIB_NORMAL, ATTRIB_COLOR, ATTRIB_TIME, NUM_ATTRIBUTES
};

static const attribute attributes[] = {
    {ATTRIB_VERTEX, 3, GL_FALSE, "position"},
    {ATTRIB_NORMAL, 3, GL_FALSE, "normal"},
    {ATTRIB_COLOR,  3, GL_TRUE,  "diffuseColor"},
    {ATTRIB_TIME,   1, GL_FALSE, "time"},
    {-1}
};

enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX, UNIFORM_NORMAL_MATRIX,
    UNIFORM_OLDEST_TIME, UNIFORM_NEWEST_TIME, NUM_UNIFORMS
};

static uniform uniforms[] = {
    {UNIFORM_MODELVIEWPROJECTION_MATRIX,    "modelViewProjectionMatrix"},
    {UNIFORM_NORMAL_MATRIX,                 "normalMatrix"},
    {UNIFORM_OLDEST_TIME,                   "oldestTime"},
    {UNIFORM_NEWEST_TIME,                   "newestTime"},
    {-1}
};

#pragma mark - Ribbon base classes

@implementation HistoryManager

- (instancetype)initWithLifetime:(double)lifetime
{
    if (self = [super init])
    {
        _startTime = [NSDate timeIntervalSinceReferenceDate];
        _lifetime = lifetime;
        _newestTime = 0;
        _oldestTime = _newestTime - _lifetime;
    }
    return self;
}

- (void)advanceToTime:(double)time
{
    _newestTime = time - _startTime;
    _oldestTime = _newestTime - _lifetime;
}

@end

@interface TriangleStrip () {
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    NSMutableData *_vertexData;
    GLuint _stride;
    GLSLProgram *_program;
}
@end

@implementation TriangleStrip

- (instancetype)initWithLifetime:(double)lifetime {
    if (self = [super initWithLifetime:lifetime])
    {
        _vertexData = [NSMutableData data];
    }
    return self;
}

- (void)setupGL {
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    _stride = 0;
    for (const attribute *a=attributes; a->indx!=-1; a++)
        _stride += a->size * sizeof(GLfloat);
    
    GLfloat *ptr = NULL;
    for (const attribute *a=attributes; a->indx!=-1; a++)
    {
        glEnableVertexAttribArray(a->indx);
        glVertexAttribPointer(a->indx, a->size, GL_FLOAT, a->normalized, _stride, ptr);
        ptr += a->size;
    }
    
    glBindVertexArrayOES(0);
    
    _program = [[GLSLProgram alloc] initWithResource:@"Shader" attributes:attributes uniforms:uniforms];
}

- (void)tearDownGL {
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    [_program tearDownGL];
    _program = nil;
}

- (void)draw {
    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE, GL_ZERO, GL_ONE);
    
    [_program use];
    
    [_program setMatrix4:_modelViewProjectionMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    [_program setMatrix3:_normalMatrix forUniform:UNIFORM_NORMAL_MATRIX];
    [_program setFloat:self.oldestTime forUniform:UNIFORM_OLDEST_TIME];
    [_program setFloat:self.newestTime forUniform:UNIFORM_NEWEST_TIME];
    
    glBindVertexArrayOES(_vertexArray);
    glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_DYNAMIC_DRAW);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (int)_vertexData.length/40);
    
    glDisable(GL_BLEND);
}

// Add a point to the ribbon geometry, and potentially a triangle as well.
- (void)appendPoint:(GLKVector3)point withColor:(GLKVector3)color forTime:(double)time
{
    GLfloat relativeTime = time - self.startTime;
    
    GLuint newIndex = (GLuint)_vertexData.length/_stride;
    GLfloat vertex[10];
    memcpy(vertex+0, point.v, 3*sizeof(GLfloat));
    memcpy(vertex+6, color.v, 3*sizeof(GLfloat));
    memcpy(vertex+9, &relativeTime, 1*sizeof(GLfloat));
    [_vertexData appendBytes:&vertex length:sizeof(vertex)];
    GLfloat *vertexData = _vertexData.mutableBytes;
    if (newIndex >= 2)
    {
        GLKVector3 p[3];
        memcpy(p+0, vertexData+(newIndex-0)*10+0, 3*sizeof(GLfloat));
        memcpy(p+1, vertexData+(newIndex-1)*10+0, 3*sizeof(GLfloat));
        memcpy(p+2, vertexData+(newIndex-2)*10+0, 3*sizeof(GLfloat));
        GLKVector3 d01 = GLKVector3Subtract(p[0], p[1]);
        GLKVector3 d02 = GLKVector3Subtract(p[0], p[2]);
        GLKVector3 normal = GLKVector3Normalize(GLKVector3CrossProduct(d01, d02));
        memcpy(vertexData+(newIndex-0)*10+3, normal.v, 3*sizeof(GLfloat));
        if (newIndex == 2)
        {
            memcpy(vertexData+(newIndex-1)*10+3, normal.v, 3*sizeof(GLfloat));
            memcpy(vertexData+(newIndex-2)*10+3, normal.v, 3*sizeof(GLfloat));
        }
    }
}

// Delete points that have aged by more than self.lifetime.
- (void)advanceToTime:(double)time
{
    [super advanceToTime:time];
    
    const GLfloat *vertexData = _vertexData.bytes;
    double oldestTime = self.oldestTime;
    int count = 0;
    for (int i=0; i<_vertexData.length/_stride; i++)
    {
        if (vertexData[i*10+9] < oldestTime)
            count++;
        else
            break;
    }
    if (count)
        [_vertexData replaceBytesInRange:NSMakeRange(0, count*_stride) withBytes:NULL length:0];
}

@end


@interface Ribbon () {
    ColorRandomizer *_colorRandomizer;
}
@end


@implementation Ribbon

- (instancetype)initWithLifetime:(double)lifetime
{
    if (self = [super initWithLifetime:lifetime])
    {
        _colorRandomizer = [[ColorRandomizer alloc] init];
    }
    return self;
}

// Accept a point and an orientation; convert to a pair of closely-spaced points.
- (void)appendPoint:(GLKVector3)point attitude:(GLKQuaternion)attitude forTime:(double)t skip:(BOOL)skip
{
    GLKVector3 color = skip ? (GLKVector3){} : [_colorRandomizer colorForTime:t - self.startTime];
    GLKVector3 offset = GLKQuaternionRotateVector3(attitude, GLKVector3Make(0.01,0,0));
    [super appendPoint:GLKVector3Add(point, GLKVector3MultiplyScalar(offset, +1)) withColor:color forTime:t];
    [super appendPoint:GLKVector3Add(point, GLKVector3MultiplyScalar(offset, -1)) withColor:color forTime:t];
}

@end

