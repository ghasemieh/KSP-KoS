SET MESSAGE TO "undock". // can be any serializable value or a primitive
SET P TO PROCESSOR("UpperCPU").
IF P:CONNECTION:SENDMESSAGE(MESSAGE) {
  PRINT "Message sent!".
}