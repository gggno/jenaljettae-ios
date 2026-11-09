//
//  SavePassUseCase.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import Foundation

// MARK: - Save Pass Error | 이용권 저장 시 입력값 오류
enum SavePassError: LocalizedError {
    case emptyTitle
    case missingStartDate
    case missingEndDate
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "이용권 이름을 입력해주세요."
        case .missingStartDate:
            return "시작일을 선택해주세요."
        case .missingEndDate:
            return "종료일을 선택해주세요."
        case .invalidDateRange:
            return "종료일은 시작일보다 빠를 수 없어요."
        }
    }
}

// MARK: - Save Pass UseCase | 이용권 입력값 검증 및 Repository 저장 요청
@MainActor
struct SavePassUseCase {
    private let repository: any ManagedItemRepository

    init(repository: any ManagedItemRepository) {
        self.repository = repository
    }

    // MARK: - Execute | 필수값 검증 후 이용권 생성 및 저장
    func execute(draft: PassDraft) throws -> ManagedItem {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else { throw SavePassError.emptyTitle }
        guard let startDate = draft.startDate else { throw SavePassError.missingStartDate }
        guard let endDate = draft.endDate else { throw SavePassError.missingEndDate }

        let calendar = Calendar.current

        guard calendar.compare(startDate, to: endDate, toGranularity: .day) != .orderedDescending else {
            throw SavePassError.invalidDateRange
        }

        // MARK: - Managed Item | 기존 공통 모델을 활용해 이용권 생성
        let item = ManagedItem(
            type: .pass,
            title: title,
            detail: draft.place.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: calendar.startOfDay(for: startDate),
            endDate: calendar.startOfDay(for: endDate),
            couponNumber: optionalText(draft.passNumber),
            memo: optionalText(draft.memo),
            imageData: draft.imageData
        )

        // MARK: - Save | 기존 Repository를 통해 SwiftData에 저장
        try repository.saveItem(item)

        return item
    }

    // MARK: - Optional Text | 선택 입력값의 공백 제거 및 nil 변환
    private func optionalText(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}
