include <honeycomb.scad>
include <roundedcube.scad>

$fn = 30;
radius = 75;

propeller_cage_height = 100;
propeller_cage_thickness = 5;
propeller_cavity_height = 50;
control_surface_height = 30;
inner_brace_height = propeller_cage_height - propeller_cavity_height - control_surface_height;
motor_mount_radius = 21;
component_space_radius = 35;

protective_grid_thickness = 2;
protective_grid_hexagon_diameter = 25;
protective_grid_wall_thickness = 2;

// outer shell
translate([0, 0, propeller_cage_thickness/2])
rotate_extrude(convexity = 10)
translate([radius, 0, 0])
hull()
{
    circle(d=propeller_cage_thickness);
    
    translate([0, propeller_cage_height - propeller_cage_thickness, 0])
    circle(d=propeller_cage_thickness);
}

difference()
{
    union()
    {
        // inner braces
        for( angle = [0, 120, 240] )
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
translate([-radius, -radius, propeller_cage_height-protective_grid_thickness])
linear_extrude(height=protective_grid_thickness)
difference()
{
    honeycomb(2*radius, 2*radius, protective_grid_hexagon_diameter, protective_grid_wall_thickness);
    
    translate([radius, radius, 0])
    difference()
    {
        square([1000, 1000], center=true);
        circle(r=radius);
    }
}

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