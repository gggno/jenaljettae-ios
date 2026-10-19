//
//  AppTypography.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/12/26.
//

import SwiftUI

enum AppTypography {

    // MARK: - Title
    static let screenTitle: Font = .system(.title, weight: .bold)
    static let detailTitle: Font = .system(.title2, weight: .bold)
    static let navigationTitle: Font = .system(.headline, weight: .semibold)
    static let sectionTitle: Font = .system(.headline, weight: .semibold)

    // MARK: - Content
    static let itemTitle: Font = .system(.callout, weight: .semibold)
    static let inputValue: Font = .system(.callout, weight: .regular)
    static let body: Font = .system(.subheadline, weight: .regular)
    static let button: Font = .system(.subheadline, weight: .semibold)

    // MARK: - Supporting Text
    static let label: Font = .system(.caption, weight: .medium)
    static let caption: Font = .system(.caption, weight: .regular)
    static let status: Font = .system(.caption2, weight: .semibold)

    // MARK: - Number
    static let number: Font = .system(.callout, weight: .medium).monospacedDigit()
}
