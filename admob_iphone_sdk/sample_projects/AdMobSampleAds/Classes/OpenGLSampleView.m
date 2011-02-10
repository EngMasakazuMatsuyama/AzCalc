//
//  OpenGLSampleView.m
//  AdMobSampleAds
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "OpenGLSampleView.h"

static NSTimeInterval kAnimationRate = (1.0 / 60.0);

@interface Interpolator : NSObject {
  float min;
  float max;
  float start;
  float end;
  float t;
  float delta;
}

@property (nonatomic, readonly) float value;
@property (nonatomic, assign) float start;
@property (nonatomic, assign) float end;
@property (nonatomic, assign) float t;
@property (nonatomic, assign) float increment;

- (id)initWithMinimum:(float)min maximum:(float)max;
- (void)resetWithNewEndPoint;
- (void)applyIncrement;

@end

@implementation Interpolator

@synthesize start;
@synthesize end;
@synthesize t;
@synthesize increment;

- (float)value {
  float ease = 3 * t * t - 2 * t * t * t;
  return t >= 1.0 ? end : start + (end - start) * ease;
}

- (float)randomValueInRange {
  return min + (max - min) * ((float)random() / (float)RAND_MAX);
}

- (id)initWithMinimum:(float)minimum maximum:(float)maximum {
  if ((self = [super init])) {
    min = minimum;
    max = maximum;
    start = [self randomValueInRange];
    end = [self randomValueInRange];
  }

  return self;
}

- (void)resetWithNewEndPoint {
  t = 0;
  start = end;
  end = [self randomValueInRange];
}

- (void)applyIncrement {
  t += increment;

  if (t >= 1.0)
    [self resetWithNewEndPoint];
}

@end

@interface OpenGLSampleView ()
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupView;
- (void)setupQuadColors;
@end

@implementation OpenGLSampleView

- (void)setAnimate:(BOOL)animate {
  if (animate) {
    [self startAnimation];
  } else {
    [self stopAnimation];
  }
}

- (BOOL)isAnimating {
  return animationTimer ? YES : NO;
}

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass {
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
  srandom(CFAbsoluteTimeGetCurrent() * 10);
  if ((self = [super initWithFrame:frame])) {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties =
      [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
       kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
       nil];

		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}

    scaleWidth = [[Interpolator alloc] initWithMinimum:3 maximum:400];
    scaleHeight = [[Interpolator alloc] initWithMinimum:3 maximum:400];
    float inc = kAnimationRate * 2;
    scaleWidth.increment = inc;
    scaleHeight.increment = inc;
    rotation = [[Interpolator alloc] initWithMinimum:0 maximum:360];
    rotation.increment = inc / 10;
  }
  return self;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
- (void)layoutSubviews {
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
  [self setupView];
	[self drawView];
}

- (BOOL)createFramebuffer {
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);

	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);

	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}

	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer {
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
}

- (void)startAnimation {
  if (![self isAnimating]) {
    [self setupQuadColors];
    animationTimer =
      [NSTimer scheduledTimerWithTimeInterval:kAnimationRate target:self
                                     selector:@selector(drawView) userInfo:nil
                                      repeats:TRUE];
  }
}

- (void)stopAnimation {
  [animationTimer invalidate];
  animationTimer = nil;
}

- (void)dealloc {
  [self stopAnimation];

	if([EAGLContext currentContext] == context)	{
		[EAGLContext setCurrentContext:nil];
	}

	[context release];
  [super dealloc];
}

- (void)setupQuadVertexes {
  vertexes[0] = 0;
  vertexes[1] = 0;
  vertexes[2] = 1;
  vertexes[3] = 0;
  vertexes[4] = 0;
  vertexes[5] = 1;
  vertexes[6] = 1;
  vertexes[7] = 1;
}

- (void)setupQuadColors {
  for (int i = 0; i < 16; ++i) {
    colors[i] = (float)random() / (float)RAND_MAX;
  }
}

- (void)setupView {
	[EAGLContext setCurrentContext:context];

  // Setup 2D view
  glViewport(0, 0, backingWidth, backingHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrthof(0, backingWidth, 0, backingHeight, -1.0f, 1.0f);

  glMatrixMode(GL_MODELVIEW);

  // We'll draw the same quad over and over (and over).
  [self setupQuadVertexes];
}

- (void)drawView {
  // Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];

  // Bind and clear to our background
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.3f, 0.5f, 0.3f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  // Random scale & rotation
  [scaleWidth applyIncrement];
  [scaleHeight applyIncrement];
  float scaleW = scaleWidth.value;
  float scaleH = scaleHeight.value;
  [rotation applyIncrement];

  // Setup the viewing transforms
  glPushMatrix();
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  // Center on the screen
  glTranslatef((backingWidth - scaleW) / 2, (backingHeight - scaleH) / 2, 0);

  // Rotate about its center
  glTranslatef(scaleW / 2, scaleH / 2, 0);
  glRotatef([rotation value], 0, 0, 1);
  glTranslatef(-scaleW / 2, -scaleH / 2, 0);

  // Scale to be visible
  glScalef(scaleW, scaleH, 1.0);

  // Blending
  glEnable(GL_BLEND);
//  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  glBlendFunc(GL_SRC_ALPHA, GL_ONE);


  // Load up our quad and colors
  glVertexPointer(2, GL_FLOAT, 0, vertexes);
	glColorPointer(4, GL_FLOAT, 0, colors);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);

  // Restore
  glDisable(GL_BLEND);
  glPopMatrix();

  // Push it out
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

@end
