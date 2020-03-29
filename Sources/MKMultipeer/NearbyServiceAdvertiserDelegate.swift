//
//  MCNearbyServiceAdvertiserDelegate.swift
//
//
//  Created by Marco Pilloni on 29/03/2020.
//

import Foundation
import MultipeerConnectivity

final class NearbyServiceAdvertiserDelegate: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    weak var parent: MKMultipeer?
    
    init(parent: MKMultipeer) {
        
        self.parent = parent
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        NSLog("%@", "didReceiveInvitationFromPeer: \(peerID.displayName)")
        
        invitationHandler(true, parent!.session)
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
        NSLog("%@", "didNotStartAdvertisingPeer with error: \(error.localizedDescription)")
        parent!.delegate?.didFailWithError(error)
        
    }
    
}
