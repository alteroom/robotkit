CELL_SIZE = 10;
PLANE_SIZE = 3.0;
SCREW_GAP = 2.8;
LARGE_GAP = 3.8;
GAP_QUALITY = 18;
BEVEL_SIZE = 1.4;
BEVEL_QUALITY = 30;
DELTA = 0.1;

// Reference
//
// 1. RKPlane(w, l);
//    RKPlane(4, 1, gaps=[[0,0],[1,0],[2,0],[3,0]]);
//    RKPlane(4, 3, gaps=[[0,0],[1,1], [2,1], [2,2], [0,2], [0,2], [2,0],[3,0]]);
// 2. RKBlock(w, l, h);
//    RKBlock(4, 3, 2);  
//    RKBlock(4, 3, 2, cut_w = 2);
//    RKBlock(4, 3, 2, cut_l = -1);
// 3. RKBox(w, l, h);
//    RKBox(8, 6, 3);
//    RKBox(4, 3, 2, cut_h = -1.7); 
//    RKBox(4, 3, 2, cut_h = 1.7); 
//    RKBox(4, 3, 2, cut_w = 3, cut_l = 2, cut_h = 1);

RKBox(4, 3, 2, cut_w = 3, cut_l = 2, cut_h = 1);

module RKPlane(width, length, gaps=[]){
    difference()
    {
        RKSolid(width, length, PLANE_SIZE/CELL_SIZE);
        for (i = [0:width-1])
        {
            for (j = [0:length-1])
            {
                RKScrewGapXY(i, j, PLANE_SIZE/CELL_SIZE);
            }
        }
        for (k = [0:2:len(gaps)-1]){
            RKLargeGap(gaps[k], gaps[k+1]);
        }
    }       
}

module RKBlock(width, length, height, cut_w=0, cut_l=0, cut_h=0)
{
    if (cut_w != 0 || cut_l != 0 || cut_h != 0){
        intersection (){
            RKBlock(width, length, height);
            if (cut_w > 0){
                cube(size = [cut_w * CELL_SIZE, length * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_w < 0){
                translate([- cut_w * CELL_SIZE, 0, 0]) 
                    cube(size = [(width + cut_w) * CELL_SIZE, length * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_l > 0){
                cube(size = [width * CELL_SIZE, cut_l * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_l < 0){
                translate([0, -cut_l * CELL_SIZE, 0]) 
                    cube(size = [width * CELL_SIZE, (length + cut_l) * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_h > 0){
                cube(size = [width * CELL_SIZE, length * CELL_SIZE, cut_h * CELL_SIZE]);
            }
            if (cut_h < 0){
                translate([0, 0, - cut_h * CELL_SIZE]) 
                    cube(size = [width * CELL_SIZE, length * CELL_SIZE, (height + cut_h) * CELL_SIZE]);
            }
        }
    } else {
        difference()
        {
            RKSolid(width, length, height);
            for (i = [0:width-1])
            {
                for (j = [0:length-1])
                {
                    RKScrewGapXY(i, j, height);
                }
            }
            for (i = [0:width-1])
            {
                for (j = [0:height-1])
                {
                    RKScrewGapXZ(i,length,j);
                }
            }
            for (i = [0:length-1])
            {
                for (j = [0:height-1])
                {
                    RKScrewGapYZ(width,i,j);
                }
            }
        }       
    }
    
}

module RKBox(width, length, height, cut_w=0, cut_l=0, cut_h=0){
if (cut_w != 0 || cut_l != 0 || cut_h != 0){
        intersection (){
            RKBox(width, length, height);
            if (cut_w > 0){
                cube(size = [cut_w * CELL_SIZE, length * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_w < 0){
                translate([- cut_w * CELL_SIZE, 0, 0]) 
                    cube(size = [(width + cut_w) * CELL_SIZE, length * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_l > 0){
                cube(size = [width * CELL_SIZE, cut_l * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_l < 0){
                translate([0, -cut_l * CELL_SIZE, 0]) 
                    cube(size = [width * CELL_SIZE, (length + cut_l) * CELL_SIZE, height * CELL_SIZE]);
            }
            if (cut_h > 0){
                cube(size = [width * CELL_SIZE, length * CELL_SIZE, cut_h * CELL_SIZE]);
            }
            if (cut_h < 0){
                translate([0, 0, - cut_h * CELL_SIZE]) 
                    cube(size = [width * CELL_SIZE, length * CELL_SIZE, (height + cut_h) * CELL_SIZE]);
            }
        }
    } else {
        union(){
            RKPlane(width, length);
            translate ([0,0, height*CELL_SIZE - PLANE_SIZE]) RKPlane(width, length);
            
            translate ([0, PLANE_SIZE, 0]) rotate ([90, 0, 0]) RKPlane(width, height);
            translate ([0, length*CELL_SIZE, 0]) rotate ([90, 0, 0]) RKPlane(width, height);
            
            translate ([PLANE_SIZE, 0, 0]) rotate ([0, -90, 0]) RKPlane(height, length);
            translate ([width*CELL_SIZE, 0, 0]) rotate ([0, -90, 0]) RKPlane(height, length);
        }
    }
}


module RKSolid(width, length, height){
    minkowski(){
        translate([BEVEL_SIZE, BEVEL_SIZE, BEVEL_SIZE])
            cube(size = [width*CELL_SIZE-BEVEL_SIZE*2, length*CELL_SIZE-BEVEL_SIZE*2, height*CELL_SIZE-BEVEL_SIZE*2]);
        sphere(r = BEVEL_SIZE - DELTA, $fn=BEVEL_QUALITY);
    }
}

module RKScrewGapXY(x, y, z, sz=SCREW_GAP)
{
    translate ([CELL_SIZE * (x + 0.5), CELL_SIZE * (y + 0.5), -DELTA])
        cylinder(h = z*CELL_SIZE + DELTA*2, d = sz, $fn=GAP_QUALITY);
}

module RKScrewGapXZ(x, y, z, sz=SCREW_GAP)
{
    translate ([CELL_SIZE * (x + 0.5), -DELTA, CELL_SIZE * (z + 0.5)])
        rotate([-90, 0, 0])
            cylinder(h = y*CELL_SIZE + DELTA*2, d = sz, $fn=GAP_QUALITY);
}

module RKScrewGapYZ(x, y, z, sz=SCREW_GAP)
{
    translate ([-DELTA, CELL_SIZE * (y + 0.5), CELL_SIZE * (z + 0.5)])
        rotate([0, 90, 0])
            cylinder(h = x*CELL_SIZE + DELTA*2, d = sz, $fn=GAP_QUALITY);
}

module RKLargeGap(from, to)
{
    left = from[0];
    right = to[0];
    front = from[1];
    back = to[1];
    translate ([CELL_SIZE * (left + 0.5), CELL_SIZE * (front + 0.5), -DELTA])
        cylinder(h = PLANE_SIZE + DELTA*2, d = LARGE_GAP, $fn=GAP_QUALITY);
    translate ([CELL_SIZE * (left + 0.5), CELL_SIZE * (back + 0.5), -DELTA])
        cylinder(h = PLANE_SIZE + DELTA*2, d = LARGE_GAP, $fn=GAP_QUALITY);
    translate ([CELL_SIZE * (right + 0.5), CELL_SIZE * (front + 0.5), -DELTA])
        cylinder(h = PLANE_SIZE + DELTA*2, d = LARGE_GAP, $fn=GAP_QUALITY);
    translate ([CELL_SIZE * (right + 0.5), CELL_SIZE * (back + 0.5), -DELTA])
        cylinder(h = PLANE_SIZE + DELTA*2, d = LARGE_GAP, $fn=GAP_QUALITY);
    w1 = (right - left) * CELL_SIZE + LARGE_GAP;
    h1 = (back - front) * CELL_SIZE;
    w2 = (right - left) * CELL_SIZE;
    h2 = (back - front) * CELL_SIZE + LARGE_GAP;
    if (w1 > 0 && h1 > 0){
        translate ([CELL_SIZE * (left + 0.5) - LARGE_GAP * 0.5, CELL_SIZE * (front + 0.5), -DELTA]) cube(size=[w1, h1, PLANE_SIZE + DELTA*2]);
    }
    if (w2 > 0 && h2 > 0){
        translate ([CELL_SIZE * (left + 0.5), CELL_SIZE * (front + 0.5) - LARGE_GAP * 0.5, -DELTA]) cube(size=[w2, h2, PLANE_SIZE + DELTA*2]);
    }
    
    
    
    
}