//
//  AnalyzeCouponImageUseCase.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/30/26.
//

import Foundation

// MARK: - Analyze Coupon Image UseCase | AI 이미지 분석 후 쿠폰 정보 정리
struct AnalyzeCouponImageUseCase {
    private let repository: any CouponAnalysisRepository

    init(repository: any CouponAnalysisRepository) {
        self.repository = repository
    }

    // MARK: - Execute | Repository 분석 결과에 비즈니스 규칙 적용
    func execute(imageData: Data) async throws -> CouponDraft {
        let draft = try await repository.analyze(imageData: imageData)
        return NormalizeCouponDraftUseCase().execute(draft)
    }
}
