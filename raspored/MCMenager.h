//
//  MCMenager.h
//  chatN
//
//  Created by Anton Orzes on 16.06.2015..
//  Copyright (c) 2015. Anton Orzes. All rights reserved.
// Multipeer Connectivity

#ifndef chatN_MCMenager_h
#define chatN_MCMenager_h


#endif
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCMenager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
