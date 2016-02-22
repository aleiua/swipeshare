//
//  FlowViewContoller.swift
//  SwipeShare
//
//  Created by Robbie Neuhaus on 2/20/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit
import Photos

class FlowViewController: ViewController, iCarouselDataSource, iCarouselDelegate {
    @IBOutlet var carousel : iCarousel!

    var images:NSMutableArray!
    var totalImageCountNeeded:Int!
    
    func fetchPhotos () {
        images = NSMutableArray()
        totalImageCountNeeded = 50
        self.fetchPhotoAtIndexFromEnd(0)
    }
    
    var items: [Int] = []
    var photoAsset:PHFetchResult!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        fetchPhotos()
        carousel.type = .CoverFlow
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return images.count
    }
    
    func fetchPhotoAtIndexFromEnd(index:Int) {
        let imgManager = PHImageManager.defaultManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .Opportunistic
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            
            if fetchResult.count > 0 {
                imgManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    self.images.addObject(image!)
                    if index + 1 < fetchResult.count && self.images.count < self.totalImageCountNeeded {
                        self.fetchPhotoAtIndexFromEnd(index + 1)
                    } else {
                        self.carousel.reloadData()
                    }
                })
            }
        }
    }
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var itemView: UIImageView
        if (view == nil)
        {
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:200, height:200))
            itemView.contentMode = .ScaleAspectFit
        }
        else
        {
            itemView = view as! UIImageView;
        }
        itemView.image = (self.images.objectAtIndex(index) as! UIImage)
        return itemView
    }
    
}