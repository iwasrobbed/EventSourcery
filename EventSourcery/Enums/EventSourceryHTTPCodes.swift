//
//  EventSourceryHTTPCodes.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/9/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

enum EventSourceryHTTPCodes: Int {
    case HTTP204 = 204

    func toInt() -> Int {
        return self.rawValue
    }
}