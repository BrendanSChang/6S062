//
//  Shader.vsh
//  InertialMotion
//
//  Created by Peter Iannucci on 3/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

// The idea of this vertex shader was to make the ribbon glow brighter when seen edge-on
// so that it would be easier to see, and hopefully more visually appealing.
//
// Also the shader causes the oldest part of the ribbon to fade out.

// These attributes are stored on a per-vertex basis in the input geometry.
attribute vec4 position;
attribute vec3 normal;
attribute vec3 diffuseColor;
attribute float time;

// This is an output of the vertex shader and an input to the fragment shader.
varying lowp vec4 colorVarying;

// These are global variables set once per frame for the entire mesh.
uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform float oldestTime, newestTime;

void main()
{
    // Compute the normal vector to the triangle in screen coordinates
    vec3 eyeNormal = normalize(normalMatrix * normal);
    
    // Scale brightness inversely (plus a constant) with the degree
    // to which the triangle is facing the screen.
    float light = abs(.2/sqrt(eyeNormal.z*eyeNormal.z)+.3);
    
    // Scale brightness linearly with the vertex's age.
    float timeAlpha = clamp((time-oldestTime)/(newestTime-oldestTime), 0.0, 1.0);
    
    // Compute the final (additive) color.
    colorVarying.rgb = diffuseColor * light * timeAlpha;
    colorVarying.a = 1.;
    
    // Compute the vertex's position in screen coordinates, too.
    gl_Position = modelViewProjectionMatrix * position;
}