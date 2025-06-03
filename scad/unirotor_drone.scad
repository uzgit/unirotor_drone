include <../lib/honeycomb.scad>
include <../lib/roundedcube.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/hinges.scad>

$fn = 130;
duct_radius = 50;
duct_thickness = 5; // radius from outer to outer is duct_radius + duct_thickness
duct_height = 60;
propeller_cavity_height = 10; // distance from the top of the duct to the bottom of the motor mount

component_space_radius = 30;
component_space_length = 150;
component_space_shell_thickness = 5;

motor_mount_radius = 21;
motor_mount_thickness = 6;
num_motor_mount_screw_holes = 3;
motor_mount_screw_hole_angle_offset = 180; // so they don't intersect the inner braces
num_motor_mount_screw_hole_diameter = 3.1;
num_motor_mount_screw_radius_from_center = 16;
motor_rear_shaft_diameter = 11;

num_inner_braces = 3; // connecting the component space to the duct and having a control surface
control_surface_height = 10;
control_surface_thickness = duct_thickness;
control_surface_length = duct_radius - component_space_radius - 5;
control_surface_seg_gap = 0.2;
control_surface_end_space = 0.6;
control_surface_vertical_offset_idk = 6.2;
control_surface_ang=0;

servo_angle_offset = 25; // difference from inner braces and control surfaces
servo_z_translation = 10; // from z=0

module servo_voids()
{
    servo_x = 12;
    servo_y = 31.6;
    servo_z = 24;
    servo_extension_z = 32;
    
    angle_delta = 360 / num_inner_braces;
    for( angle = [0 : angle_delta : 359] )
    {
        rotate([0, 0, angle + servo_angle_offset])
        translate([0, 0, servo_z_translation])
        translate([0, 0, servo_z/2])
        translate([0, component_space_radius, 0])
        translate([0, -duct_thickness/2, 0])
        union()
        {
            cube([servo_x, servo_y, servo_z], center=true);
            
            translate([0, -servo_y/2, 0])
            cube([servo_x, servo_y, servo_extension_z], center=true);
            
            screw_hole_z_translation = (servo_z/2 + 2);
            for(z_translation = [-screw_hole_z_translation, screw_hole_z_translation])
            translate([0, 0, z_translation])
            rotate([90, 0, 0])
            cylinder(d=2, h=servo_z, center=true);
        }
    }
}

module myhinge(inner)
   knuckle_hinge(length=control_surface_length, segs=7,offset=control_surface_thickness/2+control_surface_end_space, inner=inner, clearance=-control_surface_thickness/2, knuckle_diam=control_surface_thickness,
                 arm_angle=45, gap=control_surface_seg_gap, in_place=true, clip=control_surface_thickness/2)
                 children();
                 
module leaf(z=7) cube([control_surface_length,control_surface_thickness,z],anchor=TOP+BACK);

//module leaf(z=7) roundedcube([control_surface_length,control_surface_thickness,z],anchor=TOP+BACK);

module control_surface_hinge()
{
    translate([0, -control_surface_thickness/2, 0])
    xrot(180)
    myhinge(true)
    {
        position(BOT) leaf();
        color("lightblue")
        up(control_surface_end_space) attach(BOT,TOP,inside=true)
        tag("")  // cancel default "remove" tag
        xrot(-control_surface_ang,cp=[0,-control_surface_thickness/2,control_surface_thickness/2]) myhinge(false)
        position(BOT) leaf(z=control_surface_height);
    }
}

module duct(radius, thickness, height)
{
    translate([0, 0, duct_thickness/2])
    rotate_extrude()
    translate([duct_radius, 0, 0])
    hull()
    {
        circle(d=duct_thickness);
        
        translate([0, duct_height - duct_thickness, 0])
        circle(d=duct_thickness);
    }
}

module control_surfaces()
{
    assert( 360 % num_inner_braces == 0 );
    angle_delta = 360 / num_inner_braces;
    
    for( angle = [0 : angle_delta : 359] )
//    for( angle = [0] )
    {
        rotate([0, 0, angle])
//        translate([0, (radius - component_space_radius) + control_surface_length/3,  control_surface_height])
        translate([0, (duct_radius + component_space_radius)/2 - 4/2,  control_surface_height + control_surface_vertical_offset_idk])
        rotate([0, 0, 90])
        control_surface_hinge();
    }

}

module component_space(radius, length, shell_thickness=0, parent=true)
{
    z_translation = parent ? -radius : 0;
    
    translate([0, 0, z_translation])
    difference()
    {
        hull()
        union()
        {
            sphere(radius);
            
            translate([0, 0, -length])
            sphere(radius);
        }
        
        union()
        {
            if( shell_thickness > 0 )
            {
                component_space(radius - shell_thickness, length, parent=false);
            }
        }
    }    
}

module motor_mount()
{
    assert( motor_mount_radius <= component_space_radius );
    theta = acos( motor_mount_radius/component_space_radius );
    h = component_space_radius - component_space_radius * sin(theta);
    
    difference()
    {
        union()
        {
            translate([0, 0, h])
            translate([0, 0, -component_space_radius])
            sphere(component_space_radius);
        }
        union()
        {
            s = 1000;
            
            translate([0, 0, s/2])
            cube(s, center=true);
            
            translate([0, 0, -s/2 - motor_mount_thickness])
            cube(s, center=true);
            
            translate([0, 0, s/2])
            cube(s, center=true);
            
            // motor mount screw holes
            angle_delta = 360 / num_motor_mount_screw_holes;
            translate([0, 0, -motor_mount_thickness])
            union()
            {
                for( angle = [0 : angle_delta : 359] )
                rotate([0, 0, angle + motor_mount_screw_hole_angle_offset])
                translate([0, num_motor_mount_screw_radius_from_center, 0])
                cylinder(d=num_motor_mount_screw_hole_diameter, h=motor_mount_thickness);
                
                cylinder(d=motor_rear_shaft_diameter, h=motor_mount_thickness);
            }
        }
    }
}

module inner_braces()
{
    assert( 360 % num_inner_braces == 0 );
    assert( motor_mount_radius <= component_space_radius );
    theta = acos( motor_mount_radius/component_space_radius );
    h = component_space_radius - component_space_radius * sin(theta);
    
    inner_brace_height = duct_height - propeller_cavity_height - control_surface_height;
    
    angle_delta = 360 / num_inner_braces;
    
    difference()
    {
        for( angle = [0 : angle_delta : 359] )
        {
            rotate([0, 0, angle])
            translate([0, 0, inner_brace_height - duct_thickness/2 + control_surface_height])
            rotate([-90, 0, 0])
            linear_extrude(height=duct_radius - 1)
            hull()
            {
                circle(d=duct_thickness);
                
                translate([0, inner_brace_height - duct_thickness - control_surface_vertical_offset_idk, 0])
                circle(d=duct_thickness);
            }
        }
        union()
        {
            hull()
            {
                translate([0, 0, duct_height - propeller_cavity_height])
                translate([0, 0, h])
            component_space(component_space_radius, component_space_length);
            }
        }
    }
}

module unirotor_drone_body(duct_radius=duct_radius, duct_height=duct_height, component_space_radius=component_space_radius, component_space_length=component_space_length, component_space_shell_thickness=component_space_shell_thickness)
{
    duct(duct_radius, duct_thickness, duct_height);
    
    inner_braces();
    control_surfaces();
    
    assert( motor_mount_radius <= component_space_radius );
    theta = acos( motor_mount_radius/component_space_radius );
    h = component_space_radius - component_space_radius * sin(theta);
    s = 1000;
    
    translate([0, 0, duct_height - propeller_cavity_height])
    difference()
    {
        union()
        {
            // hollow space for components
            translate([0, 0, h])
            component_space(component_space_radius, component_space_length, shell_thickness=component_space_shell_thickness);
        }
        
        union()
        {
            translate([0, 0, s/2])
            cube(s, center=true);
            
            translate([0, 0, -2*component_space_radius])
            cylinder(h=2*component_space_radius, r=motor_mount_radius);
            
            translate([0, 0, -(duct_height - propeller_cavity_height)])
            servo_voids();
        }
    }
    translate([0, 0, duct_height - propeller_cavity_height])
    motor_mount();
}

//unirotor_drone_body();

//motor_mount();

s = 1000;
cut = true;
difference()
{
    union()
    {
        unirotor_drone_body();
    }
    
    union()
    {
        if( cut )
        {
            translate([0, 0, -s/2])
            cube(s, center=true);
        }
    }
}