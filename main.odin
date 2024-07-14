package kodin

import "./ncurses/"
import "core:container/rbtree"

enable_raw_mode :: proc() {
	ncurses.raw()
	ncurses.noecho()
	ncurses.keypad(ncurses.stdscr, true)
}

disable_raw_mode :: proc() {
	ncurses.noraw()
	ncurses.nocbreak()
	ncurses.echo()
	ncurses.keypad(ncurses.stdscr, false)
}

read_key :: proc() -> rune {
	return cast(rune)ncurses.getch()
}

clear_screen :: proc() {
	ncurses.erase()
}

EditorConfig :: struct {
	rows, cols: int,
}

init_editor_config :: proc() -> EditorConfig {
	y, x := ncurses.getmaxyx(ncurses.stdscr)
	return EditorConfig{cast(int)x, cast(int)y}
}

// init and deinit the window should be separated?
main :: proc() {
	ncurses.initscr()
	config := init_editor_config()
	enable_raw_mode()
	for {
		clear_screen()
		data := read_key()
		if data == 'q' & 0x1f {
			break
		}
		if data == '\n' {

		} else do ncurses.printw("%c", data)
		/*
		switch data {
		case 32 ..= 126:
			ncurses.addch(data)
		case 0 ..= 31:
			ncurses.addch(data)
		case 127:
			ncurses.addch(data)
		}
    */
	}
	disable_raw_mode()
	ncurses.endwin()
}
