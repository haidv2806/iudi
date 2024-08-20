//
//  SocketIOManager.swift
//  ColorNoteRemake
//
//  Created by Đỗ Việt on 19/07/2023.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    
    static let shared = SocketIOManager()
    
    static let sharedInstance = SocketIOManager()
    
    let socket = SocketManager(socketURL: URL(string: "https://api.iudi.xyz")!, config: [.log(true), .compress])
    var mSocket: SocketIOClient!
    
    override init() {
        super.init()
        mSocket = socket.defaultSocket
    }
    
    func getSocket() -> SocketIOClient {
        return mSocket
    }
    
    func establishConnection() {
        mSocket.connect()
    }
    
    func closeConnection() {
        mSocket.disconnect()
    }
    
    func joinChatRoom(roomId: Int) {
        mSocket.emit("join", ["room": roomId])
    }
    
    func leaveChatRoom() {
        mSocket.emit("leave", ["room": ""])
    }
    func sendTextMessage(messageData: [String: Any]) {
        if mSocket.status == .connected {
//            let messageData: [String: Any] = [
//                "room": "1", //ví dụ 21423
//                "data": [
//                    "id": "2",
//                    "RelatedUserID": "1",
//                    "type": "text",//text/ image/icon-image/muti-image
//                    "state":"",
//    //                "content":"adeqwq"
//                    "data": "https://i.ibb.co/2MJkg5P/Screenshot-2023-05-07-142345.png"// nếu dữ liệu là loại ảnh
//                     // Nếu dữ liệu là loại text
//                ]
//            ]
            
            mSocket.emit("send_message", messageData)
        } else {
            print("Socket is not connected")
        }
    }
    func handleReceviedText(){
        mSocket.on("send_message") { data, ack in
            // Xử lý dữ liệu tin nhắn mới nhận được từ SocketIO
            // Ví dụ:
            // let newMessage = ... // Tạo đối tượng tin nhắn mới từ dữ liệu nhận được
        }
    }

}
