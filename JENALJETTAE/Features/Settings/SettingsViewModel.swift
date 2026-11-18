//
//  SettingsViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation
import Combine

// MARK: - Settings ViewModel | 설정 상태 및 변경 관리
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var selectedTheme: AppThemeMode
    @Published private(set) var notificationStatus: NotificationPermissionStatus?

    private let themeRepository: any ThemeRepository
    private let notificationPermissionRepository: any NotificationPermissionRepository

    // MARK: - Dependency Injection | Repository로 설정 상태 초기화
    init(
        themeRepository: any ThemeRepository,
        notificationPermissionRepository: any NotificationPermissionRepository
    ) {
        self.themeRepository = themeRepository
        self.notificationPermissionRepository = notificationPermissionRepository
        self.selectedTheme = themeRepository.selectedTheme
    }

    // MARK: - Theme Selection | 테마 변경 및 저장
    func selectTheme(_ theme: AppThemeMode) {
        guard selectedTheme != theme else { return }

        themeRepository.saveTheme(theme)
        selectedTheme = theme
    }

    // MARK: - Notification Status | 시스템 알림 권한 갱신
    func refreshNotificationStatus() async {
        notificationStatus = await notificationPermissionRepository.authorizationStatus()
    }

    // MARK: - Notification Status Text | 알림 권한 표시
    var notificationStatusText: String {
        guard let notificationStatus else { return "확인 중" }

        switch notificationStatus {
        case .authorized:
            return "허용됨"
        case .denied:
            return "허용 안 됨"
        case .notDetermined:
            return "미설정"
        case .unknown:
            return "확인 필요"
        }
    }

    // MARK: - App Version | 앱 버전 정보
    var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        return "v\(version)"
    }
}
