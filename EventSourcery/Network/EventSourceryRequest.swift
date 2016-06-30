//
//  EventSourceryRequest.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/10/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

final class EventSourceryRequest: NSObject {

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

    // TODO: Hold a reference to any split data to find it a home within the next packet
    // Could do this by holding the data buffer strongly here and then passing it into the parser to mutate
    // which would leave any leftover event strings still in the buffer for the next response

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

        // Check for events
        guard let events = response.events?.filter({ !$0.isRetryEvent }) else { return }
        dispatch_async(dispatch_get_main_queue()) {
            events.forEach { self.onMessageCallback?($0) }
        }

        // Check if we should be forced to retry at a different interval
        if let retryTime = response.retryTime {
            retry(retryTime)
        }
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

        if error?.code != NSURLErrorCancelled {
            // Note: this also checks if error is explicitly nil
            retry()
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.onErrorCallback?(error)
        }
    }

}

// MARK: - Private API

private extension EventSourceryRequest {

    func retry(timeInterval: NSTimeInterval? = nil) {
        if let timeInterval = timeInterval {
            retryInterval = timeInterval
        }

        let nanoseconds = retryInterval * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(nanoseconds))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.connect()
        }
    }

}