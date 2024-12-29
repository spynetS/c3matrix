module c3curses;

import std::io;
import std::core::mem;
import std::collections;
import std::thread;

import libc;

struct Window{
	int[<2>] pos;
 	int[<2>] res;
	ZString current_color;
 ZString buffer;
}

fn Window* new_window(int[<2>] pos, int[<2>] res){
	Window* window = malloc(Window.sizeof);
 window.pos = pos;
 window.res = res;
 window.current_color = (ZString) malloc(char.sizeof*10);
 window.buffer = (ZString) malloc(char.sizeof*20*res.x*res.y);

 	return window;
}
fn void Window.setColor(Window* this,ZString color){

	libc::strcpy(this.current_color,color);
}

fn void Window.mvprint(Window* this, int[<2>] pos, String pixel){
	if(pos.x > this.res.x || pos.x < 0 || pos.y > this.res.y || pos.y < 0) return;
 	pos += this.pos;
  libc::sprintf(this.buffer,"%s\e[%d;%dH%s%s",this.buffer, pos.y, pos.x,this.current_color,pixel);
}
fn void Window.mvprintchar(Window* this, int[<2>] pos, char pixel){
	if(pos.x > this.res.x || pos.x < 0 || pos.y > this.res.y || pos.y < 0) return;
	pos += this.pos;
	libc::sprintf(this.buffer,"%s\e[%d;%dH%s%c",this.buffer, pos.y, pos.x,this.current_color,pixel);
}
fn void mvcursor(int[<2>] pos){
	io::printfn("\e[%d;%dH%",pos.y,pos.x);
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

fn void Window.box(Window* this,String hor, String vert){
		for(int i = 1; i < this.res.y; i ++){
	  	this.mvprint({0,i},vert);
	  	this.mvprint({this.res.x,i},vert);
	}
	for(int i = 1; i < this.res.x; i ++){
	  	this.mvprint({i,0},hor);
	  	this.mvprint({i,this.res.y},hor);
	}
	this.mvprint({0,0},"┌");
	this.mvprint({0,this.res.y},"└");
	this.mvprint({this.res.x,0},"┐");
	this.mvprint({this.res.x,this.res.y},"┘");
}

fn void Window.free(Window* window){
	free(window.current_color);
	free(window.buffer);
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

fn void! sleep(ulong ms){
	thread::sleep_ms(ms);
}

fn void Window.refresh(&window){
	io::printfn("%s",window.buffer);
	libc::sprintf(window.buffer,"");
}

extern fn char getKeyPressed();
