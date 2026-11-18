//
//  NotificationPermissionRepository.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation

// MARK: - Notification Permission Repository | 알림 권한 조회 인터페이스
@MainActor
protocol NotificationPermissionRepository {
    func authorizationStatus() async -> NotificationPermissionStatus
}
