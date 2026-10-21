//
//  HomeView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

struct HomeView: View {
    @State private var showsRegistrationTypeSelection = false
    @State private var showsSampleDetail = false
    @State private var selectedType: ItemTypeFilter = .all
    @State private var visibleMonth = Date()
    @State private var selectedDate = Date()

    // MARK: - Sample Events

    private var sampleEvents: [HomeSampleEvent] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let hotelCheckOut = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return [
            HomeSampleEvent(id: 1, date: today, type: .coupon, title: "아메리카노 교환권", subtitle: "쿠폰 · 만료일", iconName: "ic_jnt_coupon", statusLabel: "오늘"),
            HomeSampleEvent(id: 2, date: today, type: .reservation, title: "저녁 식사 예약", subtitle: "예약 · 오후 7:00", iconName: "ic_jnt_reservation", statusLabel: "오늘"),
            HomeSampleEvent(id: 3, date: tomorrow, type: .pass, title: "헬스장 이용권", subtitle: "이용권 · 종료일", iconName: "ic_jnt_pass", statusLabel: "내일"),
            HomeSampleEvent(id: 4, date: tomorrow, type: .subscription, title: "음악 스트리밍 구독", subtitle: "구독 · 예상 갱신일", iconName: "ic_jnt_subscription", statusLabel: "내일"),
            HomeSampleEvent(id: 5, date: today, type: .reservation, title: "가족 여행 숙소 예약", subtitle: "예약 · 7박 8일", iconName: "ic_jnt_reservation", statusLabel: "예정", endDate: hotelCheckOut)
        ]
    }

    private var filteredEvents: [HomeSampleEvent] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: selectedDate)
        return sampleEvents.filter { event in
            let start = calendar.startOfDay(for: event.date)
            let end = calendar.startOfDay(for: event.endDate ?? event.date)
            return start <= day && day <= end && (selectedType == .all || event.type == selectedType)
        }
    }

    private var selectedDateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: selectedDate)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "홈", onAdd: { showsRegistrationTypeSelection = true })
            
            TypeFilter(selectedType: selectedType, onSelect: { selectedType = $0 })

            ScrollView {
                VStack(spacing: AppSpacing.sectionSpacing) {
                    MonthCalendar(
                        visibleMonth: visibleMonth,
                        selectedDate: selectedDate,
                        today: Date(),
                        events: sampleEvents
                            .filter { selectedType == .all || $0.type == selectedType }
                            .map { CalendarEvent(id: $0.id, title: $0.title, type: $0.type, startDate: $0.date, endDate: $0.endDate ?? $0.date) },
                        onDateSelect: { selectedDate = $0 },
                        onMonthChange: { changeMonth(to: $0) },
                        onToday: { moveToToday() },
                        onDatePicked: { date in
                            selectedDate = date
                            visibleMonth = date
                        }
                    )
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    selectedDateEvents
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                }
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.xLarge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .fullScreenCover(isPresented: $showsRegistrationTypeSelection) {
            NavigationStack {
                RegistrationTypeSelectionView()
            }
        }
        .alert("일정 상세 화면 준비 중", isPresented: $showsSampleDetail) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("현재는 UI 확인용 예시 일정이에요.")
        }
    }

    // MARK: - Selected Date Events

    private var selectedDateEvents: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Text(selectedDateTitle)
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Text("\(filteredEvents.count)건")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }

            if filteredEvents.isEmpty {
                Text("이 날짜에는 일정이 없어요")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxLarge)
            } else {
                ForEach(filteredEvents) { event in
                    ItemCard(
                        title: event.title,
                        subtitle: event.subtitle,
                        iconName: event.iconName,
                        statusLabel: event.statusLabel,
                        statusTone: Calendar.current.isDateInToday(event.date) ? .attention : .neutral
                    ) {
                        showsSampleDetail = true
                    }
                }
            }
        }
    }

    // MARK: - Calendar Actions

    private func changeMonth(to month: Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        let numberOfDays = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 28
        let day = min(calendar.component(.day, from: selectedDate), numberOfDays)

        visibleMonth = monthStart
        selectedDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
    }

    private func moveToToday() {
        let today = Date()
        visibleMonth = today
        selectedDate = today
    }
}

// MARK: - Sample Event

private struct HomeSampleEvent: Identifiable {
    let id: Int
    let date: Date
    let type: ItemTypeFilter
    let title: String
    let subtitle: String
    let iconName: String
    let statusLabel: String
    var endDate: Date? = nil
}

#Preview {
    HomeView()
}
