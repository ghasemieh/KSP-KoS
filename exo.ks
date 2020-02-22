// -------------------------------------
// Phase 1- Vehicle Initialization
// -------------------------------------
clearscreen.
print "Phase 1- Vehicle Initialization".
print "-------------------------------".
print " ".

// Turn On all Sensors  -----
print "----- Sensors Activation and Status -----".
list SENSORS in SENSElist.

// TURN EVERY SINGLE SENSOR ON -----
for S in SENSElist {
  print "SENSOR: " + S:TYPE.
  print "VALUE:  " + S:DISPLAY.
  if S:ACTIVE {
    print "     SENSOR IS ALREADY ON.".
  } else {
    print "     SENSOR WAS OFF.  TURNING IT ON.".
    S:TOGGLE().
  }
}

// traverse parts for resources ------
print " ".
print "------------ Resorce Status -------------".
list parts in PS.
set n to  0.
for p in PS {
    if p:resources:length > 0 {
        print "["+ n +"] " + p:stage + " - " + p:name.
        for r in p:resources {
            set r:enabled to  True.
			if r:enabled {
                set s to  "enabled".
            } else {
                set s to  "disabled".
            }
            print "          " + r:name + ", (" + round(r:amount) + "/" + round(r:capacity) + "), " + s.
        }
    }
	set n to  n+1. //Position in list
}

// Countdown --------
print "Counting down:".
from {local countdown is 5.} until countdown = 0 step {set countdown to  countdown - 1.} DO {
    print "..." + countdown.
    wait 1. // pauses the script here for 1 second.
}

// staging, throttle, steering -----
SAS OFF.
RCS OFF.
lock THROTTLE to  0.
lock STEERING to  HEADING(0,90).

lock CurrentFuel to Stage:Resources:Amount.
lock TotalFuel to Stage:Resources:Capacity.

set g to  EARTH:MU / EARTH:RADIUS^2.
lock accvec to  SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
lock gforce to  accvec:MAG / g.
lock CQ to  SHIP:Q*constant:ATMtokPa*1000.
//-----------------
set MAXQ to  20000.
set MAXA to  2.
//-----------------
set Kp1 to  0.2.
set Ki1 to  0.05.
set Kd1 to  0.5.
//-----------------
set Kp2 to  0.01.
set Ki2 to  0.003.
set Kd2 to  0.007.
//-----------------
set PID1 to  PIDLOOP(Kp1, Ki1, Kd1).
set PID2 to  PIDLOOP(Kp2, Ki2, Kd2).
set PID1:setPOINT to  MAXQ.
set PID2:setPOINT to  MAXA.
set PID1:MINOUTPUT to -50.
set PID1:MAXOUTPUT to 50.
set PID2:MINOUTPUT to -5.
set PID2:MAXOUTPUT to 5.
//-----------------
set thrott to  1.
lock THROTTLE to  thrott.
set AltCor to  ALT:Radar.

// -------------------------------------
// Phase 2-Launch the vehicle
// -------------------------------------
clearscreen.
print "Phase 2-Launch the vehicle".
print "-------------------------------".
print " ".

stage.


//-----------------
set Trigger0 to  0.
set display to  0.
set Ap to  75000.
until SHIP:APOAPSIS > Ap {
	if (display = 100) {
		clearscreen.
		set display to  0.
		print "Phase 2-Launch the vehicle".
		print "-------------------------------".
		print " ".
		}
	if (CQ > MAXQ) {set Trigger0 to  1.}
	if (Trigger0 = 1) {
		set thrott to  thrott + PID1:UPDATE(TIME:SECONDS, CQ)/MAXQ.
		print "PID1:UPDATE    = " + Round(PID1:UPDATE(TIME:SECONDS, CQ)/MAXQ,4) AT (0,9).
	} 
	if (SHIP:ALTITUDE > 20000){ 
		set Trigger0 to  0.
		set thrott to  thrott + PID2:UPDATE(TIME:SECONDS, gforce).
		print "PID2:UPDATE    = " + Round(PID2:UPDATE(TIME:SECONDS, gforce),4) AT (0,9).
	}
	if thrott > 1 {set thrott to  1.}
	if thrott < 0 {set thrott to  0.}
	print "APOAPSIS       = " + Round(SHIP:APOAPSIS,0) + " m" AT (0,2).
	print "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + " m" AT (0,3).
	print "RADAR = " + Round(ALT:RADAR,0) + " m  Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" m" AT (27,3).
	print "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	print "Q (Max: " + MAXQ +") = " + Round(CQ,0) + " Pa" AT (0,5).
	print "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	print "Throttel       = " + Round(thrott*100,1)+"%  " AT (0,7).
	
	set display to  display + 1.
	wait 0.001.
}
set thrott to  0.
SAS ON.
RCS ON.
until SHIP:ALTITUDE > (SHIP:APOAPSIS - 100) {
	if (display = 100) {
		clearscreen.
		set display to  0.
		print "Phase 2-Launch the vehicle".
		print "-------------------------------".
		print " ".
		}
	print "APOAPSIS       = " + Round(SHIP:APOAPSIS,0) + " m" AT (0,2).
	print "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + " m" AT (0,3).
	print "RADAR = " + Round(ALT:RADAR,0) + " m  Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" m" AT (27,3).
	print "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	print "Q (Max: " + MAXQ +") = " + Round(CQ,0) + " Pa" AT (0,5).
	print "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	print "Throttel       = " + Round(thrott*100,1)+"%  " AT (0,7).
	
	set display to  display + 1.
	wait 0.001.
}


BRAKES ON.

// -------------------------------------
// Phase 3- Return maneuver		
// -------------------------------------
clearscreen.
print "Phase 3- Return maneuver".
print "-------------------------------".
print " ".


wait 5.

// -------------------------------------
// Phase 4- Reentry burn
// -------------------------------------
clearscreen.
print "Phase 4- Reentry burn".
print "-------------------------------".
print " ".

set MAXSpeed to  -800.
set Kp3 to  0.2.
set Ki3 to  0.02.
set Kd3 to  0.5.
//-----------------
set PID3 to  PIDLOOP(Kp3, Ki3, Kd3).
set PID3:setPOINT to  MAXSpeed.
set PID3:MINOUTPUT to -5.
set PID3:MAXOUTPUT to 5.
set Trigger1 to  0.
set DISPLAY to  0.
AG1 ON.

until SHIP:ALTITUDE < 40000 {
	if (SHIP:VERTICALSPEED < MAXSpeed){set Trigger1 to  1.}
	if (Trigger1 = 1) {	
		set thrott to  thrott + PID3:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED)/ABS(MAXSpeed).
		print "PID3:UPDATE    = " + Round(PID3:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED),4) AT (0,9).
	}
	if thrott > 1 {set thrott to  1.}
	if thrott < 0 {set thrott to  0.}
	if (display = 100) {
		clearscreen.
		set display to  0.
		print "Phase 4- Reentry burn".
		print "-------------------------------".
		print " ".
	}
	Print "AG1 Status: " + AG1 at(40,0).
	print "MAXSpeed       = " + Round(MAXSpeed,0) + " m/s " AT (0,2).
	print "deltaSpeed = " + Round(MAXSpeed-SHIP:VERTICALSPEED,1) + " m/s" AT (27,2).
	print "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + " m" AT (0,3).
	print "RADAR = " + Round(ALT:RADAR,0) + " m  Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" m" AT (27,3).
	print "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	print "Q (Max: " + MAXQ +") = " + Round(CQ,0) + " Pa" AT (0,5).
	print "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	print "Throttel       = " + Round(thrott*100,1)+"%  " AT (0,7).
	
	print "AltCor = " + Round(AltCor,2) + " m" AT (0,10).
	print "RADAR - AltCor = " + Round(ALT:RADAR - AltCor,2) + " m" AT (0,11).
	set display to  display + 1.
	wait 0.001.
}

// -------------------------------------
// Phase 5- Landing (Suicid Burn)
// -------------------------------------
clearscreen.
print "Phase 5- Landing (Suicid Burn)".
print "-------------------------------".
print " ".

set Kp4 to  0.2.
set Ki4 to  0.02.
set Kd4 to  0.5.
//-----------------
set PID4 to  PIDLOOP(Kp4, Ki4, Kd4).
set PID4:MINOUTPUT to -5.
set PID4:MAXOUTPUT to 5.
set Trigger2 to  0.
set Trigger3 to  1.
set DISPLAY to  0.
until SHIP:ALTITUDE = 0 {
	set PID4:setPOINT to  MAXSpeed.
	if (SHIP:VERTICALSPEED < MAXSpeed){set Trigger2 to  1.}
	if (Trigger2 = 1) {	
		set thrott to  thrott + PID4:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED)/ABS(MAXSpeed).
		print "PID4:UPDATE    = " + Round(PID4:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED),4) AT (0,9).
	}
	if thrott > 1 {set thrott to  1.}
	if thrott < 0 {set thrott to  0.}
	if (ABS(SHIP:VERTICALSPEED) > 8  and Trigger3 = 1){
		set MAXSpeed to  -1*sqrt(25*(ABS(ALT:RADAR - AltCor))/2).
	} else {
		set MAXSpeed to  -2.
		set Trigger3 to  0.
	}
	if (ALT:RADAR - AltCor < 0 ){
		set thrott to  0.
		set Trigger2 to  0.
		Break.
	}
	if (SHIP:ALTITUDE < 300 ){GEAR ON.}
	// ------ Dashboard --------
	if (display = 100) {
		clearscreen.
		set display to  0.
		print "Phase 5- Landing (Suicid Burn)".
		print "-------------------------------".
		print " ".
	}
	Print "AG1 Status: " + AG1 at(40,0).
	print "MAXSpeed       = " + Round(MAXSpeed,0) + " m/s " AT (0,2).
	print "deltaSpeed = " + Round(MAXSpeed-SHIP:VERTICALSPEED,1) + " m/s" AT (27,2).
	print "ALTITUDE       = " + Round(SHIP:ALTITUDE,0) + " m" AT (0,3).
	print "RADAR = " + Round(ALT:RADAR,0) + " m  Diff = " + Round(SHIP:ALTITUDE - ALT:RADAR,1) +" m" AT (27,3).
	print "Vertical Speed = " + Round(SHIP:VERTICALSPEED,0) +" m/s  =  " +  Round(SHIP:VERTICALSPEED*3.6,0) + " Km/h " AT (0,4).
	print "Q (Max: " + MAXQ +") = " + Round(CQ,0) + " Pa" AT (0,5).
	print "gforce         = " + Round(gforce,3) + "g = " + Round(accvec:MAG,2) + " m^2/s"  AT (0,6) .
	print "Throttel       = " + Round(thrott*100,1)+"%  " AT (0,7).
	
	print "AltCor = " + Round(AltCor,2) + " m" AT (0,10).
	print "RADAR - AltCor = " + Round(ALT:RADAR - AltCor,2) + " m" AT (0,11).
	set display to  display + 1.
	wait 0.001.
}
print "Landing Process Finished" at(0,20).
SAS OFF.
RCS OFF.
set i to  1.
list ENGINES in myEngine.
for eng in myEngine {
	eng:SHUTDOWN().
	print i + "th Engines off" at(0,21+i).
	set i to  i+1.
}
wait until false.