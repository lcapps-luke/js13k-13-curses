package;

class Sound {
	public static function flip(){
		ZzFX.zzfx(.5,.1,196,.1,0,.1,4,1.5,0,0,50,0,0,0,0,0,.05,1,0,0,0);
	}

	public static function slide(){
		ZzFX.zzfx(.1,.1,196,.25,0,.1,4,1.5,0,0,50,0,0,0,0,0,0,1,0,0,0);
	}

	public static function button(){
		ZzFX.zzfx(.8,.05,419,0,.01,.008,0,3,2,56,0,0,0,.8,0,0,0,.54,0,.04,-1040);
	}

	public static function curse(){
		ZzFX.zzfx(1,1,123.4708,.15,0,.1,1,1,0,100,300,.06,.07,0,20,.1,.08,.51,.11,.35,0);
	}

	public static function uncurse(){
		ZzFX.zzfx(.6,.2,140,.1,.07,.2,1,1,-1,85,290,0,.1,.4,0,.1,0,.5,.08,0,0);
	}

	public static function gainCoin(){
		ZzFX.zzfx(.3,.1,450,.01,.07,.12,1,2.4,0,1,280,.05,0,0,0,0,0,.7,.04,0,152);
	}

	public static function loseCoin(){
		ZzFX.zzfx(.4,.5,350,0,.2,.3,2,.5,1,0,0,0,.03,1.9,0,0,0,1,0,.48,-2500);
	}

	public static function roll(){
		ZzFX.zzfx(.5,1,82.40689,.02,.02,.03,0,.6,0,16,-191,.15,0,0,42,0,0,.74,.02,.06,-657);
	}

	public static function coinFlip(){
		ZzFX.zzfx(.5,2,70,.1,.05,.1,0,1.6,7,27,0,0,0,.9,0,0,0,.7,.02,0,-856);
	}
}