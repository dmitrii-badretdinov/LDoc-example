# LDoc installation
For Windows, install [Lua for Windows][1], then create `ldoc.bat` and add it to PATH.  
The contents of `ldoc.bat` should be the following:
```
@echo off
lua \path\to\ldoc\ldoc.lua %*
```
After that, you will be able to get the documentation with `ldoc path\to\folder` or `ldoc path\to\file.lua`.

# Example
The example contains several files necessary for compilation:  
1. `ka_dialog.lua`: the code and in-code documentation.
2. `config.ld`: the configuration file that sets a Markdown interpreter and a custom style sheet.
3. `ldoc.css`: the custom style sheet. The only difference from the default one is the increased width.

In order to get the compiled documentation of this example, run the following in the command line: `ldoc path\to\ka_dialog.lua`.

I used the following site as the main hub of information: [LDoc documentation][2]

[1]: https://github.com/rjpcomputing/luaforwindows/releases
[2]: https://stevedonovan.github.io/ldoc/manual/doc.md.html
