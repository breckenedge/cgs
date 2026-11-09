// Sharpie marking station for 1" x 5.5" cutting-practice strips.
//
// A gravity-feed dispenser in three parts:
//   base   - a magazine that holds a stack of strips, with a floor that
//            continues forward into a marking station
//   top    - a slotted plate over the marking station; its back edge is the
//            magazine's front wall, raised just enough off the floor (the
//            "throat") to let one strip through but not two
//   slider - a comb of bars under the base; fingers poke up through the
//            floor just under one sheet high and push the bottom strip
//
// Use: load strips into the magazine. Push the slider in: the bottom strip
// slides through the throat into the marking station, shoving the strip
// that was already there out the front. Mark through the slots. Pull the
// slider back; the fingers ramp under the stack and drop behind it. Repeat.
//
// Strips in the station butt edge to edge in a tunnel too low for two
// sheets to overlap, so they can't shingle. Sized for cardstock; the
// throat and finger heights are 2 and 1 layers at 0.2 mm.
//
// Assembly: set the slider on the table, lower the base onto it so the
// fingers drop into their floor slots, then press the top onto its pegs.
// Units are mm.

part = "assembled"; // ["assembled", "print", "base", "top", "slider"]

/* [Paper] */
inch = 25.4;
paper_w = 1 * inch;      // short side of the strip
paper_l = 5.5 * inch;    // long side of the strip
paper_clearance = 0.6;
throat = 0.4;            // between 1 and 2 sheets thick
pusher_h = 0.2;          // finger height above the floor, under 1 sheet

/* [Lines] */
// Number of strips each paper gets divided into (lines = strips - 1)
strips = 11;             // 11 -> 1/2" strips

/* [Slots] */
slot_w = 1.6;            // width at the paper
slot_top_w = 4;          // width at the top, so the Sharpie's cone reaches down
slot_overrun = 2;        // how far slots run past the paper edges

/* [Body] */
mag_h = 30;              // magazine height above the floor
wall_t = 3;
end_wall_t = 7;          // wide enough for the top's locating pegs
gate_t = 3;              // magazine front wall, part of the top
plate_t = 2.5;
front_margin = 4;
peg_d = 3;
peg_h = 2;

/* [Slider] */
bar_w = 8;
bar_t = 3;
finger_w = 2;
finger_l = 4;
crossbar_d = 10;
crossbar_h = 12;
fit = 0.3;               // sliding clearance, each side

$fn = 48;

pitch = paper_l / strips;
inner_l = paper_l + paper_clearance;
inner_w = paper_w + paper_clearance;   // magazine depth, y in [0, inner_w]

channel_h = bar_t + 2 * fit;
floor_z = channel_h + 1.6;             // keep a multiple of the layer height

// where the strip's back edge sits in the marking station
station_y = inner_w + gate_t + slot_overrun + 0.5;
front_y = station_y + paper_w + slot_overrun + front_margin;

finger_rest = -0.5;                    // finger front face, just behind the stack
travel = station_y - finger_rest;
finger_slot_back = finger_rest - finger_l - fit;
finger_slot_front = station_y + fit;
back_y = min(-wall_t, finger_slot_back) - 2.5;

// fingers go between lines so the paper is supported under every mark
finger_xs = [for (f = [0.15, 0.5, 0.85]) (floor(strips * f) + 0.5) * pitch];

outer_x0 = -end_wall_t;
outer_x1 = inner_l + end_wall_t;
peg_ys = [inner_w + gate_t + 4, front_y - 4];

module box(x0, x1, y0, y1, z0, z1) {
    translate([x0, y0, z0]) cube([x1 - x0, y1 - y0, z1 - z0]);
}

module base() {
    difference() {
        union() {
            // floor
            box(outer_x0, outer_x1, back_y, front_y, 0, floor_z);
            // magazine back wall
            box(outer_x0, outer_x1, -wall_t, 0, 0, floor_z + mag_h);
            // magazine end walls
            for (x = [[outer_x0, 0], [inner_l, outer_x1]])
                box(x[0], x[1], -wall_t, inner_w, 0, floor_z + mag_h);
            // station end ledges the top rests on; they set the throat
            for (x = [[outer_x0, 0], [inner_l, outer_x1]])
                box(x[0], x[1], inner_w, front_y, 0, floor_z + throat);
            // pegs locating the top
            for (x = [outer_x0 / 2, inner_l - outer_x0 / 2], y = peg_ys)
                translate([x, y, floor_z + throat])
                    cylinder(d = peg_d, h = peg_h);
        }
        for (x = finger_xs) {
            // channel for the slider bar, open underneath and at the back
            box(x - bar_w / 2 - fit, x + bar_w / 2 + fit,
                back_y - 1, finger_slot_front + 2, -1, channel_h);
            // finger slot through the floor (and under the back wall)
            box(x - finger_w / 2 - fit, x + finger_w / 2 + fit,
                finger_slot_back, finger_slot_front, -1, floor_z + 1);
        }
    }
}

module slot(len) {
    hull() {
        translate([-slot_w / 2, 0, -0.01])
            cube([slot_w, len, 0.01]);
        translate([-slot_top_w / 2, 0, plate_t])
            cube([slot_top_w, len, 0.01]);
    }
}

// modeled sitting on its own bottom face; it rests at floor_z + throat
module top() {
    difference() {
        union() {
            box(outer_x0, outer_x1, inner_w, front_y, 0, plate_t);
            // gate: the magazine's front wall
            box(outer_x0, outer_x1, inner_w, inner_w + gate_t, 0, mag_h - throat);
        }
        for (i = [1 : strips - 1])
            translate([i * pitch, station_y - slot_overrun, 0])
                slot(paper_w + 2 * slot_overrun);
        for (x = [outer_x0 / 2, inner_l - outer_x0 / 2], y = peg_ys)
            translate([x, y, -1])
                cylinder(d = peg_d + 2 * fit, h = plate_t + 2);
    }
}

// modeled at rest, retracted, with the finger fronts at finger_rest
module slider() {
    crossbar_front = back_y - travel - 1;
    for (x = finger_xs) {
        box(x - bar_w / 2, x + bar_w / 2, crossbar_front, finger_rest + 1, 0, bar_t);
        // finger: square front for pushing, ramped back for sliding under
        // the stack on the return stroke
        translate([x - finger_w / 2, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(finger_w)
                    polygon([
                        [finger_rest, 0],
                        [finger_rest, floor_z + pusher_h],
                        [finger_rest - 1, floor_z + pusher_h],
                        [finger_rest - finger_l, floor_z - 0.6],
                        [finger_rest - finger_l, 0],
                    ]);
    }
    box(finger_xs[0] - bar_w, finger_xs[len(finger_xs) - 1] + bar_w,
        crossbar_front - crossbar_d, crossbar_front, 0, crossbar_h);
}

if (part == "base") base();
else if (part == "top") top();
else if (part == "slider") slider();
else if (part == "print") {
    base();
    translate([0, front_y - back_y + 10 - inner_w, 0]) top();
    translate([0, -(front_y - back_y) - 10, 0]) slider();
}
else if (part == "assembled") {
    base();
    color("orange", 0.85) translate([0, 0, floor_z + throat]) top();
    color("steelblue") slider();
}
