//
//  CouponRegistrationViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/28/26.
//

import Foundation
import Combine

// MARK: - Coupon Registration ViewModel | 쿠폰 입력값과 이미지 및 저장 상태 관리
@MainActor
final class CouponRegistrationViewModel: ObservableObject {

    // MARK: - Coupon Information | 쿠폰 입력값 관리
    @Published var couponTitle = ""
    @Published var brand = ""
    @Published var couponNumber = ""
    @Published var memo = ""
    @Published var expiryDate: Date?

    // MARK: - Coupon Image | 선택한 쿠폰 이미지 데이터 관리
    @Published private(set) var imageData: Data?

    // MARK: - Save State | 쿠폰 저장 상태 및 오류 관리
    @Published private(set) var isSaving = false
    @Published private(set) var hasSaved = false
    @Published var showsSaveError = false
    @Published private(set) var saveErrorMessage = ""

    // MARK: - Apply Draft | Gemini 추출 결과를 쿠폰 입력값에 적용
    func apply(draft: CouponDraft) {
        couponTitle = draft.title ?? ""
        brand = draft.brand ?? ""
        couponNumber = draft.couponNumber ?? ""
        expiryDate = draft.expiryDate
    }

    // MARK: - Set Image | 쿠폰 이미지 추가 또는 변경
    func setImage(_ data: Data) {
        imageData = data
    }

    // MARK: - Remove Image | 쿠폰 이미지만 삭제하고 입력값 유지
    func removeImage() {
        imageData = nil
    }

    // MARK: - Save Validation | 필수값 및 중복 저장 여부 확인
    var canSave: Bool {
        !couponTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        expiryDate != nil && !isSaving && !hasSaved
    }

    // MARK: - Save Coupon | 최종 쿠폰 정보와 이미지 데이터를 UseCase로 전달
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
                memo: memo,
                imageData: imageData
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
