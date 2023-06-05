`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/20 21:05:18
// Design Name: 
// Module Name: CORDIC_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CORDIC_pipeline #(
    parameter NUMERATOR_WIDTH=21,
              DENOMINATOR_WIDTH=10,
				  NUMERATOR_FACTOR=11,
              ARCTAN_WIDTH=32
)    
(
    input clk,
    input rst,
    input in_valid,
    input signed[NUMERATOR_WIDTH-1:0]arctan_y_in,
    input signed[DENOMINATOR_WIDTH-1:0]arctan_x_in,
    output out_valid,
    output signed[ARCTAN_WIDTH-1:0]arctan_out
);

reg signed [15:0]delay_shift;
reg signed[ARCTAN_WIDTH-1:0]arctan_y;
reg signed[ARCTAN_WIDTH-1:0]arctan_x;
reg signed[ARCTAN_WIDTH-1:0]z0;
reg signed[ARCTAN_WIDTH-1:0]x1_r,y1_r,z1_r;
reg signed[ARCTAN_WIDTH-1:0]x2_r,y2_r,z2_r;
reg signed[ARCTAN_WIDTH-1:0]x3_r,y3_r,z3_r;
reg signed[ARCTAN_WIDTH-1:0]x4_r,y4_r,z4_r;
reg signed[ARCTAN_WIDTH-1:0]x5_r,y5_r,z5_r;
reg signed[ARCTAN_WIDTH-1:0]x6_r,y6_r,z6_r;
reg signed[ARCTAN_WIDTH-1:0]x7_r,y7_r,z7_r;
reg signed[ARCTAN_WIDTH-1:0]x8_r,y8_r,z8_r;
reg signed[ARCTAN_WIDTH-1:0]x9_r,y9_r,z9_r;
reg signed[ARCTAN_WIDTH-1:0]x10_r,y10_r,z10_r;
reg signed[ARCTAN_WIDTH-1:0]x11_r,y11_r,z11_r;
reg signed[ARCTAN_WIDTH-1:0]x12_r,y12_r,z12_r;
reg signed[ARCTAN_WIDTH-1:0]x13_r,y13_r,z13_r;
reg signed[ARCTAN_WIDTH-1:0]x14_r,y14_r,z14_r;
reg signed[ARCTAN_WIDTH-1:0]x15_r,y15_r,z15_r;
reg signed[ARCTAN_WIDTH-1:0]x16_r,y16_r,z16_r;
//radian parameter
`define pi_mag   32'd205887

`define angle_k0 32'd51471
`define angle_k1 32'd30385
`define angle_k2 32'd16054
`define angle_k3 32'd8149
`define angle_k4 32'd4090
`define angle_k5 32'd2047
`define angle_k6 32'd1023
`define angle_k7 32'd511
`define angle_k8 32'd255
`define angle_k9 32'd127
`define angle_k10 32'd63
`define angle_k11 32'd31
`define angle_k12 32'd15
`define angle_k13 32'd7
`define angle_k14 32'd3
`define angle_k15 32'd1

//second third quadrants
always@(*)begin
    if(rst) begin
	   arctan_x=0;
		arctan_y=0;
		z0=0;
		end
	else if(arctan_x_in[DENOMINATOR_WIDTH-1]&&!arctan_y_in[NUMERATOR_WIDTH-1])begin
	   arctan_x=~(arctan_x_in<<<NUMERATOR_FACTOR)+1;	
		arctan_y=~arctan_y_in+1;
		z0=0+`pi_mag;
		end
	else if(arctan_x_in[DENOMINATOR_WIDTH-1]&&arctan_y_in[NUMERATOR_WIDTH-1])begin
		    arctan_x=~(arctan_x_in<<<NUMERATOR_FACTOR)+1;	
		    arctan_y=~arctan_y_in+1;
		    z0=0-`pi_mag;
			 end
	else begin
		    arctan_x=arctan_x_in<<<NUMERATOR_FACTOR;		
		    arctan_y=arctan_y_in;
		    z0=0;
			 end
end

//1
always@(posedge clk)begin
       if(arctan_y[ARCTAN_WIDTH-1])begin
          x1_r<=arctan_x-(arctan_y);
			 y1_r<=arctan_y+(arctan_x);
			 z1_r<=z0-`angle_k0;
			 end
       else begin
          x1_r<=arctan_x+(arctan_y);
			 y1_r<=arctan_y-(arctan_x);
			 z1_r<=z0+`angle_k0;
			end
     
end

//2
always @(posedge clk )begin
       if(y1_r[ARCTAN_WIDTH-1])begin
          x2_r<=x1_r-(y1_r>>>1);
			 y2_r<=y1_r+(x1_r>>>1);
			 z2_r<=z1_r-`angle_k1;
			 end
        else begin
          x2_r<=x1_r+(y1_r>>>1);
			 y2_r<=y1_r-(x1_r>>>1);
			 z2_r<=z1_r+`angle_k1;
			 end
     
end

//3
always @(posedge clk )begin
       if(y2_r[ARCTAN_WIDTH-1])begin
          x3_r<=x2_r-(y2_r>>>2);
			 y3_r<=y2_r+(x2_r>>>2);
			 z3_r<=z2_r-`angle_k2;
			 end
        else begin
          x3_r<=x2_r+(y2_r>>>2);
			 y3_r<=y2_r-(x2_r>>>2);
			 z3_r<=z2_r+`angle_k2;
			 end
     
end

//4
always @(posedge clk )begin
       if(y3_r[ARCTAN_WIDTH-1])begin
          x4_r<=x3_r-(y3_r>>>3);
			 y4_r<=y3_r+(x3_r>>>3);
			 z4_r<=z3_r-`angle_k3;
			 end
        else begin
          x4_r<=x3_r+(y3_r>>>3);
			 y4_r<=y3_r-(x3_r>>>3);
			 z4_r<=z3_r+`angle_k3;
			 end
    
end
//5
always @(posedge clk )begin
       if(y4_r[ARCTAN_WIDTH-1])begin
          x5_r<=x4_r-(y4_r>>>4);
			 y5_r<=y4_r+(x4_r>>>4);
			 z5_r<=z4_r-`angle_k4;
			 end
        else begin
          x5_r<=x4_r+(y4_r>>>4);
			 y5_r<=y4_r-(x4_r>>>4);
			 z5_r<=z4_r+`angle_k4;
			 end
     
end

//6
always @(posedge clk )begin
       if(y5_r[ARCTAN_WIDTH-1])begin
          x6_r<=x5_r-(y5_r>>>5);
			 y6_r<=y5_r+(x5_r>>>5);
			 z6_r<=z5_r-`angle_k5;
			 end
        else begin
          x6_r<=x5_r+(y5_r>>>5);
			 y6_r<=y5_r-(x5_r>>>5);
			 z6_r<=z5_r+`angle_k5;
			 end
    
end

//7
always @(posedge clk )begin
       if(y6_r[ARCTAN_WIDTH-1])begin
          x7_r<=x6_r-(y6_r>>>6);
			 y7_r<=y6_r+(x6_r>>>6);
			 z7_r<=z6_r-`angle_k6;
			 end                
        else begin           
          x7_r<=x6_r+(y6_r>>>6);
			 y7_r<=y6_r-(x6_r>>>6);
			 z7_r<=z6_r+`angle_k6;
			 end
     
end

//8
always @(posedge clk )begin
       if(y7_r[ARCTAN_WIDTH-1])begin
          x8_r<=x7_r-(y7_r>>>7);
			 y8_r<=y7_r+(x7_r>>>7);
			 z8_r<=z7_r-`angle_k7;
			 end                
        else begin           
          x8_r<=x7_r+(y7_r>>>7);
			 y8_r<=y7_r-(x7_r>>>7);
			 z8_r<=z7_r+`angle_k7;
			 end
     
end

//9
always @(posedge clk )begin
       if(y8_r[ARCTAN_WIDTH-1])begin
          x9_r<=x8_r-(y8_r>>>8);
			 y9_r<=y8_r+(x8_r>>>8);
			 z9_r<=z8_r-`angle_k8;
			 end
        else begin
          x9_r<=x8_r+(y8_r>>>8);
			 y9_r<=y8_r-(x8_r>>>8);
			 z9_r<=z8_r+`angle_k8;
			 end
     
end

//10
always @(posedge clk )begin
       if(y9_r[ARCTAN_WIDTH-1])begin
          x10_r<=x9_r-(y9_r>>>9);
			 y10_r<=y9_r+(x9_r>>>9);
			 z10_r<=z9_r-`angle_k9;
			 end
        else begin
          x10_r<=x9_r+(y9_r>>>9);
			 y10_r<=y9_r-(x9_r>>>9);
			 z10_r<=z9_r+`angle_k9;
			 end
     
end

//11
always @(posedge clk )begin
       if(y10_r[ARCTAN_WIDTH-1])begin
          x11_r<=x10_r-(y10_r>>>10);
			 y11_r<=y10_r+(x10_r>>>10);
			 z11_r<=z10_r-`angle_k10;
			 end
        else begin
          x11_r<=x10_r+(y10_r>>>10);
			 y11_r<=y10_r-(x10_r>>>10);
			 z11_r<=z10_r+`angle_k10;
			 end    
end

//12
always @(posedge clk )begin
       if(y11_r[ARCTAN_WIDTH-1])begin
          x12_r<=x11_r-(y11_r>>>11);
			 y12_r<=y11_r+(x11_r>>>11);
			 z12_r<=z11_r-`angle_k11;
			 end
        else begin
          x12_r<=x11_r+(y11_r>>>11);
			 y12_r<=y11_r-(x11_r>>>11);
			 z12_r<=z11_r+`angle_k11;
			 end
     
end

//13
always @(posedge clk )begin
       if(y12_r[ARCTAN_WIDTH-1])begin
          x13_r<=x12_r-(y12_r>>>12);
			 y13_r<=y12_r+(x12_r>>>12);
			 z13_r<=z12_r-`angle_k12;
			 end
        else begin
          x13_r<=x12_r+(y12_r>>>12);
			 y13_r<=y12_r-(x12_r>>>12);
			 z13_r<=z12_r+`angle_k12;
			 end
     
end

//14
always @(posedge clk )begin
       if(y13_r[ARCTAN_WIDTH-1])begin
          x14_r<=x13_r-(y13_r>>>13);
			 y14_r<=y13_r+(x13_r>>>13);
			 z14_r<=z13_r-`angle_k13;
			 end
        else begin
          x14_r<=x13_r+(y13_r>>>13);
			 y14_r<=y13_r-(x13_r>>>13);
			 z14_r<=z13_r+`angle_k13;
			 end
     
end

//15
always @(posedge clk )begin
       if(y14_r[ARCTAN_WIDTH-1])begin
          x15_r<=x14_r-(y14_r>>>14);
			 y15_r<=y14_r+(x14_r>>>14);
			 z15_r<=z14_r-`angle_k14;
			 end
        else begin
          x15_r<=x14_r+(y14_r>>>14);
			 y15_r<=y14_r-(x14_r>>>14);
			 z15_r<=z14_r+`angle_k14;
			 end
     
end

//16
always @(posedge clk )begin
       if(y15_r[ARCTAN_WIDTH-1])begin
          x16_r<=x15_r-(y15_r>>>15);
			 y16_r<=y15_r+(x15_r>>>15);
			 z16_r<=z15_r-`angle_k15;
			 end
        else begin
          x16_r<=x15_r+(y15_r>>>15);
			 y16_r<=y15_r-(x15_r>>>15);
			 z16_r<=z15_r+`angle_k15;
			 end
     
end

always@(posedge clk)begin
   if(rst)
	   delay_shift<=0;
	else 
	    delay_shift<={delay_shift[14:0],in_valid};
end



assign out_valid=delay_shift[15];
assign arctan_out=z16_r;
endmodule
