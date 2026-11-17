//
//  ScheduleRegistrationViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation
import Combine

// MARK: - Schedule Registration ViewModel | 일정 입력·검증·저장 상태
@MainActor
final class ScheduleRegistrationViewModel: ObservableObject {

    // MARK: - Input State | 일정 입력값
    @Published var title = ""
    @Published var place = ""
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var timeMinutes: Int?
    @Published var memo = ""
    @Published private(set) var imageData: Data?

    // MARK: - Save State | 저장 진행 및 오류
    @Published private(set) var isSaving = false
    @Published private(set) var hasSaved = false
    @Published var showsSaveError = false
    @Published private(set) var saveErrorMessage = ""

    // MARK: - Date Validation | 종료일 유효성 검사
    var isInvalidDateRange: Bool {
        guard let startDate, let endDate else { return false }
        return Calendar.current.startOfDay(for: endDate) < Calendar.current.startOfDay(for: startDate)
    }

    // MARK: - Can Save | 일정명·시작일·종료일 필수
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        startDate != nil &&
        endDate != nil &&
        !isInvalidDateRange &&
        !isSaving &&
        !hasSaved
    }

    // MARK: - Edit Item | 기존 일정의 선택 입력값까지 복원
    func apply(editingItem item: ManagedItem) {
        guard item.type == .schedule else { return }
        title = item.title
        place = item.detail
        startDate = item.startDate
        endDate = item.endDate ?? item.startDate
        timeMinutes = item.scheduleTimeMinutes
        memo = item.memo ?? ""
        imageData = item.imageData
    }

    // MARK: - Image | 이미지 변경 및 삭제
    func setImage(_ data: Data) { imageData = data }
    func removeImage() { imageData = nil }

    // MARK: - Time | 선택 시간 삭제
    func removeTime() { timeMinutes = nil }

    // MARK: - Save | UseCase를 통한 일정 저장
    func save(using useCase: SaveScheduleUseCase, editingItem: ManagedItem? = nil) -> ManagedItem? {
        guard canSave else { return nil }

        isSaving = true
        defer { isSaving = false }

        do {
            let item = try useCase.execute(
                draft: ScheduleDraft(
                    title: title,
                    place: place,
                    startDate: startDate,
                    endDate: endDate,
                    timeMinutes: timeMinutes,
                    memo: memo,
                    imageData: imageData
                ),
                editingItem: editingItem
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
