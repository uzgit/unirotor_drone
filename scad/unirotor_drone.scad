include <../lib/honeycomb.scad>
include <../lib/roundedcube.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/hinges.scad>

$fn = 130;
radius = 55;
motor_mount_radius = 21;
component_space_radius = 25;
component_space_length = 150;

// duct
propeller_cage_height = 90;
propeller_cage_thickness = 5;
propeller_cavity_height = 30;
control_surface_height = 16.2;

// inner braces
num_inner_braces = 3;
inner_brace_height = propeller_cage_height - propeller_cavity_height - control_surface_height;

num_motor_mount_screws = 3;
motor_mount_screw_size = 3.1;
motor_mount_screw_radius = 16;
motor_rear_shaft_diameter = 11;
motor_mount_thickness = 6;

// motor mount and component space
protective_grid_thickness = 2;
protective_grid_hexagon_diameter = 25;
protective_grid_wall_thickness = 2;

control_surface_thickness=propeller_cage_thickness;
control_surface_length = radius - component_space_radius - 5;
control_surface_seg_gap = 0.2;
control_surface_end_space = 0.6;
control_surface_ang=0;
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
        position(BOT) leaf(z=10);
    }
}

module duct()
{
    translate([0, 0, propeller_cage_thickness/2])
    rotate_extrude(convexity = 10)
    translate([radius, 0, 0])
    hull()
    {
        circle(d=propeller_cage_thickness);
        
        translate([0, propeller_cage_height - propeller_cage_thickness, 0])
        circle(d=propeller_cage_thickness);
    }
}

module inner_braces()
{
    assert( 360 % num_inner_braces == 0 );
    angle_delta = 360 / num_inner_braces;
    for( angle = [0 : angle_delta : 359] )
    {
        rotate([0, 0, angle])
        translate([0, 0, inner_brace_height - propeller_cage_thickness/2 + control_surface_height])
        rotate([-90, 0, 0])
        linear_extrude(height=radius - 1)
        hull()
        {
            circle(d=propeller_cage_thickness);
            
            translate([0, inner_brace_height - propeller_cage_thickness, 0])
            circle(d=propeller_cage_thickness);
        }
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
        translate([0, (radius + component_space_radius)/2 - 4/2,  control_surface_height])
        rotate([0, 0, 90])
        control_surface_hinge();
    }

}

module component_space()
{
    difference()
    {
        union()
        {

            
            hull()
            {
                translate([0, 0, control_surface_height])
                cylinder(h=0.001, r=component_space_radius);
            
                translate([0, 0, control_surface_height])
                cylinder(h=inner_brace_height, r=motor_mount_radius);
            }
            cylinder(r=component_space_radius, h=control_surface_height);
        }
        union()
        {
            scale(0.95)
            hull()
            {
                translate([0, 0, control_surface_height])
                cylinder(h=0.001, r=component_space_radius);
            
                translate([0, 0, control_surface_height])
                cylinder(h=inner_brace_height, r=motor_mount_radius);
            }
            cylinder(r=0.95*component_space_radius, h=control_surface_height);
        }
    }
}

//module component_space_pill(component_space_radius=component_space_radius, motor_mount_radius=motor_mount_radius, length=component_space_length, shell_thickness=4)
//{
//    d = sqrt( component_space_radius^2 - motor_mount_radius^2 );
//    
//    size_of_everything = 1000;
//
//    translate([0, 0, -d])
//    difference()
//    {
//        hull()
//        {
//            difference()
//            {
//                sphere(r=component_space_radius);
//                
//                translate([0, 0, size_of_everything/2 + d])
//                cube(size_of_everything, center=true);
//            }
//            translate([0, 0, radius - component_space_length])
//            sphere(r=component_space_radius);
//        }
//        
//        union()
//        {
//            cube(30, center=true);
//            if( shell_thickness > 0 )
//            {
//                component_space_pill(component_space_radius=component_space_radius - shell_thickness, motor_mount_radius=motor_mount_radius, length=component_space_length - shell_thickness, shell_thickness=0);
//            }
//        }
//    }
//}

module pill(component_space_radius=component_space_radius, motor_mount_radius=motor_mount_radius, length=component_space_length, shell_thickness=0)
{
    difference()
    {
        hull()
        {
            difference()
            {
                sphere(r=component_space_radius);
            }
            translate([0, 0, radius - component_space_length])
            sphere(r=component_space_radius);
        }
        
        union()
        {
            if( shell_thickness > 0 )
            {
                pill(component_space_radius=component_space_radius - shell_thickness, motor_mount_radius=motor_mount_radius, length=component_space_length - shell_thickness, shell_thickness=0);
            }
        }
    }
}

module motor_mount_holes()
{
    for( _angle = [0 : 360 / num_motor_mount_screws : 359] )
    {
        rotate([0, 0, _angle])
        translate([0, motor_mount_screw_radius, -motor_mount_thickness/2])
        cylinder(d=motor_mount_screw_size, h=motor_mount_thickness + 10, center=true);
    }
}

module component_space_pill(shell_thickness=2)
{
    d = sqrt( component_space_radius^2 - motor_mount_radius^2 );
    
    size_of_everything = 1000;

    difference()
    {
        translate([0, 0, d])
        translate([0, 0, -component_space_radius])
        sphere(component_space_radius);
        
        union()
        {
            translate([0, 0, size_of_everything/2])
            cube(size_of_everything, center=true);
            
            translate([0, 0, -size_of_everything/2])
            translate([0, 0, -motor_mount_thickness])
            cube(size_of_everything, center=true);
            
            translate([0, 0, -motor_mount_thickness/2])
            cylinder(d=motor_rear_shaft_diameter, h=motor_mount_thickness + 10, center=true);
        }
    }
    
    difference()
    {
        translate([0, 0, d])
        translate([0, 0, -component_space_radius])
        pill(component_space_radius=component_space_radius, motor_mount_radius=motor_mount_radius, length=component_space_length, shell_thickness=shell_thickness);
        
        translate([0, 0, size_of_everything/2])
        cube(size_of_everything, center=true);
    }
}

module unirotor_drone_body()
{
    duct();
    
    shell_thickness = 5;
    
    difference()
    {
        union()
        {
            translate([0, 0, 70])
            component_space_pill(shell_thickness=propeller_cage_thickness);
        }
        
        union()
        {
            translate([0, 0, 70])
            motor_mount_holes();
            
            translate([0, 0, -500])
            cube(1000, center=true);
        }
    }
    difference()
    {
        union()
        {
            inner_braces();
        }
        
        union()
        {
            translate([0, 0, component_space_length - 70])
            translate([0, 0, -component_space_radius])
            pill(component_space_radius=component_space_radius - shell_thickness, motor_mount_radius=motor_mount_radius, length=component_space_length - shell_thickness, shell_thickness=0);
        }
    }
//        component_space();
    control_surfaces();
    
}

unirotor_drone_body();



//// control surfaces
//for( angle = [0, 120, 240] )
//{
//    rotate([0, 0, angle])
//    translate([0, component_space_radius + 2, control_surface_height - propeller_cage_thickness/2])
//    rotate([-90, 0, 0])
//    linear_extrude(height=radius - component_space_radius - 1 - 10)
//    hull()
//    {
//        
//        circle(d=propeller_cage_thickness);
//        
//        translate([0, control_surface_height - propeller_cage_thickness, 0])
//        circle(d=propeller_cage_thickness);
//    }
//}

// top honeycomb
//translate([-radius, -radius, propeller_cage_height-protective_grid_thickness])
//linear_extrude(height=protective_grid_thickness)
//difference()
//{
//    honeycomb(2*radius, 2*radius, protective_grid_hexagon_diameter, protective_grid_wall_thickness);
//    
//    translate([radius, radius, 0])
//    difference()
//    {
//        square([1000, 1000], center=true);
//        circle(r=radius);
//    }
//}

//// leg
//translate([0, 0, propeller_cage_thickness/2])
//rotate_extrude(convexity = 10)
//translate([radius, 0, 0])
//hull()
//{
//    circle(d=propeller_cage_thickness);
//    
//    translate([0, propeller_cage_height - propeller_cage_thickness, 0])
//    circle(d=propeller_cage_thickness);
//}