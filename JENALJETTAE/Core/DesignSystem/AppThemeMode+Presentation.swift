//
//  AppThemeMode+Presentation.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import SwiftUI

// MARK: - App Theme Presentation | 화면 테마 표시 정보
extension AppThemeMode {

    // MARK: - Title | 테마 이름
    var title: String {
        switch self {
        case .system: "시스템 설정"
        case .light: "라이트 모드"
        case .dark: "다크 모드"
        }
    }

    // MARK: - Description | 테마 설명
    var description: String {
        switch self {
        case .system: "기기 설정에 따라 자동으로 변경돼요."
        case .light: "항상 밝은 화면으로 표시해요."
        case .dark: "항상 어두운 화면으로 표시해요."
        }
    }

    // MARK: - Icon | 테마별 아이콘
    var icon: String {
        switch self {
        case .system: AppIcon.system
        case .light: AppIcon.light
        case .dark: AppIcon.dark
        }
    }

    // MARK: - Color Scheme | 시스템 화면 테마 적용
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
