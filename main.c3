module c3matrix;
import std::io;
import std::thread;
import libc;
import std::core::mem;
import std::os::process;


/*
If i have a list of columns where each column has a struct
of a char and its ttl. Each frame we check if a structs ttl
is at end and we remove it. The cursor for the column
goes upp and down adding new chars.

*/

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

    win.setColor("\e[32m");
    win.mvprintchar(this.x,this.cursor,this.cursor_char);
    this.cursor_char = get_random_char();

    this.cursor = (this.cursor + 1) % this.height;
    this.ints[this.cursor] = this.ttl;
    win.setColor("\e[1;33m");
    win.mvprintchar(this.x,this.cursor,this.cursor_char);

    for(int i = 0; i < this.height; i ++){
        int item = this.ints[i];
        if(item == 0){
            win.mvprintchar(this.x,i,' ');
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
    c.count_down = libc::rand() % height;
    c.ints = malloc(int.sizeof*height);
    for(int i = 0; i <  height; i ++) c.ints[i] = -1;
    return c;
}

fn void Column.free(Column* this){
    free(this.ints);
    free(this);
}


fn void sig(){
    io::printf("");
}
def TestFn = fn void(int);
fn void test(int x)
{
   libc::write(1, "Alarm triggered!\n", 17);
}
extern fn uint alarm (uint __seconds);
extern fn int getchar ();

fn int main(int argc, char** argv){

    int[<2>] size = term_size()!!;
    int w = size.x-10;
    int h = size.y;

    Window *win = new_window({0,0}, {w,h});
    win.start();

    Column** columns = malloc((Column*).sizeof*w);
    for(int i = 0; i < w; i ++){
        columns[i] = new_column(i*2,h);
    }

    int i = 0;
    while(true){
        if(try thread::sleep_ms(50)){
            for(int j = 0; j < w; j ++){
                columns[j].update(win);
            }
        }
        if(i++>10000) break;
    }

    for(int j = 0; j < w; j ++){
        columns[j].free();
    }
    free(columns);
    win.end();
    win.free();

    return 0;
}
