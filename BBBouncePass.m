//
//  BBBouncePass.m
//  BBBouncePass
//
//  Created by David Keegan on 2/14/11.
//

#import "BBBouncePass.h"
#import "BBBPDribbble.h"
#import "NSString+BBBP.h"

#define BBBPLoginError \
    [NSError errorWithDomain:NSURLErrorDomain \
                        code:NSURLErrorBadServerResponse \
                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys: \
                              @"Login failed", NSLocalizedDescriptionKey, nil]]

#define BBBPUploadError \
    [NSError errorWithDomain:NSURLErrorDomain \
                        code:NSURLErrorBadServerResponse \
                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys: \
                              @"Upload failed", NSLocalizedDescriptionKey, nil]]

@implementation BBBouncePass

@synthesize username, password;
@synthesize _authenticityToken;
@synthesize _isLoggedin;
@synthesize delegate;
@synthesize _operationQueue;

#pragma -
#pragma dribbble

- (void)login{
    if(![self isReady]){
        self._isLoggedin = NO;
        self._authenticityToken = nil;
    }
    if(!self._isLoggedin){
        self._authenticityToken = [BBBPDribbble authenticityToken];
        self._isLoggedin = [BBBPDribbble loginWithUsername:self.username 
                                                  password:self.password 
                                      andAuthenticityToken:self._authenticityToken];
    }
}

- (void)callDelegateOnMainThread:(NSDictionary *)data{
    id object = [data objectForKey:@"object"];
    NSDictionary *shotInfo = [data objectForKey:@"shotInfo"];
    
    if([object isKindOfClass:[BBBPShot class]]){
        if([self.delegate respondsToSelector:@selector(dribbbleShotUploadDidSucceedWithResultingShot:authenticityToken:shotInfo:)]){
            [self.delegate dribbbleShotUploadDidSucceedWithResultingShot:object 
                                                       authenticityToken:self._authenticityToken 
                                                                shotInfo:shotInfo];
        }
    }else if([object isKindOfClass:[NSError class]]){
        if([self.delegate respondsToSelector:@selector(dribbbleRequestDidFailWithError:authenticityToken:shotInfo:)]){        
            [self.delegate dribbbleRequestDidFailWithError:object 
                                         authenticityToken:self._authenticityToken 
                                                  shotInfo:shotInfo];
        }
    }
}

- (void)synchronousShootWithData:(NSDictionary *)shotData{
    [self login];
    
    NSString *name = [shotData objectForKey:@"name"];
    NSArray *tags = [shotData objectForKey:@"tags"];
    NSString *introductoryComment = [shotData objectForKey:@"introductoryComment"]; 
    
    NSDictionary *shotInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                            name, @"name",
                                            tags, @"tags",
                                            introductoryComment, @"introductoryComment",                              
                                            nil];
    NSMutableDictionary *delegateData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         shotInfo, @"shotInfo",                                        
                                         nil];
    
    if(self._isLoggedin){
        NSString *imageName = [shotData objectForKey:@"imageName"];
        NSData *imageData = [shotData objectForKey:@"imageData"];
        
        BBBPShot *shot = [BBBPDribbble shootImageWithName:imageName 
                                                  andData:imageData 
                                                     name:name
                                                     tags:tags
                                      introductoryComment:introductoryComment
                                    withAuthenticityToken:self._authenticityToken];
        if(shot){
            [delegateData setObject:shot forKey:@"object"];
        }else{
            [delegateData setObject:BBBPUploadError forKey:@"object"];
        }
    }else{
        [delegateData setObject:BBBPLoginError forKey:@"object"];
    }
    
    [self performSelectorOnMainThread:@selector(callDelegateOnMainThread:) 
                           withObject:delegateData 
                        waitUntilDone:YES];
}

#pragma -
#pragma Setters

- (void)setUsername:(NSString *)newUsername{
    if(![self.username isEqualToString:newUsername]){
        [username autorelease];
        username = [newUsername retain];
        self._isLoggedin = NO;
    }
}

- (void)setPassword:(NSString *)newPassword{
    if(![self.password isEqualToString:newPassword]){
        [password autorelease];
        password = [newPassword retain];
        self._isLoggedin = NO;
    }
}

#pragma -
#pragma Supers

- (void)dealloc{
    delegate = nil;
    
    [username release];
    [password release];
    
    [_authenticityToken release];
    
    [_operationQueue release];
    [super dealloc];
}

#pragma -
#pragma Public

- (id)initWithDelegate:(id<BBBouncePassDelegate>)aDelegate{
    if((self = [super init])){
        self.delegate = aDelegate;
        self._authenticityToken = nil;
        
        self._operationQueue = [[NSOperationQueue alloc] init];
        [self._operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (BOOL)isReady{
	return ([self.username length] > 0 && [self.password length] > 0);
}

-(void)shootImageNamed:(NSString *)imageName withData:(NSData *)imageData name:(NSString *)name tags:(NSArray *)tags andIntroductoryComment:(NSString *)introductoryComment{
    NSDictionary *shotData = [NSDictionary dictionaryWithObjectsAndKeys:
                              imageName, @"imageName",
                              imageData, @"imageData",
                              name, @"name",
                              tags, @"tags",
                              introductoryComment, @"introductoryComment",                              
                              nil];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self 
                                                                            selector:@selector(synchronousShootWithData:) 
                                                                              object:shotData];
    [self._operationQueue addOperation:operation];
    [operation release];
}

+ (id)pass{
	return [[[[self class] alloc] init] autorelease];
}

+ (id)passWithDelegate:(id<BBBouncePassDelegate>)aDelegate{
	return [[[[self class] alloc] initWithDelegate:aDelegate] autorelease];
}

+ (NSURL *)DribbbleURLWithComponents:(NSString *)firstString, ...{
    NSMutableString *path = [NSMutableString string];
    va_list args;
    va_start(args, firstString);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for(NSString *arg = firstString; arg != nil; arg = va_arg(args, NSString *)){
        NSString *slash = @"/";
        //If the arg already starts with a slash don't add another one
        if([[arg substringToIndex:1] isEqualToString:@"/"]){
            slash = @"";
        }
        [path appendString:[NSString stringWithFormat:@"%@%@", slash, arg]];
    }
    [pool drain];
    va_end(args);
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BBBPDribbbleURL, path];
    return [NSURL URLWithString:urlString];
}

@end
