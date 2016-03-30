//
//  RibbonViewController.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "RibbonViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "Ribbon.h"

@interface RibbonViewController () {
    GLKVector3 _location, _velocity;
    GLKQuaternion _pose;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) Ribbon *ribbon;

@end

@implementation RibbonViewController

#pragma mark - Lifecycle management for GLKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context)
        NSLog(@"Failed to create ES context");
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Prepare the ribbon for drawing
    _ribbon = [[Ribbon alloc] initWithLifetime:20.];
    [_ribbon setupGL];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Free drawing resources used by the ribbon
    [_ribbon tearDownGL];
    _ribbon = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && !self.view.window) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context)
            [EAGLContext setCurrentContext:nil];
        self.context = nil;
    }
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeWithQuaternion(GLKQuaternionInvert(_pose));
    modelViewMatrix = GLKMatrix4TranslateWithVector3(modelViewMatrix, GLKQuaternionRotateVector3(_pose, GLKVector3Make(0,0,-.3)));
    modelViewMatrix = GLKMatrix4TranslateWithVector3(modelViewMatrix, GLKVector3MultiplyScalar(_location, -1));
    
    _ribbon.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.1f, 100.0f);
    
    _ribbon.modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    [_ribbon advanceToTime:[NSDate timeIntervalSinceReferenceDate]];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [_ribbon draw];
}

#pragma mark - Location update handling

- (void)appendPoint:(GLKVector3)point attitude:(GLKQuaternion)attitude draw:(BOOL)draw
{
    _pose = attitude;
    _location = point;
    [_ribbon appendPoint:point
                attitude:attitude
                 forTime:[NSDate timeIntervalSinceReferenceDate]
                    skip:!draw];
}

#pragma mark - Customizing visual appearance of view controller

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
