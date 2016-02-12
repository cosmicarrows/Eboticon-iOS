//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "EboticonIAPHelper.h"

@implementation EboticonIAPHelper

+ (EboticonIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static EboticonIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.eboticon.Eboticon.churchpack1",
                                      @"com.eboticon.Eboticon.greekpack2",
                                     // @"com.eboticon.Eboticon.customerappreciationpack1",
                                      @"com.eboticon.Eboticon.ratchpack1",
                                      @"com.eboticon.Eboticon.baepack1",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
