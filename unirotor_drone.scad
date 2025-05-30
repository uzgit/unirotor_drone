include <honeycomb.scad>

$fn = 120;
radius = 125;

propeller_cage_height = 100;
propeller_cage_thickness = 5;
protective_grid_thickness = 2;

translate([0, 0, propeller_cage_thickness/2])
rotate_extrude(convexity = 10)
translate([radius, 0, 0])
hull()
{
    circle(d=propeller_cage_thickness);
    
    translate([0, propeller_cage_height - propeller_cage_thickness, 0])
    circle(d=propeller_cage_thickness);
}

// honeycomb(x, y, dia, wall)

translate([-radius, -radius, propeller_cage_height-protective_grid_thickness])
linear_extrude(height=protective_grid_thickness)
difference()
{
    honeycomb(2*radius, 2*radius, 10, 1);
    
    translate([radius, radius, 0])
    difference()
    {
        square([1000, 1000], center=true);
        circle(r=radius);
    }
}

//translate([0, 0, 100])
//linear_extrude()
//rotate_extrude(convexity = 10)
//translate([radius, 0, 0])
//hull()
//{
//    hull()
//    {
//        circle(r=5);
//    }
//}

//hull()
//{
//    translate([0, 0, 100])
//    hull()
//    {
//        rotate_extrude(convexity = 10, $fn = 100)
//            translate([radius, 0, 0])
//                circle(r=5, $fn = 100);
//    }
//
//    hull()
//    {
//        rotate_extrude(convexity = 10, $fn = 100)
//            translate([radius, 0, 0])
//                circle(r=5, $fn = 100);
//    }
//}