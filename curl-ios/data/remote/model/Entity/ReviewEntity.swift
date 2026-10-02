//
//  ReviewEntity.swift
//  curl-ios
//
//  Created by Nadineenik on 02.10.2026.
//

import Foundation
import SwiftData

@Model
class ReviewEntity {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var mark: Int
    var review: String
    var dateCreated: Date
    
    init(id: UUID = UUID(), userId: UUID, mark: Int, review: String, dateCreated: Date = Date()) {
        self.id = id
        self.userId = userId
        self.mark = mark
        self.review = review
        self.dateCreated = dateCreated
    }
}
