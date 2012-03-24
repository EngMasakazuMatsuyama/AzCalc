#import <UIKit/UIKit.h>

@interface MasBrowserViewController : UIViewController<UIWebViewDelegate> {
	id delegate_;
	NSURL *url_;
    UINavigationBar *navigationBar_;
	UINavigationItem* item_;
	UIWebView *webView_;
}
@property (nonatomic, assign) id delegate;
@property(nonatomic,retain) NSURL *url;
@property(nonatomic,retain) UINavigationBar *navigationBar;
@property(nonatomic,retain) UINavigationItem* item;
@property(nonatomic,retain) UIWebView *webView;

-(void)done;
-(void)back;
-(void)dismiss;

- (id)initWithUrl:(NSString *)url;

@end

@protocol MasBrowserViewControllerDelegate

- (void)closeViewMasBrowserViewController;

@end
