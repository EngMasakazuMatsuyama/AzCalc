#import "MasConstants.h"
#import "MasBrowserViewController.h"

typedef enum {
    kMasMVPosition_none = 0,
    kMasMVPosition_top,
	kMasMVPosition_bottom
} MasManagerViewPosition;

@interface MasManagerViewController : UIViewController<UIWebViewDelegate, MasBrowserViewControllerDelegate> {
	id delegate_;
    UIWebView *adWebView_;
	NSString *auID_;
	MasViewRefreshAnimationType viewRefreshAnimationType_;
	MasManagerViewPosition position_;
	BOOL startShowAd_;
    NSTimer *retryTimer;
    NSString *baseURL_;
	BOOL firstLoaded_;
    NSURL *currentURL_;
    int retryCount_;
    MasBrowserViewController *masBrowserViewController_;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIWebView *adWebView;
@property (nonatomic, retain) NSString *auID;
@property (nonatomic) MasManagerViewPosition position;
@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSURL *currentURL;
@property (nonatomic, retain) MasBrowserViewController *masBrowserViewController;
- (void)loadRequest;
- (void)showAdView;
- (void)willRotateToInterfaceOrientation;
- (void)didRotateFromInterfaceOrientation;
- (void)refreshPosition:(BOOL)animation;
- (void)pauseRefresh;
- (void)resumeRefresh;

@end

@protocol MasManagerViewControllerDelegate

@optional
- (void)masManagerViewControllerReceiveAd:(MasManagerViewController *)masManagerViewController;
- (void)masManagerViewControllerFailedToReceiveAd:(MasManagerViewController *)masManagerViewController;

@end
