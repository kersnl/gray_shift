`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 21:36:56
// Design Name: 
// Module Name: abphase_solution
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


module abphase_solution #(
     parameter ABPHASEWIDTH=32,
	            WRAPPED_PHASEWIDTH=32
)(   
     input clk,
     input rst, 
     input [2:0]k1,
	  input [3:0]k2,
	  input k3,
	  input k_valid,
	  input signed [WRAPPED_PHASEWIDTH-1:0]wrapped_phase,
	  input wrapped_phase_valid,
	  output [ABPHASEWIDTH-1:0]abphase_out,
     output abphase_valid
	 );
	 
`define	CV_PI        32'd205887
`define	factor       32'd652
`define  threshold1   32'd16384
`define  threshold2   32'd49152
`define  fixed_1      32'd65536

reg signed[WRAPPED_PHASEWIDTH-1:0]phase_normalization,phase_normalization1,adder;
reg signed[WRAPPED_PHASEWIDTH-1:0]adder_23,adder_13;
reg valid_r0=0,valid_r1=0,valid_r2,valid_r3;
reg [ABPHASEWIDTH-1:0]abphase;
reg [1:0]compare_result;
//valid
always@(posedge clk or posedge rst)begin
      if(rst)begin
		 valid_r0<=0;
		 valid_r1<=0;
		 valid_r2<=0;
		 valid_r3<=0;
		end begin
       valid_r0<=wrapped_phase_valid;
		 valid_r1<=valid_r0;
		 valid_r2<=valid_r1;
		 valid_r3<=valid_r2;
		 end
end

always@(posedge clk)begin
    if(rst)begin
	   phase_normalization<=0;
	 end
    else if(wrapped_phase_valid)
	    phase_normalization<=((wrapped_phase+`CV_PI)*`factor)>>>12;
	  else
	  phase_normalization<=phase_normalization;
end	  

always@(posedge clk)begin	
    if(rst)
	   compare_result<=2'b00; 
	 else if(phase_normalization<=`threshold1)
	   compare_result<=2'b01;
	 else if(phase_normalization>`threshold1&&phase_normalization<`threshold2)
	   compare_result<=2'b10;
	 else if(phase_normalization>=`threshold2)
	   compare_result<=2'b11;
    else compare_result<=compare_result;	
end

always@(posedge clk)begin
    if(rst)
	   phase_normalization1<=0;

	  else
	  phase_normalization1<=phase_normalization;
end	

	//
always@(posedge clk)begin
    if(rst)begin
      adder_23<=0;
	   adder_13<=0;
		end
    else if(valid_r0)begin
	   adder_23<=(k2<<16)+(k3<<19);
	   adder_13<=(k1<<16)+(k3<<19);
	 end
	    else begin
      adder_23<=adder_23;
	   adder_13<=adder_13;
	 end
end	
	
	
always@(*)begin
       if(rst)
		 adder=0;
       else if(compare_result==2'b01)
	    adder=adder_23;
		 else if(compare_result==2'b10)
		 adder=adder_13;
		 else if(compare_result==2'b11)
		 adder=adder_23-`fixed_1;
	    else
	    adder=0;
end

always@(posedge clk)begin
   if(rst)
      abphase<=0;
	else if(valid_r1)
	    abphase<=phase_normalization1+adder;
end

assign abphase_out=abphase;
assign abphase_valid=valid_r2;

integer outfile;
always@(posedge clk) begin
   if(rst)
    outfile = $fopen("E:/ZynqPro/Cyclic_Com_Gray/abphase.txt","w");  // 初始化文件
   else if(valid_r2)
    $fdisplay(outfile,"%d",abphase);
end   
	  
endmodule
