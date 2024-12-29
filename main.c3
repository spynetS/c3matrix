module c3matrix;
import std::io;
import std::thread;
import libc;
import std::core::mem;
import std::os::process;
import c3curses;


struct Item{
    int pos;
    int ttl;
}

fn char get_random_char(){
    char[] charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&*().,";
    int index = libc::rand() % (73 - 1); // Random index in the range of the charset
    return charset[index];
}

fn int get_ttl(int max){
    return libc::rand() % (max);
}

struct Column{
    int x;
    int cursor;
    int ttl;
    int count_down;
    char cursor_char;
    int height;
    int* ints;
}

fn void Column.update(Column* this, Window* win){
    if(--this.count_down > 0) return;
    if(this.cursor == 0) this.ttl = get_ttl(this.height-4);

  win.setColor("\e[0;32m");
    win.mvprintchar({this.x,this.cursor},this.cursor_char);
    this.cursor_char = get_random_char();

    this.cursor = (this.cursor + 1) % this.height;
    this.ints[this.cursor] = this.ttl;
    win.setColor("\e[1;37m");
    win.mvprintchar({this.x,this.cursor},this.cursor_char);

    for(int i = 0; i < this.height; i ++){
        int item = this.ints[i];
        if(item == 0){
            win.mvprintchar({this.x,i},' ');
            this.ints[i] = -1;
        }
        else if (item > 0){
            this.ints[i]--;
        }
    }

}

fn Column *new_column(int x, int height){
    Column *c = malloc(Column.sizeof);
    c.x = x;
    c.height = height;
    c.count_down = libc::rand() % height*2;
    c.ints = malloc(int.sizeof*height);
    for(int i = 0; i <  height; i ++) c.ints[i] = -1;
    return c;
}

fn void Column.free(Column* this){
    free(this.ints);
    free(this);
}

fn int main(int argc, char** argv){

  int delay = 45;
  bool clear = true;

  for(int i = 0; i < argc; i ++){
    String s = ((ZString) argv[i]).str_view();
    switch(s){
      case "--delay":
      case "-d":
        delay = ((ZString) argv[i+1]).str_view().to_int()!!;
        break;
      case "--no-clear":
        clear = false;
        break;
      case "--help":
      case "-h":
        io::printn("This is a port of cmatrix written in c3 (and some c) using escape codes to manipulate cursor");
        io::printn("c3matrix <options>");
        io::printn("-d  --delay  <int> :  Choose the delay in ms for each frame");
        io::printn("    --no-clear     :  Will not clear the terminal before starting");
        return 0;
    }

  }



    int[<2>] size = c3curses::term_size()!!;
    int w = size.x;
    int h = size.y;

    Window *win = c3curses::new_window({0,0}, {w,h});
    if(clear) c3curses::clear();
  c3curses::echo(false);
  c3curses::cursor(false);

    Column** columns = malloc((Column*).sizeof*w);
    for(int i = 0; i < w; i ++){
        columns[i] = new_column(i*2,h);
    }



    while(true){
        char key = c3curses::getKeyPressed();
        if(key == 'q') break;
        if(key == 'p') {
            win.mvprint({size.x/2-11,size.y/2},"Press enter to unpause");
            win.refresh();
          char val = (char) libc::getchar();
          if(val == 'q') break;
            win.mvprint({size.x/2-11,size.y/2},"                      ");
        }

        c3curses::sleep(delay)!!;
        for(int j = 0; j < w; j ++){
            columns[j].update(win);
        }
        // win.box("-","|");
        win.refresh();
    }

    for(int j = 0; j < w; j ++){
        columns[j].free();
    }
    free(columns);
    win.end();

    win.free();
    c3curses::mvcursor({0,0});
    c3curses::clear();



    return 0;
}
