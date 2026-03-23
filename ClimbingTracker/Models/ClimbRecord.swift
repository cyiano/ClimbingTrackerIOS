//
//  ClimbRecord.swift
//  ClimbingTracker
//
//  攀岩记录数据模型
//

import Foundation

/// 攀岩记录结构体
struct ClimbRecord: Codable, Identifiable {
    var id: String { dateKey }
    let dateKey: String  // 格式: "YYYY-MM-DD"
    var gym: String
    var type: String
    var note: String
    var updatedAt: String

    init(dateKey: String, gym: String, type: String = "抱石", note: String = "") {
        self.dateKey = dateKey
        self.gym = gym
        self.type = type
        self.note = note
        self.updatedAt = ISO8601DateFormatter().string(from: Date())
    }
}

/// 攀岩类型枚举
enum ClimbType: String, CaseIterable {
    case bouldering = "抱石"
    case difficulty = "难度"
    case speed = "速度"
    case none = ""

    var displayName: String {
        rawValue.isEmpty ? "未选择" : rawValue
    }
}
