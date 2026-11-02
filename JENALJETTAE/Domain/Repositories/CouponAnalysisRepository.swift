import Foundation

// MARK: - Coupon Analysis Repository | 분석 구현체와 무관한 Domain 계약
protocol CouponAnalysisRepository: Sendable {
    func analyze(imageData: Data) async throws -> CouponDraft
}
