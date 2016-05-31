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
            print("HISTORY")
            var contactsController = self.viewControllers![1] as? ConversationMessageTVC
            print("DidBlock:\(contactsController!.didBlock)")
            var historyController = self.viewControllers![0] as! MessageTableVC
        }
        else if (item == tabBar.items![1]) {
            print("CONTACTS")
//            let contactsController = self.tabBarController?.viewControllers![1] as! ConversationMessageTVC
        }
    }
    
    
    
}
