import Foundation

// MARK: - Managed Item Type | 보관 항목의 유형 정의
// Domain에는 화면의 필터나 아이콘을 넣지 않음
enum ManagedItemType {
    case coupon
    case pass
    case subscription
    case schedule
}

// MARK: - Managed Item | 쿠폰·이용권·구독·일정을 아우르는 공통 데이터
struct ManagedItem: Identifiable {
    let id: Int
    let type: ManagedItemType
    let title: String
    let detail: String
    let startDate: Date
    let endDate: Date?
}
