/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Configures the scene.
*/

import Foundation
import ARKit

// MARK: - AR scene view extensions

extension ARSCNView {
	
	func setup() {
		antialiasingMode = .multisampling4X
		automaticallyUpdatesLighting = false
		
		preferredFramesPerSecond = 60
		contentScaleFactor = 1.3
		
		if let camera = pointOfView?.camera {
			camera.wantsHDR = true
			camera.wantsExposureAdaptation = true
			camera.exposureOffset = -1
			camera.minimumExposure = -1
			camera.maximumExposure = 3
        
            let cameraLightEnabled = UserDefaults.standard.bool(for: .cameraLight)
            if cameraLightEnabled {
                let light = SCNLight()
                light.type = .omni
                light.castsShadow = true
                pointOfView?.light = light
            }
            
            UserDefaults.standard.addObserver(self, forKeyPath: Setting.cameraLight.rawValue, options: .new, context: nil)
		}
	}
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let cameraLightEnabled = UserDefaults.standard.bool(for: .cameraLight)
        if cameraLightEnabled {
            let light = SCNLight()
            light.type = .omni
            light.castsShadow = true
            pointOfView?.light = light
        }
        else {
            pointOfView?.light = nil
        }
    }
    
    func cleanup() {
        UserDefaults.standard.removeObserver(self, forKeyPath: Setting.cameraLight.rawValue)
    }
}

// MARK: - Scene extensions

extension SCNScene {
	func enableEnvironmentMapWithIntensity(_ intensity: CGFloat, queue: DispatchQueue) {
		queue.async {
			if self.lightingEnvironment.contents == nil {
				if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
					self.lightingEnvironment.contents = environmentMap
				}
			}
			self.lightingEnvironment.intensity = intensity
		}
	}
}
