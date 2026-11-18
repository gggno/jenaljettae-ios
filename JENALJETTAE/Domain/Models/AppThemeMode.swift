//
//  AppThemeMode.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation

// MARK: - App Theme Mode | 화면 테마 유형
enum AppThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }
}
