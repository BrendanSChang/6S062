//
//  Shader.fsh
//  InertialMotion
//
//  Created by Peter Iannucci on 3/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

// This fragment shader simply returns the linearly-interpolated vertex color.

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
