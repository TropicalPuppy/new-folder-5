extends Command

enum FadeType {
	OUT,
	IN
}

export(FadeType) var fade_type = FadeType.OUT
export(float) var duration = 1
export(bool) var wait_for_fade = true

func execute_command(code, _delta):
	match fade_type:
		FadeType.OUT:
			Game.screen.fade_out(duration)
		FadeType.IN:
			Game.screen.fade_in(duration)
	
	if wait_for_fade:
		code.wait_mode = Constants.WaitMode.SCREEN
	
	return true
