//
//  ScheduleDraft.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import Foundation

// MARK: - Schedule Draft | 일정 등록 화면의 입력값
struct ScheduleDraft {
    var title = ""
    var place = ""
    var startDate: Date?
    var endDate: Date?
    var timeMinutes: Int?
    var memo = ""
    var imageData: Data?
}
