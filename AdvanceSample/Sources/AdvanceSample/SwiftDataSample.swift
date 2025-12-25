//
//  SwiftDataSample.swift
//  AdvanceSample
//
//  Created by RenYan Wei on 2025/12/24.
//

import Foundation
import SwiftData

// 1. 定义数据模型
@available(macOS 14, *)
@Model
final class ServerLog {
    var id: UUID
    var timestamp: Date
    var endpoint: String
    var responseCode: Int

    init(endpoint: String, responseCode: Int) {
        self.id = UUID()
        self.timestamp = Date()
        self.endpoint = endpoint
        self.responseCode = responseCode
    }
}

// 2. 编程式管理类（后端逻辑类）
@available(macOS 14, *)
class LogService {
    let container: ModelContainer
    let context: ModelContext

    init() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
        let databaseURL = tempDirectory.appendingPathComponent(
            "server_logs_\(UUID().uuidString).sqlite"
        )
        print("🚀 正在初始化临时数据库：\(databaseURL.path)")

        let config = ModelConfiguration(
            url: databaseURL,
            cloudKitDatabase: .none
        )

        self.container = try ModelContainer(
            for: ServerLog.self,
            configurations: config
        )
        self.context = ModelContext(container)
    }

    func logRequest(path: String, code: Int) async throws {
        let newLog = ServerLog(endpoint: path, responseCode: code)
        context.insert(newLog)
        print("log request \(newLog.id)")
        try await context.save()
    }

    func fetchRecentLogs() async throws -> [ServerLog] {
        let descriptor = FetchDescriptor<ServerLog>(sortBy: [
            SortDescriptor(\.timestamp, order: .reverse)
        ])
        return try await context.fetch(descriptor)
    }
}

@available(macOS 14, *)
public func logServicesSample() async {
    startSample(functionName: "SwiftDataSample  logServicesSample")

    do {
        let logService = try await LogService()

        print("log record request....")
        try await logService.logRequest(path: "/index", code: 200)
        try await logService.logRequest(path: "/status", code: 404)
        try await logService.logRequest(path: "/home/list", code: 200)

        let logs: [ServerLog] = try await logService.fetchRecentLogs()

        print("fetch count: \(logs.count)")

        for log in logs {
            print(
                "log: \(log.id), \(log.timestamp), \(log.endpoint),\(log.responseCode)"
            )
        }

    } catch {
        print("SwiftData LogService Error: \(error)")
    }

    endSample(functionName: "SwiftDataSample  logServicesSample")
}

// 1. 定义数据模型
@available(macOS 14, *)
@Model
final class ServiceMetrics {
    var id: UUID
    var serviceName: String
    var responseTime: Double
    var timestamp: Date

    init(serviceName: String, responseTime: Double) {
        self.id = UUID()
        self.serviceName = serviceName
        self.responseTime = responseTime
        self.timestamp = Date()
    }
}

// 2. 定义后端服务类 (使用 ModelActor 保证线程安全)
@available(macOS 14, *)
@ModelActor
actor MetricsDataService {
    // ModelActor 自动提供了 modelContext 和 modelContainer

    /// 插入一条新记录
    func recordMetric(name: String, time: Double) throws {
        let newMetric = ServiceMetrics(serviceName: name, responseTime: time)
        modelContext.insert(newMetric)
        // 后端服务建议手动 save
        try modelContext.save()
        print("Metric recorded for \(name)")
    }

    /// 查询平均响应时间
    func getAverageResponseTime(for name: String) throws -> Double {
        let predicate = #Predicate<ServiceMetrics> { $0.serviceName == name }
        let descriptor = FetchDescriptor<ServiceMetrics>(predicate: predicate)

        let results: [ServiceMetrics] = try modelContext.fetch(descriptor)
        guard !results.isEmpty else { return 0.0 }

        let total = results.reduce(0.0) { $0 + $1.responseTime }
        return total / Double(results.count)
    }

    func fetchLatestMetrics(for name: String) throws -> [ServiceMetrics] {
        // 1. 定义谓词
        let predicate = #Predicate<ServiceMetrics> { $0.serviceName == name }

        // 2. 定义排序（例如按时间倒序）
        let sort = SortDescriptor(\ServiceMetrics.timestamp, order: .reverse)

        // 3. 创建描述符（注意参数名：predicate 和 sortBy）
        let descriptor = FetchDescriptor<ServiceMetrics>(
            predicate: predicate,
            sortBy: [sort]
        )

        // 4. 执行查询
        return try modelContext.fetch(descriptor)
    }

    /// 清理旧数据
    func deleteMetrics(olderThan date: Date) throws {
        try modelContext.delete(
            model: ServiceMetrics.self,
            where: #Predicate { $0.timestamp < date }
        )
        try modelContext.save()
    }
}

@available(macOS 14, *)
public func metricsDataServiceSample() async {
    startSample(functionName: "SwiftDataSample  metricsDataServiceSample")

    // 模拟后端调用流程
    func runServerTask() async {
        do {
            // 1. 获取当前程序运行的目录
            let currentDirectory = URL(
                fileURLWithPath: FileManager.default.currentDirectoryPath
            )
            // 2. 定义数据库文件名（例如 metrics.store）
            let databaseURL = currentDirectory.appendingPathComponent(
                "Data/metrics.sqlite"
            )

            print("正在初始化数据库：\(databaseURL.path)")

            // 3. 显式配置容器路径
            //            let config = ModelConfiguration(url: databaseURL)

            let config = ModelConfiguration(isStoredInMemoryOnly: true)

            // A. 初始化容器（只需一次）
            let container = try ModelContainer(
                for: ServiceMetrics.self,
                configurations: config
            )

            // B. 初始化服务实例
            let service = MetricsDataService(modelContainer: container)

            // C. 调用写入操作
            try await service.recordMetric(name: "AuthService", time: 125.5)
            try await service.recordMetric(name: "AuthService", time: 98.2)

            // D. 调用查询操作
            let avgTime = try await service.getAverageResponseTime(
                for: "AuthService"
            )
            print("Average response time: \(avgTime)ms")

            // E. 调用清理操作
            let lastWeek = Calendar.current.date(
                byAdding: .day,
                value: -7,
                to: Date()
            )!
            try await service.deleteMetrics(olderThan: lastWeek)

        } catch {
            print("SwiftData Error: \(error)")
        }
    }

    // 启动任务
    let handler = Task {
        await runServerTask()
    }

    await handler

    endSample(functionName: "SwiftDataSample  metricsDataServiceSample")

}
