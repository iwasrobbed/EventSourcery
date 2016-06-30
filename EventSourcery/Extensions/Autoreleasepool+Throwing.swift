//
//  Autoreleasepool+Throwing.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/30/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

// Modified from: https://github.com/apple/swift-evolution/blob/master/proposals/0061-autoreleasepool-signature.md
public func throwing_autoreleasepool<ResultType>(@noescape code: Void throws -> ResultType) throws -> ResultType {
    var result: ResultType?
    var error: ErrorType?

    autoreleasepool {
        do {
            result = try code()
        } catch let e {
            error = e
        }
    }

    if let result = result {
        return result
    }

    throw error!
}
