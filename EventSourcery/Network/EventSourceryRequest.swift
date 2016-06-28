//
//  EventSourceryRequest.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/10/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

class EventSourceryRequest: NSObject {

    // MARK: - Properties

    var state = EventSourceryState.Closed
    var retryInterval: NSTimeInterval = 3 // seconds

    // MARK: - Instantiation

    init(url: NSURL, headers: [String: String], onOpen: EventSourceryOnOpen? = nil, onMessage: EventSourceryOnMessage? = nil, onError: EventSourceryOnError? = nil) {
        self.url = url
        self.headers = headers

        self.onOpenCallback = onOpen
        self.onMessageCallback = onMessage
        self.onErrorCallback = onError
    }

    // MARK: - Connection

    func connect() {
        state = .Connecting
        task.resume()
    }

    func close() {
        state = .Closed
        urlSession.invalidateAndCancel()
    }

    // MARK: - Private Properties

    private let url: NSURL
    private let headers: [String: String]
    private let operationQueue = NSOperationQueue()

    private let onOpenCallback: EventSourceryOnOpen?
    private let onMessageCallback: EventSourceryOnMessage?
    private let onErrorCallback: EventSourceryOnError?

    // MARK: - Private Computed Properties

    private lazy var urlSession: NSURLSession = {
        return NSURLSession(configuration: self.configuration, delegate: self, delegateQueue: self.operationQueue)
    }()

    private lazy var task: NSURLSessionDataTask = {
        return self.urlSession.dataTaskWithURL(self.url)
    }()

    private lazy var additionalHeaders: [String: String] = {
        var additionalHeaders = self.headers
        if let eventID = EventSourceryCache.lastEventID {
            additionalHeaders[EventSourceryKeys.Headers.lastEventId] = eventID
        }
        additionalHeaders[EventSourceryKeys.Headers.accept] = EventSourceryKeys.Headers.textEventStream
        additionalHeaders[EventSourceryKeys.Headers.cacheControl] = EventSourceryKeys.Headers.noCache
        return additionalHeaders
    }()

    private lazy var configuration: NSURLSessionConfiguration = {
        let maxTimeout = NSTimeInterval(DBL_MAX)
        $0.timeoutIntervalForRequest = maxTimeout
        $0.timeoutIntervalForResource = maxTimeout
        $0.HTTPAdditionalHeaders = self.additionalHeaders
        return $0
    }(NSURLSessionConfiguration.defaultSessionConfiguration())

}

// MARK: - NSURLSessionDelegate

extension EventSourceryRequest: NSURLSessionDelegate {

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        var response = EventSourceryResponse(task: dataTask, data: data)

        guard !response.connectionClosed else { return }
        guard state == .Open else { return }

        // Parse data buffer and event stream
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        completionHandler(.Allow)

        var response = EventSourceryResponse(task: dataTask)
        guard !response.connectionClosed else { return }

        state = .Open

        dispatch_async(dispatch_get_main_queue()) {
            self.onOpenCallback?()
        }
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        state = .Closed

        var response = EventSourceryResponse(task: task)
        guard !response.connectionClosed else { return }

        if error == nil {
            retry()
        } else if let error = error where error.code != NSURLErrorCancelled {
            retry()
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.onErrorCallback?(error)
        }
    }

}

// MARK: - Private API

private extension EventSourceryRequest {

    func retry() {
        let nanoseconds = retryInterval * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(nanoseconds))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.connect()
        }
    }

}