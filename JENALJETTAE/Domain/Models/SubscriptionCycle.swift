//
//  SubscriptionCycle.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation

// MARK: - Subscription Cycle | 정기 구독 결제 간격
enum SubscriptionCycle: String, CaseIterable {
    case monthly
    case everyTwoMonths
    case everyThreeMonths
    case everySixMonths
    case yearly

    var title: String {
        switch self {
        case .monthly: return "매월"
        case .everyTwoMonths: return "2개월"
        case .everyThreeMonths: return "3개월"
        case .everySixMonths: return "6개월"
        case .yearly: return "매년"
        }
    }

    var intervalMonths: Int {
        switch self {
        case .monthly: return 1
        case .everyTwoMonths: return 2
        case .everyThreeMonths: return 3
        case .everySixMonths: return 6
        case .yearly: return 12
        }
    }

    // MARK: - Billing Date | 구독 시작일 기준 예상 결제일 계산
    func billingDate(from anchor: Date, in targetMonth: Date) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let anchorParts = calendar.dateComponents([.year, .month, .day], from: anchor)
        let targetParts = calendar.dateComponents([.year, .month], from: targetMonth)

        guard let anchorYear = anchorParts.year,
              let anchorMonth = anchorParts.month,
              let anchorDay = anchorParts.day,
              let targetYear = targetParts.year,
              let targetMonthNumber = targetParts.month else { return nil }

        let monthOffset = (targetYear - anchorYear) * 12 + (targetMonthNumber - anchorMonth)
        guard monthOffset >= 0, monthOffset % intervalMonths == 0 else { return nil }

        guard let firstDay = calendar.date(from: DateComponents(year: targetYear, month: targetMonthNumber, day: 1)),
              let dayRange = calendar.range(of: .day, in: .month, for: firstDay) else { return nil }

        // 1/31 → 2/28(29) → 3/31
        let billingDay = min(anchorDay, dayRange.count)

        return calendar.date(from: DateComponents(year: targetYear, month: targetMonthNumber, day: billingDay))
    }

    // MARK: - Upcoming Billing Dates | 시작일을 제외한 다음 예상 결제일
    func upcomingBillingDates(from subscriptionStartDate: Date, count: Int = 3, referenceDate: Date = Date()) -> [Date] {
        guard count > 0 else { return [] }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        guard let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: subscriptionStartDate)),
              let referenceMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) else { return [] }

        let monthOffset = calendar.dateComponents([.month], from: startMonth, to: referenceMonth).month ?? 0

        // index 0은 구독 시작일이므로 제외하고, 첫 반복 결제부터 계산
        var occurrenceIndex = max(1, (monthOffset + intervalMonths - 1) / intervalMonths)

        let referenceDay = calendar.startOfDay(for: referenceDate)
        var dates: [Date] = []

        while dates.count < count {
            guard let targetMonth = calendar.date(byAdding: .month, value: occurrenceIndex * intervalMonths, to: startMonth) else { break }

            if let date = billingDate(from: subscriptionStartDate, in: targetMonth), date >= referenceDay {
                dates.append(date)
            }

            occurrenceIndex += 1
        }

        return dates
    }
}
