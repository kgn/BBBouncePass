//
//  BBBouncePass.h
//  BBBouncePass
//
//  Created by David Keegan on 2/14/11.
//

#import "BBBPShot.h"

#define BBBPDribbbleURL @"http://dribbble.com"
#define BBBPHTTPPOSTBoundryPrefix @"BBBouncePass"

@protocol BBBouncePassDelegate;

@interface BBBouncePass : NSObject {
    NSString *username, *password;
    id<BBBouncePassDelegate> delegate;
    
    @private
    NSString *_authenticityToken;
    BOOL _isLoggedin;
    NSOperationQueue *_operationQueue;
}

@property (copy, nonatomic) NSString *username, *password;
@property (assign) id<BBBouncePassDelegate> delegate;
@property (copy, nonatomic) NSString *_authenticityToken;
@property (nonatomic) BOOL _isLoggedin;
@property (retain) NSOperationQueue *_operationQueue;

+ (id)pass;
+ (id)passWithDelegate:(id<BBBouncePassDelegate>)aDelegate;
- (id)initWithDelegate:(id<BBBouncePassDelegate>)aDelegate;

+ (NSURL *)DribbbleURLWithComponents:(NSString *)firstString, ... NS_REQUIRES_NIL_TERMINATION;

- (BOOL)isReady;

//Asynchronously upload an image to dribbble,
//Delegate methods will be called when the upload is done or failes. 
-(void)shootImageNamed:(NSString *)imageName 
              withData:(NSData *)imageData 
                  name:(NSString *)name 
                  tags:(NSArray *)tags 
andIntroductoryComment:(NSString *)introductoryComment;

@end

@protocol BBBouncePassDelegate <NSObject>

@optional
- (void)dribbbleRequestDidFailWithError:(NSError *)error 
                      authenticityToken:(NSString *)authenticityToken 
                               shotInfo:(NSDictionary *)shotInfo;
- (void)dribbbleShotUploadDidSucceedWithResultingShot:(BBBPShot *)shot 
                                    authenticityToken:(NSString *)authenticityToken 
                                             shotInfo:(NSDictionary *)shotInfo;

@end
