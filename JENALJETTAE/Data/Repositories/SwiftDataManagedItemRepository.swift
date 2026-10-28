//
//  SwiftDataManagedItemRepository.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/27/26.
//

import Foundation
import SwiftData

// MARK: - SwiftData Repository | 실제 일정 데이터 저장·조회·삭제
@MainActor
final class SwiftDataManagedItemRepository: ManagedItemRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch | SwiftData Entity를 Domain 모델로 변환하여 조회
    func fetchItems() throws -> [ManagedItem] {
        let descriptor = FetchDescriptor<ManagedItemEntity>(
            sortBy: [SortDescriptor(\.startDate)]
        )

        return try modelContext.fetch(descriptor).map { entity in
            guard let type = ManagedItemType(rawValue: entity.type) else {
                throw RepositoryError.invalidType(entity.type)
            }

            return ManagedItem(
                id: entity.id,
                type: type,
                title: entity.title,
                detail: entity.detail,
                startDate: entity.startDate,
                endDate: entity.endDate,
                couponNumber: entity.couponNumber,
                memo: entity.memo
            )
        }
    }

    // MARK: - Save | ID를 기준으로 신규 저장 또는 기존 데이터 수정
    func saveItem(_ item: ManagedItem) throws {
        let id = item.id
        let descriptor = FetchDescriptor<ManagedItemEntity>(
            predicate: #Predicate { $0.id == id }
        )

        if let entity = try modelContext.fetch(descriptor).first {
            entity.type = item.type.rawValue
            entity.title = item.title
            entity.detail = item.detail
            entity.startDate = item.startDate
            entity.endDate = item.endDate
            entity.couponNumber = item.couponNumber
            entity.memo = item.memo
        
        } else {
            let entity = ManagedItemEntity(
                id: item.id,
                type: item.type.rawValue,
                title: item.title,
                detail: item.detail,
                startDate: item.startDate,
                endDate: item.endDate,
                couponNumber: item.couponNumber,
                memo: item.memo
            )
            modelContext.insert(entity)
        }

        try modelContext.save()
    }

    // MARK: - Delete | ID에 해당하는 저장 데이터 삭제
    func deleteItem(id: UUID) throws {
        let descriptor = FetchDescriptor<ManagedItemEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else { return }

        modelContext.delete(entity)
        try modelContext.save()
    }
}

// MARK: - Repository Error | 저장 데이터 변환 오류
private enum RepositoryError: LocalizedError {
    case invalidType(String)

    var errorDescription: String? {
        switch self {
        case .invalidType(let type):
            return "지원하지 않는 항목 유형입니다: \(type)"
        }
    }
}
