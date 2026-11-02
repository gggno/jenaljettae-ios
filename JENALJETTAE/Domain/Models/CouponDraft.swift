//
//  CouponDraft.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/30/26.
//

import Foundation

// MARK: - Coupon Draft | Gemini가 추출한 저장 전 쿠폰 정보
struct CouponDraft: Sendable {
    var title: String?
    var brand: String?
    var expiryDate: Date?
    var couponNumber: String?
    var reviewNotes: [String] = []
}
