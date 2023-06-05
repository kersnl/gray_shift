`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/31 11:55:26
// Design Name: 
// Module Name: phase_ccgc
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

module phase_ccgc(
      input clk,
		input rst,
		//ccgc
		input ccp1_n_1,
		input ccp1_n,
		input ccp2_n,
		input ccp3_n,
		input ccp4_n,
		input frame_vsync_k,
		input hsync_k,
		//phase shift
		input [7:0]phase_shift_1,
		input [7:0]phase_shift_2,
		input [7:0]phase_shift_3,
		input line_hsync,
      //out data
		output [31:0]abphase_out,
		output abphase_valid
    );
  
wire K3_out;
wire [2:0]K1_out;
wire [3:0]K2_out;
wire K_valid;
     
wire phase_shift_valid  ;
wire [31:0]wrapped_phase ;     
wire wrapped_phase_valid;


ccgc_alg ccgc_alg_inst
(
    .clk(clk),
    .rst(rst),
    .frame_valid(frame_vsync_k),
    .line_valid(hsync_k),
     .gray_ccp1_n(ccp1_n),
     .gray_ccp2_n(ccp2_n),
     .gray_ccp3_n(ccp3_n),
     .gray_ccp4_n(ccp4_n),
     .gray_ccp1_n_1(ccp1_n_1),
     .K3_out(K3_out),
     .K1_out(K1_out),
     .K2_out(K2_out),
     .K_valid(K_valid),
     .gray_ccp1_valid (1'b1)
);
wrapped_phase #(
    .IMAGE_WIDTH(8),
	 .WRAPPED_PHASE_WIDTH(10),
	 .MULTIPLIER_WIDTH(9),
	 .MULTIPLICAND_WIDTH(13),
	 .NUMERATOR_FACTOR(11),
	 .ARCTAN_WIDTH(32)
)	 wrapped_phase_inst(
       .clk(clk),
		 .rst(rst),
		 .phase_shift_1(phase_shift_1),
		 .phase_shift_2(phase_shift_2),
		 .phase_shift_3(phase_shift_3),
		 .phase_shift_valid(line_hsync),
		 .wrapped_phase_valid(wrapped_phase_valid),
		 .arctan_out(wrapped_phase)
);


abphase_solution #(
   .ABPHASEWIDTH(32),
	.WRAPPED_PHASEWIDTH(32)
)abphase_solution_inst(
    .clk(clk),
    .rst(rst),
	 .k1(K1_out),
	 .k2(K2_out),
	 .k3(K3_out),
	 .k_valid(K_valid),
	 .wrapped_phase(wrapped_phase),
	 .wrapped_phase_valid(wrapped_phase_valid),
	 .abphase_out(abphase_out),
	 .abphase_valid(abphase_valid)
);





endmodule
