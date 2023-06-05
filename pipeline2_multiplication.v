`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/13 20:42:02
// Design Name: 
// Module Name: pipeline_multiplication
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


module pipeline2_multiplication #(
         parameter MULTIPLIER_WIDTH=9,
			          MULTIPLICAND_WIDTH=13
)
(     
      input clk,
		input rst,
		input in_valid,
		input  signed[MULTIPLIER_WIDTH-1:0]  Multiplier_A,
		input  signed[MULTIPLICAND_WIDTH-1:0]Multiplicand_B,
		output mul_out_valid,
		output signed[MULTIPLIER_WIDTH+MULTIPLICAND_WIDTH-2:0]pipe_mul_out
    );
	 
	 
	reg signed[MULTIPLIER_WIDTH+MULTIPLICAND_WIDTH-2:0]pipe_mul1_high,pipe_mul1_low; 
	reg signed[MULTIPLIER_WIDTH+MULTIPLICAND_WIDTH-2:0]pipe_mul2;
	reg in_valid_R,in_valid_R1;
   reg signed[MULTIPLIER_WIDTH+MULTIPLICAND_WIDTH-2:0]pipe2_mul;


//valide signal Shoot
always @(posedge clk )begin
   if(rst)begin
      in_valid_R<=0;
		in_valid_R1<=0;
		end
	else begin
	   in_valid_R<=in_valid;
		in_valid_R1<=in_valid_R;
		end
end

always @(posedge clk )begin
   if(rst)
      pipe_mul1_high<=0;
	else if(in_valid)
	   pipe_mul1_high<=(Multiplier_A<<<12)-(Multiplier_A<<<5);
end 


always @(posedge clk )begin
   if(rst)
      pipe_mul1_low<=0;
	else if(in_valid)
	   pipe_mul1_low<=(Multiplier_A<<<9)+(Multiplier_A<<<2)+Multiplier_A;
end

always @(posedge clk )begin
   if(rst)
      pipe_mul2<=0;
	else if(in_valid_R)
	   pipe_mul2<=pipe_mul1_high-pipe_mul1_low;
end
	 
assign pipe_mul_out=pipe_mul2;
assign mul_out_valid=in_valid_R1;


/* integer outfile;
always@(posedge clk) begin
   if(rst)
    outfile = $fopen("E:/ZynqPro/code_sy_test/arctan_Numerator.txt","w");  // 初始化文件
   else if(in_valid_R1)
    $fdisplay(outfile,"%d",pipe_mul2);
end  */

/* integer outfile2;
always@(posedge clk) begin
   if(!rst)
    outfile2 = $fopen("E:/ZynqPro/code_sy_test/arctan_NumeratorDSP.txt","w");  // 初始化文件
   else if(in_valid_R)
    $fdisplay(outfile2,"%d",pipe2_mul);
end  */
endmodule
