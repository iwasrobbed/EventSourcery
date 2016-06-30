//
//  EventSourceryEvent.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/14/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

public struct EventSourceryEvent {

    // MARK: - Public Properties

    let id: String
    let event: String?
    let message: String?

    var isRetryEvent: Bool {
        // Look for the event "retry:"
        let retryString = EventSourceryKeys.Response.retry + EventSourceryKeys.Format.delimiter
        return dataString.containsString(retryString)
    }

    var retryTime: NSTimeInterval? {
        guard var timeComponent = dataString.componentsSeparatedByString(EventSourceryKeys.Format.delimiter).last else { return nil }

        timeComponent = timeComponent.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard let milliseconds = NSTimeInterval(timeComponent) else { return nil }
        return milliseconds / 1000
    }

    // MARK: - Instantiation

    init(eventString: String) throws {
        self.dataString = eventString
        (id, event, message) = try EventSourceryEvent.parse(eventString)
    }

    // MARK: - Private Properties

    let dataString: String

}

private extension EventSourceryEvent {

    static func parse(dataString: String) throws -> (String, String?, String?) {
        var eventDictionary = [String: String]()

        for line in dataString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
            try throwing_autoreleasepool({
                var keyUnbridged: NSString?, valueUnbridged: NSString?
                let scanner = NSScanner(string: line)
                scanner.scanUpToString(EventSourceryKeys.Format.delimiter, intoString: &keyUnbridged)
                scanner.scanString(EventSourceryKeys.Format.delimiter, intoString: nil)
                scanner.scanUpToString(EventSourceryKeys.Format.separatorLF, intoString: &valueUnbridged)

                if keyUnbridged != nil && valueUnbridged != nil {
                    guard let key: String = String(keyUnbridged), value: String = String(valueUnbridged) else {
                        throw EventSourceryErrors.TypeConversionError(message: "Could not convert NSString back to String")
                    }

                    if eventDictionary[key] != nil {
                        eventDictionary[key] = "\(eventDictionary[key])\(EventSourceryKeys.Format.separatorLF)\(value)"
                    } else {
                        eventDictionary[key] = value
                    }
                } else if keyUnbridged != nil && valueUnbridged == nil {
                    guard let key: String = String(keyUnbridged) else {
                        throw EventSourceryErrors.TypeConversionError(message: "Could not convert NSString back to String")
                    }

                    eventDictionary[key] = ""
                }
            })
        }

        guard let eventDictionaryId = eventDictionary[EventSourceryKeys.Response.id] else {
            throw EventSourceryErrors.EventStringParsingError(message: "Found a nil event ID so cannot instantiate this event")
        }

        return (eventDictionaryId, eventDictionary[EventSourceryKeys.Response.event], eventDictionary[EventSourceryKeys.Response.data])
    }

}