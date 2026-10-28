//
//  ManagedItemEntity.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/27/26.
//

import Foundation
import SwiftData

// MARK: - Managed Item Entity | SwiftData에 저장되는 일정 데이터
@Model
final class ManagedItemEntity {
    var id: UUID
    var type: String
    var title: String
    var detail: String
    var startDate: Date
    var endDate: Date?
    var createdAt: Date

    // MARK: - Coupon Details | 쿠폰 전용 추가 정보
    var couponNumber: String?
    var memo: String?

    init(
        id: UUID = UUID(),
        type: String,
        title: String,
        detail: String = "",
        startDate: Date,
        endDate: Date? = nil,
        couponNumber: String? = nil,
        memo: String? = nil,
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
        self.createdAt = createdAt
    }
}
