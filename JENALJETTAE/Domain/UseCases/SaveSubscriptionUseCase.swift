//
//  SaveSubscriptionUseCase.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation

// MARK: - Save Subscription Error | 정기 구독 저장 입력값 오류
enum SaveSubscriptionError: LocalizedError {
    case emptyTitle
    case missingSubscriptionStartDate
    case invalidAmount

    var errorDescription: String? {
        switch self {
        case .emptyTitle: return "구독 서비스명을 입력해주세요."
        case .missingSubscriptionStartDate: return "구독 시작일을 선택해주세요."
        case .invalidAmount: return "결제 금액은 0 이상의 정수로 입력해주세요."
        }
    }
}

// MARK: - Save Subscription UseCase | 입력값 검증 및 공통 Repository 저장
@MainActor
struct SaveSubscriptionUseCase {
    private let repository: any ManagedItemRepository

    init(repository: any ManagedItemRepository) { self.repository = repository }

    // MARK: - Execute | 구독 정보 생성 후 SwiftData에 저장
    func execute(draft: SubscriptionDraft) throws -> ManagedItem {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw SaveSubscriptionError.emptyTitle }
        guard let subscriptionStartDate = draft.subscriptionStartDate else { throw SaveSubscriptionError.missingSubscriptionStartDate }
        if let amount = draft.amount, amount < 0 { throw SaveSubscriptionError.invalidAmount }

        // 구독에서 startDate는 반복 계산 기준인 '구독 시작일', endDate는 미사용
        let item = ManagedItem(
            type: .subscription,
            title: title,
            startDate: Calendar.current.startOfDay(for: subscriptionStartDate),
            endDate: nil,
            memo: optionalText(draft.memo),
            imageData: draft.imageData,
            subscriptionCycle: draft.cycle,
            subscriptionAmount: draft.amount
        )

        try repository.saveItem(item)
        return item
    }

    private func optionalText(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}
