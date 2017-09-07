/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    enum SegueIdentifier: String {
        case showSettings
        case showObjects
    }
    
    // MARK: - Interface Actions
    
    @IBAction func chooseObject(_ button: UIButton) {
        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
        if isLoadingObject { return }
        
        textManager.cancelScheduledMessage(forType: .contentPlacement)
        performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: button)
    }
    
    /// - Tag: restartExperience
    @IBAction func restartExperience(_ sender: Any) {
        guard restartExperienceButtonIsEnabled, !isLoadingObject else { return }
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            
            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("STARTING A NEW SESSION")
            
            self.virtualObjectManager.removeAllVirtualObjects()
            self.addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
            self.addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
            self.focusSquare?.isHidden = true
            
            self.resetTracking()
            
            self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            // Show the focus square after a short delay to ensure all plane anchors have been deleted.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.setupFocusSquare()
            })
            
            // Disable Restart button for a while in order to give the session enough time to restart.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.restartExperienceButtonIsEnabled = true
            })
        }
    }
    
    @IBAction func changeWall(_ button: UIButton) {
        guard let object = virtualObjectManager.lastUsedObject else {
            return
        }
        
        let wall = object.childNode(withName: "ID6897", recursively: true)!
        let m = wall.geometry!.firstMaterial!
        print(m)
        /*
         <SCNMaterial: 0x1c43c1590 '_127_Britain_rustic_bricks_texture-seamless4'
         diffuse=<SCNMaterialProperty: 0x1c06c8810 | contents=file:///private/var/containers/Bundle/Application/FA340FE4-3AC7-47A9-889C-D573CE8257D0/HouseExplorer.app/Models.scnassets/house/Svends%20House/_127_Britain_rustic_bricks_texture-seamless4.jpg>
         ambient=<SCNMaterialProperty: 0x1c06c8880 | contents=UIExtendedSRGBColorSpace 0.484529 0.484529 0.484529 1>
         specular=<SCNMaterialProperty: 0x1c06c87a0 | contents=UIExtendedSRGBColorSpace 0 0 0 1>
         emission=<SCNMaterialProperty: 0x1c44cff80 | contents=UIExtendedSRGBColorSpace 0 0 0 1>
         transparent=<SCNMaterialProperty: 0x1c06c8730 | contents=UIExtendedSRGBColorSpace 1 1 1 1>
         reflective=<SCNMaterialProperty: 0x1c06c86c0 | contents=UIExtendedSRGBColorSpace 0 0 0 1>
         multiply=<SCNMaterialProperty: 0x1c06c8650 | contents=UIExtendedSRGBColorSpace 1 1 1 1>
         normal=<SCNMaterialProperty: 0x1c06c85e0 | contents=UIExtendedSRGBColorSpace 1 1 1 1>
         >
         */
     
        let url = Bundle.main.url(forResource: "Models.scnassets/house/Svends House/_104_white_metal_facade_cladding_texture-seamless", withExtension: "jpg")
        //let mp = SCNMaterialProperty(contents: url)
        m.diffuse.contents = url
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // All popover segues should be popovers even on iPhone.
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceRect = button.bounds
        }
        
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else { return }
        if segueIdentifer == .showObjects, let objectsViewController = segue.destination as? VirtualObjectSelectionViewController {
            objectsViewController.delegate = self
        }
    }
    
}
