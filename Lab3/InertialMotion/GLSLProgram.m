//
//  GLSLProgram.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "GLSLProgram.h"

@interface GLSLProgram () {
    GLuint _program;
    NSMutableArray *_uniformLocations;
}
@end

@implementation GLSLProgram

#pragma mark -  OpenGL ES 2 shader compilation

- (instancetype)initWithResource:(NSString *)resource attributes:(const attribute *)attributes uniforms:(const uniform *)uniforms
{
    self = [super init];
    if (!self)
        return self;
    
    GLuint vertShader, fragShader;
    
    _program = glCreateProgram();
    
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER fromResource:resource ofType:@"vsh"])
        return nil;
    
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER fromResource:resource ofType:@"fsh"])
        return nil;
    
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    for (const attribute *a=attributes; a->indx!=-1; a++)
        glBindAttribLocation(_program, a->indx, a->name);
    
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return nil;
    }
    
    _uniformLocations = [NSMutableArray array];
    
    // Get uniform locations.
    for (int i=0; uniforms[i].indx!=-1; i++)
    {
        const uniform *u = &uniforms[i];
        _uniformLocations[u->indx] = @(glGetUniformLocation(_program, u->name));
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return self;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type fromResource:(NSString *)resource ofType:(NSString *)typeString
{
    GLint status;
    const GLchar *source;
    
    NSString *file = [[NSBundle mainBundle] pathForResource:resource ofType:typeString];
    NSString *shaderTypeString = (type == GL_VERTEX_SHADER) ? @"vertex" : @"fragment";
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load %@ shader", shaderTypeString);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        NSLog(@"Failed to compile %@ shader", shaderTypeString);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tearDownGL
{
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (void)use
{
    glUseProgram(_program);
}

- (void)setMatrix4:(GLKMatrix4)value forUniform:(GLuint)indx
{
    glUniformMatrix4fv([_uniformLocations[indx] intValue], 1, 0, value.m);
}

- (void)setMatrix3:(GLKMatrix3)value forUniform:(GLuint)indx
{
    glUniformMatrix3fv([_uniformLocations[indx] intValue], 1, 0, value.m);
}

- (void)setFloat:(GLfloat)value forUniform:(GLuint)indx
{
    glUniform1f([_uniformLocations[indx] intValue], value);
}

@end
