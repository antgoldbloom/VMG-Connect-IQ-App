//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.ActivityRecording as Record;
using Toybox.Attention as Attention;
using Toybox.Time as Time;
using Toybox.Timer as Timer;

	var session = null;
	var wind_dir = 0;
	var wind_dir_string = '0';
	var posnInfo = null;
	var counter = 0;
	var sessionTimer = new Timer.Timer();
	
	function setWindDirection(wind_dir_chg) {
	    wind_dir = wind_dir  + wind_dir_chg;
	    if (wind_dir > 359) {
	    	wind_dir = wind_dir - 360;
	    } else if (wind_dir < 0) {
	    	wind_dir = wind_dir + 360;
	    }
	    
	    wind_dir_string = wind_dir.toString();
	    Ui.requestUpdate();
		
	}
	
	
	function startRecording() {
		if( posnInfo != null ) {
			if( Toybox has :ActivityRecording ) {
				if( session == null )  {
		        	session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_GENERIC});
		            session.start();
					sessionTimer.start(method(:incrementTimer), 1000, true);	
		            Ui.requestUpdate();
		        } else if( ( session != null ) && ( session.isRecording() == false ) ) {
		            session.start();
					sessionTimer.start(method(:incrementTimer), 1000, true);	
		            Ui.requestUpdate();            
				} else if( ( session != null ) && session.isRecording() ) {
					sessionTimer.stop();
		            session.stop();
		            Ui.requestUpdate();
		        }
				
				if (Attention has :vibrate) {
		        	var vibrateData = [
		            	new Attention.VibeProfile(  25, 100 ),
		                new Attention.VibeProfile(  50, 100 ),
		                new Attention.VibeProfile(  75, 100 ),
		                new Attention.VibeProfile( 100, 100 ),
		                new Attention.VibeProfile(  75, 100 ),
		                new Attention.VibeProfile(  50, 100 ),
		                new Attention.VibeProfile(  25, 100 )
					];
		
					Attention.vibrate(vibrateData);
				}
		
				Attention.playTone(Attention.TONE_START);
				
				
			}
		}
	
		return true;
	}
	
	
	function incrementTimer() {
		counter += 1;
	    Ui.requestUpdate();
	}
	
	function stopRecording() {
		if( posnInfo != null ) {
	        
	        if( Toybox has :ActivityRecording ) {
	            if( session != null ) {
					if (session.isRecording()) {
	                	session.stop();
	                }
	                session.save();
	                session = null;
	
					if (Attention has :vibrate) {
		        		var vibrateData = [
		            		new Attention.VibeProfile(  25, 100 ),
		                	new Attention.VibeProfile(  50, 100 ),
		                	new Attention.VibeProfile(  75, 100 ),
		                	new Attention.VibeProfile( 100, 100 ),
		                	new Attention.VibeProfile(  75, 100 ),
		                	new Attention.VibeProfile(  50, 100 ),
		                	new Attention.VibeProfile(  25, 100 )
						];
	
						Attention.vibrate(vibrateData);
					}
	
					Attention.playTone(Attention.TONE_STOP);
					Ui.requestUpdate();
			
	    		}
			}
	
		}
		sessionTimer.stop();
		return true;
	
	}

class PositionSampleView extends Ui.View {

	function initialize() { 

		View.initialize(); // Initialize the UI
	}

    //! Load your resources here
    function onLayout(dc) {
    }

    function onHide() {
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }




    //! Update the view
    function onUpdate(dc) {
        var speedStr;
		var speedDecPlace;
		var headingStr;
		var VMGStr;
		var VMGDecPlace;
		var timerStr;
		
        // Set background color
    
		if( posnInfo != null ) {
	        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_WHITE );
    	    dc.clear();
        	dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);

            speedStr = (Math.round(10*posnInfo.speed * 1.943844492)/10).toString();
            speedDecPlace = speedStr.find(".");
            speedStr = speedStr.substring(0,speedDecPlace+2);
            
            headingStr = (((Math.toDegrees(posnInfo.heading).toLong() + 360) % 360).toString());
            
            VMGStr = (Math.round((10*(Math.cos(posnInfo.heading-Math.toRadians(wind_dir))*posnInfo.speed * 1.943844492)))/10).toString();
            VMGDecPlace = VMGStr.find(".");
			VMGStr = VMGStr.substring(0,VMGDecPlace+2);
                                        
            dc.drawText( (dc.getWidth() / 2), 0, Gfx.FONT_SYSTEM_XTINY , "vmg", Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( (dc.getWidth() / 2), 0, Gfx.FONT_SYSTEM_NUMBER_THAI_HOT, VMGStr , Gfx.TEXT_JUSTIFY_CENTER );            
      
            dc.drawText( 60, 108, Gfx.FONT_SYSTEM_XTINY , "kts", Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( 60, 113, Gfx.FONT_SYSTEM_NUMBER_HOT    , speedStr, Gfx.TEXT_JUSTIFY_CENTER );

            dc.drawText( 155, 108, Gfx.FONT_SYSTEM_XTINY , "deg", Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( 155, 113, Gfx.FONT_SYSTEM_NUMBER_HOT    , headingStr, Gfx.TEXT_JUSTIFY_CENTER );
			
			dc.drawText((dc.getWidth() / 2), 195, Gfx.FONT_SYSTEM_TINY , ("twd " + wind_dir_string) , Gfx.TEXT_JUSTIFY_CENTER);
	
			dc.drawLine(0, 109, 218, 109);			
			dc.drawLine(0, 195, 218, 195);
			dc.drawLine(109, 109, 109, 195);

			var accuracy = "";
			if (posnInfo.accuracy < 4) {
				dc.drawText( 3, 85, Gfx.FONT_SYSTEM_XTINY , "weak signal", Gfx.TEXT_JUSTIFY_LEFT );
			} else {		
				var clockTime = Sys.getClockTime();
				var timeStr; 
				if (clockTime.min < 10) { //add a leading zero before the minute
					timeStr = Lang.format("$1$:0$2$", [clockTime.hour, clockTime.min]);
				} else {
					timeStr = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min]);
				}
				dc.drawText( 3, 85, Gfx.FONT_SYSTEM_SMALL, timeStr, Gfx.TEXT_JUSTIFY_LEFT );
			}
			
		            
    	    if( session != null && session.isRecording() ) {
				dc.setColor( Gfx.COLOR_RED , Gfx.COLOR_TRANSPARENT );
				var hours = (counter / 3600).toLong();
				var minutes = ((counter / 60).toLong() % 60);
				var seconds = counter % 60;
				
				if (minutes < 10) {
					minutes = "0" + minutes.toString();
				} else {
					minutes = minutes.toString();
				}
				
				if (seconds < 10) {
					seconds = "0" + seconds.toString();
				} else {
					seconds = seconds.toString();
				}
				
				
				if (counter > 3600) {
					timerStr = hours.toString() + ":" +  minutes +":" + seconds;	
				} else if (counter > 60) {
					timerStr = minutes + ":" + seconds;	
				} else {
					timerStr = seconds;
				}
				
				
				
				dc.drawText( 215, 85, Gfx.FONT_SYSTEM_SMALL, timerStr, Gfx.TEXT_JUSTIFY_RIGHT);
			} else if (session != null) {
				dc.setColor( Gfx.COLOR_BLACK , Gfx.COLOR_TRANSPARENT );
				dc.drawText( 215, 85, Gfx.FONT_SYSTEM_SMALL, "pause", Gfx.TEXT_JUSTIFY_RIGHT);
			} else {
				dc.drawText( 10, 90, Gfx.FONT_SYSTEM_SMALL  , "", Gfx.TEXT_JUSTIFY_CENTER );
			}
	
			
        } else {
            dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
    	    dc.clear();
        	dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            
            
            dc.drawText( (dc.getWidth() / 2), 35, Gfx.FONT_MEDIUM, "No GPS signal", Gfx.TEXT_JUSTIFY_CENTER );
	        var bitmap;
	        bitmap = Ui.loadResource(Rez.Drawables.id_crash);
        	dc.drawBitmap(50, 75, bitmap);


            //dc.drawText( (dc.getWidth() / 2), 110, Gfx.FONT_MEDIUM, "You can't kite indoors!", Gfx.TEXT_JUSTIFY_CENTER );
        }
    }

    function setPosition(info) {
        posnInfo = info;
        Ui.requestUpdate();
    }


	


}
