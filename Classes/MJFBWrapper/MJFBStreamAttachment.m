/*
 *
 * MJFBStreamAttachment.m
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

#import "MJFBStreamAttachment.h"


@implementation MJFBStreamAttachment
@synthesize message = _message, name = _name, href = _href, caption = _caption, description = _description, media = _media, properties = _properties, actionLink = _actionLink;

- (id)init {
	if (self = [super init]) {
		_media = [[NSMutableArray alloc] init];
		_properties = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (NSString *)buildJSONString {
	NSMutableArray *values = [[NSMutableArray alloc]init];
	if (_name != nil) {
		[values addObject:[NSString stringWithFormat:@"\"name\":\"%@\"", _name]];
	}

	if (_href != nil) {
		[values addObject:[NSString stringWithFormat:@"\"href\":\"%@\"", _href]];
	}

	if (_caption != nil) {
		[values addObject:[NSString stringWithFormat:@"\"caption\":\"%@\"", _caption]];
	}

	if (_description != nil) {
		[values addObject:[NSString stringWithFormat:@"\"description\":\"%@\"", _description]];
	}

	if ([_media count] > 0) {
		[values addObject:[NSString stringWithFormat:@"\"media\":[%@]", [_media componentsJoinedByString:@","]]];
	}
	if ([_properties count] > 0) {
		[values addObject:[NSString stringWithFormat:@"\"properties\":{%@}", [_properties componentsJoinedByString:@","]]];
	}
	
	NSString *json = [NSString stringWithFormat:@"{%@}", [values componentsJoinedByString:@","]];
	[values release];
	return json;
}

- (NSString *)description {
	return [self buildJSONString];
}

- (void)dealloc {
	[_actionLink release];
	[_message release];
	[_name release];
	[_href release];
	[_caption release];
	[_media release];
	[_properties release];
	[_description release];
	[super dealloc];
}
@end
