// Compile this way:
//      gcc -framework cocoa -x objective-c -o quickgrab quickgrab.m
//  

#define MYLog(...) do { if (__builtin_expect(kDebuggingEnabled, 0)) { NSLog(__VA_ARGS__); } } while(0)

#import <Cocoa/Cocoa.h>

// we start with debugging off...
bool kDebuggingEnabled = NO;



// Neat NSLog like function to stdout...
// http://stackoverflow.com/a/3487392/348694
void NSPrint(NSString *format, ...) {
    va_list args;
    va_start(args, format);

    fputs([[[[NSString alloc] initWithFormat:format arguments:args] autorelease] UTF8String], stdout);
    fputs("\n", stdout);
    va_end(args);
}


void showWindowList(int pid);
void showWindowList(int pid)
{
    MYLog(@"List of windows available for capture...");
    
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    MYLog(@"Found %d windows\n", CFArrayGetCount(windowList));
    //MYLog(@"%@", windowList);   

    //Lets walk through the list
    for (NSMutableDictionary* entry in (NSArray*)windowList)
    {     
        NSString *ownerName = [entry objectForKey: (id)kCGWindowOwnerName];
        NSInteger ownerPID = [[entry objectForKey: (id)kCGWindowOwnerPID] integerValue];
        NSString *name = [entry objectForKey: (id)kCGWindowName];
        NSNumber *wnumber = [entry objectForKey: (id)kCGWindowNumber];
        NSNumber *wlevel = [entry objectForKey: (id)kCGWindowLayer];
        
        // Show all or specific app windows at 0 Level only
        if ( (pid == 0 || ownerPID  == pid ) && [wlevel integerValue] == 0) 
            NSPrint(@"App: %@, PID: %d, Window ID: %d, Window Title: %@", \
                ownerName, ownerPID, [wnumber integerValue], name);
        
    }

}

void showHelp(void);
void showHelp(void)
{
    printf("usage: quickgrab [-pid <id>] [-winid <id>] [-showlist yes] [-debug yes] -file <file> \n\
  -pid      <id>    Process ID of application that you want to target. If there are \n\
                    multiple windows, the first, as ordered by the system will be captured. \n\
  -winid    <id>    Window ID you want to capture. To get the ID use -showlist option. \n\
  -showlist yes     Lists available windows with the Process IDs and Window IDs to use \n\
                    with the other options.\n\
  -debug    yes     Enables output of debugging information. \n\
  -file     <file>  Where to save the image. \n\
\n\
  It captures the top most window of the active application unless -pid and/or -winid \n\
  options are supplied. \n\
\n \
\n \
Examples \n\
\n\
    Capture the top window of active application after 2 seconds.\n\
\n\
        $ sleep 2 ; ./quickgrab -file activewindow.png\n\
\n\
    Taking continuous shots of top window every 2 seconds\n\
\n\
        $ while true; do ./quickgrab -file topwindow.png ; sleep 2 ; done\n\
\n\
    Like above but creating a new file for every shot with date/time as the filename...\n\
\n\
        $ while true; do ./quickgrab -file `date \"+%%Y%%m%%d%%H%%M%%S\"`.png ; sleep 2 ; done\n\
");
}


void grabWindow(int winid, NSString *filename);
void grabWindow(int winid, NSString *filename)
{
    MYLog(@"Getting image of window id: %d", winid);
    
    CGImageRef cgImage = CGWindowListCreateImage(CGRectNull, \
        kCGWindowListOptionIncludingWindow, winid, kCGWindowImageDefault);    
    
    if(cgImage == NULL)
	    exit(3);
	    
	MYLog(@"Image created...");
	
    // Create a bitmap rep from the image...
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    
    // Save the file
    NSData *data = [bitmapRep representationUsingType: NSPNGFileType properties: nil];
    [data writeToFile: filename atomically: NO];
    
    CGImageRelease(cgImage);
    
    MYLog(@"Image saved to %@", filename);
}



int main(int argc, char *argv[])
{
    id pool=[NSAutoreleasePool new];
    
    // Get command line arguments    
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    NSString *fileArg  = [args stringForKey:@"file"];
    NSInteger pidArg = [args integerForKey:@"pid"];
    NSInteger widArg = [args integerForKey:@"winid"];
    BOOL listArg = [args boolForKey:@"showlist"];
    BOOL debugArg = [args boolForKey:@"debug"];

    // Enable debugging if user asks
    if ( debugArg == 1) 
    {
        kDebuggingEnabled = YES;
    }
    
    MYLog(@"%@", [[NSProcessInfo processInfo] arguments]);
    MYLog(@"Output File(fileArg)   = %@", fileArg);
    MYLog(@"Process ID(pidArg)    = %d", pidArg);
    MYLog(@"Window ID(widArg)    = %d", widArg);
    MYLog(@"Show Window List    = %d", listArg);
    MYLog(@"Enable Debugging    = %d", debugArg);
    
//     if ( listArg )
//     {
//         showWindowList(pidArg);
//         exit(0);
//     }

    // Stop, nothing to do!
    if ( fileArg == nil && !listArg)
    {
        showHelp();
        exit(1);
    }

    MYLog(@"Getting list of windows available for capture...");
    
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    MYLog(@"Found %d windows\n", CFArrayGetCount(windowList));
    //MYLog(@"%@", windowList);   

    //Lets walk through the list
    for (NSMutableDictionary* entry in (NSArray*)windowList)
    {     
        NSString *ownerName = [entry objectForKey: (id)kCGWindowOwnerName];
        NSInteger ownerPID = [[entry objectForKey: (id)kCGWindowOwnerPID] integerValue];
        NSString *name = [entry objectForKey: (id)kCGWindowName];
        NSNumber *wnumber = [entry objectForKey: (id)kCGWindowNumber];
        NSNumber *wlevel = [entry objectForKey: (id)kCGWindowLayer];
        
        // Only interested on windows at 0 level only
        if ([wlevel integerValue] == 0) 
            if ( listArg ) 
            {
                if (pidArg == 0 || ownerPID  == pidArg ) 
                    NSPrint(@"App: %@, PID: %d, Window ID: %d, Window Title: %@", \
                        ownerName, ownerPID, [wnumber integerValue], name);
        
            } 
            else 
            {
                // User didn't say so we grab the first (top most) window
                if ( pidArg == 0 && widArg == 0 )
                {
                    grabWindow([wnumber integerValue], fileArg);
                    break;
                }

                // if PID given we grab the first window of the app
                if ( ownerPID == pidArg && widArg == 0 )
                {
                    grabWindow([wnumber integerValue], fileArg);
                    break;
                } 
                
                // Finally if they gave a specific window id
                if ( widArg == [wnumber integerValue] )
                {
                    grabWindow([wnumber integerValue], fileArg);
                    break;
                } 
 
            }
    }

    [pool drain];
    return 0;
}