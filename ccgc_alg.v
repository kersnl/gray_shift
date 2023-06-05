`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/20 12:13:18
// Design Name: 
// Module Name: ccgc_k3
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


module ccgc_alg(
    input clk,
    input rst,
    input frame_valid,
    input line_valid,
    input gray_ccp1_n,
    input gray_ccp2_n,
    input gray_ccp3_n,
    input gray_ccp4_n,
    input gray_ccp1_n_1,
    output K3_out,
    output [2:0]K1_out,
    output [3:0]K2_out,
    output K_valid,
    input gray_ccp1_valid
    );
reg IsEvenFrame;
reg gray_ccp1_corrected;
reg line_valid_r0;
reg line_valid_r1;
reg line_valid_r2;
reg line_valid_r3;
reg line_valid_r4;
reg line_valid_r5;

reg gray_ccp2_n_r0;
reg gray_ccp2_n_r1;
reg gray_ccp2_n_r2;
reg gray_ccp3_n_r0;
reg gray_ccp3_n_r1;
reg gray_ccp3_n_r2;
reg gray_ccp4_n_r0;
reg gray_ccp4_n_r1;
reg gray_ccp4_n_r2;
 reg ccgc_k3_r;
 reg gray_ccp1_n_r0;

reg gray_ccp1_corrected_r0;

 reg [2:0] V1;
 reg [2:0] K1;
 reg [3:0] V2;
 reg [3:0] IV2;
 reg [3:0] K2;



assign ccgc_k3_w=line_valid?(gray_ccp1_n^gray_ccp1_n_1):0;

always@(posedge clk)begin
     if(rst) ccgc_k3_r<=0;
     else ccgc_k3_r<=ccgc_k3_w;
end




//对信号数据打拍处理
// 延迟一拍line_valid
 always@(posedge clk )begin
     if(rst) begin 
       line_valid_r0<=0;
       line_valid_r1<=0;
       line_valid_r2<=0;
       line_valid_r3<=0;
       line_valid_r4<=0;
       line_valid_r5<=0;
     end
     else begin
     line_valid_r0<=line_valid;
     line_valid_r1<=line_valid_r0;
     line_valid_r2<=line_valid_r1;
     line_valid_r3<=line_valid_r2;
     line_valid_r4<=line_valid_r3;
     line_valid_r5<=line_valid_r4;
     end
end

// 延迟一拍gray_ccp1_n
always@(posedge clk )begin
     if(rst) gray_ccp1_n_r0<=0;
     else if(line_valid)
     gray_ccp1_n_r0<=gray_ccp1_n;
     else gray_ccp1_n_r0<=gray_ccp1_n_r0;
end

// 延迟2拍gray_ccp2_n
always@(posedge clk )begin
     if(rst) begin
     gray_ccp2_n_r0<=0;
     gray_ccp2_n_r1<=0;
     gray_ccp2_n_r2<=0;
     end
     else begin
     gray_ccp2_n_r0<=gray_ccp2_n;
     gray_ccp2_n_r1<=gray_ccp2_n_r0;
     gray_ccp2_n_r2<=gray_ccp2_n_r1;
     end
end

// 延迟2拍gray_ccp3_n
always@(posedge clk )begin
     if(rst) begin
     gray_ccp3_n_r0<=0;
     gray_ccp3_n_r1<=0;
      gray_ccp3_n_r2<=0;
     end
     else begin
     gray_ccp3_n_r0<=gray_ccp3_n;
     gray_ccp3_n_r1<=gray_ccp3_n_r0;
     gray_ccp3_n_r2<=gray_ccp3_n_r1;
     end
end

// 延迟2拍gray_ccp4_n
always@(posedge clk )begin
     if(rst) begin
     gray_ccp4_n_r0<=0;
     gray_ccp4_n_r1<=0;
     gray_ccp4_n_r2<=0;
     end
     else begin
     gray_ccp4_n_r0<=gray_ccp4_n;
     gray_ccp4_n_r1<=gray_ccp4_n_r0;
     gray_ccp4_n_r2<=gray_ccp4_n_r1;
     end
end




//检测上升沿
reg frame_neg_r0,frame_neg_r1;
always @(posedge clk) begin
    if(rst)begin
       frame_neg_r0<=0;
       frame_neg_r1<=0;
    end
    else begin
       frame_neg_r0<=frame_valid;
       frame_neg_r1<=frame_neg_r0;
    end
end
assign frame_neg_w=frame_neg_r0&~frame_neg_r1;


//奇偶组数判断
always@(posedge clk )begin
     if(rst) IsEvenFrame<=0;
     else if(frame_neg_w)
      IsEvenFrame<=~IsEvenFrame;
end
always @(posedge clk) begin
    if(rst)begin
       gray_ccp1_corrected<=0;
    end
    else if(IsEvenFrame&&line_valid_r0)
       gray_ccp1_corrected<=ccgc_k3_r^gray_ccp1_n_r0;
    else if(~IsEvenFrame&&line_valid_r0)
       gray_ccp1_corrected<=0^gray_ccp1_n_r0;
    
end

//延迟gray_ccp1_corrected
always@(posedge clk )begin
     if(rst) begin
     gray_ccp1_corrected_r0<=0;
     end
     else begin
     gray_ccp1_corrected_r0<=gray_ccp1_corrected;
     end
end


//V1 
always @(posedge clk ) begin
    if(rst)begin
       V1<=0;
    end
    else if(line_valid_r1)
      V1<={gray_ccp1_corrected,{2{1'b0}}}+{gray_ccp2_n_r1,1'b0}+gray_ccp3_n_r1;
    else 
      V1<=V1;
end

//look up K1
always @(posedge clk ) begin
    if(rst)begin
       K1<=0;
    end
    else if(line_valid_r2)begin
          case(V1) 
           3'd0:K1<=0;
           3'd1:K1<=1;
           3'd3:K1<=2;
           3'd2:K1<=3;
           3'd6:K1<=4;
           3'd7:K1<=5;
           3'd5:K1<=6;
           3'd4:K1<=7;
          endcase
        end
    else 
       K1<=K1;
end

//V2
always @(posedge clk ) begin
    if(rst)begin
       V2<=0;
    end
    else if(line_valid_r2)begin
      V2<={gray_ccp1_corrected_r0,{3{1'b0}}}+{gray_ccp2_n_r2,{2{1'b0}}}+{gray_ccp3_n_r2,1'b0}+gray_ccp4_n_r2;
        end
    else 
       V2<=V2;
end

//IV2
always @(posedge clk) begin
    if(rst)begin
       IV2<=0;
    end
    else if(line_valid_r3)begin
      case(V2)
        4'd0:IV2<=0;
        4'd1:IV2<=1;
        4'd3:IV2<=2;
        4'd2:IV2<=3;
        4'd6:IV2<=4;
        4'd7:IV2<=5;
        4'd5:IV2<=6;
        4'd4:IV2<=7;

        4'd12:IV2<=8;
        4'd13:IV2<=9;
        4'd15:IV2<=10;
        4'd14:IV2<=11;
        4'd10:IV2<=12;
        4'd11:IV2<=13;
        4'd9:IV2<=14;
        4'd8:IV2<=15;
      endcase
        end
    else 
       IV2<=IV2;
end

//V2
always @(posedge clk) begin
    if(rst)begin
       K2<=0;
    end
    else if(line_valid_r4)begin
       K2<=(IV2+1)>>1;
        end
    else 
       K2<=K2;
end

assign K2_out=line_valid_r5?K2:'bx;


// /*对齐三个K值*/
//k3 移位寄存器
reg [4:0]K3_S;
always @(posedge clk ) begin
    if(rst)begin
       K3_S<=0;
    end
    else if(line_valid)begin
       K3_S<={K3_S[3:0],ccgc_k3_r};
        end
    else 
       K3_S<=K3_S;
end
assign K3_out=line_valid_r5?K3_S[4]:'bx;


//k1 
reg [2:0]K1_r0;
reg [2:0]K1_r1;

always @(posedge clk) begin
    if(rst)begin
       K1_r0<=0;
       K1_r1<=0;
    end
    else begin
       K1_r0<=K1;
       K1_r1<=K1_r0;
        end

end
assign K1_out=line_valid_r5?K1_r1:'bx;
assign K_valid=line_valid_r5; 
// integer outfile;
// always@(posedge clk) begin
//    if(!rst)
//     outfile = $fopen("E:/ZynqPro/Cyclic_Com_Gray/gray_ccp1_corrected.txt","w");  // 初始化文件
//    else if(line_valid_r1)
//     $fdisplay(outfile,"%02x\n",gray_ccp1_corrected);
// end

/* integer outfile;
always@(posedge clk) begin
   if(rst)
    outfile = $fopen("E:/ZynqPro/Cyclic_Com_Gray/K3_out.txt","w");  // 初始化文件
   else if(line_valid_r5)
    $fdisplay(outfile,"%2x",K3_out);
end  */
endmodule
