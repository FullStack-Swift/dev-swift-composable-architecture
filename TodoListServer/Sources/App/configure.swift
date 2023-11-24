import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// cache websocket
var websocketClients: WebsocketClients!

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
  websocketClients = WebsocketClients(eventLoop: app.eventLoopGroup.next())
  app.webSocket("todo-list") { request, webSocket in
    webSocket.send("Connected Socket", promise: request.eventLoop.makePromise())
    websocketClients.add(WebSocketClient(id: UUID(), socket: webSocket))
    webSocket.onText { ws, text in
      websocketClients.active.forEach { client in
        client.socket.send(text, promise: request.eventLoop.makePromise())
      }
    }
  }
  
  // register routes
  try routes(app)
}
