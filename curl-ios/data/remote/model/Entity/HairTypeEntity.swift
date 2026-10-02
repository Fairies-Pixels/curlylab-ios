//
//  HairTypeEntity.swift
//  curl-ios
//
//  Created by Nadineenik on 02.10.2026.
// чтобы мы могли сохранить локально ответ от сервера, HairTypeRequest - только для сети
//

import SwiftData

@Model
class HairTypeEntity{
    var userId: String
    var porosity: String?
    var isColored: Bool?
    var thickness: String?
    
    init(userId: String, porosity: String?, isColored: Bool?, thickness: String? ){
        self.userId = userId
        self.porosity  = porosity
        self.isColored = isColored
        self.thickness = thickness
    }
}
