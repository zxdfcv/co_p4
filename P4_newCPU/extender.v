`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:45:21 11/02/2022 
// Design Name: 
// Module Name:    extender 
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
module extender( //32_bit
	input [15:0] in,
	input sel, //Mode Ñ¡Ôñ
	output [31:0] out
    );
	parameter init = 32'h0000_0000;
	assign out = (sel == 1'b0) ? {16'h0000, in} : 
						(sel == 1'b1) ? {{16{in[15:15]}}, in} : //¸´ÖÆÐÅºÅ
						init;

endmodule
