//
//  SaveCouponUseCase.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/28/26.
//

import Foundation

// MARK: - Save Coupon Error | 쿠폰 저장 시 발생하는 입력값 오류
enum SaveCouponError: LocalizedError {
    case emptyTitle
    case missingExpiryDate

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "상품명을 입력해주세요."
        case .missingExpiryDate:
            return "만료일을 선택해주세요."
        }
    }
}

// MARK: - Save Coupon UseCase | 쿠폰 입력값 검증 및 Repository 저장 요청
@MainActor
struct SaveCouponUseCase {
    private let repository: any ManagedItemRepository

    init(repository: any ManagedItemRepository) {
        self.repository = repository
    }

    // MARK: - Execute | 필수값 검증 후 쿠폰 생성 및 저장
    func execute(
        title: String,
        brand: String,
        expiryDate: Date?,
        couponNumber: String,
        memo: String
    ) throws -> ManagedItem {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { throw SaveCouponError.emptyTitle }
        guard let expiryDate else { throw SaveCouponError.missingExpiryDate }

        let item = ManagedItem(
            type: .coupon,
            title: trimmedTitle,
            detail: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: Calendar.current.startOfDay(for: Date()),
            endDate: Calendar.current.startOfDay(for: expiryDate),
            couponNumber: optionalText(couponNumber),
            memo: optionalText(memo)
        )

        try repository.saveItem(item)
        return item
    }

    // MARK: - Optional Text | 입력하지 않은 선택 항목은 nil로 변환
    private func optionalText(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}
