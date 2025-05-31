include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/hinges.scad>
$fn=64;
control_surface_thickness=5;
control_surface_seg_gap = 0.2;
control_surface_end_space = 0.6;
control_surface_ang=45;
module myhinge(inner)
   knuckle_hinge(length=25, segs=7,offset=control_surface_thickness/2+control_surface_end_space, inner=inner, clearance=-control_surface_thickness/2, knuckle_diam=control_surface_thickness,
                 arm_angle=45, gap=control_surface_seg_gap, in_place=true, clip=control_surface_thickness/2)
                 children();
module leaf() cuboid([25,control_surface_thickness,25],anchor=TOP+BACK, rounding=7, edges=[BOT+LEFT,BOT+RIGHT]);

module control_surface_hinge()
{
xrot(90)
  myhinge(true){
    position(BOT) leaf();
    color("lightblue")
      up(control_surface_end_space) attach(BOT,TOP,inside=true)
      tag("")  // cancel default "remove" tag
      xrot(-control_surface_ang,cp=[0,-control_surface_thickness/2,control_surface_thickness/2]) myhinge(false)
        position(BOT) leaf();
  }
  }
  
  control_surface_hinge();