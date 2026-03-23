//
//  RecordFormView.swift
//  ClimbingTracker
//
//  攀岩记录表单：用于新增或编辑攀岩记录
//

import SwiftUI

struct RecordFormView: View {
    @ObservedObject var dataManager: DataManager
    let dateKey: String
    @Binding var isPresented: Bool

    @State private var gym: String = ""
    @State private var climbType: ClimbType = .bouldering
    @State private var note: String = ""
    @State private var showingDeleteAlert = false

    private var existingRecord: ClimbRecord? {
        dataManager.getRecord(for: dateKey)
    }

    private var isEditing: Bool {
        existingRecord != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("日期")) {
                    Text(dateKey)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("岩馆名称")) {
                    TextField("请输入岩馆名称", text: $gym)
                        .autocapitalization(.none)

                    // 岩馆历史建议
                    if !dataManager.getAllGyms().isEmpty {
                        Picker("历史岩馆", selection: $gym) {
                            Text("选择历史岩馆").tag("")
                            ForEach(dataManager.getAllGyms(), id: \.self) { gymName in
                                Text(gymName).tag(gymName)
                            }
                        }
                    }
                }

                Section(header: Text("攀岩类型（可选）")) {
                    Picker("类型", selection: $climbType) {
                        ForEach(ClimbType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("备注（可选）")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }

                if isEditing {
                    Section {
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Text("删除记录")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑攀岩记录" : "新增攀岩记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(gym.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    deleteRecord()
                }
            } message: {
                Text("确定要删除这条攀岩记录吗？")
            }
            .onAppear {
                loadExistingRecord()
            }
        }
    }

    // MARK: - 数据操作

    private func loadExistingRecord() {
        if let record = existingRecord {
            gym = record.gym
            climbType = ClimbType(rawValue: record.type) ?? .bouldering
            note = record.note
        }
    }

    private func saveRecord() {
        let trimmedGym = gym.trimmingCharacters(in: .whitespaces)
        guard !trimmedGym.isEmpty else { return }

        let record = ClimbRecord(
            dateKey: dateKey,
            gym: trimmedGym,
            type: climbType.rawValue,
            note: note.trimmingCharacters(in: .whitespaces)
        )

        dataManager.saveRecord(record)
        isPresented = false
    }

    private func deleteRecord() {
        dataManager.deleteRecord(dateKey: dateKey)
        isPresented = false
    }
}

#Preview {
    RecordFormView(
        dataManager: DataManager.shared,
        dateKey: "2024-03-15",
        isPresented: .constant(true)
    )
}
