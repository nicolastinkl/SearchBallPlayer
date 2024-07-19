//
//  Objc.m
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/19.
//

#import "Objc.h"
#import <objc/runtime.h>

@implementation Objc

+ (void)load{
    
}
@end

@implementation WKWebView (EJSCustomHandler)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getClassMethod(self.class, @selector(handlesURLScheme:));
        Method swizzledMethod = class_getClassMethod(self.class, @selector(ejs_handlesURLScheme:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

+ (BOOL)ejs_handlesURLScheme:(NSString *)urlScheme {
    if ([urlScheme hasPrefix:@"http"] || [urlScheme hasPrefix:@"https"]) {
        return NO;
    }
    return [self ejs_handlesURLScheme:urlScheme];
}

@end
 
