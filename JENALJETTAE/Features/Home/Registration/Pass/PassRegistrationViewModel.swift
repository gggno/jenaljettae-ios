//
//  PassRegistrationViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import Foundation
import Combine

// MARK: - Pass Registration ViewModel | 이용권 입력 상태 및 저장 관리
@MainActor
final class PassRegistrationViewModel: ObservableObject {
    // MARK: - Input State | 이용권 입력값
    @Published var passTitle = ""
    @Published var place = ""
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var passNumber = ""
    @Published var memo = ""
    @Published private(set) var imageData: Data?

    // MARK: - Save State | 저장 진행·완료·오류 상태
    @Published private(set) var isSaving = false
    @Published private(set) var hasSaved = false
    @Published var showsSaveError = false
    @Published private(set) var saveErrorMessage = ""

    // MARK: - Validation | 이름과 이용 기간 검증
    var isInvalidDateRange: Bool {
        guard let startDate, let endDate else { return false }
        return Calendar.current.compare(startDate, to: endDate, toGranularity: .day) == .orderedDescending
    }

    var canSave: Bool {
        !passTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        startDate != nil && endDate != nil && !isInvalidDateRange && !isSaving && !hasSaved
    }

    // MARK: - Image | 이미지 선택·제거
    func setImage(_ data: Data) { imageData = data }
    func removeImage() { imageData = nil }

    // MARK: - Save | 입력값을 PassDraft로 변환하여 저장
    func savePass(using useCase: SavePassUseCase) -> ManagedItem? {
        guard canSave else { return nil }

        isSaving = true
        defer { isSaving = false }

        let draft = PassDraft(
            title: passTitle,
            place: place,
            startDate: startDate,
            endDate: endDate,
            passNumber: passNumber,
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
