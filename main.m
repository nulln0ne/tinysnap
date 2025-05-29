#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>

#ifdef __has_include
#  if __has_include("config.h")
#    include "config.h"
#  else
#    include "config.def.h"
#  endif
#else
#  include "config.def.h"
#endif

AXUIElementRef getFrontmostWindow() {
    AXUIElementRef sys = AXUIElementCreateSystemWide();
    AXUIElementRef app;
    if (AXUIElementCopyAttributeValue(sys, kAXFocusedApplicationAttribute, (CFTypeRef *)&app) != kAXErrorSuccess) return NULL;
    CFRelease(sys);

    AXUIElementRef win;
    if (AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute, (CFTypeRef *)&win) != kAXErrorSuccess) {
        CFRelease(app);
        return NULL;
    }
    CFRelease(app);
    return win;
}

void moveAndResize(AXUIElementRef win, CGPoint pos, CGSize size) {
    AXValueRef p = AXValueCreate(kAXValueCGPointType, &pos);
    AXValueRef s = AXValueCreate(kAXValueCGSizeType, &size);
    AXUIElementSetAttributeValue(win, kAXPositionAttribute, p);
    AXUIElementSetAttributeValue(win, kAXSizeAttribute, s);
    CFRelease(p);
    CFRelease(s);
}

void snapLeft(AXUIElementRef win) {
    NSScreen *s = [NSScreen mainScreen];
    NSRect f = [s visibleFrame];
    moveAndResize(win, (CGPoint){f.origin.x, f.origin.y}, (CGSize){f.size.width/2, f.size.height});
}

void snapRight(AXUIElementRef win) {
    NSScreen *s = [NSScreen mainScreen];
    NSRect f = [s visibleFrame];
    moveAndResize(win, (CGPoint){f.origin.x + f.size.width/2, f.origin.y}, (CGSize){f.size.width/2, f.size.height});
}

void center(AXUIElementRef win, BOOL resize) {
    NSScreen *s = [NSScreen mainScreen];
    NSRect f = [s visibleFrame];
    CGSize size = resize ? (CGSize){800, 600} : (CGSize){0, 0};
    if (!resize) {
        AXValueRef sv;
        if (AXUIElementCopyAttributeValue(win, kAXSizeAttribute, (CFTypeRef *)&sv) == kAXErrorSuccess) {
            AXValueGetValue(sv, kAXValueCGSizeType, &size);
            CFRelease(sv);
        }
    }
    CGPoint pos = (CGPoint){
        f.origin.x + (f.size.width - size.width) / 2,
        f.origin.y + (f.size.height - size.height) / 2
    };
    moveAndResize(win, pos, size);
}

void maximize(AXUIElementRef win) {
    NSRect f = [[NSScreen mainScreen] visibleFrame];
    moveAndResize(win, (CGPoint){f.origin.x, f.origin.y}, (CGSize){f.size.width, f.size.height});
}

OSStatus handler(EventHandlerCallRef next, EventRef ev, void *data) {
    EventHotKeyID id;
    GetEventParameter(ev, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(id), NULL, &id);

    AXUIElementRef win = getFrontmostWindow();
    if (!win) return noErr;

    switch (id.id) {
        case 1: snapLeft(win); break;
        case 2: snapRight(win); break;
        case 3: center(win, NO); break;
        case 4: center(win, YES); break;
        case 5: maximize(win); break;
    }

    CFRelease(win);
    return noErr;
}

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)note {
    EventTypeSpec t = { kEventClassKeyboard, kEventHotKeyPressed };
    InstallApplicationEventHandler(&handler, 1, &t, NULL, NULL);

    #define HOTKEY(id, mod, code) \
        { EventHotKeyRef r; EventHotKeyID i = {'htk0', id}; \
          RegisterEventHotKey(code, mod, i, GetApplicationEventTarget(), 0, &r); }
    HOTKEYS
    #undef HOTKEY
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        [NSApplication sharedApplication].activationPolicy = NSApplicationActivationPolicyProhibited;
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [NSApplication sharedApplication].delegate = delegate;
        [NSApplication sharedApplication];
        [NSApp run];
    }
    return 0;
}

