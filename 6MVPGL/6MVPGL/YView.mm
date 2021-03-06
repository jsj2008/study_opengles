//
//  YView.m
//  3
//
//  Created by wangkaiyu on 2018/11/26.
//  Copyright © 2018 wangkaiyu. All rights reserved.
//

#import "YView.h"
#import <OpenGLES/ES3/gl.h>
#import "utils.h"
#import <GLKit/GLKit.h>
#include "KYTexture.h"
#include "math3d.h"
#include <iostream>


@interface YView()
{
    CAEAGLLayer *_layer;
    EAGLContext *_cont;
    GLuint _renderBuffer,_depthRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programY;
    GLuint _positionY;
    GLuint _colorY;
    GLuint _mvp;
    GLuint _texIn;
    GLuint _tex;
    GLuint _tex111;
    GLuint _m;
    GLuint _v;
    GLuint _p;
    GLuint texture0;

}

@end


@implementation YView
float a = 0;
+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        [self setupLayer];
        [self setupContext];
        const char *path = [[[NSBundle mainBundle] pathForResource:@"test2Ret" ofType:@".jpg"] UTF8String];
        GLuint texture0 = KYTexture::getTextureId(path);
        
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setProgram];
        [self setupDisplayLink];
    }
    return self;
}

-(void)setupLayer
{
    _layer = (CAEAGLLayer*)self.layer;
    _layer.opaque = YES;
}

-(void)loadtex{
    
}


-(void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _cont = [[EAGLContext alloc] initWithAPI:api];
    
    [EAGLContext setCurrentContext:_cont];
}

-(void)setupRenderBuffer
{
    glGenRenderbuffers(1, &(_renderBuffer));
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_COLOR_ATTACHMENT0, self.frame.size.width, self.frame.size.height);
    [_cont renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
}
- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
//    [_cont renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];

}
-(void)setupFrameBuffer
{
    glGenFramebuffers(1, &(_frameBuffer));
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);

}

-(void)setProgram
{
    NSString *ver = [[NSBundle mainBundle] pathForResource:@"ver" ofType:@"glsl"];
    NSString *frag = [[NSBundle mainBundle] pathForResource:@"frag" ofType:@"glsl"];
    
    GLuint vershader = [utils loadShader:GL_VERTEX_SHADER withpath:ver];
    GLuint fragshader = [utils loadShader:GL_FRAGMENT_SHADER withpath:frag];
    
    _programY = glCreateProgram();
    glAttachShader(_programY, vershader);
    glAttachShader(_programY, fragshader);
    glLinkProgram(_programY);
     glUseProgram(_programY);
    _positionY = glGetAttribLocation(_programY, "Yposition");
    _colorY = glGetAttribLocation(_programY, "Ycolor");
    //_mvp = glGetUniformLocation(_programY, "mvp");
    _m = glGetUniformLocation(_programY, "Model");
    _v = glGetUniformLocation(_programY, "View");
    _p = glGetUniformLocation(_programY, "Projection");
    _texIn = glGetAttribLocation(_programY, "texIoord");
    _tex = glGetUniformLocation(_programY, "uSampler");
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

//float redius = 10.0;
float redius_z = -10.0;


-(void)render:(CADisplayLink*)displayLink
{
   
    glClearColor(0.0, 0.3, 0.3, 0.4);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glEnable(GL_DEPTH_TEST);

    GLfloat points[] = {  // opengles 以屏幕中心为原点。
//        -1.0, -1.0,
//        1.0, -1.0,
//        -1.0, 1.0,
//        1.0, 1.0,
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f
    };
    GLfloat color[] = {  // opengles 以屏幕中心为原点。
        0.0f,1.0f,0.0f,1.0f,
        0.0f,1.0f,0.0f,1.0f,
        1.0f,0.0f,0.0f,1.0f,
        0.0f,0.0f,0.0f,1.0f
        
    };
    GLfloat texCoordIn[] = {  // opengles 以屏幕中心为原点。
//        0.0, 0.0,
//        1.0, 0.0,
//        0.0, 1.0,
//        1.0, 1.0
        0.0f, 0.0f,
       1.0f, 0.0f,
       1.0f, 1.0f,
       1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
      
        0.0f, 0.0f,
       1.0f, 0.0f,
       1.0f, 1.0f,
       1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
      
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
         1.0f, 0.0f,
       
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
       
         0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
         0.0f, 0.0f,
         0.0f, 1.0f,
       
         0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
         0.0f, 0.0f,
         0.0f, 1.0f
        
    };
    // Model View  Projection
//    M3DMatrix44f _model;
//    m3dLoadIdentity44(_model);
//    M3DMatrix44f _model_copy;
//    m3dLoadIdentity44(_model_copy);
//    // scale
//    M3DMatrix44f s;
//    m3dLoadIdentity44(s);
//    m3dScaleMatrix44(s, 0.5,0.5,0.5);
//    m3dCopyMatrix44(_model_copy, _model);
//    m3dMatrixMultiply44(_model, s, _model_copy);
////    // rotate
//    a += 2.0;
//    M3DMatrix44f r_matrix_init;
//    m3dRotationMatrix44(r_matrix_init, m3dDegToRad(a),  1.0, 0.0, 0.0);
//    m3dCopyMatrix44(_model_copy, _model);
//    m3dMatrixMultiply44(_model, r_matrix_init, _model_copy);
////    // tran
//    M3DMatrix44f translation_init;
//    m3dLoadIdentity44(translation_init);
//    translation_init[12] = 0.0;
//    translation_init[13] = 0.0;
//    translation_init[14] = 0.0;
//    //m3dTranslationMatrix44(translation_init, 1.0, 1.0, 0.0);
//    m3dCopyMatrix44(_model_copy, _model);
//    m3dMatrixMultiply44(_model, translation_init, _model_copy);
//    std::cout << _model[12] << _model[13] << _model[14] << std::endl;
//    glUniformMatrix4fv(_m, 1, GL_FALSE, _model);

    float redius=0.0;
    redius_z+=0.1;
    
    
    M3DMatrix44f mViewMatrix;
//    m3dLoadIdentity44(mViewMatrix);
//    m3dTranslationMatrix44(mViewMatrix, redius, 0.0, redius_z);
   
//
    M3DMatrix44f mProjection;
    m3dLoadIdentity44(mProjection);
    m3dMakePerspectiveMatrix(mProjection, 45.0 * 3.14 /180.0, 720.0/1280.0, 0.1, 100);
    glUniformMatrix4fv(_p, 1, GL_FALSE,mProjection);

    M3DVector3f cameraPos;
    m3dLoadVector3(cameraPos, -redius_z, 0.0, redius_z);
    M3DVector3f cameraTarget;
    m3dLoadVector3(cameraTarget, 0.0, 0.0, 0.0);
    M3DVector3f cameraUp;
    m3dLoadVector3(cameraUp, 0.0, 1.0, 0.0);
    
    M3DVector3f cameraDir;
    
    M3DVector3f temp_cv;
    m3dCopyVector3(temp_cv, cameraTarget);
    m3dNegateVector3(temp_cv);
    
    M3DVector3f n;
    m3dAddVectors3(n, cameraPos, temp_cv);
    m3dNormalizeVector3(n);
    
    M3DVector3f u; // right
    m3dCrossProduct3(u, cameraUp, n);
    m3dNormalizeVector3(u);
    
    M3DVector3f v; // up
    m3dCrossProduct3(v, n, u);
    
    M3DVector3f temp_u;
    m3dCopyVector3(temp_u, u);
    m3dNegateVector3(temp_u);
    
    M3DVector3f temp_v;
    m3dCopyVector3(temp_v, v);
    m3dNegateVector3(temp_v);
    
    M3DVector3f temp_n;
    m3dCopyVector3(temp_n, n);
    m3dNegateVector3(temp_n);
    
    M3DMatrix44f matrix = { u[0], v[0], n[0], 0.0f,
        u[1], v[1], n[1], 0.0f,
        u[2], v[2], n[2], 0.0f,
        m3dDotProduct3(temp_u, cameraPos), m3dDotProduct3(temp_v, cameraPos), m3dDotProduct3(temp_n, cameraPos), 1.0f};
    
    m3dCopyMatrix44(mViewMatrix, matrix);
     glUniformMatrix4fv(_v, 1, GL_FALSE,mViewMatrix);

    
//    mViewMatrix
//    M3DVector3f ev = {0.0, 0.0, 1.0};
//    M3DVector3f lv = {0.0, 0.0, -1.0};
//    M3DVector3f uv = {0.0, 1.0, 0.0};
//    M3DVector3f temp_cv;
//    m3dCopyVector3(temp_cv, lv);
//    m3dNegateVector3(temp_cv);
//
//    M3DVector3f n;
//    m3dAddVectors3(n, ev, temp_cv);
//    m3dNormalizeVector3(n);
//
//    M3DVector3f u;
//    m3dCrossProduct3(u, uv, n);
//    m3dNormalizeVector3(u);
//
//    M3DVector3f v;
//    m3dCrossProduct3(v, n, u);
//
//    M3DVector3f temp_u;
//    m3dCopyVector3(temp_u, u);
//    m3dNegateVector3(temp_u);
//
//    M3DVector3f temp_v;
//    m3dCopyVector3(temp_v, v);
//    m3dNegateVector3(temp_v);
//
//    M3DVector3f temp_n;
//    m3dCopyVector3(temp_n, n);
//    m3dNegateVector3(temp_n);
//
//    M3DMatrix44f matrix = { u[0], v[0], n[0], 0.0f,
//        u[1], v[1], n[1], 0.0f,
//        u[2], v[2], n[2], 0.0f,
//        m3dDotProduct3(temp_u, ev), m3dDotProduct3(temp_v, ev), m3dDotProduct3(temp_n, ev), 1.0f};
//    m3dCopyMatrix44(mViewMatrix, matrix);
//    M3DMatrix44f mProjectionMatrix;
//    m3dLoadIdentity44(mProjectionMatrix);
//    float fovyRadians = m3dDegToRad(80.0);
//    float aspect = fabsf(720.0/1280.0);
//    float nearZ = 0.1f;
//    float farZ = 1000.0f;
//    float cotan = 1.0f / tanf(fovyRadians / 2.0f);
//    M3DMatrix44f Pmatrix = { cotan / aspect, 0.0f, 0.0f, 0.0f,
//        0.0f, cotan, 0.0f, 0.0f,
//        0.0f, 0.0f, (farZ + nearZ) / (nearZ - farZ), -1.0f,
//        0.0f, 0.0f, (2.0f * farZ * nearZ) / (nearZ - farZ), 0.0f};
//    m3dCopyMatrix44(mProjectionMatrix, matrix);
//
//    M3DMatrix44f vp;
//    m3dMatrixMultiply44(vp,mProjectionMatrix, mViewMatrix);

    
//    M3DMatrix44f mvp;
//    m3dMatrixMultiply44(mvp, vp, _model);

//    float aspect = fabsf(self.frame.size.width /self.frame.size.height);
//    GLKMatrix4 proMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
//    //    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
//    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(1.0f, 0.0f, 2.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
//    GLKMatrix4 mvp = GLKMatrix4Multiply(proMatrix, viewMatrix);
//    mvp = GLKMatrix4Translate(mvp, 0.0, 0.0, 0.0);
//    mvp = GLKMatrix4RotateY(mvp, GLKMathRadiansToDegrees(45));
//    glUniformMatrix4fv(_mvp, 1, 0, mvp.m);
    
    glVertexAttribPointer(_positionY, 3, GL_FLOAT, GL_FALSE, 0, points);
    glEnableVertexAttribArray(_positionY);
    glVertexAttribPointer(_texIn, 2, GL_FLOAT, GL_FALSE, 0, texCoordIn);
    glEnableVertexAttribArray(_texIn);
    glVertexAttribPointer(_colorY, 4, GL_FLOAT, GL_FALSE, 0, color);
    glEnableVertexAttribArray(_colorY);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture0);
    glUniform1i(_tex, 0);
    
    //glDrawArrays(GL_TRIANGLES, 0, 36);

    float arr[] = {
      0.0,-1.0
    };
    
    for(unsigned int i = 0; i < 2; i++)
    {
    
//        glDrawArrays(GL_TRIANGLES, 0, 36);
        //// Model View  Projection
        M3DMatrix44f _model;
        m3dLoadIdentity44(_model);
        M3DMatrix44f _model_copy;
        m3dLoadIdentity44(_model_copy);
        // scale
//        M3DMatrix44f s;
//        m3dLoadIdentity44(s);
//        m3dScaleMatrix44(s, 0.5,0.5,0.5);
//        m3dCopyMatrix44(_model_copy, _model);
//        m3dMatrixMultiply44(_model, s, _model_copy);
        //    // rotate
        a += 2.0 * i;
        M3DMatrix44f r_matrix_init;
        m3dRotationMatrix44(r_matrix_init, m3dDegToRad(a),  1.0, 0.3, 0.5);
        m3dCopyMatrix44(_model_copy, _model);
        m3dMatrixMultiply44(_model, r_matrix_init, _model_copy);
        //    // tran
        M3DMatrix44f translation_init;
        m3dLoadIdentity44(translation_init);
        translation_init[12] = arr[i];
        translation_init[13] = arr[i];
        translation_init[14] = arr[i];
        //m3dTranslationMatrix44(translation_init, 1.0, 1.0, 0.0);
        m3dCopyMatrix44(_model_copy, _model);
        m3dMatrixMultiply44(_model, translation_init, _model_copy);
        glUniformMatrix4fv(_m, 1, GL_FALSE, _model);
        //glm::mat4 model;
//        model = glm::translate(model, cubePositions[i]);
//        float angle = 20.0f * i;
//        model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
//        ourShader.setMat4("model", model);

        glDrawArrays(GL_TRIANGLES, 0, 36);
         [_cont presentRenderbuffer:_renderBuffer];
    }
    
   // [_cont presentRenderbuffer:_renderBuffer];
}

@end

