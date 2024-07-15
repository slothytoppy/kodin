package kodin

import "./ncurses/"
import "core:os"
import "core:strings"

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
	cx, cy:     i32,
	rows, cols: int,
}

Editor := EditorConfig{}

init_editor :: proc() {
	y, x := ncurses.getmaxyx(ncurses.stdscr)
	Editor = {
		cx   = 0,
		cy   = 0,
		rows = cast(int)x,
		cols = cast(int)y,
	}
}

get_cursor_pos :: proc() -> (x, y: i32) {
	y, x = ncurses.getyx(ncurses.stdscr)
	return x, y
}

draw_rows :: proc(buffer: ^Buffer) {
	for i in 0 ..= Editor.cols {
		if i == Editor.cols / 2 {
			welcome_msg: []byte = {
				'K',
				'o',
				'd',
				'i',
				'n',
				' ',
				'E',
				'd',
				'i',
				't',
				'o',
				'r',
				' ',
				'-',
				'-',
				' ',
				'v',
				'e',
				'r',
				's',
				'i',
				'o',
				'n',
				' ',
				'0',
				'.',
				'0',
				'.',
				'1',
				'\n',
			}
			padding := (Editor.cols - len(welcome_msg)) / 2
			if padding > 0 {
				BufAppend(buffer, ..[]byte{'~'})
				padding -= 1
			}
			for i in 0 ..< padding {
				BufAppend(buffer, ' ')
			}
			BufAppend(buffer, ..welcome_msg)
		} else {
			BufAppend(buffer, '~', '\n')
		}
	}
}

editorMoveCursor :: proc(key_name: cstring) {
	switch key_name {
	case "KEY_LEFT":
		if Editor.cx > 0 {
			Editor.cx -= 1
		}
	case "KEY_RIGHT":
		if Editor.cx < i32(Editor.rows) {
			Editor.cx -= 1
		}
	case "KEY_UP":
		if Editor.cy > 0 {
			Editor.cy -= 1
		}
	case "KEY_DOWN":
		if Editor.cy < cast(i32)Editor.cols {
			Editor.cy += 1
		}

	}
}

refresh_screen :: proc() {
	buff: Buffer
	draw_rows(&buff)
	ncurses.curs_set(0)
	ncurses.printw("%s", buff[:])
	ncurses.move(Editor.cy, Editor.cx)
	BufDelete(&buff)
	ncurses.curs_set(1)
	ncurses.refresh()
}

process_key_press :: proc() {
	data := read_key()
	key := ncurses.keyname(i32(data))
	switch key {
	case "^Q":
		ncurses.endwin()
		os.exit(0)
	case "KEY_LEFT", "KEY_RIGHT", "KEY_UP", "KEY_DOWN":
		editorMoveCursor(key)
	}
}

get_window_size :: proc() -> (x, y: i32) {
	y, x = ncurses.getmaxyx(ncurses.stdscr)
	return x, y
}

Buffer :: [dynamic]byte
Erow :: distinct Buffer

BufAppend :: proc(buffer: ^Buffer, input: ..byte) {
	append(buffer, ..input)
}

BufDelete :: proc(buffer: ^Buffer) {
	delete(buffer[:])
}

// init and deinit the window should be separated?
main :: proc() {
	ncurses.initscr()
	init_editor()
	enable_raw_mode()
	for {
		refresh_screen()
		process_key_press()
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
