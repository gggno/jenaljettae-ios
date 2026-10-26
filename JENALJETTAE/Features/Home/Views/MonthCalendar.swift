//
//  MonthCalendar.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/20/26.
//

import SwiftUI
import UIKit

// MARK: - Calendar Event

struct CalendarEvent: Identifiable {
    let id: Int
    let title: String
    let type: ItemTypeFilter
    let startDate: Date
    let endDate: Date
}

private struct CalendarWeek: Identifiable {
    let dates: [Date]
    let segments: [CalendarEventSegment]
    let hiddenCounts: [Int]
    var id: Date { dates[0] }
}

private struct CalendarEventSegment: Identifiable {
    let id: Int
    let title: String
    let startColumn: Int
    let endColumn: Int
    let lane: Int
    let isMultiDay: Bool
    let continuesBefore: Bool
    let continuesAfter: Bool
}

private struct CalendarEventCandidate {
    let event: CalendarEvent
    let startColumn: Int
    let endColumn: Int
    let isMultiDay: Bool
    let continuesBefore: Bool
    let continuesAfter: Bool
}

struct MonthCalendar: View {
    let visibleMonth: Date
    let selectedDate: Date
    let today: Date
    let events: [CalendarEvent]
    let onDateSelect: (Date) -> Void
    let onMonthChange: (Date) -> Void
    let onToday: () -> Void
    let onDatePicked: (Date) -> Void

    @State private var showsDatePicker = false
    @State private var pickerYear = Calendar.current.component(.year, from: Date())
    @State private var pickerMonth = Calendar.current.component(.month, from: Date())
    
    @ScaledMetric(relativeTo: .caption2) private var dateHeaderHeight: CGFloat = 18
    @ScaledMetric(relativeTo: .caption2) private var eventBarHeight: CGFloat = 15
    @ScaledMetric(relativeTo: .caption2) private var overflowHeight: CGFloat = 11

    private let eventBarSpacing: CGFloat = 1

    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var dateCellHeight: CGFloat { dateHeaderHeight + eventBarHeight * 2 + eventBarSpacing + overflowHeight + 4 }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.timeZone = .current
        return calendar
    }

    // MARK: - Calendar Dates

    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth)) ?? visibleMonth
    }

    private var monthDates: [Date] {
        let leadingDays = calendar.component(.weekday, from: monthStart) - 1
        let numberOfDays = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        let totalDays = ((leadingDays + numberOfDays + 6) / 7) * 7
        guard let firstDate = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart) else { return [] }
        return (0..<totalDays).compactMap { calendar.date(byAdding: .day, value: $0, to: firstDate) }
    }

    private var weekRows: [CalendarWeek] {
        stride(from: 0, to: monthDates.count, by: 7).map { index in
            makeWeek(Array(monthDates[index..<index + 7]))
        }
    }

    private var selectableYears: ClosedRange<Int> {
        let year = calendar.component(.year, from: selectedDate)
        return (year - 100)...(year + 100)
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.xSmall) {
            monthHeader
                .padding(.horizontal, AppSpacing.small)

            weekdayHeader
            dateGrid
        }
        .padding(.top, AppSpacing.xxSmall)
        .padding(.bottom, AppSpacing.small)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack(spacing: 0) {
            Button {
                pickerYear = calendar.component(.year, from: visibleMonth)
                pickerMonth = calendar.component(.month, from: visibleMonth)
                showsDatePicker = true
            } label: {
                HStack(spacing: AppSpacing.xxSmall) {
                    Text(String(format: "%d년 %d월", calendar.component(.year, from: visibleMonth), calendar.component(.month, from: visibleMonth)))
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("날짜 선택")
            .popover(isPresented: $showsDatePicker, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                datePickerPopover
                    .presentationCompactAdaptation(.popover)
            }

            Spacer(minLength: 0)
            
            monthButton(icon: "ic_jnt_chevron_left", label: "이전 달", offset: -1)
            monthButton(icon: "ic_jnt_chevron_right", label: "다음 달", offset: 1)

            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                onToday()
            } label: {
                Text("오늘")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.primaryForeground)
                    .padding(.horizontal, AppSpacing.xSmall)
                    .padding(.vertical, AppSpacing.xxSmall)
                    .background(AppColor.primaryTint, in: Capsule())
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func monthButton(icon: String, label: String, offset: Int) -> some View {
        Button {
            if let newMonth = calendar.date(byAdding: .month, value: offset, to: monthStart) {
                UISelectionFeedbackGenerator().selectionChanged()
                onMonthChange(newMonth)
            }
        } label: {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Date Picker Popover

    private var datePickerPopover: some View {
        VStack(spacing: AppSpacing.xSmall) {
            HStack {
                Text("날짜 선택")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Button("취소") { showsDatePicker = false }
                    .foregroundStyle(AppColor.textSecondary)
            }

            HStack(spacing: 0) {
                Picker("월", selection: $pickerMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)월").tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .clipped()

                Picker("연도", selection: $pickerYear) {
                    ForEach(selectableYears, id: \.self) { year in
                        Text(String(format: "%d년", year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .clipped()
            }

            Button {
                applyPickedMonth()
            } label: {
                Text("이동")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColor.primary, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.small)
        .frame(width: 290)
        .background(AppColor.card)
    }

    private func applyPickedMonth() {
        guard let monthStart = calendar.date(from: DateComponents(year: pickerYear, month: pickerMonth, day: 1)),
              let days = calendar.range(of: .day, in: .month, for: monthStart) else { return }

        let day = min(calendar.component(.day, from: selectedDate), days.count)
        let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
        onDatePicked(date)
        showsDatePicker = false
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Date Grid

    private var dateGrid: some View {
        VStack(spacing: 0) {
            ForEach(weekRows) { week in
                weekRow(week)
            }
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColor.border)
                .frame(height: 0.5)
                .allowsHitTesting(false)
        }
    }

    private func weekRow(_ week: CalendarWeek) -> some View {
        GeometryReader { geometry in
            let dayWidth = geometry.size.width / 7

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(Array(week.dates.enumerated()), id: \.offset) { index, date in
                        dateCell(date, hiddenCount: week.hiddenCounts[index])
                            .frame(width: dayWidth, height: dateCellHeight)
                            .overlay(alignment: .trailing) {
                                if index < 6 {
                                    Rectangle()
                                        .fill(AppColor.border)
                                        .frame(width: 0.5)
                                }
                            }
                    }
                }

                ForEach(week.segments) { segment in
                    eventBar(segment)
                        .frame(width: dayWidth * CGFloat(segment.endColumn - segment.startColumn + 1) - 4, height: eventBarHeight)
                        .offset(
                            x: dayWidth * CGFloat(segment.startColumn) + 2,
                            y: dateHeaderHeight + CGFloat(segment.lane) * (eventBarHeight + eventBarSpacing)
                        )
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: dateCellHeight)
        .overlay(alignment: .bottom) {
            if week.id != weekRows.last?.id {
                Rectangle()
                    .fill(AppColor.border)
                    .frame(height: 0.5)
            }
        }

    }

    private func dateCell(_ date: Date, hiddenCount: Int) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDate(date, inSameDayAs: today)
        let isCurrentMonth = calendar.isDate(date, equalTo: visibleMonth, toGranularity: .month)
        let dayEvents = events.filter { event in
            calendar.startOfDay(for: event.startDate) <= calendar.startOfDay(for: date) &&
            calendar.startOfDay(for: event.endDate) >= calendar.startOfDay(for: date)
        }
        let eventTitles = dayEvents.map(\.title).joined(separator: ", ")

        return Button {
            if isCurrentMonth {
                onDateSelect(date)
            } else {
                onDatePicked(date)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColor.primary : .clear)
                        .overlay {
                            Circle()
                                .stroke(isToday && !isSelected ? AppColor.primaryForeground : .clear, lineWidth: 1.5)
                        }
                        .frame(width: 16, height: 16)

                    Text(String(calendar.component(.day, from: date)))
                        .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? AppColor.onPrimary : (isCurrentMonth ? AppColor.textPrimary : AppColor.textSecondary))
                }
                .padding(.leading, 2)
                .padding(.top, 1)

                Spacer(minLength: 0)

                if hiddenCount > 0 {
                    Text("+\(hiddenCount)개")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(AppColor.primaryForeground)
                        .lineLimit(1)
                        .frame(height: overflowHeight)
                        .padding(.leading, 4)
                        .padding(.bottom, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: dateCellHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted)), \(isToday ? "오늘, " : "")\(isSelected ? "선택됨, " : "")일정 \(dayEvents.count)건, \(eventTitles)")
    }

    private func eventBar(_ segment: CalendarEventSegment) -> some View {
        let background = segment.isMultiDay ? AppColor.primary : AppColor.primaryTint
        let foreground = segment.isMultiDay ? AppColor.onPrimary : AppColor.primaryForeground
        let leadingRadius: CGFloat = segment.continuesBefore ? 0 : 4
        let trailingRadius: CGFloat = segment.continuesAfter ? 0 : 4

        return Text(segment.title)
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(foreground)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, 0)
            .background(background, in: UnevenRoundedRectangle(
                topLeadingRadius: leadingRadius,
                bottomLeadingRadius: leadingRadius,
                bottomTrailingRadius: trailingRadius,
                topTrailingRadius: trailingRadius
            ))

    }

    // MARK: - Week Event Lanes

    private func makeWeek(_ dates: [Date]) -> CalendarWeek {
        let firstDate = calendar.startOfDay(for: dates[0])
        let lastDate = calendar.startOfDay(for: dates[6])

        let candidates: [CalendarEventCandidate] = events.compactMap { event in
            let startDate = calendar.startOfDay(for: event.startDate)
            let endDate = calendar.startOfDay(for: event.endDate)
            guard startDate <= endDate, startDate <= lastDate, endDate >= firstDate else { return nil }

            let startColumn = max(0, calendar.dateComponents([.day], from: firstDate, to: startDate).day ?? 0)
            let endColumn = min(6, calendar.dateComponents([.day], from: firstDate, to: endDate).day ?? 6)

            return CalendarEventCandidate(
                event: event,
                startColumn: startColumn,
                endColumn: endColumn,
                isMultiDay: startDate != endDate,
                continuesBefore: startDate < firstDate,
                continuesAfter: endDate > lastDate
            )
        }
        .sorted { left, right in
            if left.isMultiDay != right.isMultiDay { return left.isMultiDay }
            if left.event.startDate != right.event.startDate { return left.event.startDate < right.event.startDate }
            return left.event.id < right.event.id
        }

        var occupied = Array(repeating: Array(repeating: false, count: 7), count: 2)
        var segments: [CalendarEventSegment] = []
        var hiddenCounts = Array(repeating: 0, count: 7)

        for candidate in candidates {
            let columns = candidate.startColumn...candidate.endColumn
            if let lane = (0..<2).first(where: { lane in columns.allSatisfy { !occupied[lane][$0] } }) {
                for column in columns { occupied[lane][column] = true }
                segments.append(CalendarEventSegment(
                    id: candidate.event.id,
                    title: candidate.event.title,
                    startColumn: candidate.startColumn,
                    endColumn: candidate.endColumn,
                    lane: lane,
                    isMultiDay: candidate.isMultiDay,
                    continuesBefore: candidate.continuesBefore,
                    continuesAfter: candidate.continuesAfter
                ))
            } else {
                for column in columns { hiddenCounts[column] += 1 }
            }
        }

        return CalendarWeek(dates: dates, segments: segments, hiddenCounts: hiddenCounts)
    }
}
