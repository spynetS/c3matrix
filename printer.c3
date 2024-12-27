module c3matrix;
import std::io;
import std::core::mem;
import std::collections;

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
