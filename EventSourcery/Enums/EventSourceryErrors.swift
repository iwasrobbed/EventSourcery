//
//  EventSourceryErrors.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/13/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

public enum EventSourceryErrors: ErrorType {
    /**
     Thrown when there was an issue parsing the response
    */
    case ParsingError(message: String)
}