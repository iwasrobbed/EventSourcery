//
//  EventSourceryResponse.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/10/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

struct EventSourceryResponse {

    // MARK: - Internal Properties

    lazy var connectionClosed: Bool = {
        guard let response = self.urlResponse else {
            return false
        }

        return response.statusCode == EventSourceryHTTPCodes.HTTP204.toInt()
    }()

    // MARK: - Instantiation

    init(task: NSURLSessionTask, data: NSData? = nil) {
        self.urlResponse = task.response as? NSHTTPURLResponse
        self.data = data
    }

    // MARK: - Events

    lazy var events: [EventSourceryEvent]? = {
        guard let events = try? EventSourceryResponseParser.init(data: self.data).parse() else { return nil }
        return events
    }()

    // MARK: - Retrying

    lazy var retryTime: NSTimeInterval? = {
        guard let events = self.events, retryEvent = events.filter({ $0.isRetryEvent }).first else { return nil }
        return retryEvent.retryTime
    }()

    // MARK: - Private Properties

    private let urlResponse: NSHTTPURLResponse?
    private let data: NSData?

}