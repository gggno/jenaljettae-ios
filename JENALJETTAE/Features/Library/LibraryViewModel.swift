//
//  LibraryViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation
import Combine

// MARK: - Library Scope | 보관 상태 필터
enum LibraryScope: CaseIterable {
    case all
    case active
    case history

    var title: String {
        switch self {
        case .all: return "전체 항목"
        case .active: return "진행 중"
        case .history: return "지난 기록"
        }
    }
}

// MARK: - Library Sort | 보관함 정렬 기준
enum LibrarySortOrder: CaseIterable {
    case nearestDate
    case recentlyCreated
    case oldestCreated
    case nameAscending

    var title: String {
        switch self {
        case .nearestDate: return "날짜순"
        case .recentlyCreated: return "최근 등록순"
        case .oldestCreated: return "오래된 등록순"
        case .nameAscending: return "이름순"
        }
    }
}

// MARK: - Library ViewModel | 저장 항목 조회·상태·검색·정렬
@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var items: [ManagedItem] = []
    @Published private(set) var errorMessage: String?
    @Published var selectedScope: LibraryScope = .all
    @Published var selectedType: ManagedItemType?
    @Published var searchText = ""
    @Published var sortOrder: LibrarySortOrder = .nearestDate

    private let repository: any ManagedItemRepository
    private let calendar = Calendar.current

    init(repository: any ManagedItemRepository) {
        self.repository = repository
        reload()
    }

    // MARK: - Counts | 보관 현황 숫자
    var totalCount: Int { items.count }
    var activeCount: Int { items.filter { !isArchived($0) }.count }
    var historyCount: Int { items.filter { isArchived($0) }.count }

    // MARK: - Filtered Items | 상태·유형·검색어·정렬을 함께 적용
    var filteredItems: [ManagedItem] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return items.filter { item in
            let scopeMatches: Bool
            switch selectedScope {
            case .all: scopeMatches = true
            case .active: scopeMatches = !isArchived(item)
            case .history: scopeMatches = isArchived(item)
            }
            let typeMatches = selectedType == nil || selectedType == item.type
            let searchMatches = keyword.isEmpty || [item.title, item.detail, item.couponNumber ?? "", item.memo ?? ""]
                .contains { $0.localizedCaseInsensitiveContains(keyword) }
            return scopeMatches && typeMatches && searchMatches
        }.sorted { lhs, rhs in
            switch sortOrder {
            case .recentlyCreated:
                // 실제 등록 시각이 있는 항목 우선, 예전 항목(nil)은 아래로 정렬
                switch (lhs.createdAt, rhs.createdAt) {
                case let (left?, right?):
                    if left != right { return left > right }
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): break
                }
            case .oldestCreated:
                // 등록일이 확인되는 항목은 오래된 순서로, 등록일이 없는 항목은 뒤로 정렬
                switch (lhs.createdAt, rhs.createdAt) {
                case let (left?, right?):
                    if left != right { return left < right }
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): break
                }
            case .nameAscending:
                // 이름순은 아래 공통 가나다순 비교를 사용
                break
            case .nearestDate:
                let lhsArchived = isArchived(lhs)
                let rhsArchived = isArchived(rhs)
                if lhsArchived != rhsArchived { return !lhsArchived }
                let leftDate = relevantDate(for: lhs)
                let rightDate = relevantDate(for: rhs)
                if leftDate != rightDate { return lhsArchived ? leftDate > rightDate : leftDate < rightDate }
            }
            return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
    }

    // MARK: - Reload | SwiftData 저장 항목 갱신
    func reload() {
        do {
            items = try repository.fetchItems()
            errorMessage = nil
        } catch {
            items = []
            errorMessage = error.localizedDescription
            print("보관함 새로고침 실패: \(error)")
        }
    }

    // MARK: - Archived State | 종료일 다음 날부터 지난 기록
    func isArchived(_ item: ManagedItem) -> Bool {
        let today = calendar.startOfDay(for: Date())
        switch item.type {
        case .coupon, .pass, .schedule:
            return calendar.startOfDay(for: item.endDate ?? item.startDate) < today
        case .subscription:
            return false // 현재 모델에는 구독 해지·종료 상태가 없음
        }
    }

    // MARK: - Status | 기존 상세 화면의 D-day·진행 상태 규칙
    func status(for item: ManagedItem) -> String {
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: item.startDate)
        let end = calendar.startOfDay(for: item.endDate ?? item.startDate)

        switch item.type {
        case .coupon:
            return end < today ? "만료" : dDay(to: end)
        case .pass, .schedule:
            if start > today { return dDay(to: start) }
            return end < today ? "종료" : "진행중"
        case .subscription:
            if start > today { return dDay(to: start) }
            if start == today { return "오늘 구독 시작" }
            if let billingDate = nextBillingDate(for: item), calendar.isDate(billingDate, inSameDayAs: today) { return "오늘 갱신 예정" }
            return "구독중"
        }
    }

    // MARK: - Row Subtitle | 유형별 핵심 날짜 정보
    func subtitle(for item: ManagedItem) -> String {
        switch item.type {
        case .coupon:
            return "쿠폰 · \(shortDate(item.endDate ?? item.startDate)) 만료"
        case .pass:
            return "이용권 · \(shortDate(item.endDate ?? item.startDate)) 종료"
        case .subscription:
            let today = calendar.startOfDay(for: Date())
            if calendar.startOfDay(for: item.startDate) > today { return "정기 구독 · \(shortDate(item.startDate)) 시작" }
            if let nextDate = nextBillingDate(for: item) { return "정기 구독 · 다음 결제 \(shortDate(nextDate))" }
            return "정기 구독 · \(shortDate(item.startDate)) 시작"
        case .schedule:
            let time = item.scheduleTimeMinutes.map { String(format: " %02d:%02d", $0 / 60, $0 % 60) } ?? ""
            return "일정 · \(shortDate(item.startDate))\(time)"
        }
    }

    // MARK: - Type Title | 유형 선택 메뉴용 제목
    func typeTitle(_ type: ManagedItemType) -> String {
        switch type {
        case .coupon: return "쿠폰"
        case .pass: return "이용권"
        case .subscription: return "정기 구독"
        case .schedule: return "일정"
        }
    }

    // MARK: - Relevant Date | 날짜순 목록에서 비교할 날짜
    private func relevantDate(for item: ManagedItem) -> Date {
        let today = calendar.startOfDay(for: Date())
        switch item.type {
        case .coupon, .pass:
            return item.endDate ?? item.startDate
        case .schedule:
            if calendar.startOfDay(for: item.startDate) > today { return item.startDate }
            return item.endDate ?? item.startDate
        case .subscription:
            return nextBillingDate(for: item) ?? item.startDate
        }
    }

    // MARK: - Next Billing Date | 구독 반복 결제일 계산
    private func nextBillingDate(for item: ManagedItem) -> Date? {
        let today = calendar.startOfDay(for: Date())
        if calendar.startOfDay(for: item.startDate) >= today { return item.startDate }
        return item.subscriptionCycle?.upcomingBillingDates(from: item.startDate, count: 1, referenceDate: today).first
    }

    // MARK: - Date Text | 날짜 및 D-day 표기
    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }

    private func dDay(to target: Date) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: target)).day ?? 0
        return days == 0 ? "D-DAY" : "D-\(days)"
    }
}
