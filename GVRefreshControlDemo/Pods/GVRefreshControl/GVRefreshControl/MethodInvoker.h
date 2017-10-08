//
//  MethodInvoker.h
//  PullToRefreshDemo
//
//  Created by Gabriel Bezerra Valério on 07/10/17.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface MethodInvoker : NSObject

+(void)invokeVoidMethodWithMethod:(Method) method for:(id) obj;

@end
