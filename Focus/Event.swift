//
//  Event.swift
//  Focus
//
//  Created by Scott Horsfall on 6/15/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import Foundation
import EventKit

extension EKEvent {
    
    public var bananagram: Bool
    
    public func isMeeting(meeting: Bool) -> Bool {
        if !meeting {
            return false
        }
        
        return true
    }
}
