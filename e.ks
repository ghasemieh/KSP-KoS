WAIT UNTIL NOT CORE:MESSAGES:EMPTY. // make sure we've received something
SET RECEIVED TO CORE:MESSAGES:POP.
IF RECEIVED:CONTENT = "undock" {
  PRINT "Message Recieved...".
  lock STEERING to  HEADING(80,90).
  SAS ON.
  RCS ON.
  wait 5.
  stage.
  wait 15.
  stage.
  set THROTTLE to  1.
  PRINT "Engine Started...".
} ELSE {
  PRINT "Unexpected message: " + RECEIVED:CONTENT.
}