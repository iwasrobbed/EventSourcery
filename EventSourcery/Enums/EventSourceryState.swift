//
//  EventSourceryState.swift
//  EventSourcery
//
//  Created by Rob Phillips on 6/9/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation

public enum EventSourceryState {
    /**
     The connection has not yet been established, or it was closed and the user agent is reconnecting.
    */
    case Connecting

    /**
     The user agent has an open connection and is dispatching events as it receives them.
    */
    case Open

    /**
     The connection is not open, and the user agent is not trying to reconnect. Either there was a fatal error or the close() method was invoked.
    */
    case Closed
}