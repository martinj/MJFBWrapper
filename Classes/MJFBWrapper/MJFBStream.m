/*
 *
 * MJFBStream.m
 *  
 * Copyright (c) 2010, Martin Jonsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * * Neither the name of the <organization> nor the
 * names of its contributors may be used to endorse or promote products
 * derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MJFBStream.h"

@interface MJFBStream (private)
- (void)didCancel;
@end

@implementation MJFBStream
@synthesize delegate = _delegate, session = _session;

- (id)init {
	if (self = [super init]) {
		publishStreamPermission = [[MJFBPermission alloc] initWithPermissionName:@"publish_stream" delegate:self];
		cancelled = NO;
	}
	
	return self;
}

- (id)initWithDelegate:(id<MJFBStreamDelegate>)delegate {
	if (self = [self init]) {
		self.delegate = delegate;
	}
	
	return self;
}

- (id)initWithFBSession:(FBSession *)session delegate:(id<MJFBStreamDelegate>)delegate {
	if (self = [self initWithDelegate:delegate]) {
		self.session = session;
	}
	
	return self;
}

- (void)publishAttachment {
	if (self.delegate && [self.delegate respondsToSelector:@selector(stream:willPublishAttachment:)])  {
		[self.delegate stream:self willPublishAttachment:_attachment];
	}
	
	if (cancelled) {
		[self didCancel];
		return;
	}
	
	NSString *attachmentString = [_attachment buildJSONString];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:attachmentString forKey:@"attachment"];
	
	if (_attachment.message != nil) {
		[params setObject:_attachment.message forKey:@"message"];
	}

	if (_attachment.actionLink != nil) {
		[params setObject:_attachment.actionLink forKey:@"action_links"];
	}
	
	[[FBRequest requestWithDelegate:self] call:@"Stream.publish" params:params];
}

- (void)detachDelegateFromSession {
	FBSession *session = [FBSession session];
	[session.delegates removeObject:self];
}

#pragma mark delegate methods
- (void)didCancel {
	if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelAttachment:)]) {
		[self.delegate didCancelAttachment:_attachment];
	}
	
	[self release];
}

- (void)didPublish {
	if (self.delegate && [self.delegate respondsToSelector:@selector(didPublishAttachment:)]) {
		[self.delegate didPublishAttachment:_attachment];
	}
	
	[self release];
}

- (void)didFailWithError:(NSError *)error {
	if (self.delegate && [self.delegate respondsToSelector:@selector(didFailWithError:forAttachment:)]) {
		[self.delegate didFailWithError:error forAttachment:_attachment];
	}
	
	[self release];
}

#pragma mark public methods
- (void)publishAttachment:(MJFBStreamAttachment *)attachment {	
	[self retain];
	
	[_attachment release];
	_attachment = [attachment retain];
	
	if (![[FBSession session] isConnected]) {
		FBSession *session = [FBSession session];
		if ([session.delegates indexOfObject:self] == NSNotFound) {
			[session.delegates addObject:self];
		}
		FBLoginDialog *dialog = [[[FBLoginDialog alloc] init] autorelease];		
		dialog.delegate = self;
		[dialog show];
	} else {
		[publishStreamPermission obtainPermission];
	}
}

- (void)cancel {
	cancelled = YES;
}

#pragma mark FBSessionDelegate
/**
 * Called when a user has successfully logged in and begun a session.
 */
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	[self detachDelegateFromSession];
	[publishStreamPermission obtainPermission];
}

/**
 * Called when a user closes the login dialog without logging in.
 */
- (void)sessionDidNotLogin:(FBSession*)session {
	[self detachDelegateFromSession];
	[self didCancel];
}

#pragma mark FBDialogDelegate
/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	[self didFailWithError:error];
}

#pragma mark FBRequestDelegate
/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	[self didFailWithError:error];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	[self didPublish];
}

/**
 * Called when the request was cancelled.
 */
- (void)requestWasCancelled:(FBRequest*)request {
	[self didCancel];
}


#pragma mark MJFBPermissionDelegate
- (void)permissionGranted:(MJFBPermission *)permission {
	[self publishAttachment];
}

- (void)permissionDenied:(MJFBPermission *)permission {
	if (self.delegate && [self.delegate respondsToSelector:@selector(permissionDenied:)]) {
		[self.delegate permissionDenied:permission];
	}	
	
	[self release];
}

- (void)permission:(MJFBPermission *)permission failedWithError:(NSError *)error {
	[self didFailWithError:error];
}

#pragma mark Memory Management
- (void)dealloc {	
	[publishStreamPermission release];
	[_attachment release];
	[_session release];
	[super dealloc];
}
@end
