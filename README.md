BBBouncePass is an Objective-C library for uploading shots to [Dribbble](http://dribbble.com). There is no official api for doing this so BBBouncePass wraps up all the nasty raw HTTP calls required to accomplish this into a simple api.

    #import "BBBouncePass.h"
    BBBouncePass *dribbble = [BBBouncePass passWithDelegate:self];
    dribbble.username = @"username";
    dribbble.password = @"password";
    [dribbble shootImageNamed:@"test_image.png" 
                     withData:imageData
                         name:@"A Test Image"
                         tags:nil 
       andIntroductoryComment:nil];

BBBouncePass was originally developed for [Coaches Loupe](https://github.com/InScopeApps/Coaches-Loupe).

BBBouncePass uses [Hpple](https://github.com/topfunky/hpple). All the necessary files from *Hpple* are included with BBBouncePass but you'll need to read their setup docs for information on how to add *libxml2* to your project.

Thanks to [Jonathan Badeen](http://www.badeen.com) for helping with the code and letting me use his [Dribbble](http://dribbble.com) account for testing. I don't have an account yet, if you like BBBouncePass or [Coaches Loupe](https://github.com/InScopeApps/Coaches-Loupe) and have an invite I'd love to start shooting :)