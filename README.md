This clone is written without ncurses which led to include some c code
to get the keyboard presses to work. Everything else is written in c3

When building, the c code will be complied to a static library. Then
when compiling the c3 code the library will be included.


