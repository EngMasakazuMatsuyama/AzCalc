//
//  NADView.h
//  NendAd
//
//  広告枠ベースビュークラス

#import <UIKit/UIKit.h>

#define NAD_ADVIEW_SIZE_320x48  CGSizeMake(320,48)

@class NADView;

@protocol NADViewDelegate <NSObject>

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView;


@end

@interface NADView : UIView {
    
    id delegate;
    
}

@property (nonatomic, assign) id <NADViewDelegate> delegate;

// モーダルビューを表示元のビューコントローラを指定
@property (nonatomic, assign) UIViewController *rootViewController;

// apikeyとspotのセット
- (void)setNendID:(NSString *)apiKey spotID:(NSString *)spotID;


// 広告のロード
// 送信するパラメータをNSDictionaryの形で作成し、引数として渡す
//
// 例)年齢:30を送信したい場合
//   [nadView load:[NSDictionary dictionaryWithObjectsAndKeys:@"31",@"age",nil]];
//
- (void)load:(NSDictionary *)parameter;

@end
