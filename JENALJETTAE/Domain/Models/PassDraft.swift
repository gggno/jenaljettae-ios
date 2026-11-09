//
//  PassDraft.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import Foundation

// MARK: - Pass Draft | 이용권 등록 입력 데이터
struct PassDraft {
    var title = ""
    var place = ""
    var startDate: Date?
    var endDate: Date?
    var passNumber = ""
    var memo = ""
    var imageData: Data?
}
