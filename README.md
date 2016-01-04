# quick-log Atom Editor Package

Atom package to add debug statements with vars in just a few clicks, no typing.
  See the [project repo](https://github.com/mark-hahn/quick-log) on github.

*Adding debug statemnt ...*

![Add](https://cloud.githubusercontent.com/assets/811455/12099319/6a68eecc-b2dc-11e5-90af-c62d220a1795.gif)

*Running ...*

![Run](https://cloud.githubusercontent.com/assets/811455/12099318/6a60f2e4-b2dc-11e5-9c86-350e3956aea8.gif)

## Description

Quick-log works on any coffeescript or javascript source file in the Atom editor.

Quick-log adds a debug statement to your source with a single click and keypress.  The statement contains a label created from the file name and the line number of the statement. Then you may add any variable by selecting it and using the same keybinding.

When the statement is executed during debugging a line is output to stdout with a timestamp, file, line number, and any vars. Vars are shown with a lable for the var. See the section *Debug Output Format* for an example.

All debug statements can be removed, cleaning up the source, with one keypress.

## Install

Run `apm install quick-log` on the command line, or use the Atom settings page.

## Keybindings

There are two Atom commands.  `quick-log:add` (default ctrl-?) is a multi-purpose command to add debug statements and vars in the statement.  `quick-log:clean` (default ctrl-alt-?) removes all quick-log statements restoring the source to the original.

## Adding Debug Statement

Click on a line of your source code to place the cursor.  Then execute `quick-log:add`.  A new line will be created above that line with a minimal quick-log debug statement.  It will look like `qLog(99);` where 99 is the line number for the new debug statement.  That line number will be updated whenever anything changes in the source file.

Be careful to insert the new line such that the syntax is not broken and the program flow isn't disturbed.

You can edit the statement manually as long as you don't disturb the beginning of the call `qLog(`. Debug statements can be removed by just deleting the line as normal.
  
## Adding statement label and variables (optional)

Immediately after adding the debug statement you can add a label for the debug line by selecting any text on some other line of the source and executing `quick-log:add`. This will add a short statement label based on that selected text.  You can then add variables by selecting any variable in your source and executing `quick-log:add` again.

You can also add label/variables at any later time. Click on the debug statement, press `quick-log:add` to select it, and then add the label or variables as you did above.

## Debug Output Format

When debugging, each time the debug statement is executed it will write this line format to stdout.

```
10:14:23 setDim(99) width: 92 height: 130
```

`10:14:23` is a timestamp showing hour, minute, and second. `setDim(99)` is the statement label, in this case a function name, with the line number in parentheses.  ` width: 92` and `height: 130` are values with their variable name.

## Shortened Labels

The statement label and each variable label is shortened to a maximum of 8 characters.  This is done by removing all non-legal JS symbol characters and then removing all vowels, if needed.  While these can sometimes be hard to read, they are useful to identify the original labels.

## Auto-Inserted Function

If there are one or more quick-log debug statement anywhere in the source file, a function is automatically added to the bottom.  This is the definition of the `qLog` function.  If the last debug statement is removed this function definition will also be removed automatically.

## Cleaning your source file

Executing `quick-log:clean` will remove all debug statements and the auto-inserted funcion (see last topic).  This restores the source file to its original condition.

# License
quick-log is copyright Mark Hahn with the MIT license.

