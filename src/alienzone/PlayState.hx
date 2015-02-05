/**
 *--------------------------------------------------------------------+
 * PlayState.hx
 *--------------------------------------------------------------------+
 * Copyright DarkOverlordOfData (c) 2014
 *--------------------------------------------------------------------+
 *
 * This file is a part of Alien Zone
 *
 * Alien Zone is free software; you can copy, modify, and distribute
 * it under the terms of the GPLv3 License
 *
 *--------------------------------------------------------------------+
 *
 */
package alienzone;

import alienzone.systems.RenderSystem;
import alienzone.systems.SystemPriorities;
import ash.tick.ITickProvider;
import ash.core.Engine;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxState;
import alienzone.graphics.Button.ButtonStyle;

import alienzone.match3.MatchObject;
import alienzone.match3.Piece;
import alienzone.match3.Grid;


enum GameType {
    Infinity;
    FTL;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {

    private var gameType:GameType;
    private var engine:Engine;
    private var factory:EntityFactory;


    public function new(gameType:GameType) {
        super();
        this.gameType = gameType;
    }

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void {
		super.create();

        /**
         *  Create the engine
         */
        engine = new Engine();
        factory = new EntityFactory(engine);
        engine.addSystem(new RenderSystem(this, factory), SystemPriorities.render);

        /**
         *  Initialize the entities
         */
        factory
        .fps(0, 0)
        .image(0, 0, "images/slots.png", 0.2)
        .button(260, 20, "Back", ButtonSmall, function() {
            FlxG.switchState(new MenuState());
        })
        .start(0, 3, 0)
        ;
        
    }


    /**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void {
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void {
		super.update();
        engine.update(FlxG.elapsed);
	}
}