import Foundation

// MARK: - Managed Item Repository | 저장 방식과 무관하게 항목 조회 규약 정의
protocol ManagedItemRepository {
    func fetchItems() -> [ManagedItem]
}
