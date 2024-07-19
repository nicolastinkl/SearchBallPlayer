//
//  MethodSwizzing.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/19.
//

import Foundation
import UIKit

extension NSObject {
    static func swizzleMethod(originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getClassMethod(self, originalSelector),
              let swizzledMethod = class_getClassMethod(self, swizzledSelector) else {
            return
        }

        let didAddMethod = class_addMethod(self,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(self,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

class URLSchemeHandler: NSObject {
    @objc class func handlesURLScheme(_ urlScheme: String) -> Bool {
        // Original implementation
        return true
    }

    @objc class func yyhandlesURLScheme(_ urlScheme: String) -> Bool {
        print("yyhandlesURLScheme")
        if urlScheme == "http" || urlScheme == "https" {
            return false  // Do not handle HTTP or HTTPS schemes
        } else {
            // Call the original implementation (now `yyhandlesURLScheme:` is swapped with `handlesURLScheme:`)
            return self.yyhandlesURLScheme(urlScheme)
        }
    }
}

// Ensure swizzling happens once during app launch
extension URLSchemeHandler {
    static let swizzle: Void = {
        swizzleMethod(originalSelector: #selector(handlesURLScheme(_:)),
                      swizzledSelector: #selector(yyhandlesURLScheme(_:)))
    }()
}

// Call this swizzling method in AppDelegate or during application setup
func setupSwizzling() {
    URLSchemeHandler.swizzle
}
