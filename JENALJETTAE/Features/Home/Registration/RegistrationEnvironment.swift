//
//  RegistrationEnvironment.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/28/26.
//

import SwiftUI

// MARK: - Save Coupon UseCase Key | 쿠폰 저장 기능을 하위 화면에 전달
private struct SaveCouponUseCaseKey: EnvironmentKey {
    static var defaultValue: SaveCouponUseCase? { nil }
}

// MARK: - Coupon Saved Action Key | 쿠폰 저장 완료 함수를 하위 화면에 전달
private struct CouponSavedActionKey: EnvironmentKey {
    static var defaultValue: (@MainActor (ManagedItem) -> Void)? { nil }
}

// MARK: - Registration Environment | 등록 화면에서 사용할 환경 값 정의
extension EnvironmentValues {
    var saveCouponUseCase: SaveCouponUseCase? {
        get { self[SaveCouponUseCaseKey.self] }
        set { self[SaveCouponUseCaseKey.self] = newValue }
    }

    var onCouponSaved: (@MainActor (ManagedItem) -> Void)? {
        get { self[CouponSavedActionKey.self] }
        set { self[CouponSavedActionKey.self] = newValue }
    }
}
