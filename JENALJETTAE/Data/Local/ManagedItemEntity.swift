//
//  ManagedItemEntity.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/27/26.
//

import Foundation
import SwiftData

// MARK: - Managed Item Entity | SwiftData에 저장되는 공통 데이터
@Model
final class ManagedItemEntity {
    var id: UUID
    var type: String
    var title: String
    var detail: String
    var startDate: Date
    var endDate: Date?
    var createdAt: Date

    var couponNumber: String?
    var memo: String?

    @Attribute(.externalStorage)
    var imageData: Data?

    // MARK: - Subscription Details | 정기 구독 선택 필드
    var subscriptionCycle: String?
    var subscriptionAmount: Int?

    // MARK: - Schedule Details | 일정 시작 시간
    var scheduleTimeMinutes: Int?

    init(
        id: UUID = UUID(),
        type: String,
        title: String,
        detail: String = "",
        startDate: Date,
        endDate: Date? = nil,
        couponNumber: String? = nil,
        memo: String? = nil,
        imageData: Data? = nil,
        subscriptionCycle: String? = nil,
        subscriptionAmount: Int? = nil,
        scheduleTimeMinutes: Int? = nil,
        createdAt: Date = .now
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
        self.createdAt = createdAt
    }
}
