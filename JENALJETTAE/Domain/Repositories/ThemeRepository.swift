//
//  ThemeRepository.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation

// MARK: - Theme Repository | 화면 테마 조회 및 저장 인터페이스
@MainActor
protocol ThemeRepository {
    var selectedTheme: AppThemeMode { get }
    func saveTheme(_ theme: AppThemeMode)
}
