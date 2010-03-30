/*
 *
 * MJFBWrapperAppDelegate.m
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

#import "MJFBWrapperAppDelegate.h"

#error ADD YOUR FACEBOOK API KEY
static NSString *kAPIKey = @"<INSERT YOUR FACEBOOK API KEY HERE AND REMOVE #error ABOVE>";
static NSString *kAPISecret = @"<INSERT YOUR FACEBOOK API SECRET HERE AND REMOVE #error ABOVE>";

@implementation MJFBWrapperAppDelegate

@synthesize window;

- (void)feedbackTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[view show];
	[view release];
}

- (MJFBStreamAttachment *)createAttachmentWithImage:(UIImage *)image {
	MJFBStreamAttachment *attachment = [[[MJFBStreamAttachment alloc]init] autorelease];
	attachment.message = @"Message";
	attachment.name = @"Name";
	attachment.description = @"Description";
	attachment.href = @"http://www.domain.com";
	attachment.caption = @"Caption";
	
	attachment.actionLink = [MJFBActionLink linkWithText:@"action" href:@"http://www.action.com"];
	
	[attachment.properties addObject:[MJFBAttachmentProperty propertyWithName:@"aName" text:@"text" href:@"http://www.text.com"]];
	
	if (image != nil) {
		[attachment.media addObject:[MJFBAttachmentImageShackMedia mediaWithImage:image]];
	}
	
	return attachment;
}

#pragma mark IBActions
- (IBAction)postToStream:(id)sender {
	FBSession *session = [FBSession sessionForApplication:kAPIKey secret:kAPISecret delegate:self];
	[session resume];
	MJFBStream *fbStream = [[MJFBStream alloc] initWithFBSession:session delegate:self];	
	[fbStream publishAttachment:[self createAttachmentWithImage:nil]];
	[fbStream release];
}

- (IBAction)postToStreamWithImage:(id)sender {
	FBSession *session = [FBSession sessionForApplication:kAPIKey secret:kAPISecret delegate:self];
	[session resume];
	MJFBStream *fbStream = [[MJFBStream alloc] initWithFBSession:session delegate:self];	
	[fbStream publishAttachment:[self createAttachmentWithImage:[UIImage imageNamed:@"image.jpg"]]];
	[fbStream release];	
}


#pragma mark MJFBStream Delegate
- (void)willPublishAttachment:(MJFBStreamAttachment *)attachment {
	NSLog(@"willPublishAttachment");
}

- (void)didPublishAttachment:(MJFBStreamAttachment *)attachment {
	[self feedbackTitle:@"Info" message:@"Successfully posted to Facebook"];
}

- (void)didCancelAttachment:(MJFBStreamAttachment *)attachment {
	[self feedbackTitle:@"Info" message:@"Post was canceled"];
}

- (void)didFailWithError:(NSError *)error forAttachment:(MJFBStreamAttachment *)attachment {
	[self feedbackTitle:@"error" message:[error localizedDescription]];
}

- (void)permissionDenied:(MJFBPermission *)permission {
	[self feedbackTitle:@"info" message:@"User didn't allow posting"];
}


- (void)session:(FBSession*)session didLogin:(FBUID)uid {}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
