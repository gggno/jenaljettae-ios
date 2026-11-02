//
//  AppDelegate.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/30/26.
//

import UIKit
import DeviceCheck
import FirebaseCore
import FirebaseAppCheck

// MARK: - App Check Provider | 개발 환경과 배포 환경에 따라 인증 방식 구분
final class JenalAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> FirebaseAppCheck.AppCheckProvider? {
        #if DEBUG
        return AppCheckDebugProvider(app: app)
        #else
        if DCAppAttestService.shared.isSupported {
            return AppAttestProvider(app: app)
        }
        return DeviceCheckProvider(app: app)
        #endif
    }
}

// MARK: - App Delegate | App Check 설정 후 Firebase 초기화
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppCheck.setAppCheckProviderFactory(JenalAppCheckProviderFactory())
        FirebaseApp.configure()
        return true
    }
}
