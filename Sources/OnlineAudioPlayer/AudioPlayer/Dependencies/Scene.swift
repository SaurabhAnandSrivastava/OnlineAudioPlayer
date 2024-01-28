//
//  Scene.swift
//  CFL
//
//  Created by synchsofthq on 24/07/21.
//

import UIKit

class Scene: NSObject {
    static func getSceneDelegate()->SceneDelegate{
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return SceneDelegate()
        }
        return sceneDelegate
    }
}
