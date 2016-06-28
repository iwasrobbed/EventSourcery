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

    // MARK: - Private Properties

    private let urlResponse: NSHTTPURLResponse?
    private let data: NSData?

}