//
//  YView.m
//  3
//
//  Created by wangkaiyu on 2018/11/26.
//  Copyright © 2018 wangkaiyu. All rights reserved.
//

#import "YView.h"
//#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES3/gl.h>
#import "utils.h"
#import <GLKit/GLKit.h>

//#import <OpenGLES/ES2/glext.h>

@interface YView()
{
    CAEAGLLayer *_layer;
    EAGLContext *_cont;
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programY;
    GLuint _positionY;
    GLuint _colorY;
    GLuint _mvp;

}

@end


@implementation YView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setProgram];
        [self render];
    }
    return self;
}

-(void)setupLayer
{
    _layer = (CAEAGLLayer*)self.layer;
    _layer.opaque = YES;
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
    [_cont renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
}

-(void)setupFrameBuffer
{
    glGenFramebuffers(1, &(_frameBuffer));
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
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
    _mvp = glGetUniformLocation(_programY, "mvp");

}

-(void)render{
    glClearColor(1.0, 0.3, 0.3, 0.4);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLfloat points[] = {  // opengles 以屏幕中心为原点。
        0.0f,1.0f,
        0.0f,-1.0f,
        1.0f,0.0f,
        -1.0f,0.0f,
        
        
    };
    GLfloat color[] = {  // opengles 以屏幕中心为原点。
        0.0f,1.0f,0.0f,1.0f,
        0.0f,1.0f,0.0f,1.0f,
        1.0f,0.0f,0.0f,1.0f,
        0.0f,0.0f,0.0f,1.0f
        
    };
    
    float aspect = fabsf(self.frame.size.width /self.frame.size.height);
    GLKMatrix4 proMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    //    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(1.0f, 0.0f, 2.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    GLKMatrix4 mvp = GLKMatrix4Multiply(proMatrix, viewMatrix);
    mvp = GLKMatrix4Translate(mvp, 0.0, 0.0, 0.0);
    mvp = GLKMatrix4RotateY(mvp, GLKMathRadiansToDegrees(45));
    glUniformMatrix4fv(_mvp, 1, 0, mvp.m);

    glVertexAttribPointer(_positionY, 2, GL_FLOAT, GL_FALSE, 0, points);
    glEnableVertexAttribArray(_positionY);
    glVertexAttribPointer(_colorY, 4, GL_FLOAT, GL_FALSE, 0, color);
    glEnableVertexAttribArray(_colorY);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    //    glDrawArrays(GL_LINES, 0, 4);  // 十字 不连接
    //    glDrawArrays(GL_LINE_LOOP, 0, 4);  // 头尾相连
    //    glDrawArrays(GL_LINE_STRIP, 0, 4);  // 头尾不相连
    //    glDrawArrays(GL_TRIANGLES, 0, 4);  // 够三个点才回链接
    //    glDrawArrays(GL_TRIANGLE_FAN, 0, 5);  // 以第一个点为中心点
    //     glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);  // 头尾不相连。123 234
    
    [_cont presentRenderbuffer:_renderBuffer];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

