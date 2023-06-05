`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/20 16:00:23
// Design Name: 
// Module Name: wrapped_phase
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


module wrapped_phase #(
          parameter IMAGE_WIDTH=8,
                    WRAPPED_PHASE_WIDTH=10,
						  MULTIPLIER_WIDTH=9,
						  MULTIPLICAND_WIDTH=13,
						  NUMERATOR_FACTOR=11,
						  ARCTAN_WIDTH=32
						  
)
(
     input clk,
     input rst,  //fdce 异步复位
     input [IMAGE_WIDTH-1:0]phase_shift_1,
     input [IMAGE_WIDTH-1:0]phase_shift_2,
     input [IMAGE_WIDTH-1:0]phase_shift_3,
     input                  phase_shift_valid,
     output wrapped_phase_valid,
     output signed[ARCTAN_WIDTH-1:0]arctan_out
);
parameter signed [12:0]sqrt3=13'b0_1_10111011011;

reg phase_shift_valid_r0;
reg phase_shift_valid_r1;
reg phase_shift_valid_r2;
reg signed[IMAGE_WIDTH+19:0]arctan_Numerator;
reg signed[IMAGE_WIDTH+1:0]arctan_den;
reg signed[IMAGE_WIDTH+1:0]arctan_den_r;
wire signed[IMAGE_WIDTH+1:0]arctan_den_w;
wire signed[MULTIPLIER_WIDTH+MULTIPLICAND_WIDTH-2:0]mul_out;
wire mul_out_valid;
wire out_valid;

//延迟有效信号
always @(posedge clk or posedge rst) begin
    if(rst)begin
       phase_shift_valid_r0<=0;
       phase_shift_valid_r1<=0;
        phase_shift_valid_r2<=0;
    end
    else begin
       phase_shift_valid_r0<=phase_shift_valid;
       phase_shift_valid_r1<=phase_shift_valid_r0;
       phase_shift_valid_r2<=phase_shift_valid_r1;
    end
end

reg signed [IMAGE_WIDTH:0]diff_I1I3;
reg signed [IMAGE_WIDTH:0]diff_I2I1;
reg signed [IMAGE_WIDTH:0]diff_I2I3;
//I1-I3
always @(posedge clk or posedge rst) begin
    if(rst)
      diff_I1I3<=0;
    else if(phase_shift_valid)
       diff_I1I3<=phase_shift_1-phase_shift_3;
    else 
       diff_I1I3<=diff_I1I3;
end

//I2-I3
always @(posedge clk or posedge rst) begin
    if(rst)
      diff_I2I3<=0;
    else if(phase_shift_valid)
       diff_I2I3<=phase_shift_2-phase_shift_3;
    else 
       diff_I2I3<=diff_I2I3;
end

//I2-I1
always @(posedge clk or posedge rst) begin
    if(rst)
      diff_I2I1<=0;
    else if(phase_shift_valid)
       diff_I2I1<=phase_shift_2-phase_shift_1;
    else 
       diff_I2I1<=diff_I2I1;
end

//denominator
always @(posedge clk or posedge rst) begin
    if(rst)
      arctan_den<=0;
    else if(phase_shift_valid_r0)
       arctan_den<=diff_I2I3+diff_I2I1;
    else 
       arctan_den<=arctan_den;
end

//delay by one clock cycle
always @(posedge clk or posedge rst) begin
    if(rst)
      arctan_den_r<=0;
    else if(phase_shift_valid_r1)
       arctan_den_r<=arctan_den;
    else 
       arctan_den_r<=arctan_den_r;
end
assign arctan_den_w=arctan_den_r;

pipeline2_multiplication #(
  .MULTIPLIER_WIDTH(MULTIPLIER_WIDTH),
  .MULTIPLICAND_WIDTH(MULTIPLICAND_WIDTH)
)pipeline2_multiplication_inst
(
    .clk(clk),
	 .rst(rst),
	 .in_valid(phase_shift_valid_r0),
    .Multiplier_A(diff_I1I3),
	 .Multiplicand_B(sqrt3),
	 .mul_out_valid(mul_out_valid),
    .pipe_mul_out(mul_out)
);


CORDIC_pipeline #(
    .NUMERATOR_WIDTH(MULTIPLIER_WIDTH+MULTIPLICAND_WIDTH-1),
    .DENOMINATOR_WIDTH(10),
	 .NUMERATOR_FACTOR(NUMERATOR_FACTOR),
    .ARCTAN_WIDTH(ARCTAN_WIDTH)
) CORDIC_pipeline_inst(
    .clk(clk),
	 .rst(rst),
	 .in_valid(phase_shift_valid_r2),
    .arctan_y_in(mul_out),
	 .arctan_x_in(arctan_den_r),
	 .out_valid(out_valid),
	 .arctan_out(arctan_out)
);
assign wrapped_phase_valid=out_valid;
integer outfile;
always@(posedge clk) begin
   if(rst)
    outfile = $fopen("E:/ZynqPro/Cyclic_Com_Gray/arctan_Numerator.txt","w");  // 初始化文件
   else if(mul_out_valid)
    $fdisplay(outfile,"%d",mul_out);
end 

integer outfile1;
always@(posedge clk) begin
   if(rst)
    outfile1 = $fopen("E:/ZynqPro/Cyclic_Com_Gray/arctan.txt","w");  // 初始化文件
   else if(out_valid)
    $fdisplay(outfile1,"%d",arctan_out);
end 

endmodule
