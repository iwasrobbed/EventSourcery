//
//  EventSourceryKeys.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/10/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

struct EventSourceryKeys {

    struct Event {
        static let message = "message"
        static let error = "error"
        static let open = "open"
        static let readyState = "readyState"
    }

    struct Format {
        static let delimiter = ":"
        static let separatorLFLF = "\n\n" // Line feed
        static let separatorCRCR = "\r\r" // Carriage return
        static let separatorCRLFCRLF = "\r\n\r\n"
        static let separatorKeyValuePair = "\n"
    }

    struct Headers {
        static let accept = "Accept"
        static let cacheControl = "Cache-Control"
        static let lastEventId = "Last-Event-Id"
        static let noCache = "no-cache"
        static let textEventStream = "text/event-stream"
    }

    struct Response {
        static let data = "data"
        static let event = "event"
        static let id = "id"
        static let retry = "retry"
    }

}