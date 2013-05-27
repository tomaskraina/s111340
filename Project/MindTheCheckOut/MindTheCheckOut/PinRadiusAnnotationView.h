//
//  PinRadiusAnnotationView.h
//  MindTheCheckOut
//
//  Created by Tom K on 5/27/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PinRadiusAnnotationView : MKPinAnnotationView
@property (strong, nonatomic) id<MKOverlay> radiusOverlay;
@end
