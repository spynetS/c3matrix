module c3matrix;
import std::io;
import std::core::mem;
import std::collections;
import std::thread;

import libc;

struct Window{
	int[<2>] pos;
 int[<2>] res;
 ZString current_color;
}

fn Window* new_window(int[<2>] pos, int[<2>] res){
	Window* window = malloc(Window.sizeof);
 window.pos = pos;
 window.res = res;
 window.current_color = (ZString) malloc(char.sizeof*10);

 	return window;
}
fn void Window.setColor(Window* this,ZString color){

	libc::strcpy(this.current_color,color);
}

fn void Window.mvprint(Window* this, int x,  int y, String pixel){
	io::printfn("\e[%d;%dH%s%s", this.pos.y+y, this.pos.x+x,this.current_color,pixel);
}
fn void Window.mvprintchar(Window* this, int x,  int y, char pixel){
	io::printfn("\e[%d;%dH%s%c", this.pos.y+y, this.pos.x+x,this.current_color,pixel);
}

fn void clear(){
	io::printfn("\e[2J");
}
fn void echo(bool on){
  if(!on){
  	libc::system("stty -echo");
  }
  else{
  	libc::system("stty echo");
  }
}
fn void cursor(bool on){
  if(!on){
 	io::printfn("\e[?25l");
  }
  else{
 	io::printfn("\e[?25h");
  }
}

fn void Window.box(Window* this){
	for(int i = 0; i <= this.res.y; i ++){
	  	this.mvprint(0,i,"#");
	  	this.mvprint(this.res.x,i,"#");
	}
	for(int i = 0; i <= this.res.x; i ++){
	  	this.mvprint(i,0,"#");
	  	this.mvprint(i,this.res.y,"#");
	}
}

fn void Window.free(Window* window){
	free(window.current_color);
	free(window);
}

fn void Window.start(Window *this){
    clear();
    echo(false);
    cursor(false);
}
fn void Window.end(Window *this){
    echo(true);
    cursor(true);
}

extern fn int ioctl(int fd, int request, void* argv);
const int TIOCGWINSZ = 0x5413; // Request code for terminal size
const int STDOUT_FILENO = 1;   // File descriptor for stdout

struct Winsize {
		ushort ws_row;    // Number of rows
		ushort ws_col;    // Number of columns
		ushort ws_xpixel; // Unused in this example
		ushort ws_ypixel; // Unused in this example
}

fn int[<2>]! term_size(){
		Winsize size;
		if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == -1) {
			return IoError.FILE_NOT_FOUND?;
		}
		return {size.ws_col,size.ws_row};
}

extern fn char getKeyPressed();
