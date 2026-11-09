//
//  RegistrationEnvironment.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/28/26.
//

import SwiftUI

// MARK: - Coupon Registration | 쿠폰 저장 의존성
private struct SaveCouponUseCaseKey: EnvironmentKey {
    static var defaultValue: SaveCouponUseCase? { nil }
}

private struct CouponSavedActionKey: EnvironmentKey {
    static var defaultValue: (@MainActor (ManagedItem) -> Void)? { nil }
}

// MARK: - Pass Registration | 이용권 저장 의존성
private struct SavePassUseCaseKey: EnvironmentKey {
    static var defaultValue: SavePassUseCase? { nil }
}

private struct PassSavedActionKey: EnvironmentKey {
    static var defaultValue: (@MainActor (ManagedItem) -> Void)? { nil }
}

// MARK: - Subscription Registration | 정기 구독 저장 의존성
private struct SaveSubscriptionUseCaseKey: EnvironmentKey {
    static var defaultValue: SaveSubscriptionUseCase? { nil }
}

private struct SubscriptionSavedActionKey: EnvironmentKey {
    static var defaultValue: (@MainActor (ManagedItem) -> Void)? { nil }
}

// MARK: - Schedule Registration | 일정 저장 의존성
private struct SaveScheduleUseCaseKey: EnvironmentKey {
    static var defaultValue: SaveScheduleUseCase? { nil }
}

private struct ScheduleSavedActionKey: EnvironmentKey {
    static var defaultValue: (@MainActor (ManagedItem) -> Void)? { nil }
}

// MARK: - Registration Environment | 등록 의존성 및 저장 콜백
extension EnvironmentValues {
    var saveCouponUseCase: SaveCouponUseCase? {
        get { self[SaveCouponUseCaseKey.self] }
        set { self[SaveCouponUseCaseKey.self] = newValue }
    }

    var onCouponSaved: (@MainActor (ManagedItem) -> Void)? {
        get { self[CouponSavedActionKey.self] }
        set { self[CouponSavedActionKey.self] = newValue }
    }

    var savePassUseCase: SavePassUseCase? {
        get { self[SavePassUseCaseKey.self] }
        set { self[SavePassUseCaseKey.self] = newValue }
    }

    var onPassSaved: (@MainActor (ManagedItem) -> Void)? {
        get { self[PassSavedActionKey.self] }
        set { self[PassSavedActionKey.self] = newValue }
    }

    var saveSubscriptionUseCase: SaveSubscriptionUseCase? {
        get { self[SaveSubscriptionUseCaseKey.self] }
        set { self[SaveSubscriptionUseCaseKey.self] = newValue }
    }

    var onSubscriptionSaved: (@MainActor (ManagedItem) -> Void)? {
        get { self[SubscriptionSavedActionKey.self] }
        set { self[SubscriptionSavedActionKey.self] = newValue }
    }

    var saveScheduleUseCase: SaveScheduleUseCase? {
        get { self[SaveScheduleUseCaseKey.self] }
        set { self[SaveScheduleUseCaseKey.self] = newValue }
    }

    var onScheduleSaved: (@MainActor (ManagedItem) -> Void)? {
        get { self[ScheduleSavedActionKey.self] }
        set { self[ScheduleSavedActionKey.self] = newValue }
    }
}
