//
//  LRRestyResponse.h
//  LRResty
//
//  Created by Luke Redpath on 03/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LRRestyRequest;

/**
 * Represents a response for a single LRRestyRequest; will typically be used
 * in response handler blocks or delegate objects implementing LRRestyClientResponseDelegate.
 */
@interface LRRestyResponse : NSObject {
  NSUInteger status;
  NSData *responseData;
  NSDictionary *headers;
  NSDictionary *cookies;
}
/**
 * Returns the raw response data.
 */
@property (nonatomic, readonly) NSData *responseData;

- (id)initWithStatus:(NSInteger)statusCode responseData:(NSData *)data headers:(NSDictionary *)theHeaders originalRequest:(LRRestyRequest *)originalRequest;
/**
 * The HTTP status code.
 */
- (NSUInteger)status;
/**
 * Attempts to return a string representation of the response body.
 */
- (NSString *)asString;
/**
 * Returns the named cookie.
 */
- (NSHTTPCookie *)cookieNamed:(NSString *)name;
/**
 * Returns the value for the named header.
 */
- (NSString *)valueForHeader:(NSString *)header;
/**
 * Returns the value for the named cookie.
 */
- (NSString *)valueForCookie:(NSString *)cookieName;
@end
