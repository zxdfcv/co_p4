`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:38 10/29/2022 
// Design Name: 
// Module Name:    grf 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module grf(
	input clk,
	input reset,
	input WE,
	input [4:0] A1,
	input [4:0] A2,
	input [4:0] A3,
	input [31:0] WD,
	input [31:0] pc,
	output [31:0] RD1, 
	output [31:0] RD2
    );
	reg [31:0] grf[0:31];
	integer i;
	
	parameter init = 32'h0000_0000;
	always@(posedge clk, posedge reset) begin 
		if (reset == 1'b1) begin
			for (i = 0; i < 32; i = i + 1) begin
				grf[i] <= init;
			end
		end else begin
			case(WE)
			1'b1: begin grf[A3] <= WD; //����д��
			$display("@%h: $%d <= %h", pc, A3, WD);
			end
			default: ;
			//$display("@%h: $%d <= %h", pc, A3, WD);
			endcase	
			//                     $display("@%h: $%d <= %h", pc, A3, WD);
		end
	
	end
	
	assign RD1 = grf[A1];
	assign RD2 = grf[A2]; //�����Ӧ����

endmodule
