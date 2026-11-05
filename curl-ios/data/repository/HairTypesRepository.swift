//
//  HairTypesRepository.swift
//  curl-ios
//
//  Created by Nadinee on 05.11.2026.
//

import Foundation

protocol HairTypesRepository {
    func updateHairType(userId: String, request: HairTypeRequest) async throws
}

final class HairTypesRepositoryImpl: HairTypesRepository {
    private let apiService = ApiService.shared
    
    func updateHairType(userId: String, request: HairTypeRequest) async throws {
        let path = "/hairtypes/\(userId)"
        let token = await AuthManager.shared.getAccessToken()
        try await apiService.put(path, body: request, token: token)
    }
}
