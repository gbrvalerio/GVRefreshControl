//
//  MethodInvoker.m
//  PullToRefreshDemo
//
//  Created by Gabriel Bezerra Valério on 07/10/17.
//

#import "MethodInvoker.h"

@implementation MethodInvoker

+(void)invokeVoidMethodWithMethod:(Method) method for:(id) obj {
    method_invoke(obj, method);
}

@end
