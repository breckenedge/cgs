// Sharpie marking station for 1" x 5.5" cutting-practice strips.
//
// A gravity-feed dispenser in four parts:
//   base     - a magazine that holds a stack of strips, with a floor that
//              continues forward into a marking station
//   top      - a slotted plate over the marking station; its back edge is
//              the magazine's front wall, raised just enough off the floor
//              (the "throat") to let one strip through but not two
//   slider   - a comb of bars under the base; fingers poke up through the
//              floor just under one sheet high and push the bottom strip
//   follower - a plate that sits on the stack, held down by rubber bands so
//              the bottom strip stays flat and gripped as the stack runs low
//
// Use: load strips into the magazine and set the follower on top. Push the
// slider in and let go: the bottom strip slides through the throat into the
// marking station, shoving the strip that was already there out the front,
// and rubber bands snap the slider back. Mark through the slots. Repeat.
//
// Strips in the station butt edge to edge in a tunnel too low for two
// sheets to overlap, so they can't shingle. Sized for cardstock; the
// throat and finger heights are 2 and 1 layers at 0.2 mm.
//
// Assembly: set the slider on the table, lower the base onto it so the
// fingers drop into their floor slots, then press the top onto its pegs.
// Hook a band between each crossbar post and the frame post behind it.
// For the follower, hook a band from each fin notch down through the end
// wall slot to the leaning post outside.
// Units are mm.

part = "assembled"; // ["assembled", "print", "base", "top", "slider", "follower"]

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
crossbar_h = 6;
fit = 0.3;               // sliding clearance, each side

/* [Rubber bands] */
// Sized for 1-3/4" (#12) bands; post spacing at rest
return_band_gap = 45;
post_d = 5;
post_h = 8;
band_slot_w = 4;         // slots in the end walls the follower bands pass through

/* [Follower] */
follower_t = 3;
fin_t = 4;
fin_h = 40;
fin_base_w = 30;

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

// slider crossbar at rest, and the frame behind it the return bands pull to
crossbar_front = back_y - travel - 1;
crossbar_post_y = crossbar_front - crossbar_d / 2;
crossbar_post_xs = [finger_xs[0], finger_xs[len(finger_xs) - 1]];
frame_post_y = crossbar_post_y - return_band_gap;
frame_back_y = frame_post_y - 5;
rail_w = 6;

// follower band anchors, outside each end wall
ear_l = 14;
ear_w = 12;

module box(x0, x1, y0, y1, z0, z1) {
    translate([x0, y0, z0]) cube([x1 - x0, y1 - y0, z1 - z0]);
}

// the cap flares at 45 degrees so it prints without support; posts that
// lean have no cap, since the band's pull already slides it to the base
module band_post(cap = true) {
    translate([0, 0, -0.5]) cylinder(d = post_d, h = post_h + 0.5);
    if (cap)
        translate([0, 0, post_h - 1.5]) {
            cylinder(d1 = post_d, d2 = post_d + 3, h = 1.5);
            translate([0, 0, 1.5]) cylinder(d = post_d + 3, h = 1);
        }
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
            // frame behind the slider for the return bands
            for (x = [[outer_x0, outer_x0 + rail_w], [outer_x1 - rail_w, outer_x1]])
                box(x[0], x[1], frame_back_y, back_y, 0, floor_z);
            box(outer_x0, outer_x1, frame_back_y, frame_post_y + 5, 0, floor_z);
            for (x = crossbar_post_xs)
                translate([x, frame_post_y, floor_z]) band_post();
            // ears with posts for the follower bands, leaning outward so the
            // bands ride down to the base of the post
            for (s = [-1, 1]) {
                ear_x = s < 0 ? outer_x0 : outer_x1;
                box(min(ear_x, ear_x + s * ear_l), max(ear_x, ear_x + s * ear_l),
                    inner_w / 2 - ear_w / 2, inner_w / 2 + ear_w / 2, 0, floor_z);
                translate([ear_x + s * 4, inner_w / 2, floor_z - 0.5])
                    rotate([0, s * 45, 0]) band_post(cap = false);
            }
        }
        for (x = finger_xs) {
            // channel for the slider bar, open underneath and at the back
            box(x - bar_w / 2 - fit, x + bar_w / 2 + fit,
                back_y - 1, finger_slot_front + 2, -1, channel_h);
            // finger slot through the floor (and under the back wall)
            box(x - finger_w / 2 - fit, x + finger_w / 2 + fit,
                finger_slot_back, finger_slot_front, -1, floor_z + 1);
        }
        // slots in the end walls for the follower bands
        for (x = [[outer_x0 - 1, 1], [inner_l - 1, outer_x1 + 1]])
            box(x[0], x[1], inner_w / 2 - band_slot_w / 2, inner_w / 2 + band_slot_w / 2,
                floor_z + 2, floor_z + mag_h + 1);
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
    box(crossbar_post_xs[0] - bar_w, crossbar_post_xs[1] + bar_w,
        crossbar_front - crossbar_d, crossbar_front, 0, crossbar_h);
    for (x = crossbar_post_xs)
        translate([x, crossbar_post_y, crossbar_h]) band_post();
}

// modeled sitting on its own bottom face, centered over the magazine
module follower() {
    cx = inner_l / 2;
    top_half_w = fin_base_w / 2 + fin_h;   // 45 degree sides print unsupported
    difference() {
        union() {
            box(fit * 2, inner_l - fit * 2, fit * 2, inner_w - fit * 2, 0, follower_t);
            // fin: the handle, and the high anchor for the bands
            translate([0, inner_w / 2 + fin_t / 2, 0])
                rotate([90, 0, 0])
                    linear_extrude(fin_t)
                        polygon([
                            [cx - fin_base_w / 2, 0],
                            [cx + fin_base_w / 2, 0],
                            [cx + top_half_w, follower_t + fin_h],
                            [cx - top_half_w, follower_t + fin_h],
                        ]);
        }
        // band notches near the fin's top corners
        for (s = [-1, 1])
            translate([cx + s * (top_half_w - 10), inner_w / 2, follower_t + fin_h - 2.5])
                cube([3, fin_t + 2, 5.01], center = true);
    }
}

if (part == "base") base();
else if (part == "top") top();
else if (part == "slider") slider();
else if (part == "follower") follower();
else if (part == "print") {
    base();
    translate([0, front_y + 10 - inner_w, 0]) top();
    slider_dy = frame_back_y - 10 - (finger_rest + 1);
    translate([0, slider_dy, 0]) slider();
    translate([0, slider_dy + crossbar_front - crossbar_d - 10 - inner_w, 0]) follower();
}
else if (part == "assembled") {
    base();
    color("orange", 0.85) translate([0, 0, floor_z + throat]) top();
    color("steelblue") slider();
    color("seagreen") translate([0, 0, floor_z + 15]) follower();
}
