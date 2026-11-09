// Sharpie marking station for 1" x 5.5" cutting-practice strips.
//
// A gravity-feed dispenser:
//   base     - a magazine that holds a stack of strips, with a floor that
//              continues forward into a marking station
//   gate     - the magazine's front wall, raised just enough off the floor
//              (the "throat") to let one strip through but not two
//   template - a slotted plate over the marking station; it lifts off its
//              pegs so templates with straight or curved slots can be swapped
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
// Assembly: set the slider in the frame behind the base and slide it
// forward into the dovetail channels until the latch arms at the ends of
// its crossbar click past the stops on the frame rails (squeeze the arms
// inward to take it out again). Press the gate and a template onto their
// pegs.
// Hook a band between each crossbar post and the frame post behind it.
// For the follower, hook a band from each fin notch down through the end
// wall slot to the leaning post outside.
// Units are mm.

part = "assembled"; // ["assembled", "print", "base", "gate", "template", "slider", "follower"]

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
template = "arc"; // ["straight", "arc"]
// How far an arc bows out over the strip's 1" width
arc_sagitta = 3;
slot_w = 1.6;            // width at the paper
slot_top_w = 4;          // width at the top, so the Sharpie's cone reaches down
slot_overrun = 2;        // how far slots run past the paper edges

/* [Body] */
mag_h = 30;              // magazine height above the floor
wall_t = 3;
end_wall_t = 7;          // wide enough for the top's locating pegs
gate_t = 3;
gate_foot = 9;           // depth of the gate's base plate, with room for its pegs
plate_t = 2.5;
front_margin = 4;
peg_d = 3;
peg_h = 2;

/* [Slider] */
bar_bottom_w = 4;        // dovetail: narrow where the bar sits on the table,
bar_flare = 1.5;         // flaring at 45 degrees over this height
bar_t = 3;
finger_w = 2;
finger_l = 4;
crossbar_d = 10;
crossbar_h = 6;
fit = 0.3;               // sliding clearance, each side
latch_arm_l = 22;        // long and thin so PLA flexes without cracking
latch_arm_t = 1.8;
latch_tooth = 1.5;       // how far the tooth sticks out past the arm
latch_tooth_l = 3;
latch_stop_l = 3;

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

// channel profile: the bar's dovetail plus clearance, then a roof closing
// at 45 degrees up to the finger slot so it prints without support
channel_bottom_half = bar_bottom_w / 2 + fit * sqrt(2);
channel_half = channel_bottom_half + bar_flare;
finger_slot_half = finger_w / 2 + fit;
channel_peak = bar_t + fit + channel_half - finger_slot_half;
layer_h = 0.2;
floor_z = ceil((channel_peak + 0.8) / layer_h) * layer_h;

// where the strip's back edge sits in the marking station; slots have
// rounded ends that reach slot_top_w / 2 past their centerline
template_y = inner_w + gate_foot;
station_y = template_y + slot_overrun + slot_top_w / 2 + 2;
front_y = station_y + paper_w + slot_overrun + slot_top_w / 2 + front_margin;

finger_rest = -0.5;                    // finger front face, just behind the stack
travel = station_y - finger_rest;
finger_slot_back = finger_rest - finger_l - fit;
finger_slot_front = station_y + fit;
back_y = min(-wall_t, finger_slot_back) - 2.5;

// fingers go between lines so the paper is supported under every mark
finger_xs = [for (f = [0.15, 0.5, 0.85]) (floor(strips * f) + 0.5) * pitch];

outer_x0 = -end_wall_t;
outer_x1 = inner_l + end_wall_t;
peg_xs = [outer_x0 / 2, inner_l - outer_x0 / 2];
gate_peg_y = inner_w + (gate_t + gate_foot) / 2;
template_peg_ys = [template_y + 4, front_y - 4];
peg_ys = concat([gate_peg_y], template_peg_ys);

// slider crossbar at rest, and the frame behind it the return bands pull to
crossbar_front = back_y - travel - 1;
crossbar_post_y = crossbar_front - crossbar_d / 2;
crossbar_post_xs = [finger_xs[0], finger_xs[len(finger_xs) - 1]];
frame_post_y = crossbar_post_y - return_band_gap;
frame_back_y = frame_post_y - 5;
rail_w = 6;

// crossbar ends carry latch arms that run back alongside the frame rails;
// the tooth on each arm catches a stop on the rail at rest
crossbar_x0 = outer_x0 + rail_w + 2;
crossbar_x1 = outer_x1 - rail_w - 2;
latch_tip_y = crossbar_front - crossbar_d - latch_arm_l;
latch_stop_y = latch_tip_y - latch_stop_l;

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

// cross-sections in x-z, centered on the bar
module bar_profile() {
    b = bar_bottom_w / 2;
    polygon([
        [-b, 0], [b, 0], [b + bar_flare, bar_flare], [b + bar_flare, bar_t],
        [-b - bar_flare, bar_t], [-b - bar_flare, bar_flare],
    ]);
}

module channel_profile() {
    b = channel_bottom_half;
    top = bar_t + fit;
    polygon([
        [-(b - 1), -1], [b - 1, -1],
        [channel_half, bar_flare], [channel_half, top],
        [finger_slot_half, channel_peak], [-finger_slot_half, channel_peak],
        [-channel_half, top], [-channel_half, bar_flare],
    ]);
}

module extrude_y(y0, y1) {
    translate([0, y1, 0])
        rotate([90, 0, 0])
            linear_extrude(y1 - y0)
                children();
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
            for (x = peg_xs, y = peg_ys)
                translate([x, y, floor_z + throat])
                    cylinder(d = peg_d, h = peg_h);
            // frame behind the slider for the return bands
            for (x = [[outer_x0, outer_x0 + rail_w], [outer_x1 - rail_w, outer_x1]])
                box(x[0], x[1], frame_back_y, back_y, 0, floor_z);
            box(outer_x0, outer_x1, frame_back_y, frame_post_y + 5, 0, floor_z);
            for (x = crossbar_post_xs)
                translate([x, frame_post_y, floor_z]) band_post();
            // stops the latch teeth catch on
            box(outer_x0 + rail_w - 0.01, crossbar_x0 - 0.5,
                latch_stop_y, latch_tip_y, 0, floor_z);
            box(crossbar_x1 + 0.5, outer_x1 - rail_w + 0.01,
                latch_stop_y, latch_tip_y, 0, floor_z);
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
            // dovetail channel for the slider bar, open at the back
            translate([x, 0, 0])
                extrude_y(back_y - 1, finger_slot_front + 2) channel_profile();
            // finger slot through the floor (and under the back wall),
            // open at the back so the fingers can slide in
            box(x - finger_w / 2 - fit, x + finger_w / 2 + fit,
                back_y - 1, finger_slot_front, -1, floor_z + 1);
        }
        // slots in the end walls for the follower bands
        for (x = [[outer_x0 - 1, 1], [inner_l - 1, outer_x1 + 1]])
            box(x[0], x[1], inner_w / 2 - band_slot_w / 2, inner_w / 2 + band_slot_w / 2,
                floor_z + 2, floor_z + mag_h + 1);
    }
}

// sideways offset of a slot's centerline at distance y across the strip
// (0 at the back edge, paper_w at the front)
function slot_offset(y) =
    template == "arc"
        ? let(r = (paper_w * paper_w / 4 + arc_sagitta * arc_sagitta) / (2 * arc_sagitta),
              d = y - paper_w / 2)
          sqrt(r * r - d * d) - (r - arc_sagitta)
        : 0;

// a slot swept along its centerline: narrow at the paper, wide at the top
// so the Sharpie's cone reaches down
module slot() {
    n = template == "straight" ? 1 : 24;
    ys = [for (i = [0 : n]) -slot_overrun + i * (paper_w + 2 * slot_overrun) / n];
    for (i = [0 : n - 1])
        hull()
            for (y = [ys[i], ys[i + 1]])
                translate([slot_offset(y), y, -0.01])
                    cylinder(d1 = slot_w, d2 = slot_top_w, h = plate_t + 0.02);
}

// modeled sitting on its own bottom face; it rests at floor_z + throat
module gate() {
    difference() {
        union() {
            box(outer_x0, outer_x1, inner_w, template_y, 0, plate_t);
            box(outer_x0, outer_x1, inner_w, inner_w + gate_t, 0, mag_h - throat);
        }
        for (x = peg_xs)
            translate([x, gate_peg_y, -1])
                cylinder(d = peg_d + 2 * fit, h = plate_t + 2);
    }
}

// modeled sitting on its own bottom face; it rests at floor_z + throat
module template() {
    difference() {
        box(outer_x0, outer_x1, template_y + fit, front_y, 0, plate_t);
        for (i = [1 : strips - 1])
            translate([i * pitch, station_y, 0]) slot();
        for (x = peg_xs, y = template_peg_ys)
            translate([x, y, -1])
                cylinder(d = peg_d + 2 * fit, h = plate_t + 2);
    }
}

// modeled at rest, retracted, with the finger fronts at finger_rest
module slider() {
    for (x = finger_xs) {
        translate([x, 0, 0])
            extrude_y(crossbar_front - 0.01, finger_rest + 1) bar_profile();
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
    box(crossbar_x0, crossbar_x1, crossbar_front - crossbar_d, crossbar_front, 0, crossbar_h);
    // latch arms: the tooth's ramped front pushes the arm inward past the
    // stop as the slider goes in; its square back then holds against it
    for (s = [-1, 1]) {
        edge = s < 0 ? crossbar_x0 : crossbar_x1;
        box(min(edge, edge - s * latch_arm_t), max(edge, edge - s * latch_arm_t),
            latch_tip_y, crossbar_front - crossbar_d + 0.01, 0, crossbar_h);
        translate([edge, 0, 0])
            linear_extrude(crossbar_h)
                polygon([
                    [0, latch_tip_y],
                    [s * latch_tooth, latch_tip_y],
                    [0, latch_tip_y + latch_tooth_l],
                ]);
    }
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
else if (part == "gate") gate();
else if (part == "template") template();
else if (part == "slider") slider();
else if (part == "follower") follower();
else if (part == "print") {
    base();
    translate([0, front_y + 10 - inner_w, 0]) gate();
    translate([0, front_y + 10 - inner_w + gate_foot + 5, 0]) template();
    slider_dy = frame_back_y - 10 - (finger_rest + 1);
    translate([0, slider_dy, 0]) slider();
    translate([0, slider_dy + crossbar_front - crossbar_d - 10 - inner_w, 0]) follower();
}
else if (part == "assembled") {
    base();
    color("orange", 0.85) translate([0, 0, floor_z + throat]) {
        gate();
        template();
    }
    color("steelblue") slider();
    color("seagreen") translate([0, 0, floor_z + 15]) follower();
}
