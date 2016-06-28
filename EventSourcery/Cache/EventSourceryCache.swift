//
//  EventSourceryCache.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/9/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

struct EventSourceryCache {

    /**
     A UUID for the last event that was received from the server
    */
    static var lastEventID: String? {
        get {
            return EventSourceryCache.cache.stringForKey(EventSourceryCache.lastEventCacheKey)
        }
        set {
            EventSourceryCache.cache.setObject(newValue, forKey: EventSourceryCache.lastEventCacheKey)
        }
    }

    // MARK: - Private Properties

    private static let cacheKey = "EventSourceryCache"
    private static let lastEventCacheKey = "\(cacheKey).lastEventId"
    private static let cache = NSUserDefaults.standardUserDefaults()
}
