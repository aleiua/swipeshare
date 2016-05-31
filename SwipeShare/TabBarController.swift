//
//  TabBarController.swift
//  SwipeShare
//
//  Created by Garrett Watumull on 5/16/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Messages"
        
    }
    
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item == tabBar.items![0]) {
            
            let contactsController = self.viewControllers![1] as? ConversationMessageTVC
            let historyController = self.viewControllers![0] as! MessageTableVC

            if (contactsController?.didBlock == true) {
                print("Reloading messages in history view since someone was blocked.")
                historyController.getMessagesFromCore()
            }
        }
        else if (item == tabBar.items![1]) {
            let contactsController = self.viewControllers![1] as? ConversationMessageTVC
            contactsController!.didBlock = false
        }
    }
    
    
    
}
