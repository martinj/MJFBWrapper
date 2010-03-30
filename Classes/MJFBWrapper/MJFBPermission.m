/*
 *
 * MJFBPermission.m
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

#import "MJFBPermission.h"


@implementation MJFBPermission
@synthesize delegate = _delegate, permissionName = _permissionName;

#pragma mark init
- (id)initWithPermissionName:(NSString *)permissionName {
	if (self = [super init]) {
		_cachedPermissionGranted = NO;
		_permissionName = [permissionName retain];
	}
	
	return self;
}

- (id)initWithPermissionName:(NSString *)permissionName delegate:(id<MJFBPermissionDelegate>)delegate {
	if (self = [self initWithPermissionName:permissionName]) {
		self.delegate = delegate;
	}
	
	return self;
}

#pragma mark delegate events
- (void)permissionGranted {
	_cachedPermissionGranted = YES;
	if (self.delegate && [self.delegate respondsToSelector:@selector(permissionGranted:)]) {
		[self.delegate permissionGranted:self];
	}
}

- (void)permissionDenied {
	_cachedPermissionGranted = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(permissionGranted:)]) {
		[self.delegate permissionGranted:self];
	}
}

- (void)permissionFailedWithError:(NSError *)error {
	if (self.delegate && [self.delegate respondsToSelector:@selector(permission:failedWithError:)]) {
		[self.delegate permission:self failedWithError:error];
	}	
}

#pragma mark Public methods
- (void)obtainPermission {
	if (_cachedPermissionGranted) {
		[self permissionGranted];
	} else {
		NSDictionary *params = [NSDictionary dictionaryWithObject:self.permissionName forKey:@"ext_perm"];
		[[FBRequest requestWithDelegate:self] call:@"Users.hasAppPermission" params:params];
	}
}

#pragma mark FBRequestDelegate
/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	[self permissionFailedWithError:error];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isEqualToString:@"1"]) {
		[self permissionGranted];
	} else {
		FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
		dialog.delegate = self;
		dialog.permission = self.permissionName;
		[dialog show];
	}	
}

#pragma mark FBDialogDelegate
/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidSucceed:(FBDialog*)dialog {
	[self permissionGranted];
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(FBDialog*)dialog {
	[self permissionDenied];
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	[self permissionFailedWithError:error];
}


#pragma mark Memory Management
- (void)dealloc {
	[_permissionName release];
	[super dealloc];
}
@end
