//
//  ViewController.swift
//  ExampleLiveKit
//
//  Created by Bách on 26/10/2021.
//

import UIKit
import LiveKit

class ViewController: UIViewController {
    var room: Room!
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var localView: UIView!
    
    @IBOutlet weak var remoteParticipantStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        let url: String = "wss://livekit.stg.bituclub.com"
        let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzc0NjQzNzgsImlzcyI6IkFQSWtQOGEydmpaaWc5RyIsImp0aSI6IjE4MTgxOCIsIm5iZiI6MTYzNDg3MjM3OCwic3ViIjoiYmFjaGFiY2VyIiwidmlkZW8iOnsicm9vbSI6InRlc3QiLCJyb29tSm9pbiI6dHJ1ZX19.WWU_E2GJXoV_L9qqXH2rvjsZqNzkEz6WiQc5KR6Xshk"
        LiveKit.isDebug = true
        self.room = Room(connectOptions: .init(url: url, token: token), delegate: self)
        self.room.enableVideo()
    }
    
    var parView: [String: VideoView] = [:]
    
    func attachVideo(track: VideoTrack, participant: Participant, for isLocal: Bool = false) {
        DispatchQueue.main.async {
            let target: UIView! = isLocal ? self.localView : self.remoteView
            if !isLocal {
                if self.parView[participant.sid] == nil {
                    let view = VideoView()
                    
                    view.clipsToBounds = true
                    view.translatesAutoresizingMaskIntoConstraints = false
                    self.parView[participant.sid] = view
                    self.updateParViews()
                    track.addRenderer(view.rendererView)
                }
            } else {
                let view = VideoView()
                target.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.topAnchor.constraint(equalTo: target.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: target.bottomAnchor).isActive = true
                view.leadingAnchor.constraint(equalTo: target.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: target.trailingAnchor).isActive = true
                track.addRenderer(view.rendererView)
            }
        }
    }
    
    func updateParViews() {
        let views: [VideoView] = parView.map({$0.value})
        remoteParticipantStack.arrangedSubviews.forEach { v in
            v.removeFromSuperview()
        }
        let chunkedViews = views.chunked(into: 2)
        chunkedViews.forEach { views in
            if chunkedViews.count == 1 {
                views.forEach { view in
                    remoteParticipantStack.addArrangedSubview(view)
                }
            } else {
                let stack = UIStackView(arrangedSubviews: views)
                stack.axis = .horizontal
                stack.distribution = .fillEqually
                remoteParticipantStack.addArrangedSubview(stack)
            }
        }
        remoteParticipantStack.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    
    @IBAction func didTapConnect() {
        UIApplication.shared.isIdleTimerDisabled = true
        room.connect()
    }
    
    @IBAction func didTapDisconnect() {
        UIApplication.shared.isIdleTimerDisabled = false
        remoteView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        localView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        room.disconnect()
    }
    
    @IBAction func enabledVideo(_ button: UIButton) {
        guard let local = room.localParticipant else {return}
        let isEnabled = room.isEnabledVideo
        isEnabled ? room.disableVideo() : room.enableVideo()
        button.setTitle(isEnabled ? "Stop" : "Start", for: .normal)
    }
}

extension ViewController: RoomDelegate {
    func room(_ room: Room, didConnect isReconnect: Bool) {}
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribe trackPublication: RemoteTrackPublication, track: Track) {
        guard let videoTrack = track as? VideoTrack else {
            return
        }
        
        attachVideo(track: videoTrack, participant: participant)
    }
    
    func room(_ room: Room, participantDidLeave participant: RemoteParticipant) {
        if let view = self.parView[participant.sid] {
            view.removeFromSuperview()
        }
        self.parView.removeValue(forKey: participant.sid)
    }
    
    func room(_ room: Room, participant: Participant, didUpdate track: TrackPublication, muted: Bool) {
        
    }
    
    func room(_ room: Room, participant: LocalParticipant, didEnabledVideo videoTrack: LocalVideoTrack) {
        self.attachVideo(track: videoTrack, participant: participant, for: true)
    }
    
    func room(_ room: Room, participant: LocalParticipant, didDisabledVideo videoTrack: LocalVideoTrack) {
        localView.subviews.forEach { view in
            view.removeFromSuperview()
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
