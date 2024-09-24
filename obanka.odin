package banka

import "core:c/libc"
import "core:fmt"
import rl "vendor:raylib"


Window :: struct {
	name:   cstring,
	width:  i32,
	height: i32,
	fps:    i32,
}

GameWorld :: struct {
	width:  i32,
	height: i32,
}

InputState :: struct {
	left_mouse_clicked:    bool,
	right_mouse_clicked:   bool,
	add_button_clicked:    bool,
	remove_button_clicked: bool,
	mouse_position:        rl.Vector2,
}

process_input :: proc(inputState: ^InputState) {
	inputState^ = InputState {
		left_mouse_clicked    = rl.IsMouseButtonReleased(.LEFT),
		right_mouse_clicked   = rl.IsMouseButtonReleased(.RIGHT),
		add_button_clicked    = rl.IsKeyReleased(rl.KeyboardKey.A),
		remove_button_clicked = rl.IsKeyReleased(rl.KeyboardKey.R),
		mouse_position        = rl.GetMousePosition(),
	}
}

Vector2i :: [2]int
bankaDimm :: 4

banka4l :: struct {
	slots:    [bankaDimm]i32,
	position: rl.Vector2i,
}

BankaCell :: struct {
	width:  i32,
	height: i32,
}

drawDebugInfo :: proc(inputState: InputState) {
	debugTextColor := rl.BLACK
	
	rl.DrawText(
		rl.TextFormat(
			"Mouse Position: [ %.0f, %.0f ]",
			inputState.mouse_position.x,
			inputState.mouse_position.y,
		),
		10,
		40,
		20,
		debugTextColor,
	)

	mouseDelta := rl.GetMouseDelta()
	rl.DrawText(
		rl.TextFormat(
			"Mouse Delta: [ %.0f, %.0f ]",
			mouseDelta.x,
			mouseDelta.y,
		),
		10,
		65,
		20,
		debugTextColor,
	)
}


// worldToScreen :: proc(worldPos: rl.Vector2, window: Window) -> Vector2i {
// 	cellSize := rl.Vector2()
// }

drawBanka :: proc(banka: banka4l, bankaCell: BankaCell) {
	for i in 0 ..< bankaDimm {
		slotColor: rl.Color
		switch banka.slots[i] {
		case 0:
			slotColor = rl.LIGHTGRAY
		case 1:
			slotColor = rl.BROWN
		case 2:
			slotColor = rl.PURPLE
		case:
			panic("Wrong value in banka!")
		}
	
		x := banka.position[0]
		y := banka.position[1]

		rl.DrawRectangle(
			x,
			y + i32(i) * bankaCell.height,
			bankaCell.width,
			bankaCell.height,
			slotColor,
		)
		// Draw border
		rl.DrawRectangleLines(
			x,
			y + i32(i) * bankaCell.height,
			bankaCell.width,
			bankaCell.height,
			rl.BLACK,
		)
	}
}

drawBankas :: proc(bankas: [dynamic]banka4l, window: Window, bankaCell: BankaCell) {
	n := i32(len(bankas))

	for banka, i in bankas {
		// x_pos := (window.width / (n + 1) * (i32(i) + 1)) - (bankaCell.width / 2)
		// y_pos := window.height / 2

		drawBanka(bankas[i], bankaCell)
	}
}

checkIsMouseOnBanka :: proc(banka: banka4l, mousePos: rl.Vector2) -> bool {
	return false
}

main :: proc() {
	windowWidth: libc.int = 900
	windowHeight: libc.int = 800

	window := Window {
		name   = "Banka",
		width  = i32(windowWidth),
		height = i32(windowHeight),
		fps    = 60,
	}

	gameWorld := GameWorld {
		width  = 10,
		height = 10,
	}

	bankaCell := BankaCell {
		width  = window.width / gameWorld.width,
		height = window.height / gameWorld.height,
	}

	inputState := InputState {
		left_mouse_clicked  = false,
		right_mouse_clicked = false,
		mouse_position      = rl.Vector2{},
	}

	rl.InitWindow(window.width, window.height, window.name)
	rl.SetTargetFPS(window.fps)

	currMousePosition: rl.Vector2
	prevMousePosition := rl.GetMousePosition()

	bankas: [dynamic]banka4l
	defer delete(bankas)

	append(&bankas, banka4l{slots = {0, 1, 2, 1}})
	append(&bankas, banka4l{slots = {0, 0, 0, 0}})

	selectedBanka: ^banka4l
	hoveredBanka: ^banka4l

	for (!rl.WindowShouldClose()) {
		// Update
		process_input(&inputState)

		isMouseMoved := !rl.Vector2Equals(rl.GetMouseDelta(), rl.Vector2(0))
		if rl.IsCursorOnScreen() && isMouseMoved {
			isBankaHovered := false

			for &banka, i in bankas {
				if checkIsMouseOnBanka(banka, inputState.mouse_position) {
					isBankaHovered = false
					hoveredBanka = &banka
					if inputState.left_mouse_clicked {
						selectedBanka = &banka
					}
					break
				}
			}

			if !isBankaHovered {
				hoveredBanka = nil
			}
		}

		if inputState.add_button_clicked {
			append(&bankas, banka4l{slots = {0, 1, 2, 1}})
		}

		if inputState.remove_button_clicked && len(bankas) > 0 {
			pop(&bankas)
		}

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKGRAY)

		drawDebugInfo(inputState)

		drawBankas(bankas, window, bankaCell)

		rl.EndDrawing()
	}
}
