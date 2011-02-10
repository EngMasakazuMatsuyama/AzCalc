//
//  OpenGLSampleView.h
//  AdMobSampleAds
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>

@class Interpolator;

@interface OpenGLSampleView : UIView {
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;

	EAGLContext *context;

	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;

  // Use NSTimer rather than CADisplayLink for backwards compatability
  NSTimer *animationTimer;

  // Change the scaling & rotation
  Interpolator *scaleWidth;
  Interpolator *scaleHeight;
  Interpolator *rotation;

  // Vertex and color data
  GLfloat vertexes[8];
  GLfloat colors[16];
}

@property (nonatomic, getter=isAnimating) BOOL animate;

- (void)startAnimation;
- (void)stopAnimation;

- (void)drawView;

@end
