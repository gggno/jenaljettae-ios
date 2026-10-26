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

    init(repository: any ManagedItemRepository) {
        self.repository = repository
        let today = Date()
        self.visibleMonth = today
        self.selectedDate = today
        self.items = repository.fetchItems()
    }

    // MARK: - Calendar Events | 선택 유형에 맞는 일정을 달력 표시용으로 변환
    var calendarEvents: [CalendarEvent] {
        typeFilteredItems.map { item in
            CalendarEvent(
                id: item.id,
                title: item.title,
                type: filterType(for: item.type),
                startDate: item.startDate,
                endDate: item.endDate ?? item.startDate
            )
        }
    }

    // MARK: - Filtered Events | 선택 날짜에 포함된 일정만 목록으로 제공
    var filteredEvents: [HomeSampleEvent] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: selectedDate)

        return typeFilteredItems.filter { item in
            let start = calendar.startOfDay(for: item.startDate)
            let end = calendar.startOfDay(for: item.endDate ?? item.startDate)
            return start <= day && day <= end
        }.map { makeHomeEvent(from: $0) }
    }

    // MARK: - Type Filter | 선택한 카테고리에 해당하는 일정만 조회
    private var typeFilteredItems: [ManagedItem] {
        items.filter { selectedType == .all || filterType(for: $0.type) == selectedType }
    }

    // MARK: - Reload | 향후 실제 저장소 변경 내역을 다시 조회할 때 사용
    func reload() {
        items = repository.fetchItems()
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

    // MARK: - Pick Date | 날짜 선택기에서 지정한 월과 날짜를 함께 변경
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
            date: item.startDate,
            type: type,
            title: item.title,
            subtitle: "\(prefix) · \(item.detail)",
            iconName: iconName,
            statusLabel: statusLabel,
            endDate: item.endDate
        )
    }
}
