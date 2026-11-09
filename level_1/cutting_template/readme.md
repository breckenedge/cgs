# Cutting Strip Marking Station (abandoned)

An experiment in 3D-printing a tool to mark 1" x 5.5" cardstock strips with Sharpie lines, so children have something to practice cutting along. It works on paper (in OpenSCAD, anyway), but it was never printed and won't be used.

## What we were trying to do

Children practicing with scissors cut 1" x 5.5" strips into short pieces along pre-drawn lines. Drawing those lines by hand on dozens of strips is tedious, so the goal was a template that makes the lines quick and consistent: first straight lines, then gentle arcs so the children could also practice following a curve.

## How the design evolved

1. **Base and lid.** A tray holds one strip and a slotted lid drops on top. You draw a line through each slot.
2. **One-piece cap.** A slotted cap with lips that hook over the corner of a stack of strips. You mark the top strip, tip the cap back and slide the strip out.
3. **One-piece sled.** The back lip is replaced by a ridge one sheet thick, so pulling the sled toward you pushes the top strip off the stack.
4. **Gravity-feed dispenser.** This is where it ended up, in `cutting_template.scad`:
   - **base:** a magazine holding the stack, with a floor that continues forward into a marking station.
   - **gate:** the magazine's front wall, raised 0.4 mm off the floor so one strip passes under it but not two.
   - **template:** a slotted plate over the marking station. It lifts off its pegs, so templates with straight slots (`template_straight.stl`) or arcs (`template_arc.stl`) can be swapped.
   - **slider:** dovetailed bars under the base, with fingers just under one sheet high. Pushing the slider in feeds the bottom strip into the marking station and pushes the previous strip out the front. A snap latch holds the slider at rest.
   - **follower:** a plate on top of the stack, held down with rubber bands.

   Rubber bands return the slider and hold the follower down. Every part prints without supports.

## Why it was abandoned

Catechesis of the Good Shepherd asks for *poverty of the materials*: materials in the atrium are meant to be simple, just what the work needs, with nothing to distract from it. A child, or an adult preparing the work, should be able to see how something is made and make it again. A four-part machine with rubber bands, snap latches and layer-height tolerances is the opposite of that. Preparing cutting strips is better done the plain way: a ruler and a marker, or lines printed on the sheet before it is cut into strips.

So this design stays here as a record, and the cutting strips will be made without it.
