import Foundation
import Combine

// MARK: - Home ViewModel | 홈 화면 상태와 항목 조회·필터링 관리
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedType: ItemTypeFilter = .all
    @Published var visibleMonth: Date
    @Published var selectedDate: Date
    @Published private(set) var items: [ManagedItem]

    private let repository: any ManagedItemRepository

    // MARK: - Initialize | Repository에서 저장된 항목 조회 및 초기 날짜 설정
    init(repository: any ManagedItemRepository) {
        self.repository = repository

        let today = Date()
        self.visibleMonth = today
        self.selectedDate = today
        self.items = []

        do {
            items = try repository.fetchItems()
        } catch {
            print("일정 조회 실패: \(error)")
        }
    }

    // MARK: - Calendar Events | 달력에 표시할 일정 데이터 변환
    var calendarEvents: [CalendarEvent] {
        typeFilteredItems.compactMap { item in
            guard let range = displayRange(for: item) else { return nil }

            return CalendarEvent(
                id: item.id,
                title: item.title,
                type: filterType(for: item.type),
                startDate: range.start,
                endDate: range.end
            )
        }
    }

    // MARK: - Filtered Events | 선택 날짜에 해당하는 일정만 목록으로 제공
    var filteredEvents: [HomeSampleEvent] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: selectedDate)

        return typeFilteredItems.filter { item in
            guard let range = displayRange(for: item) else { return false }

            let start = calendar.startOfDay(for: range.start)
            let end = calendar.startOfDay(for: range.end)

            return start <= day && day <= end
        }.map { makeHomeEvent(from: $0) }
    }

    // MARK: - Type Filter | 선택한 카테고리에 해당하는 항목만 조회
    private var typeFilteredItems: [ManagedItem] {
        items.filter { selectedType == .all || filterType(for: $0.type) == selectedType }
    }

    // MARK: - Display Range | 쿠폰은 만료일만, 다른 항목은 기존 기간으로 표시
    private func displayRange(for item: ManagedItem) -> (start: Date, end: Date)? {
        if item.type == .coupon {
            guard let expiryDate = item.endDate else { return nil }
            return (expiryDate, expiryDate)
        }

        return (item.startDate, item.endDate ?? item.startDate)
    }

    // MARK: - Reload | Repository에서 최신 데이터를 다시 조회하여 화면 갱신
    func reload() {
        do {
            items = try repository.fetchItems()
        } catch {
            print("일정 새로고침 실패: \(error)")
        }
    }

    // MARK: - Select Date | 달력 날짜 선택 결과 반영
    func selectDate(_ date: Date) {
        selectedDate = date
    }

    // MARK: - Change Month | 기존 일자를 유지하되 이동 월의 마지막 날짜로 보정
    func changeMonth(to month: Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        let numberOfDays = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 28
        let day = min(calendar.component(.day, from: selectedDate), numberOfDays)

        visibleMonth = monthStart
        selectedDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
    }

    // MARK: - Move To Today | 달력 표시 월과 선택 날짜를 오늘로 초기화
    func moveToToday() {
        let today = Date()
        visibleMonth = today
        selectedDate = today
    }

    // MARK: - Pick Date | 날짜 선택 결과를 달력과 선택 날짜에 반영
    func pickDate(_ date: Date) {
        selectedDate = date
        visibleMonth = date
    }

    // MARK: - Type Mapping | Domain의 유형을 홈 필터 유형으로 변환
    private func filterType(for type: ManagedItemType) -> ItemTypeFilter {
        switch type {
        case .coupon: return .coupon
        case .pass: return .pass
        case .subscription: return .subscription
        case .schedule: return .schedule
        }
    }

    // MARK: - Event Mapping | 일정 데이터를 기존 카드용 표시 모델로 변환
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
            iconName = "ic_jnt_reservation"
        }

        let calendar = Calendar.current
        let statusLabel: String

        if item.endDate != nil {
            statusLabel = "예정"
        } else if calendar.isDateInToday(item.startDate) {
            statusLabel = "오늘"
        } else if calendar.isDateInTomorrow(item.startDate) {
            statusLabel = "내일"
        } else {
            statusLabel = "예정"
        }

        return HomeSampleEvent(
            id: item.id,
            date: item.type == .coupon ? (item.endDate ?? item.startDate) : item.startDate,
            type: type,
            title: item.title,
            subtitle: "\(prefix) · \(item.detail)",
            iconName: iconName,
            statusLabel: statusLabel,
            endDate: item.type == .coupon ? nil : item.endDate
        )
    }
}
