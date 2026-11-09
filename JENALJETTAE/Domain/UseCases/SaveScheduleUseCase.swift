//
//  SaveScheduleUseCase.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation

// MARK: - Save Schedule Error | 일정 검증 오류
enum SaveScheduleError: LocalizedError {
    case emptyTitle
    case missingStartDate
    case missingEndDate
    case invalidDateRange
    case invalidTime

    var errorDescription: String? {
        switch self {
        case .emptyTitle: return "일정명을 입력해주세요."
        case .missingStartDate: return "시작일을 선택해주세요."
        case .missingEndDate: return "종료일을 선택해주세요."
        case .invalidDateRange: return "종료일은 시작일보다 빠를 수 없어요."
        case .invalidTime: return "시작 시간을 확인해주세요."
        }
    }
}

// MARK: - Save Schedule UseCase | 입력 검증 후 기존 공통 저장소에 보관
@MainActor
struct SaveScheduleUseCase {
    private let repository: any ManagedItemRepository

    init(repository: any ManagedItemRepository) {
        self.repository = repository
    }

    // MARK: - Execute | 입력값 검증 및 일정 저장
    func execute(draft: ScheduleDraft) throws -> ManagedItem {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else { throw SaveScheduleError.emptyTitle }
        guard let startDate = draft.startDate else { throw SaveScheduleError.missingStartDate }
        guard let endDate = draft.endDate else { throw SaveScheduleError.missingEndDate }

        if let minutes = draft.timeMinutes, !(0..<1440).contains(minutes) {
            throw SaveScheduleError.invalidTime
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        guard end >= start else { throw SaveScheduleError.invalidDateRange }

        // MARK: - Create Item | 공통 ManagedItem 사용
        let item = ManagedItem(
            type: .schedule,
            title: title,
            detail: draft.place.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: start,
            endDate: end,
            memo: optionalText(draft.memo),
            imageData: draft.imageData,
            scheduleTimeMinutes: draft.timeMinutes
        )

        try repository.saveItem(item)
        return item
    }

    private func optionalText(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}
