//
//  DataManager.swift
//  ClimbingTracker
//
//  数据管理器：负责数据的持久化、备份和导入
//

import Foundation
import Combine

/// 岩馆统计数据结构
struct GymStat: Identifiable {
    let id = UUID()
    let gym: String
    let count: Int
}

/// 月度趋势数据结构
struct MonthTrendStat: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

/// 数据管理器（单例模式）
class DataManager: ObservableObject {
    static let shared = DataManager()

    private let storageKey = "climbRecordsV1"

    @Published var records: [String: ClimbRecord] = [:]

    private init() {
        loadRecords()
    }

    // MARK: - 数据持久化

    /// 从UserDefaults加载记录
    func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: ClimbRecord].self, from: data) else {
            records = [:]
            return
        }
        records = decoded
    }

    /// 保存记录到UserDefaults
    func saveRecords() {
        guard let encoded = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    // MARK: - 记录操作

    /// 添加或更新记录
    func saveRecord(_ record: ClimbRecord) {
        records[record.dateKey] = record
        saveRecords()
    }

    /// 删除记录
    func deleteRecord(dateKey: String) {
        records.removeValue(forKey: dateKey)
        saveRecords()
    }

    /// 获取指定日期的记录
    func getRecord(for dateKey: String) -> ClimbRecord? {
        return records[dateKey]
    }

    // MARK: - 岩馆历史

    /// 获取所有岩馆名称（去重并排序）
    func getAllGyms() -> [String] {
        let gyms = Set(records.values.map { $0.gym })
        return gyms.sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    // MARK: - 统计功能

    /// 获取指定年份的岩馆统计
    func getYearStats(year: Int) -> [GymStat] {
        var gymCounts: [String: Int] = [:]

        for (dateKey, record) in records {
            guard let date = dateKey.toDate(), Calendar.current.component(.year, from: date) == year else {
                continue
            }
            gymCounts[record.gym, default: 0] += 1
        }

        return gymCounts.map { GymStat(gym: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    /// 获取近12个月的趋势数据
    func getMonthTrendStats() -> [MonthTrendStat] {
        let calendar = Calendar.current
        let now = Date()
        var results: [MonthTrendStat] = []

        for i in (0..<12).reversed() {
            guard let targetDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let year = calendar.component(.year, from: targetDate)
            let month = calendar.component(.month, from: targetDate)

            let count = records.filter { dateKey, _ in
                guard let date = dateKey.toDate() else { return false }
                return calendar.component(.year, from: date) == year &&
                       calendar.component(.month, from: date) == month
            }.count

            results.append(MonthTrendStat(label: "\(year)/\(month)", count: count))
        }

        return results
    }

    /// 获取指定月份的岩馆统计
    func getMonthStats(year: Int, month: Int) -> (total: Int, gyms: [GymStat]) {
        var gymCounts: [String: Int] = [:]
        var total = 0

        for (dateKey, record) in records {
            guard let date = dateKey.toDate() else { continue }
            let calendar = Calendar.current
            if calendar.component(.year, from: date) == year &&
               calendar.component(.month, from: date) == month {
                gymCounts[record.gym, default: 0] += 1
                total += 1
            }
        }

        let sortedGyms = gymCounts.map { GymStat(gym: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        return (total: total, gyms: sortedGyms)
    }

    // MARK: - 备份和导入

    /// 导出数据为JSON
    func exportData() -> Data? {
        let payload: [String: Any] = [
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
            "storageKey": storageKey,
            "records": records.mapValues { record in
                [
                    "gym": record.gym,
                    "type": record.type,
                    "note": record.note,
                    "updatedAt": record.updatedAt
                ]
            }
        ]

        return try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
    }

    /// 导入数据
    func importData(from data: Data) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "DataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "导入格式不正确"])
        }

        // 尝试解析records字段
        if let recordsDict = json["records"] as? [String: [String: String]] {
            var newRecords: [String: ClimbRecord] = [:]
            for (dateKey, recordData) in recordsDict {
                guard let gym = recordData["gym"] else { continue }
                let type = recordData["type"] ?? "抱石"
                let note = recordData["note"] ?? ""
                let updatedAt = recordData["updatedAt"] ?? ISO8601DateFormatter().string(from: Date())

                newRecords[dateKey] = ClimbRecord(
                    dateKey: dateKey,
                    gym: gym,
                    type: type,
                    note: note
                )
            }
            records = newRecords
            saveRecords()
        } else {
            throw NSError(domain: "DataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "找不到records字段"])
        }
    }
}

// MARK: - 辅助扩展

extension String {
    /// 将日期字符串（YYYY-MM-DD）转换为Date对象
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

extension Date {
    /// 将Date对象转换为日期字符串（YYYY-MM-DD）
    func toDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
