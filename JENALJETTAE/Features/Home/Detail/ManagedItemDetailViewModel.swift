//
//  ManagedItemDetailViewModel.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/9/26.
//

import Foundation
import Combine

// MARK: - Managed Item Detail ViewModel | ID 기준 항목 조회
@MainActor
final class ManagedItemDetailViewModel: ObservableObject {
    @Published private(set) var item: ManagedItem?
    @Published private(set) var errorMessage: String?

    private let itemID: UUID
    private let repository: any ManagedItemRepository

    init(itemID: UUID, repository: any ManagedItemRepository) {
        self.itemID = itemID
        self.repository = repository
    }

    // MARK: - Load Item | 기존 Repository를 통해 최신 데이터 조회
    func load() {
        do {
            item = try repository.fetchItems().first { $0.id == itemID }
            errorMessage = item == nil ? "항목을 찾을 수 없어요." : nil
        } catch {
            item = nil
            errorMessage = "상세 정보를 불러오지 못했어요.\n\(error.localizedDescription)"
        }
    }
}
