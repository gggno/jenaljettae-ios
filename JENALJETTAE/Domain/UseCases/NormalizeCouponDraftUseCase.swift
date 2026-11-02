//
//  NormalizeCouponDraftUseCase.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/30/26.
//

import Foundation

// MARK: - Normalize Coupon Draft UseCase | AI 추출 결과의 중복 브랜드명 정리
struct NormalizeCouponDraftUseCase {
    func execute(_ draft: CouponDraft) -> CouponDraft {
        var result = draft

        // MARK: - Product Title | 상품명 앞에 중복된 브랜드명만 제거
        if let brand = result.brand, let title = result.title, !brand.isEmpty {
            let prefix = "\(brand))"

            if title.hasPrefix(prefix) {
                let cleaned = String(title.dropFirst(prefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !cleaned.isEmpty {
                    result.title = cleaned
                }
            }
        }

        return result
    }
}
