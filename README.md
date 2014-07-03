QuickGrab
=========

Command line tool to take screenshots with no user interaction.

This was created for two reasons. The first is to get my hands dirty with OSX programming and the second was that there is no such tool for my aging MacBook running Snow Leopard. Specifically, I wanted to create a tool that could take a screenshot completely unattended, with perhaps a specified window id or process. A version of `screencapture` in later editions of OS X can do this, but not for OSX 10.6.8 :(

So those of you that can't or don't want to upgrade, I hope you find it useful.



Usage
=========

    usage: quickgrab [-pid <id>] [-winid <id>] [-showlist yes] [-debug yes] -file <file> 
      -pid      <id>    Process ID of application that you want to target. If there are 
                        multiple windows, the first, as ordered by the system will be captured.
      -winid    <id>    Window ID you want to capture. To get the ID use -showlist option.
      -showlist yes     Lists available windows with the Process IDs and Window IDs to use 
                        with the other options.
      -debug    yes     Enables output of debugging information.
      -file     <file>  Where to save the image.
      
      It captures the top most window of the active application unless -pid and/or -winid 
      options are supplied.
      
      
    Examples
        
    Capture the top window of active application after 2 seconds.
        
        $ sleep 2 ; ./quickgrab -file activewindow.png
        
    Taking continuous shots of top window every 2 seconds
        
        $ while true; do ./quickgrab -file topwindow.png ; sleep 2 ; done
        
    Like above but creating a new file for every shot with date/time as the filename...
        
        $ while true; do ./quickgrab -file `date "+%Y%m%d%H%M%S"`.png ; sleep 2 ; done
        
