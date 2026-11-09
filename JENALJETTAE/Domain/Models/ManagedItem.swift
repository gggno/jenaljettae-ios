//
//  ManagedItem.swift
//  JENALJETTAE
//

import Foundation

// MARK: - Managed Item Type | 보관 항목의 유형 정의
enum ManagedItemType: String {
    case coupon
    case pass
    case subscription
    case schedule
}

// MARK: - Managed Item | 쿠폰·이용권·구독·일정을 아우르는 공통 데이터
struct ManagedItem: Identifiable {
    let id: UUID
    let type: ManagedItemType
    let title: String
    let detail: String
    let startDate: Date
    let endDate: Date?

    // MARK: - Shared Optional Details | 공통 선택 정보
    let couponNumber: String?
    let memo: String?
    let imageData: Data?

    // MARK: - Subscription Details | 정기 구독 전용 정보
    let subscriptionCycle: SubscriptionCycle?
    let subscriptionAmount: Int?

    // MARK: - Schedule Details | 시작 시간(00:00부터 분 단위)
    let scheduleTimeMinutes: Int?

    init(
        id: UUID = UUID(),
        type: ManagedItemType,
        title: String,
        detail: String = "",
        startDate: Date,
        endDate: Date? = nil,
        couponNumber: String? = nil,
        memo: String? = nil,
        imageData: Data? = nil,
        subscriptionCycle: SubscriptionCycle? = nil,
        subscriptionAmount: Int? = nil,
        scheduleTimeMinutes: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.startDate = startDate
        self.endDate = endDate
        self.couponNumber = couponNumber
        self.memo = memo
        self.imageData = imageData
        self.subscriptionCycle = subscriptionCycle
        self.subscriptionAmount = subscriptionAmount
        self.scheduleTimeMinutes = scheduleTimeMinutes
    }
}
