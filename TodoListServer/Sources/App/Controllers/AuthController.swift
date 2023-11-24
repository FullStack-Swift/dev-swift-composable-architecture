import Vapor
import Fluent

struct UserAuthenticator: AsyncBearerAuthenticator {
  typealias User = App.User
  
  func authenticate(
    bearer: BearerAuthorization,
    for request: Request
  ) async throws {
    if bearer.token == "foo" {
//      request.auth.login(User(name: "Vapor"))
    }
  }
}

struct AuthController: RouteCollection {
  
  func boot(routes: RoutesBuilder) throws {
    
  }
  
  
  func register(req: Request) async throws -> User {
    try User.Create.validate(content: req)
    let create = try req.content.decode(User.Create.self)
    guard create.password == create.confirmPassword else {
      throw Abort(.badRequest, reason: "Passwords did not match")
    }
    let user = try User(
      name: create.name,
      email: create.email,
      passwordHash: Bcrypt.hash(create.password)
    )
    try await user.save(on: req.db)
    return user
  }
  
  func login(req: Request) async throws -> User {
//    let password = req.password
    fatalError()
  }
}
