//
//  SelectedDateEventsView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/22/26.
//

import SwiftUI

// MARK: - Selected Date Events

struct SelectedDateEventsView: View {
    let selectedDate: Date
    let events: [HomeSampleEvent]
    let onEventTap: () -> Void

    private var selectedDateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Text(selectedDateTitle)
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Text("\(events.count)건")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }

            if events.isEmpty {
                Text("이 날짜에는 일정이 없어요")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxLarge)
            } else {
                ForEach(events) { event in
                    ItemCard(
                        title: event.title,
                        subtitle: event.subtitle,
                        iconName: event.iconName,
                        statusLabel: event.statusLabel,
                        statusTone: Calendar.current.isDateInToday(event.date) ? .attention : .neutral
                    ) {
                        onEventTap()
                    }
                }
            }
        }
    }
}

// MARK: - Sample Event

struct HomeSampleEvent: Identifiable {
    let id: UUID
    let date: Date
    let type: ItemTypeFilter
    let title: String
    let subtitle: String
    let iconName: String
    let statusLabel: String
    var endDate: Date? = nil
}
