//
//  SubscriptionDraft.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation

// MARK: - Subscription Draft | 정기 구독 등록 입력 데이터
struct SubscriptionDraft {
    var title = ""
    var cycle: SubscriptionCycle = .monthly
    var subscriptionStartDate: Date?
    var amount: Int?
    var memo = ""
    var imageData: Data?
}
