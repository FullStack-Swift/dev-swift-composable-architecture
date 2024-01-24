import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  
  app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
  
  app.migrations.add(Todo.Migration())
  
  app.migrations.add(User.Migration())
  
  app.migrations.add(UserToken.Migration())
  
  try await app.autoMigrate()
  
  // webSocket
  WebsocketClients.websocketClients = WebsocketClients(eventLoop: app.eventLoopGroup.next())
  app.webSocket("todo-list") { request, webSocket in
    webSocket.send("Connected Socket", promise: request.eventLoop.makePromise())
    WebsocketClients.websocketClients.add(WebSocketClient(id: UUID(), socket: webSocket))
    webSocket.onText { ws, text in
      WebsocketClients.websocketClients.active.forEach { client in
        client.socket.send(text, promise: request.eventLoop.makePromise())
      }
    }
  }
  
  // register routes
  try routes(app)
}
