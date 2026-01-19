//
//  Item.swift
//  CoverLetterGen
//
//  Created by Jonni Åkesson on 2026-01-19.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
