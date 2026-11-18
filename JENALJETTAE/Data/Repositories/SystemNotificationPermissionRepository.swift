//
//  SystemNotificationPermissionRepository.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation
import UserNotifications

// MARK: - System Notification Permission Repository | 알림 권한 조회
@MainActor
final class SystemNotificationPermissionRepository: NotificationPermissionRepository {

    func authorizationStatus() async -> NotificationPermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unknown
        }
    }
}
