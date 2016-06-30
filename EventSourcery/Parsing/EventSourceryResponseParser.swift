//
//  EventSourceryResponseParser.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/13/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

struct EventSourceryResponseParser {

    // MARK: - Instantiation

    init(data: NSData?) {
        self.data = data
    }

    // MARK: - Parsing

    func parse() throws -> [EventSourceryEvent]? {
        return try parseEvents()
    }

    // MARK: - Private properties

    private let data: NSData?
}

private extension EventSourceryResponseParser {

    func parseEvents() throws -> [EventSourceryEvent]? {
        guard let parsedEvents = try? parseEventStrings(), eventStrings = parsedEvents else {
            throw EventSourceryErrors.ResponseParsingError(message: "Could not parse events to turn into messages")
        }

        var events = [EventSourceryEvent]()
        for eventString in eventStrings {
            // Check if it's a comment, which can be ignored
            // e.g. ": some comment here\n"
            if eventString.hasPrefix(EventSourceryKeys.Format.delimiter) {
                continue
            }

            let event = try EventSourceryEvent(eventString: eventString)
            events.append(event)
        }

        // Record the last event
        if let lastEvent = events.last {
            EventSourceryCache.lastEventID = lastEvent.id
        }

        return events.count > 0 ? events : nil
    }

    func parseEventStrings() throws -> [String]? {
        var eventStrings = [String]()

        guard let data = data else { return nil }
        guard let delimiter = EventSourceryKeys.Format.separatorLFLF.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw EventSourceryErrors.ResponseParsingError(message: "Could not instantiate delimiter into data")
        }

        var searchRange = NSMakeRange(0, data.length)
        var foundRange = data.rangeOfData(delimiter, options: NSDataSearchOptions(), range: searchRange)
        while foundRange.location != NSNotFound {
            // Found an event
            if foundRange.location > searchRange.location {
                let range = NSMakeRange(searchRange.location, foundRange.location - searchRange.location)
                let chunk = data.subdataWithRange(range)
                guard let event = NSString(data: chunk, encoding: NSUTF8StringEncoding) as? String else {
                    throw EventSourceryErrors.ResponseParsingError(message: "Could not chunk found data into a UTF-8 string")
                }

                eventStrings.append(event)
            }

            // Find next event
            searchRange.location = foundRange.location + foundRange.length
            searchRange.length = data.length - searchRange.location
            foundRange = data.rangeOfData(delimiter, options: NSDataSearchOptions(), range: searchRange)
        }

        return eventStrings
    }

}