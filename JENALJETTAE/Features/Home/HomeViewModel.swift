//
//  HomeViewModel.swift
//  JENALJETTAE
//

import Foundation
import Combine

// MARK: - Home ViewModel | 홈 상태·일정 조회 및 반복 구독 일정 계산
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedType: ItemTypeFilter = .all
    @Published var visibleMonth: Date
    @Published var selectedDate: Date
    @Published private(set) var items: [ManagedItem]

    private let repository: any ManagedItemRepository

    // MARK: - Init | 홈 초기 상태
    init(repository: any ManagedItemRepository) {
        self.repository = repository

        let today = Date()
        visibleMonth = today
        selectedDate = today
        items = []

        reload()
    }

    // MARK: - Calendar Events | 달력에 표시할 이벤트
    var calendarEvents: [CalendarEvent] {
        typeFilteredItems.compactMap { item in
            guard let range = displayRange(for: item, in: visibleMonth) else {
                return nil
            }

            return CalendarEvent(
                id: item.id,
                title: item.title,
                type: filterType(for: item.type),
                startDate: range.start,
                endDate: range.end
            )
        }
    }

    // MARK: - Filtered Events | 선택 날짜의 이벤트
    var filteredEvents: [HomeSampleEvent] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: selectedDate)

        return typeFilteredItems
            .filter { item in
                guard let range = displayRange(for: item, in: selectedDate) else {
                    return false
                }

                return calendar.startOfDay(for: range.start) <= day &&
                       day <= calendar.startOfDay(for: range.end)
            }
            .map { makeHomeEvent(from: $0) }
    }

    // MARK: - Type Filter | 선택 유형 필터링
    private var typeFilteredItems: [ManagedItem] {
        items.filter {
            selectedType == .all || filterType(for: $0.type) == selectedType
        }
    }

    // MARK: - Display Range | 항목 유형별 달력 날짜 계산
    private func displayRange(
        for item: ManagedItem,
        in month: Date
    ) -> (start: Date, end: Date)? {
        switch item.type {
        case .coupon, .pass:
            guard let endDate = item.endDate else { return nil }
            return (endDate, endDate)

        case .subscription:
            guard let billingDate = subscriptionBillingDate(for: item, in: month) else {
                return nil
            }
            return (billingDate, billingDate)

        case .schedule:
            return (item.startDate, item.endDate ?? item.startDate)
        }
    }

    // MARK: - Recurring Billing Date | 구독 결제일 계산
    private func subscriptionBillingDate(
        for item: ManagedItem,
        in month: Date
    ) -> Date? {
        guard let cycle = item.subscriptionCycle else { return nil }
        return cycle.billingDate(from: item.startDate, in: month)
    }

    // MARK: - Reload | SwiftData 항목 새로고침
    func reload() {
        do {
            items = try repository.fetchItems()
        } catch {
            print("일정 새로고침 실패: \(error)")
        }
    }

    // MARK: - Select Date | 날짜 선택
    func selectDate(_ date: Date) {
        selectedDate = date
    }

    // MARK: - Change Month | 월 이동
    func changeMonth(to month: Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: month)
        ) ?? month

        let days = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 28
        let day = min(calendar.component(.day, from: selectedDate), days)

        visibleMonth = monthStart
        selectedDate = calendar.date(
            byAdding: .day,
            value: day - 1,
            to: monthStart
        ) ?? monthStart
    }

    // MARK: - Move To Today | 오늘로 이동
    func moveToToday() {
        selectedDate = Date()
        visibleMonth = selectedDate
    }

    // MARK: - Pick Date | 날짜와 달력 월을 함께 변경
    func pickDate(_ date: Date) {
        selectedDate = date
        visibleMonth = date
    }

    // MARK: - Filter Type | Domain 유형을 UI 필터 유형으로 변환
    private func filterType(for type: ManagedItemType) -> ItemTypeFilter {
        switch type {
        case .coupon: return .coupon
        case .pass: return .pass
        case .subscription: return .subscription
        case .schedule: return .schedule
        }
    }

    // MARK: - Home Event | 홈 카드 정보 구성
    private func makeHomeEvent(from item: ManagedItem) -> HomeSampleEvent {
        let type = filterType(for: item.type)

        let prefix: String
        let iconName: String

        switch item.type {
        case .coupon:
            prefix = "쿠폰"
            iconName = "ic_jnt_coupon"

        case .pass:
            prefix = "이용권"
            iconName = "ic_jnt_pass"

        case .subscription:
            prefix = "구독"
            iconName = "ic_jnt_subscription"

        case .schedule:
            prefix = "일정"
            iconName = "ic_jnt_schedule"
        }

        let date = item.type == .schedule
            ? selectedDate
            : (displayRange(for: item, in: selectedDate)?.start ?? item.startDate)

        let statusLabel: String

        if (item.type == .coupon || item.type == .pass) && item.endDate != nil {
            statusLabel = "예정"
        } else if Calendar.current.isDateInToday(date) {
            statusLabel = "오늘"
        } else if Calendar.current.isDateInTomorrow(date) {
            statusLabel = "내일"
        } else {
            statusLabel = "예정"
        }

        let subtitle: String

        if item.type == .subscription {
            let cost = item.subscriptionAmount.map { "\($0.formatted())원" }

            subtitle = (
                [prefix, item.subscriptionCycle?.title, cost]
                    .compactMap { $0 }
            ).joined(separator: " · ")

        } else if item.type == .schedule {
            var parts = [prefix]

            if let minutes = item.scheduleTimeMinutes {
                parts.append(
                    String(format: "%02d:%02d", minutes / 60, minutes % 60)
                )
            }

            if !item.detail.isEmpty {
                parts.append(item.detail)
            }

            subtitle = parts.joined(separator: " · ")
        } else {
            subtitle = item.detail.isEmpty
                ? prefix
                : "\(prefix) · \(item.detail)"
        }

        return HomeSampleEvent(
            id: item.id,
            date: date,
            type: type,
            title: item.title,
            subtitle: subtitle,
            iconName: iconName,
            statusLabel: statusLabel,
            endDate: item.type == .schedule ? item.endDate : nil
        )
    }
}
