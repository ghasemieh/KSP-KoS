// -------------------------------------
// Phase 1- Vehicle Initialization
// -------------------------------------
CLEARSCREEN.
PRINT "Phase 1- Vehicle Initialization".
PRINT "-------------------------------".
PRINT " ".

// Turn On all Sensors  -----
PRINT "----- Sensors Activation and Status -----".
LIST SENSORS IN SENSELIST.

// TURN EVERY SINGLE SENSOR ON -----
FOR S IN SENSELIST {
  PRINT "SENSOR: " + S:TYPE.
  PRINT "VALUE:  " + S:DISPLAY.
  if S:ACTIVE {
    PRINT "     SENSOR IS ALREADY ON.".
  } ELSE {
    PRINT "     SENSOR WAS OFF.  TURNING IT ON.".
    S:TOGGLE().
  }
}

// traverse parts for resources ------
PRINT " ".
PRINT "------------ Resorce Status -------------".
list parts in PS.
set n to 0.
for p in PS {
    if p:resources:length > 0 {
        print "["+ n +"] " + p:stage + " - " + p:name.
        for r in p:resources {
            set r:enabled to True.
			if r:enabled {
                set s to "enabled".
            } else {
                set s to "disabled".
            }
            print "          " + r:name + ", (" + round(r:amount) + "/" + round(r:capacity) + "), " + s.
        }
    }
	set n to n+1. //Position in List
}

// Countdown --------
PRINT "Counting down:".
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {set countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

// staging, throttle, steering -----
SAS OFF.
RCS OFF.
LOCK THROTTLE to 1.
LOCK STEERING to HEADING(0,90).

// PID-loop setup -------
set g to EARTH:MU / EARTH:RADIUS^2.
LOCK accvec to SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce to accvec:MAG / g.
LOCK CQ to SHIP:Q*constant:ATMtokPa*1000.
//-----------------
set MAXQ to 20000.
set MAXA to 2.
//-----------------
set Kp1 to 0.2.
set Ki1 to 0.05.
set Kd1 to 0.5.
//-----------------
set Kp2 to 0.01.
set Ki2 to 0.003.
set Kd2 to 0.007.
//-----------------
set PID1 to PIDLOOP(Kp1, Ki1, Kd1).
set PID2 to PIDLOOP(Kp2, Ki2, Kd2).
set PID1:SETPOINT to MAXQ.
set PID2:SETPOINT to MAXA.
//-----------------
set thrott to 1.
LOCK THROTTLE to thrott.
set TotalFuel to STAGE:LIQUIDFUEL.
LOCK CurrentFuel to STAGE:LIQUIDFUEL.
set AltCor to ALT:Radar.

// -------------------------------------
// Phase 2-Launch the vehicle
// -------------------------------------
CLEARSCREEN.
PRINT "Phase 2-Launch the vehicle".
PRINT "-------------------------------".
PRINT " ".

STAGE.

set TotalFuel to STAGE:LIQUIDFUEL.
LOCK CurrentFuel to STAGE:LIQUIDFUEL.
//-----------------
set Trigger to 0.
set display to 0.
set Ap to 70000.
UNTIL SHIP:APOAPSIS > Ap {
	if (display = 100) {
		CLEARSCREEN.
		set display to 0.
		PRINT "Phase 2-Launch the vehicle".
		PRINT "-------------------------------".
		PRINT " ".
		}
	if (CQ > MAXQ) {set Trigger to 1.}
	if (Trigger = 1) {
		set thrott to thrott + PID1:UPDATE(TIME:SECONDS, CQ)/MAXQ.
		PRINT "PID1:UPDATE    = " + Round(PID1:UPDATE(TIME:SECONDS, CQ)/MAXQ,4) AT (0,9).
	} 
	if (SHIP:ALTITUDE > 20000){ 
		set Trigger to 0.
		set thrott to thrott + PID2:UPDATE(TIME:SECONDS, gforce).
		PRINT "PID2:UPDATE    = " + Round(PID2:UPDATE(TIME:SECONDS, gforce),4) AT (0,9).
	}
	if thrott > 1 {set thrott to 1.}
	if thrott < 0 {set thrott to 0.}
	PRINT "APOAPSIS       = " + Round(SHIP:APOAPSIS,0) AT (0,2).
	PRINT "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + "  " AT (0,3).
	PRINT "RADAR = " + Round(ALT:RADAR,0) + "   Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" " AT (25,3).
	PRINT "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	PRINT "Q (Max: " + MAXQ +") = " + Round(CQ,0) AT (0,5).
	PRINT "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	PRINT "thrott         = " + Round(thrott*100,1)+"%  " AT (0,7).
	PRINT "Fuel           = " + Round(CurrentFuel/TotalFuel*100,1) +"%  " AT (0,8).
	set display to display + 1.
	WAIT 0.001.
}
set thrott to 0.
SAS ON.
RCS ON.
UNTIL SHIP:ALTITUDE > (SHIP:APOAPSIS - 100) {
	if (display = 100) {
		CLEARSCREEN.
		set display to 0.
		PRINT "Phase 2-Launch the vehicle".
		PRINT "-------------------------------".
		PRINT " ".
		}
	PRINT "APOAPSIS       = " + Round(SHIP:APOAPSIS,0) AT (0,2).
	PRINT "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + "  " AT (0,3).
	PRINT "RADAR = " + Round(ALT:RADAR,0) + "   Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" " AT (25,3).
	PRINT "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	PRINT "Q (Max: " + MAXQ +") = " + Round(CQ,0) AT (0,5).
	PRINT "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	PRINT "thrott         = " + Round(thrott*100,1)+"%  " AT (0,7).
	PRINT "Fuel           = " + Round(CurrentFuel/TotalFuel*100,1) +"%  " AT (0,8).
	set display to display + 1.
	WAIT 0.001.
}
BRAKES ON.

// -------------------------------------
// Phase 3- Return maneuver		
// -------------------------------------
CLEARSCREEN.
PRINT "Phase 3- Return maneuver".
PRINT "-------------------------------".
PRINT " ".

wait 2.

// -------------------------------------
// Phase 4- Reentry burn
// -------------------------------------
CLEARSCREEN.
PRINT "Phase 4- Reentry burn".
PRINT "-------------------------------".
PRINT " ".

set MAXSpeed to 800.
set Kp3 to 0.2.
set Ki3 to 0.005.
set Kd3 to 0.5.
//-----------------
set PID3 to PIDLOOP(Kp3, Ki3, Kd3).
set PID3:SETPOINT to MAXSpeed.
set Trigger to 0.
set DISPLAY to 0.

UNTIL SHIP:ALTITUDE < 40000 {
	if (display = 100) {
		CLEARSCREEN.
		set display to 0.
		PRINT "Phase 4- Reentry burn".
		PRINT "-------------------------------".
		PRINT " ".
		}
	if (ABS(SHIP:VERTICALSPEED) > MAXSpeed){set Trigger to 1.}
	if (Trigger = 1) {	
		set thrott to thrott - PID3:UPDATE(TIME:SECONDS, ABS(SHIP:VERTICALSPEED))/MAXSpeed.
		PRINT "PID3:UPDATE    = " + Round(PID3:UPDATE(TIME:SECONDS, ABS(SHIP:VERTICALSPEED)),4) AT (0,9).
	}
	if thrott > 1 {set thrott to 1.}
	if thrott < 0 {set thrott to 0.}
	PRINT "MAXSpeed       = " + Round(MAXSpeed,0) AT (0,2).
	PRINT "deltaSpeed = " + Round(ABS(MAXSpeed)-ABS(SHIP:VERTICALSPEED),0) AT (25,2).
	PRINT "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + "  " AT (0,3).
	PRINT "RADAR = " + Round(ALT:RADAR,0) + "   Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" " AT (25,3).
	PRINT "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	PRINT "Q (Max: " + MAXQ +") = " + Round(CQ,0) AT (0,5).
	PRINT "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	PRINT "thrott         = " + Round(thrott*100,1)+"%  " AT (0,7).
	PRINT "Fuel           = " + Round(CurrentFuel/TotalFuel*100,1) +"%  " AT (0,8).
	set display to display + 1.
	WAIT 0.001.
}
//set thrott to 0.
//wait until SHIP:ALTITUDE < 20000.
// -------------------------------------
// Phase 5- Landing (Suicid Burn)
// -------------------------------------
CLEARSCREEN.
PRINT "Phase 5- Landing (Suicid Burn)".
PRINT "-------------------------------".
PRINT " ".

set Kp4 to 0.2.
set Ki4 to 0.005.
set Kd4 to 0.5.
//-----------------
set PID4 to PIDLOOP(Kp4, Ki4, Kd4).
set Trigger to 0.
set DISPLAY to 0.
set Trigger2 to 1.
UNTIL SHIP:ALTITUDE = 0 {
	set PID4:SETPOINT to MAXSpeed.
	if (display = 100) {
		CLEARSCREEN.
		set display to 0.
		PRINT "Phase 5- Landing (Suicid Burn)".
		PRINT "-------------------------------".
		PRINT " ".
		}
	if (ABS(SHIP:VERTICALSPEED) > MAXSpeed){set Trigger to 1.}
	if (Trigger = 1) {	
		set thrott to thrott - PID4:UPDATE(TIME:SECONDS, ABS(SHIP:VERTICALSPEED))/MAXSpeed.
		PRINT "PID4:UPDATE    = " + Round(PID4:UPDATE(TIME:SECONDS, ABS(SHIP:VERTICALSPEED)),4) AT (0,9).
	}
	if thrott > 1 {set thrott to 1.}
	if thrott < 0 {set thrott to 0.}
	PRINT "MAXSpeed       = " + Round(MAXSpeed,0) AT (0,2).
	PRINT "deltaSpeed = " + Round(ABS(MAXSpeed)-ABS(SHIP:VERTICALSPEED),0) + "  " AT (25,2).
	PRINT "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + "  " AT (0,3).
	PRINT "RADAR = " + Round(ALT:RADAR,0) + "   Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" " AT (25,3).
	PRINT "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	PRINT "Q (Max: " + MAXQ +") = " + Round(CQ,0) AT (0,5).
	PRINT "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	PRINT "thrott         = " + Round(thrott*100,1)+"%  " AT (0,7).
	PRINT "Fuel           = " + Round(CurrentFuel/TotalFuel*100,1) +"%  " AT (0,8).
	set display to display + 1.
	if (ABS(SHIP:VERTICALSPEED) > 8  and Trigger2 = 1){
		set MAXSpeed to sqrt(25*(ABS(ALT:RADAR - AltCor))/2).
	} else {
		set MAXSpeed to 2.
		set Trigger2 to 0.
		}
	if (SHIP:ALTITUDE < 300 ){GEAR ON.}
	PRINT "RADAR - AltCor = " + Round(ALT:RADAR - AltCor,2) AT (0,10).
	if (ALT:RADAR - AltCor < 0 ){
		set thrott to 0.
		Break.}
	WAIT 0.001.
}
Print "Landing Process Finished" at(0,20).
wait until false.