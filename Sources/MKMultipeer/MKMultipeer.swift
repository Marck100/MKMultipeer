//
//  MKMultipeer.swift
//
//
//  Created by Marco Pilloni on 29/03/2020.
// 

import Foundation
import MultipeerConnectivity

public protocol MKMultipeerDelegate: class {
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
    
    var sessionDelegate: SessionDelegate!
    var nearbyServiceBrowserDelegate: NearbyServiceBrowserDelegate!
    var nearbyServiceAdvertiserDelegate: NearbyServiceAdvertiserDelegate!
    
    lazy var session: MCSession = {
        
        let delegate = SessionDelegate(parent: self)
        
        let session = MCSession(peer: me, securityIdentity: nil, encryptionPreference: encryptingPreference)
        session.delegate = sessionDelegate//self
        
        return session
        
    }()
    
    private var browser: MCNearbyServiceBrowser?
    private var advertiser: MCNearbyServiceAdvertiser?
    
    public var connectedPeers: [MCPeerID] {
        
        let peers = session.connectedPeers
        
        return peers
        
    }
    
    weak public var delegate: MKMultipeerDelegate?
    
    //MARK: LifeCycle
    
    public init(serviceType: String, encryptingPreference: MCEncryptionPreference = .required) {
        
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
        
        self.nearbyServiceBrowserDelegate = NearbyServiceBrowserDelegate(parent: self)
        
        browser = MCNearbyServiceBrowser(peer: me, serviceType: serviceType)
        browser!.delegate = nearbyServiceBrowserDelegate
        browser!.startBrowsingForPeers()
        
        NSLog("%@", "StartBrowsingForPeers")
        
    }
    
    public func join() {
        
        self.nearbyServiceAdvertiserDelegate = NearbyServiceAdvertiserDelegate(parent: self)
        
        advertiser = MCNearbyServiceAdvertiser(peer: me, discoveryInfo: nil, serviceType: serviceType)
        advertiser!.delegate = nearbyServiceAdvertiserDelegate
        advertiser!.startAdvertisingPeer()
        
        NSLog("%@", "StartAdvertisingPeer")
        
    }
    
    public func stopHosting() {
        
        browser?.stopBrowsingForPeers()
        
    }
    
    public func stopJoining() {
        
        advertiser?.stopAdvertisingPeer()
        
    }
    
    public func sendItem<T: Codable>(_ item: T, toPeers peers: [MCPeerID]) throws {
        
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(item) {
            
            do {
                
                try session.send(data, toPeers: peers, with: .reliable)
                
            } catch let error {
                
                throw(error)
                
            }
            
        }
        
    }
    
    public func receive<T: Codable>(type: T.Type, completionHandler: @escaping (T) -> Void) {
        
        NotificationCenter.default.addObserver(forName: .init("didReceiveData"), object: nil, queue: nil) { (notification) in
            
            if let data = notification.object as? Data, let item: T = try? type.decode(fromData: data) {
                
                completionHandler(item)
                
            }
            
        }
        
    }
    
}
