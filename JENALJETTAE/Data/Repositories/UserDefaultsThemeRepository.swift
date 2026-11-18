//
//  UserDefaultsThemeRepository.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import Foundation

// MARK: - UserDefaults Theme Repository | 화면 테마 로컬 저장
@MainActor
final class UserDefaultsThemeRepository: ThemeRepository {
    static let storageKey = "appThemeMode"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Selected Theme | 저장된 화면 테마 조회
    var selectedTheme: AppThemeMode {
        let value = defaults.string(forKey: Self.storageKey) ?? ""
        return AppThemeMode(rawValue: value) ?? .system
    }

    // MARK: - Save Theme | 화면 테마 저장
    func saveTheme(_ theme: AppThemeMode) {
        defaults.set(theme.rawValue, forKey: Self.storageKey)
    }
}

