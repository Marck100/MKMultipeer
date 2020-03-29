//
//  NearbyServiceBrowserDelegate.swift
//  Example
//
//  Created by Marco Pilloni on 29/03/2020.
//  Copyright © 2020 Marco Pilloni. All rights reserved.
//

import Foundation
import MultipeerConnectivity

final class NearbyServiceBrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    
    weak var parent: MKMultipeer?
    
    init(parent: MKMultipeer) {
        
        self.parent = parent
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        NSLog("%@", "foundPeer: \(peerID.displayName)")
        
        parent?.delegate?.foundPeer(peerID)
        
        NSLog("%@", "invitePeer: \(peerID.displayName)")
        
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
