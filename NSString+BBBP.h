//
//  NSString+BBBP.h
//  BBBouncePass
//
//  Created by David Keegan on 2/20/11.
//

@interface NSString (BBBP)

+ (NSString *)HTTPPOSTBoundryStringWithPrefix:(NSString *)prefix;
+ (NSString *)urlEncodedStringForArgs:(NSDictionary *)args;

- (NSString *)stringWithURLEncoding;
- (NSString *)stringByTrimmingCharacters:(NSString *)trimCharacters;

@end
