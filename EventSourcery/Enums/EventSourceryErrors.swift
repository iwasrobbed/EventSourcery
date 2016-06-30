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
    case ResponseParsingError(message: String)

    /**
     Thrown when there was an issue parsing the individual event string into a valid event type
     */
    case EventStringParsingError(message: String)

    /**
     Thrown when there was an issue converting from one type to another
     */
    case TypeConversionError(message: String)
}