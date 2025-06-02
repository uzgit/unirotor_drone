include <../lib/honeycomb.scad>
include <../lib/roundedcube.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/hinges.scad>

$fn = 130;
duct_radius = 100;
duct_thickness = 5; // radius from outer to outer is duct_radius + duct_thickness
duct_height = 100;
propeller_cavity_height = 30; // distance from the top of the duct to the bottom of the motor mount

component_space_radius = 40;
component_space_length = 150;
component_space_shell_thickness = 5;

num_inner_braces = 3; // connecting the component space to the duct and having a control surface
control_surface_height = 15;

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
//                translate([0, 0, -shell_thickness])
                component_space(radius - shell_thickness, length, parent=false);
            }
        }
    }    
}

module unirotor_drone_body(duct_radius=duct_radius, duct_height=duct_height, component_space_radius=component_space_radius, component_space_length=component_space_length, component_space_shell_thickness=component_space_shell_thickness)
{
    duct(duct_radius, duct_thickenss, duct_height);
    
//    inner_braces();
    
    translate([0, 0, duct_height - propeller_cavity_height])
    component_space(component_space_radius, component_space_length, shell_thickness=component_space_shell_thickness);
}

//unirotor_drone_body();

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
            translate([0, 0, -500])
            cube(1000, center=true);
        }
    }
}
