`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:45:52 10/29/2022 
// Design Name: 
// Module Name:    dm 
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
module dm(
	input clk,
	input reset,
	input MemWrite,
	input [13:2] addr, //取出数据地址
	input [31:0] dataIn, //输入数据
	input [31:0] pc,
	output [31:0] dataOut //输出数据
);

reg [31:0] mem[0:3071];
parameter init = 32'h0000_0000;
integer i;

always@(posedge clk, posedge reset) begin
	if (reset == 1'b1) begin
		for (i = 0; i < 3072; i = i + 1) begin
				mem[i] <= init;
		end
	end else begin
		case(MemWrite) 
		1'b1: begin mem[addr] <= dataIn; //这样写没问题
			$display("@%h: *%h <= %h", pc, addr, dataIn);
		end
		default: ;
		endcase
	end
end

	assign dataOut = mem[addr];

endmodule 
