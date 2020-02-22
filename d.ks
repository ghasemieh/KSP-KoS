SET spot TO LATLNG(10, 20).     // Initialize point at latitude 10,
                                // longitude 20

PRINT spot:LAT.                 // Print 10
PRINT spot:LNG.                 // Print 20

PRINT spot:DISTANCE.            // Print distance from vessel to x
PRINT spot:HEADING.             // Print the heading to the point
PRINT spot:BEARING.             // Print the heading to the point
                                // relative to vessel heading

SET spot TO SHIP:GEOPOSITION.   // Make spot into a location on the
                                // surface directly underneath the
                                // current ship

SET spot TO LATLNG(spot:LAT,spot:LNG+5). // Make spot into a new
                                         // location 5 degrees east
                                         // of the old one

// Point nose of ship at a spot 100,000 meters altitude above a
// particular known latitude of 50 east, 20.2 north:
LOCK STEERING TO LATLNG(50,20.2):ALTITUDEPOSITION(100000).

// A nice complex example:
// -------------------------
// Drawing an debug arrow in 3D space at the spot where the GeoCoordinate
// "spot" is:
// It starts at a position 100m above the ground altitude and is aimed down
// at the spot on the ground:
SET VD TO VECDRAWARGS(
              spot:ALTITUDEPOSITION(spot:TERRAINHEIGHT+100),
              spot:POSITION - spot:ALTITUDEPOSITION(TERRAINHEIGHT+100),
              red, "THIS IS THE SPOT", 1, true).

PRINT "THESE TWO NUMBERS SHOULD BE THE SAME:".
PRINT (SHIP:ALTITIUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).
PRINT ALT:RADAR.