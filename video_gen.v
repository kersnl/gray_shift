`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/23 09:29:10
// Design Name: 
// Module Name: video_gen
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


module video_gen #(
    parameter CLK_PERIOD =10,
            parameter IMG_HEIGHT=720, 
            parameter IMG_WIDTH=1280,
            parameter DATA_WIDTH=8,
            parameter ROW_INTERVAL=20   
)(
     output reg clk,
     output reg rst_n,
    output reg [DATA_WIDTH-1:0]hex_shift1,
    output reg [DATA_WIDTH-1:0]hex_shift2,
    output reg [DATA_WIDTH-1:0]hex_shift3, 
    output reg [DATA_WIDTH-1:0]hex_data1,
    output reg [DATA_WIDTH-1:0]hex_data2,
    output reg [DATA_WIDTH-1:0]hex_data3,
    output reg [DATA_WIDTH-1:0]hex_data4,
    output reg [DATA_WIDTH-1:0]hex_data_n_1,
    output reg                 line_hsync,
	 output hsync_out,
    output reg                 frame_vsync
    );


//产生时钟
initial begin
     begin
    clk=0;
    forever
    #(CLK_PERIOD/2) clk=~clk;
    end
end

//复位

initial begin
     begin
         rst_n=1;
     #20 rst_n=0;
     #20 rst_n=1;
    end
end

function integer clogb2(input integer depth);
       for(clogb2=0;depth>0;clogb2=clogb2+1)
            depth=depth>>1;
endfunction

reg hsync;
reg vsync;
reg hsync_start;
reg [clogb2(IMG_HEIGHT)-1:0]hsync_cnt;
reg [10:0]clk_cnt;

integer image_shift1;
integer image_shift2;
integer image_shift3;

integer image_data1;
integer image_data2;
integer image_data3;
integer image_data4;
integer image_data_n_1;
integer j,k;


integer i;
initial begin
    image_shift1=$fopen("E:/ZynqPro/Cyclic_Com_Gray/phase1.txt","r");
    image_shift2=$fopen("E:/ZynqPro/Cyclic_Com_Gray/phase2.txt","r");
    image_shift3=$fopen("E:/ZynqPro/Cyclic_Com_Gray/phase3.txt","r");
    image_data1=$fopen("E:/ZynqPro/Cyclic_Com_Gray/ccg4.txt","r");
    image_data2=$fopen("E:/ZynqPro/Cyclic_Com_Gray/ccg5.txt","r");
    image_data3=$fopen("E:/ZynqPro/Cyclic_Com_Gray/ccg6.txt","r");
    image_data4=$fopen("E:/ZynqPro/Cyclic_Com_Gray/ccg7.txt","r");
    image_data_n_1=$fopen("E:/ZynqPro/Cyclic_Com_Gray/ccgn_1.txt","r");
    vsync=0;
    #(30*CLK_PERIOD) vsync=1;

        hsync=0;
     #(50*CLK_PERIOD) hsync=1;
     for(i=0;i<IMG_HEIGHT;i=i+1)
     begin
     #(IMG_WIDTH*CLK_PERIOD) hsync=0;
     #(ROW_INTERVAL*CLK_PERIOD) hsync=1;
    //  if(hsync_cnt==IMG_HEIGHT-1)
    //   hsync=0;
    end 
    #(10*CLK_PERIOD)  vsync=0;
     #(10*CLK_PERIOD)  $stop;
end

always @(posedge clk ) begin
    if(!rst_n) begin
    line_hsync<=0;
    frame_vsync<=0;
    end
    else 
    line_hsync <=hsync;
    frame_vsync<=vsync;
end


always@(posedge clk) begin

     if(hsync) begin
      $fscanf(image_shift1,"%2h\n",hex_shift1);
      $fscanf(image_shift2,"%2h\n",hex_shift2);
      $fscanf(image_shift3,"%2h\n",hex_shift3);
      //$display("the number is %h\n",hex_data1);
    end 
end

reg [14:0]hsync_r;
always@(posedge clk) begin
       hsync_r<={hsync_r[13:0],hsync};
end


always@(posedge clk) begin
    if(!rst_n)begin
	   hex_data1<='bx;
		hex_data2<='bx;
		hex_data3<='bx;
		hex_data4<='bx;
		hex_data_n_1<='bx;
	 end
    else if(hsync_r[13]) begin
      $fscanf(image_data1,"%2h\n",hex_data1);
      $fscanf(image_data2,"%2h\n",hex_data2);
      $fscanf(image_data3,"%2h\n",hex_data3);
      $fscanf(image_data4,"%2h\n",hex_data4);
      $fscanf(image_data_n_1,"%2h\n",hex_data_n_1);
      end
end
assign hsync_out=hsync_r[14];
endmodule
