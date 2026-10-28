import Foundation

// MARK: - Sample Managed Item Repository | SwiftData 도입 전 테스트 데이터 제공
struct SampleManagedItemRepository: ManagedItemRepository {
    func fetchItems() throws -> [ManagedItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let hotelCheckOut = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return [
            ManagedItem(id: UUID(), type: .coupon, title: "아메리카노 교환권", detail: "만료일", startDate: today, endDate: nil),
            ManagedItem(id: UUID(), type: .schedule, title: "저녁 식사 일정", detail: "오후 7:00", startDate: today, endDate: nil),
            ManagedItem(id: UUID(), type: .pass, title: "헬스장 이용권", detail: "종료일", startDate: tomorrow, endDate: nil),
            ManagedItem(id: UUID(), type: .subscription, title: "음악 스트리밍 구독", detail: "예상 갱신일", startDate: tomorrow, endDate: nil),
            ManagedItem(id: UUID(), type: .schedule, title: "가족 여행 숙소 일정", detail: "7박 8일", startDate: today, endDate: hotelCheckOut)
        ]
    }
    
    // MARK: - Save & Delete | 샘플 Repository에서는 실제 저장을 지원하지 않음
    func saveItem(_ item: ManagedItem) throws {
        throw SampleRepositoryError.readOnly
    }

    func deleteItem(id: UUID) throws {
        throw SampleRepositoryError.readOnly
    }
}

private enum SampleRepositoryError: Error {
    case readOnly
}
