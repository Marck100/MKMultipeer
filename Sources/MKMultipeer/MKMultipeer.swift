//
//  MKMultipeer.swift
//  
//
//  Created by Marco Pilloni on 29/03/2020.
//

import Foundation
import MultipeerConnectivity

protocol MKMultipeerDelegate: class {
    func foundPeer(_ peer: MCPeerID)
    func lostPeer(_ peer: MCPeerID)
    func peerDidChange(_ state: MCSessionState)
    func didFailWithError(_ error: Error)
}

public final class MKMultipeer: NSObject {
    
    //MARK: Property
    
    /// Current Device's PeerID
    private let me = MCPeerID(displayName: UIDevice.current.name)
    
    private let serviceType: String
    
    /// Session's Encrypting Preference
    private let encryptingPreference: MCEncryptionPreference
    
    private var sessionDelegate: SessionDelegate!
    
    lazy internal var session: MCSession = {
        
        let session = MCSession(peer: me, securityIdentity: nil, encryptionPreference: encryptingPreference)
        session.delegate = sessionDelegate
        
        return session
        
    }()
    
    private var browser: MCNearbyServiceBrowser?
    private var advertiser: MCNearbyServiceAdvertiser?
    
    var connectedPeers: [MCPeerID] {
        
        let peers = session.connectedPeers
        
        return peers
        
    }
    
    var delegate: MKMultipeerDelegate?
    
    //MARK: LifeCycle
    
    init(serviceType: String, encryptingPreference: MCEncryptionPreference = .required) {
        
        self.serviceType = serviceType
        self.encryptingPreference = encryptingPreference
   
        super.init()
        
        self.sessionDelegate = SessionDelegate(parent: self)
        
    }
    
    deinit {
        
        stopHosting()
        stopJoining()
        
    }
    
    //MARK: Method
    
    public func host() {
        
        let delegate = NearbyServiceBrowserDelegate(parent: self)
        
        browser = MCNearbyServiceBrowser(peer: me, serviceType: serviceType)
        browser!.delegate = delegate
        browser!.startBrowsingForPeers()
        
        NSLog("%@", "StartBrowsingForPeers")
        
    }
    
    public func join() {
        
        let delegate = NearbyServiceAdvertiserDelegate(parent: self)
        
        advertiser = MCNearbyServiceAdvertiser(peer: me, discoveryInfo: nil, serviceType: serviceType)
        advertiser!.delegate = delegate
        advertiser!.startAdvertisingPeer()
        
        NSLog("%@", "StartAdvertisingPeer")
        
    }
    
    public func stopHosting() {
        
        browser?.stopBrowsingForPeers()
        
    }
    
    public func stopJoining() {
        
        advertiser?.stopAdvertisingPeer()
        
    }
    
    func sendItem<T: Codable>(_ item: T, toPeers peers: [MCPeerID]) throws {
        
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(item) {
            
            do {
                
                try session.send(data, toPeers: peers, with: .reliable)
                
            } catch let error {
                
                throw(error)
                
            }
            
        }
        
    }
    
    func receive<T: Codable>(type: T.Type, completionHandler: @escaping (T) -> Void) {
        
        NotificationCenter.default.addObserver(forName: .init("didReceiveData"), object: nil, queue: nil) { (notification) in
            
            if let data = notification.object as? Data, let item: T = try? type.decode(fromData: data) {
                
                completionHandler(item)
                
            }
            
        }
        
    }
    
}

////MARK:- MCSessionDelegate
//extension MKMultipeer: MCSessionDelegate {
//    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//
//        delegate?.peerDidChange(state)
//
//        switch state {
//        case .connected:
//            NSLog("%@", "\(peerID.displayName) connected")
//        case .connecting:
//            NSLog("%@", "\(peerID.displayName) connecting")
//        case .notConnected:
//            NSLog("%@", "\(peerID.displayName) not connected")
//        @unknown default:
//            break
//        }
//
//    }
//
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//
//        NSLog("%@", "didReceiveData")
//        NotificationCenter.default.post(name: .init("didReceiveData"), object: data)
//
//    }
//
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//
//        NSLog("%@", "didReceiveStreamWithName: \(streamName)")
//
//    }
//
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//
//        NSLog("%@", "didStartReceivingResourceWithName: \(resourceName)")
//
//    }
//
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//
//        NSLog("%@", "didFinishReceivingResourceWithName: \(resourceName)")
//
//    }
//
//    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
//
//        NSLog("%@", "didReceiveCertificate from peer: \(peerID.displayName)")
//
//        certificateHandler(true)
//
//    }
//
//}

//MARK: MCNearbyServiceBrowserDelegate
//extension MKMultipeer: MCNearbyServiceBrowserDelegate {
//
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//
//        NSLog("%@", "foundPeer: \(peerID.displayName)")
//
//        delegate?.foundPeer(peerID)
//
//        NSLog("%@", "invitePeer: \(peerID.displayName)")
//
//        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10.0)
//
//    }
//
//    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        NSLog("%@", "lostPeer: \(peerID)")
//        delegate?.lostPeer(peerID)
//    }
//
//    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
//
//        NSLog("%@", "didNotStartBrowsingForPeers with error: \(error.localizedDescription)")
//        delegate?.didFailWithError(error)
//
//    }
//
//}

//extension MKMultipeer: MCNearbyServiceAdvertiserDelegate {
//    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        
//        NSLog("%@", "didReceiveInvitationFromPeer: \(peerID.displayName)")
//        
//        invitationHandler(true, session)
//        
//    }
//    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        
//        NSLog("%@", "didNotStartAdvertisingPeer with error: \(error.localizedDescription)")
//        delegate?.didFailWithError(error)
//        
//    }
//    
//}



