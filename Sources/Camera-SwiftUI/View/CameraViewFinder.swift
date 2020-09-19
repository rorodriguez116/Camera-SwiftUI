//
//  CameraViewController.swift
//  Campus
//
//  Created by Rolando Rodriguez on 12/17/19.
//  Copyright © 2019 Rolando Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftUI

public struct CameraPreviewer: UIViewRepresentable {
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer
    private var size: CGSize
    
    public init(previewLayer: AVCaptureVideoPreviewLayer, size: CGSize) {
        self.videoPreviewLayer = previewLayer
        self.size = size
    }
    
    public func makeUIView(context: Context) -> UIView {
        let viewFinder = UIView()
        viewFinder.frame.size = CGSize(width: size.width, height: size.height)
        //        Adds videoPreviewLayer to the PreviewView layer herarchy
        self.videoPreviewLayer.frame.size = viewFinder.bounds.size
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        viewFinder.layer.addSublayer(videoPreviewLayer)
        
        return viewFinder
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

public struct CameraFocusView: UIViewRepresentable {
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer
    private let focusAction: (CGPoint) -> ()
    private var focusView: UIView

    public init(previewLayer: AVCaptureVideoPreviewLayer, onTapAction: @escaping (CGPoint) -> ()) {
        self.focusAction = onTapAction
        self.focusView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.videoPreviewLayer = previewLayer
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 1.5
        focusView.layer.cornerRadius = 25
        focusView.layer.opacity = 0
        focusView.backgroundColor = .clear
    }
    
    public func makeCoordinator() -> CameraFocusView.Coordinator {
        Coordinator(videoPreviewLayer: self.videoPreviewLayer, focusAction: self.focusAction, focusView: self.focusView)
    }
    
    public func makeUIView(context: Context) -> UIView {
        let viewFinder = UIView()
        viewFinder.backgroundColor = UIColor.clear
        let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.focusAndExposeTap(gestureRecognizer:)))
        viewFinder.addGestureRecognizer(gRecognizer)
        viewFinder.layer.insertSublayer(focusView.layer, at: 0)
        
        return viewFinder
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
        
    public class Coordinator: NSObject {
        private var videoPreviewLayer: AVCaptureVideoPreviewLayer
        private var focusAction: (CGPoint) -> ()
        private var focusView: UIView

        init(videoPreviewLayer: AVCaptureVideoPreviewLayer, focusAction: @escaping (CGPoint) -> (), focusView: UIView) {
            self.videoPreviewLayer = videoPreviewLayer
            self.focusAction = focusAction
            self.focusView = focusView
            super.init()
        }
        
        @objc func focusAndExposeTap(gestureRecognizer: UITapGestureRecognizer) {
            let layerPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: layerPoint)
            
            self.focusView.layer.frame = CGRect(origin: layerPoint, size: CGSize(width: 50, height: 50))
            self.focusAction(devicePoint)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.focusView.layer.opacity = 1
            }) { (completed) in
                if completed {
                    UIView.animate(withDuration: 0.3) {
                        self.focusView.layer.opacity = 0
                    }
                }
            }
        }
    }
}
