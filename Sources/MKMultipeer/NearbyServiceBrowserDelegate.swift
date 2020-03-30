//
//  NearbyServiceBrowserDelegate.swift
//
//
//  Created by Marco Pilloni on 29/03/2020.
//

import Foundation
import MultipeerConnectivity

final class NearbyServiceBrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    
    weak var parent: MKMultipeer?
    
    init(parent: MKMultipeer) {
        
        self.parent = parent
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        #if DEBUG
        NSLog("%@", "foundPeer: \(peerID.displayName)")
        #endif
        parent?.delegate?.foundPeer(peerID)
        
        #if DEBUG
        NSLog("%@", "invitePeer: \(peerID.displayName)")
        #endif
        browser.invitePeer(peerID, to: parent!.session, withContext: nil, timeout: 10.0)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        parent!.delegate?.lostPeer(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        
        NSLog("%@", "didNotStartBrowsingForPeers with error: \(error.localizedDescription)")
        parent!.delegate?.didFailWithError(error)
        
    }
    
}
