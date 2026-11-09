//
//  SubscriptionRegistrationViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation
import Combine

// MARK: - Subscription Registration ViewModel | 입력 상태·검증·저장 관리
@MainActor
final class SubscriptionRegistrationViewModel: ObservableObject {
    // MARK: - Input State | 구독 입력값
    @Published var title = ""
    @Published var cycle: SubscriptionCycle = .monthly
    @Published var subscriptionStartDate: Date?
    @Published var amountText = ""
    @Published var memo = ""
    @Published private(set) var imageData: Data?

    // MARK: - Save State | 저장 진행 및 오류
    @Published private(set) var isSaving = false
    @Published private(set) var hasSaved = false
    @Published var showsSaveError = false
    @Published private(set) var saveErrorMessage = ""

    private var normalizedAmount: String {
        amountText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
    }

    var isInvalidAmount: Bool {
        !normalizedAmount.isEmpty && (Int(normalizedAmount).map { $0 >= 0 } != true)
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        subscriptionStartDate != nil && !isInvalidAmount && !isSaving && !hasSaved
    }

    // MARK: - Image | 공통 이미지 컴포넌트와 연결
    func setImage(_ data: Data) { imageData = data }
    func removeImage() { imageData = nil }

    // MARK: - Save | Draft 생성 후 UseCase에 위임
    func save(using useCase: SaveSubscriptionUseCase) -> ManagedItem? {
        guard canSave else { return nil }
        isSaving = true
        defer { isSaving = false }

        let draft = SubscriptionDraft(
            title: title,
            cycle: cycle,
            subscriptionStartDate: subscriptionStartDate,
            amount: Int(normalizedAmount),
            memo: memo,
            imageData: imageData
        )

        do {
            let item = try useCase.execute(draft: draft)
            hasSaved = true
            return item
        } catch {
            saveErrorMessage = error.localizedDescription
            showsSaveError = true
            return nil
        }
    }
}
