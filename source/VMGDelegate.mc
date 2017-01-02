//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;


class PositionSampleDelegate extends Ui.BehaviorDelegate {


    function onKeyPressed(evt) {
        if( evt.getKey() == KEY_UP ) {
            setWindDirection(1);        
        } else if( evt.getKey() == KEY_DOWN ) {
            setWindDirection(-1);
        } else if( evt.getKey() == 4 ) { //presses the start key
        	startRecording();
		}
		
        return true;
    }

    function onMenu() {
       setWindDirection(45);
	}

    function onHold(evt) {
        if( evt.getKey() == KEY_UP ) {
            setWindDirection(10);        
        } else if( evt.getKey() == KEY_DOWN ) {
            setWindDirection(-10);
        }
        return true;
    }
    



}
