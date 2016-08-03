//
//  CautionAnnotationView.swift
//  HighWaters
//
//  Created by James O'Connor on 8/1/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import MapKit

class CautionAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier reuseidentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseidentifier)
    
    setupAnnotationView()

    }

    private func setupAnnotationView() {
  
        self.frame.size = CGSizeMake(40, 40)
        
        let imageView = UIImageView(image: UIImage(named: "CautionIcon"))
        
        imageView.frame = self.frame
    
        self.addSubview(imageView)
    
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}