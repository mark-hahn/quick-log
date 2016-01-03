# coffee-trace Atom editor package

Add detailed trace output to the console for functions and assignment statements in coffee files with one keypress for each line of source code traced.  See project at [GitHub](https://github.com/mark-hahn/coffee-trace).

![Adding Calls](https://github.com/mark-hahn/coffee-trace/blob/master/trace.gif?raw=true)

![Log Output](https://github.com/mark-hahn/coffee-trace/blob/master/log.gif?raw=true)

# Usage
Pressing `ctrl-alt-t` (`coffee-trace:toggle`) when `->` or `=>` is selected in your coffee source file will add a debug call that wraps the function and logs that function to the console along with argument values. Pressing that key combo when the `=` of an assignment statement is selected will add a debug call that logs each assignment along with the value assigned.

Note that you don't actually have to select all of `->`, `=>`, or `=`. Clicking on them, or in the space around them, will work as well.  If you aren't in a coffee file, or you have not clicked in a proper place, then pressing the key combo will do nothing.

Multiple source files can have trace statements at the same time.  In the sample console output below you can see that the file name is shown in each trace line along with the line number.

After adding the trace calls you must reload Atom to run your package and see the trace output.

A trace log `coffee-trace.log` will be added to the folder the source file is in and will have the same contents as the console.log output.  There will be a configuration option to turn this off in a future version.

# The Trace Calls Inserted
The function trace calls and assignment trace calls inserted look like ...
    
    compressedText: (text, len, pos) ->                                    # before
    compressedText: cT("dText:text,len,pos->~78fcT") (text, len, pos) ->   # after
    
    @text = @buffer.getText()                      # before
    @text = cT("@text=~32acT") @buffer.getText()   # after
  
Each call is to the trace function `cT()`.  The string argument for that call contains three parts.  There is a shortened version of the code, e.g. `dText:text,len,pos->`, the line number `78`, and the type of call (`fcT` for functions and `acT` for assignments).

# The Trace Function Added

The trace function `cT()` is added to the bottom of the source file.  It is in javascript so that it can be a named function and called from above.  It is always the same (per version of coffee-trace).  This function prints the line in the console and then calls the wrapped function or returns the asigned value so that the code execution is unchanged by the tracing.

# The Console Output

    43.76 coffee-trace:18 (toggle:             ) [] 
    48.63 coffee-trace:31 (@buffer=            ) [TextBuffer]
    48.63 coffee-trace:32 (@text=              ) ["hello world"]
    49.76 coffee-trace:78 (dText:text,len,pos->) ["more text", 20, 10] 
    
Each trace line in the console has these parts aligned in columns.

- Time (43.76).  The seconds and hundredth's of a second of wall time.
- File name (possibly truncated) and line number (coffee-trace:31).
- Abbreviated source code (@text=). This helps remember the line and usually shows variable names.
- Trace values (["more text", 20, 10]).  An array of function argument values or one assignment value.

# Restoring Your Source Code

The key combo  `ctrl-alt-t` (`coffee-trace:toggle`) toggles the trace calls and the trace function on and off. 

- Click in one of the existing trace calls and press the key combo to remove that call. If you remove the last trace call then the trace function at the bottom of the file will also be removed. 
- If you click in the trace function itself and press the key combo then all trace calls in the file and that trace function will be removed.  This is the easy way to restore your file to it's original condition.

# License
Coffee-trace is copyrighted with the MIT license.

