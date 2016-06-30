//
//  EventSourcery.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/9/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

// MARK: - Public API

public typealias EventSourceryOnOpen = (() -> Void)
public typealias EventSourceryOnMessage = (EventSourceryEvent -> Void)
public typealias EventSourceryOnError = (NSError? -> Void)

final public class EventSourcery: NSObject {

    // MARK: - Public Properties

    public var state: EventSourceryState {
        return request.state
    }

    // MARK: - Instantiation

    public init(url: NSURL, headers: [String: String], onOpen: EventSourceryOnOpen? = nil, onMessage: EventSourceryOnMessage? = nil, onError: EventSourceryOnError? = nil) {
        self.request = EventSourceryRequest(url: url, headers: headers, onOpen: onOpen, onMessage: onMessage, onError: onError)

        super.init()
    }

    // MARK: - Connection

    public func connect() {
        request.connect()
    }

    public func close() {
        request.close()
    }

    // MARK: - Event Listeners

    // TODO

    // MARK: - Private Properties

    private let request: EventSourceryRequest
}
