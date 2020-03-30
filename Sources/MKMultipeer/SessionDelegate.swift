//
//  SessionDelegate.swift
//
//  Created by Marco Pilloni on 29/03/2020.
//
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
        #if DEBUG
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
        #endif
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        #if DEBUG
        NSLog("%@", "didReceiveData")
        #endif
        NotificationCenter.default.post(name: .init("didReceiveData"), object: data)
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
        #if DEBUG
        NSLog("%@", "didReceiveStreamWithName: \(streamName)")
        #endif
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        #if DEBUG
        NSLog("%@", "didStartReceivingResourceWithName: \(resourceName)")
        #endif
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        #if DEBUG
        NSLog("%@", "didFinishReceivingResourceWithName: \(resourceName)")
        #endif
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        #if DEBUG
        NSLog("%@", "didReceiveCertificate from peer: \(peerID.displayName)")
        #endif
        certificateHandler(true)
        
    }
    
}
