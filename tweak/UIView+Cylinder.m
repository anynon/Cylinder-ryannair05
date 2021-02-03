#import "UIView+Cylinder.h"
#import <objc/runtime.h>

@implementation UIView(Cylinder)
-(BOOL)wasModifiedByCylinder
{
    NSNumber *num = objc_getAssociatedObject(self, @selector(wasModifiedByCylinder));
    return num;
}

-(void)setWasModifiedByCylinder:(BOOL)wasModifiedByCylinder
{
    NSNumber *num = (wasModifiedByCylinder ? [NSNumber numberWithBool:true] : nil);
    objc_setAssociatedObject(self, @selector(wasModifiedByCylinder), num, OBJC_ASSOCIATION_RETAIN);
}


static int lastSubPtr;
-(int)cylinderLastSubviewCount
{
    NSNumber *last = objc_getAssociatedObject(self, &lastSubPtr);
    NSNumber *current = [NSNumber numberWithInt:self.subviews.count];
    if(last == nil) {
        last = current;
    }
    objc_setAssociatedObject(self, &lastSubPtr, current, OBJC_ASSOCIATION_RETAIN);
    return last.intValue;
}

@end
