package;
import Controls.Control;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
 /**
	hey you fun commiting people, 
	i don't know about the rest of the mod but since this is basically 99% my code 
	i do not give you guys permission to grab this specific code and re-use it in your own mods without asking me first.
	the secondary dev, ben
*/

class CharacterInSelect
{
	public var name:String;
	public var noteMs:Array<Float>;
	public var forms:Array<CharacterForm>;

	public function new(name:String, noteMs:Array<Float>, forms:Array<CharacterForm>)
	{
		this.name = name;
		this.noteMs = noteMs;
		this.forms = forms;
	}
}
class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var positionOffsets:Array<Float> = new Array<Float>();

	public function new(name:String, polishedName:String)
	{
		this.name = name;
		this.polishedName = polishedName;
	}
}
class CharacterSelectState extends MusicBeatState
{
	public var char:Boyfriend;
	public var current:Int = 0;
	public var curForm:Int = 0;
	public var notemodtext:FlxText;
	public var characterText:FlxText;

	public var funnyIconMan:HealthIcon;

	var strummies:FlxTypedGroup<FlxSprite>;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;

	var selectedCharacter:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var currentSelectedCharacter:CharacterInSelect;

	var noteMsTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	
	public var characters:Array<CharacterInSelect> = 
	[
		new CharacterInSelect('bf', [1, 1, 1, 1], [
			new CharacterForm('bf', 'Boyfriend'),
			new CharacterForm('bf-pixel', 'Pixel Boyfriend')
		]),
		new CharacterInSelect('dave', [0.25, 0.25, 2, 2], [
			new CharacterForm('dave', 'Dave'),
			new CharacterForm('dave-annoyed', 'Dave (Insanity)'),
			new CharacterForm('dave-splitathon', 'Dave (Splitathon)')
		]),
		new CharacterInSelect('bambi', [0, 0, 3, 0], [
			new CharacterForm('bambi', 'Mr. Bambi'),
			new CharacterForm('bambi-new', 'Bambi (Farmer)'),
			new CharacterForm('bambi-splitathon', 'Bambi (Splitathon)'),
			new CharacterForm('bambi-angey', 'Bambie'),
			new CharacterForm('bambi-old', 'Bambi (Joke)')
		]),
		new CharacterInSelect('dave-angey', [2, 2, 0.25, 0.25], [
			new CharacterForm('dave-angey', '3D Dave')
		]),
		new CharacterInSelect('tristan', [2, 0.5, 0.5, 0.5], [
			new CharacterForm('tristan', 'Tristan')
		]),
		new CharacterInSelect('tristan-golden', [0.25, 0.25, 0.25, 2], [
			new CharacterForm('tristan-golden', 'Golden Tristan')
		]),
		new CharacterInSelect('bambi-3d', [0, 3, 0, 0], [
			new CharacterForm('bambi-3d', '[EXPUNGED]'),
			new CharacterForm('bambi-unfair', '[EXPUNGED]'),
			new CharacterForm('expunged', '[EXPUNGED]')
		]),

	];
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();

		Conductor.changeBPM(110);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		if (FlxG.save.data.charactersUnlocked == null)
		{
			reset();
		}
		currentSelectedCharacter = characters[current];

		if (isDebug)
		{
			for (character in characters)
			{
				unlockCharacter(character.name); //unlock everyone
			}
		}

		FlxG.sound.playMusic(Paths.music("goodEnding"), 1, true);

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/shared/sky_night'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.75, 0.75);
		bg.active = false;
		add(bg);

		var stageHills:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('backgrounds/dave-house/night/hills'));
		stageHills.setGraphicSize(Std.int(stageHills.width * 1.25));
		stageHills.updateHitbox();
		stageHills.antialiasing = true;
		stageHills.scrollFactor.set(0.8, 0.8);
		stageHills.active = false;
		add(stageHills);

		var gate:FlxSprite = new FlxSprite(-200, -125).loadGraphic(Paths.image('backgrounds/dave-house/night/gate'));
		gate.setGraphicSize(Std.int(gate.width * 1.2));
		gate.updateHitbox();
		gate.antialiasing = true;
		gate.scrollFactor.set(0.9, 0.9);
		gate.active = false;
		add(gate);

		var stageFront:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('backgrounds/dave-house/night/grass'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.2));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.active = false;
		add(stageFront);

		FlxG.camera.zoom = 0.75;
		camHUD.zoom = 0.75;

		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, "bf");
		char.screenCenter();
		char.y = 450;
		add(char);

		strummies = new FlxTypedGroup<FlxSprite>();
		strummies.cameras = [camHUD];
		add(strummies);
	
		generateStaticArrows();
		
		notemodtext = new FlxText((FlxG.width / 3.5) + 80, 40, 0, "1.00x       1.00x        1.00x       1.00x", 30);
		notemodtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		notemodtext.scrollFactor.set();
		notemodtext.alpha = 0;
		notemodtext.y -= 10;
		FlxTween.tween(notemodtext, {y: notemodtext.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * 0)});
		notemodtext.cameras = [camHUD];
		add(notemodtext);
		
		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.font = 'Comic Sans MS Bold';
		characterText.setFormat(Paths.font("comic.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.fieldWidth = 1080;
		characterText.borderSize = 7;
		characterText.screenCenter(X);
		characterText.cameras = [camHUD];
		add(characterText);
		
		var resetText = new FlxText((FlxG.width / 2) + 350, (FlxG.height / 8) - 200, "Press R To Reset");
		resetText.font = 'Comic Sans MS Bold';
		resetText.setFormat(Paths.font("comic.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.autoSize = false;
		resetText.fieldWidth = FlxG.height;
		resetText.borderSize = 5;
		resetText.cameras = [camHUD];
		add(resetText);

		funnyIconMan = new HealthIcon('bf', true);
		funnyIconMan.sprTracker = characterText;
		funnyIconMan.cameras = [camHUD];
		funnyIconMan.visible = false;
		add(funnyIconMan);

		var tutorialThing:FlxSprite = new FlxSprite(-150, -50).loadGraphic(Paths.image('ui/charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.5));
		tutorialThing.antialiasing = true;
		tutorialThing.cameras = [camHUD];
		add(tutorialThing);		
	}

	private function generateStaticArrows():Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, 0);

			babyArrow.frames = Paths.getSparrowAtlas('notes/NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.x += Note.swagWidth * i;
			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.ID = i;
	
			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 3.5));
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			babyArrow.cameras = [camHUD];
			strummies.add(babyArrow);
		}
	}
	override public function update(elapsed:Float):Void 
	{
	
		Conductor.songPosition = FlxG.sound.music.time;
		
		var controlSet:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		super.update(elapsed);
		//FlxG.camera.focusOn(FlxG.ce);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			LoadingState.loadAndSwitchState(new FreeplayState());
		}
		
		for (i in 0...controlSet.length)
		{
			if (controlSet[i] && !PressedTheFunny)
			{
				switch (i)
				{
					case 0:
						char.playAnim(char.nativelyPlayable ? 'singLEFT' : 'singRIGHT', true);
					case 1:
						char.playAnim('singDOWN', true);
					case 2:
						char.playAnim('singUP', true);
					case 3:
						char.playAnim(char.nativelyPlayable ? 'singRIGHT' : 'singLEFT', true);
				}
			}
		}
		if (controls.ACCEPT)
		{
			if (isLocked(characters[current].name))
			{
				FlxG.camera.shake(0.05, 0.1);
				FlxG.sound.play(Paths.sound('badnoise1'), 0.9);
				return;
			}
			if (PressedTheFunny)
			{
				return;
			}
			else
			{
				PressedTheFunny = true;
			}
			selectedCharacter = true;
			var heyAnimation:Bool = char.animation.getByName("hey") != null; 
			char.playAnim(heyAnimation ? 'hey' : 'singUP', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(1.9, endIt);
		}
		if (FlxG.keys.justPressed.LEFT && !selectedCharacter)
		{
			curForm = 0;
			current--;
			if (current < 0)
			{
				current = characters.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (FlxG.keys.justPressed.RIGHT && !selectedCharacter)
		{
			curForm = 0;
			current++;
			if (current > characters.length - 1)
			{
				current = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.DOWN && !selectedCharacter)
		{
			curForm--;
			if (curForm < 0)
			{
				curForm = characters[current].forms.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.UP && !selectedCharacter)
		{
			curForm++;
			if (curForm > characters[current].forms.length - 1)
			{
				curForm = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.R && !selectedCharacter)
		{
			reset();
			FlxG.resetState();
		}
	}
	public static function unlockCharacter(character:String)
	{
		if (!FlxG.save.data.charactersUnlocked.contains(character))
		{
			FlxG.save.data.charactersUnlocked.push(character);
		}
	}
	public static function isLocked(character:String):Bool
	{
		return !FlxG.save.data.charactersUnlocked.contains(character);
	}
	public static function reset()
	{
		FlxG.save.data.charactersUnlocked = new Array<String>();
		unlockCharacter('bf');
		FlxG.save.flush();
	}

	public function UpdateBF()
	{
		funnyIconMan.color = FlxColor.WHITE;
		currentSelectedCharacter = characters[current];
		characterText.text = currentSelectedCharacter.forms[curForm].polishedName;
		char.destroy();
		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, currentSelectedCharacter.forms[curForm].name);
		char.screenCenter();
		char.y = 450;

		switch (char.curCharacter)
		{
			case 'bf-pixel':
				char.y -= 50;
				char.x -= 50;
			case 'dave' | 'dave-annoyed':
				char.y = 260;
			case 'dave-splitathon':
				char.y = 260;
				char.x -= 25;
			case 'bambi' | 'bambi-old':
				char.y = 400;
			case 'bambi-new':
				char.y = 400;
			case 'bambi-splitathon':
				char.y = 475;
				char.x -= 25;
			case 'bambi-angey':
				char.y = 475;
			case 'dave-angey':
				char.y = 150;
				char.x -= 50;
			case 'tristan':
				char.y = 425;
			case 'tristan-golden':
				char.y -= 50;
			case 'bambi-3d':
				char.x += 250;
				char.y = 600;
			case 'bambi-unfair':
				char.x += 200;
				char.y = 750;
		}
		add(char);
		funnyIconMan.animation.play(char.curCharacter);
		if (isLocked(characters[current].name))
		{
			char.color = FlxColor.BLACK;
			funnyIconMan.color = FlxColor.BLACK;
			funnyIconMan.animation.curAnim.curFrame = 1;
			characterText.text = '???';
		}
		characterText.screenCenter(X);
		notemodtext.text = FlxStringUtil.formatMoney(currentSelectedCharacter.noteMs[0]) + "x       " + FlxStringUtil.formatMoney(currentSelectedCharacter.noteMs[3]) + "x        " + FlxStringUtil.formatMoney(currentSelectedCharacter.noteMs[2]) + "x       " + FlxStringUtil.formatMoney(currentSelectedCharacter.noteMs[1]) + "x";
	}

	override function beatHit()
	{
		super.beatHit();
		if (char != null && !selectedCharacter && curBeat % 2 == 0)
		{
			char.playAnim('idle', true);
		}
	}
	
	
	public function endIt(e:FlxTimer = null)
	{
		PlayState.characteroverride = currentSelectedCharacter.name;
		PlayState.formoverride = currentSelectedCharacter.forms[curForm].name;
		PlayState.curmult = currentSelectedCharacter.noteMs;
		LoadingState.loadAndSwitchState(new PlayState());
	}
	
}