import Foundation

// MARK: - Managed Item Repository | 저장 방식과 무관하게 항목 관리 규약 정의
@MainActor
protocol ManagedItemRepository {
    func fetchItems() throws -> [ManagedItem]
    func saveItem(_ item: ManagedItem) throws
    func deleteItem(id: UUID) throws
}
