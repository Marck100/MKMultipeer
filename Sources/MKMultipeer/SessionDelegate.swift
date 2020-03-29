//
//  SessionDelegate.swift
//  Example
//
//  Created by Marco Pilloni on 29/03/2020.
//  Copyright © 2020 Marco Pilloni. All rights reserved.
//

import Foundation
import MultipeerConnectivity

final class SessionDelegate: NSObject, MCSessionDelegate {
    
    weak var parent: MKMultipeer?
    
    init(parent: MKMultipeer) {
        
        self.parent = parent
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    
        parent!.delegate?.peerDidChange(state)
        
        switch state {
        case .connected:
            NSLog("%@", "\(peerID.displayName) connected")
        case .connecting:
            NSLog("%@", "\(peerID.displayName) connecting")
        case .notConnected:
            NSLog("%@", "\(peerID.displayName) not connected")
        @unknown default:
            break
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        NSLog("%@", "didReceiveData")
        NotificationCenter.default.post(name: .init("didReceiveData"), object: data)
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
        NSLog("%@", "didReceiveStreamWithName: \(streamName)")
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
        NSLog("%@", "didStartReceivingResourceWithName: \(resourceName)")
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
        NSLog("%@", "didFinishReceivingResourceWithName: \(resourceName)")
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        
        NSLog("%@", "didReceiveCertificate from peer: \(peerID.displayName)")
        
        certificateHandler(true)
        
    }
    
}
