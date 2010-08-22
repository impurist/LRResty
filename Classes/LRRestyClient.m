//
//  LRRestyClient.m
//  LRResty
//
//  Created by Luke Redpath on 03/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "LRRestyClient.h"
#import "LRRestyResponse.h"
#import "LRRestyClientResponseDelegate.h"
#import "LRRestyRequest.h"
#import "NSDictionary+QueryString.h"
#import "LRRestyClientBlockDelegate.h"
#import "LRRestyRequestPayload.h"

@interface LRRestyClient ()
- (LRRestyRequest *)requestForURL:(NSURL *)url method:(NSString *)httpMethod payload:(id)payload headers:(NSDictionary *)headers delegate:(id<LRRestyClientResponseDelegate>)delegate;
- (void)performRequest:(LRRestyRequest *)request;
@end

#pragma mark -

@implementation LRRestyClient

@synthesize delegate = clientDelegate;

- (id)init
{
  if (self = [super init]) {
    operationQueue = [[NSOperationQueue alloc] init];    
    requestModifiers = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  Block_release(errorHandlerBlock);
  [requestModifiers release];
  [operationQueue release];
  [super dealloc];
}

#pragma mark -
#pragma mark Core API

- (void)getURL:(NSURL *)url parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers delegate:(id<LRRestyClientResponseDelegate>)delegate;
{
  LRRestyRequest *request = [self requestForURL:url method:@"GET" payload:nil headers:headers delegate:delegate];
  [request setQueryParameters:parameters];
  [self performRequest:request];
}

- (void)postURL:(NSURL *)url payload:(id)payload headers:(NSDictionary *)headers delegate:(id<LRRestyClientResponseDelegate>)delegate;
{
  [self performRequest:[self requestForURL:url method:@"POST" payload:payload headers:headers delegate:delegate]];
}

- (void)putURL:(NSURL *)url payload:(id)payload headers:(NSDictionary *)headers delegate:(id<LRRestyClientResponseDelegate>)delegate;
{
  [self performRequest:[self requestForURL:url method:@"PUT" payload:payload headers:headers delegate:delegate]];
}

#pragma mark -

- (void)attachRequestModifier:(LRRestyRequestBlock)block;
{
  [requestModifiers addObject:Block_copy(block)];
}

- (void)setHandlesCookiesAutomatically:(BOOL)shouldHandleCookies;
{
  [self attachRequestModifier:^(LRRestyRequest *request) {
    [request setHandlesCookiesAutomatically:shouldHandleCookies];
  }];
}

- (void)setUsername:(NSString *)username password:(NSString *)password;
{
  [self attachRequestModifier:^(LRRestyRequest *request) {
    [request setBasicAuthUsername:username password:password];
  }];
}

- (void)setErrorHandlerBlock:(LRRestyErrorHandlerBlock)block;
{
  Block_release(errorHandlerBlock);
  errorHandlerBlock = Block_copy(block);
}

#pragma mark -
#pragma mark Private

- (LRRestyRequest *)requestForURL:(NSURL *)url method:(NSString *)httpMethod payload:(id)payload headers:(NSDictionary *)headers delegate:(id<LRRestyClientResponseDelegate>)delegate;
{
  LRRestyRequest *request = [[LRRestyRequest alloc] initWithURL:url method:httpMethod client:self delegate:delegate];
  [request setPayload:[LRRestyRequestPayloadFactory payloadFromObject:payload]];
  [request setHeaders:headers];
  return [request autorelease];
}

- (void)performRequest:(LRRestyRequest *)request;
{
  if ([clientDelegate respondsToSelector:@selector(restyClientWillPerformRequest:)] ){
    [clientDelegate restyClientWillPerformRequest:self];
  }

  [request setCompletionBlock:^{
    if ([clientDelegate respondsToSelector:@selector(restyClientDidPerformRequest:)]) {
      [clientDelegate restyClientDidPerformRequest:self];
    }
  }];
    
  for (LRRestyRequestBlock requestModifier in requestModifiers) {
    requestModifier(request);
  }
  [operationQueue addOperation:request];
}

@end

@implementation LRRestyClient (Blocks)

- (LRRestyClientBlockDelegate *)delegateForBlock:(LRRestyResponseBlock)block;
{
  return [LRRestyClientBlockDelegate delegateWithBlock:block errorHandler:errorHandlerBlock];
}

- (void)getURL:(NSURL *)url parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers withBlock:(LRRestyResponseBlock)block;
{
  [self getURL:url parameters:parameters headers:headers delegate:[self delegateForBlock:block]];
}

- (void)postURL:(NSURL *)url payload:(id)payload headers:(NSDictionary *)headers withBlock:(LRRestyResponseBlock)block;
{
  [self postURL:url payload:payload headers:headers delegate:[self delegateForBlock:block]];
}

- (void)putURL:(NSURL *)url payload:(id)payload headers:(NSDictionary *)headers withBlock:(LRRestyResponseBlock)block;
{
  [self putURL:url payload:payload headers:headers delegate:[self delegateForBlock:block]];
}

@end
