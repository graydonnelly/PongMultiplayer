//
//  Network.swift
//  Pong
//
//  Created by Isi Donnelly on 7/15/21.
//  Copyright © 2021 Go Deep Games. All rights reserved.
//

import Foundation
import SwiftSocket

let address = "66.189.22.25"
let port:Int32 = 5051

class Network {
    
    let address: String
    let port: Int32
    let client: TCPClient
    
    init(){
        self.address = "66.189.22.25"
        self.port = 5051
        self.client = TCPClient(address: self.address, port: self.port)
        
        self.connect()
    }
    
    
    func connect(){
        switch client.connect(timeout: 1) {
           case .success:
            print("success!")
           case .failure(let error):
             print("failed with error: ", error)
         }
    }
    
    
    func send(data: DataToSend) -> DataToReceive {
        
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        let errorMessage = DataToReceive(error: "There was error dumbass")
        
        switch client.send(string: jsonString){
        
            case .success:
                guard let data = client.read(1024*10, timeout: 1) else {return errorMessage}
                if let response = String(bytes: data, encoding: .utf8){
                    
                    print(response)
                    let responseString = response.data(using: .utf8)!
                    let responseStruct = try! JSONDecoder().decode(DataToReceive.self, from: responseString)
                    print(responseStruct)
                    return responseStruct
                    
                }
                
            case .failure(let error):
                print(error)
                return errorMessage
        
            }
        return errorMessage
    }
    
    
    
}

