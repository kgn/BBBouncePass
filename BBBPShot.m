//
//  BBBPShot.m
//  BBBouncePass
//
//  Created by David Keegan on 2/20/11.
//

#import "BBBPShot.h"

@implementation BBBPShot

@synthesize name;
@synthesize URL, shortURL;

- (void)dealloc{
    [name release];
    [URL release];
    [shortURL release];
    [super dealloc];
}

@end
