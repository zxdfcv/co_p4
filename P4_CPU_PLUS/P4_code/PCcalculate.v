`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:24:44 11/02/2022 
// Design Name: 
// Module Name:    PCcalculate 
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
module PCcalculate(
	input [31:0] order,
	input [31:0] branch,
	input [31:0] jal, //orj
	input [31:0] jr,
	input zero,
	input [2:0] nPC_sel, //三位pc选择
	output [31:0] next_pc
    );
	wire [1:0] mux3_sel;
	wire [31:0] mux3_out;
	assign mux3_sel = {nPC_sel[1:1], (zero & nPC_sel[0:0])};
	mux3 mux3_PCcal(.x0(order), .x1(branch), .x2(jal), .sel(mux3_sel), .result(mux3_out));//先接三个输入MUX
	mux2 mux2_PCcal(.x0(mux3_out), .x1(jr), .sel(nPC_sel[2:2]), .result(next_pc));//后接两个输入MUX
endmodule
