//
//  CouponRegistrationViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/28/26.
//

import Foundation
import Combine

// MARK: - Coupon Registration ViewModel | 쿠폰 입력값과 저장 상태 관리
@MainActor
final class CouponRegistrationViewModel: ObservableObject {
    @Published var couponTitle = ""
    @Published var brand = ""
    @Published var couponNumber = ""
    @Published var memo = ""
    @Published var expiryDate: Date?

    @Published private(set) var isSaving = false
    @Published private(set) var hasSaved = false
    @Published var showsSaveError = false
    @Published private(set) var saveErrorMessage = ""

    // MARK: - Save Validation | 필수값 및 중복 저장 여부 확인
    var canSave: Bool {
        !couponTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        expiryDate != nil &&
        !isSaving &&
        !hasSaved
    }

    // MARK: - Save Coupon | 저장할 때 UseCase를 전달받아 실행
    func saveCoupon(using useCase: SaveCouponUseCase) -> ManagedItem? {
        guard canSave else { return nil }

        isSaving = true
        defer { isSaving = false }

        do {
            let item = try useCase.execute(
                title: couponTitle,
                brand: brand,
                expiryDate: expiryDate,
                couponNumber: couponNumber,
                memo: memo
            )

            hasSaved = true
            return item
        } catch {
            saveErrorMessage = error.localizedDescription
            showsSaveError = true
            return nil
        }
    }
}
