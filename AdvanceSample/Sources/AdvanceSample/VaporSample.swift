import Vapor

func vaporSample() async throws {
    print("--- vaporSample start ---")
    
    let app = Application(.testing)
    defer { app.shutdown() }
    
    app.get("api", "hello") { req -> String in
        return "Hello from Vapor!"
    }
    
    app.get("api", "users", ":id") { req -> String in
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing user ID")
        }
        return "User ID: \(id)"
    }
    
    app.post("api", "users") { req -> UserResponse in
        let userReq = try req.content.decode(UserRequest.self)
        return UserResponse(id: UUID().uuidString, name: userReq.name, email: userReq.email)
    }
    
    app.grouped(LoggingMiddleware()).get("api", "protected") { req -> String in
        return "Protected resource"
    }
    
    try app.start()
    print("Vapor server started on http://localhost:\(app.http.server.address?.port ?? 8080)")
    print("Available routes:")
    print("  GET  /api/hello")
    print("  GET  /api/users/:id")
    print("  POST /api/users")
    print("  GET  /api/protected (with logging middleware)")
    
    try app.asyncShutdown()
    print("--- vaporSample end ---")
}

struct UserRequest: Content {
    let name: String
    let email: String
}

struct UserResponse: Content {
    let id: String
    let name: String
    let email: String
}

struct LoggingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        print("[Middleware] \(request.method.rawValue) \(request.url.path)")
        let response = try await next.respond(to: request)
        print("[Middleware] Response: \(response.status.code)")
        return response
    }
}
