//
//  DataManagementView.swift
//  ClimbingTracker
//
//  数据管理视图：备份和导入数据
//

import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingImportPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLarge) {
                // 数据管理卡片
                VStack(alignment: .leading, spacing: Theme.spacingMedium) {
                    Text("数据管理")
                        .font(.headline)

                    VStack(spacing: Theme.spacingMedium) {
                        Button(action: exportData) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("备份数据")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(Theme.cornerRadiusSmall)
                        }
                        .foregroundColor(.primary)

                        Button(action: { showingImportPicker = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("导入数据")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(Theme.cornerRadiusSmall)
                        }
                        .foregroundColor(.primary)
                    }

                    Text("数据默认保存在 UserDefaults（键名：climbRecordsV1）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .cardStyle()

                // 关于卡片
                VStack(alignment: .leading, spacing: Theme.spacingMedium) {
                    Text("关于")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                        HStack {
                            Text("版本")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("1.0.0")
                        }

                        Divider()

                        HStack {
                            Text("功能")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("攀岩记录与统计")
                        }
                    }
                    .font(.subheadline)
                }
                .cardStyle()

                // 使用说明卡片
                VStack(alignment: .leading, spacing: Theme.spacingMedium) {
                    Text("使用说明")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                        HelpItem(icon: "calendar", title: "日历", description: "点击日期记录攀岩活动")
                        Divider()
                        HelpItem(icon: "chart.bar.fill", title: "统计", description: "查看年度和月度攀岩统计")
                        Divider()
                        HelpItem(icon: "square.and.arrow.down", title: "备份", description: "导出数据到JSON文件")
                        Divider()
                        HelpItem(icon: "square.and.arrow.up", title: "导入", description: "从JSON文件恢复数据")
                    }
                }
                .cardStyle()
            }
            .padding(Theme.spacingLarge)
        }
        .gradientBackground()
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - 数据操作

    private func exportData() {
        guard let data = dataManager.exportData() else {
            alertMessage = "导出失败：无法生成数据"
            showingAlert = true
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let filename = "climb-record-backup-\(dateString).json"

        // 保存到临时目录
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: tempURL)

            // 使用UIActivityViewController分享文件
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                // 适配iPad
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            alertMessage = "导出失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                // 开始访问安全作用域资源
                guard url.startAccessingSecurityScopedResource() else {
                    alertMessage = "无法访问文件"
                    showingAlert = true
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }

                let data = try Data(contentsOf: url)
                try dataManager.importData(from: data)

                alertMessage = "导入成功，记录已更新"
                showingAlert = true
            } catch {
                alertMessage = "导入失败：\(error.localizedDescription)"
                showingAlert = true
            }

        case .failure(let error):
            alertMessage = "选择文件失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - 帮助项视图

struct HelpItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.spacingMedium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.primary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    DataManagementView(dataManager: DataManager.shared)
}
