`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:47:41 10/29/2022 
// Design Name: 
// Module Name:    datapath1 
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
module controller(
	input [31:26] op,
	input [5:0] funct,
	output regDist,
	output ALUSrc,
	output MemtoReg,
	output RegWrite,
	output MemWrite,
	output [2:0] nPC_sel, //输出信号 跳转指令相关
	output ExtOp,
	output [1:0] ALUCtr, //ALU两位控制信号
	output Imm_high_zero,
	output ByteSel
);
parameter init = 13'b0_0_0_0_0_000_0_00_0_0;
reg [12:0] signal;
always@(*) begin
	case(op)
	6'b000000: case(funct)
					6'b100000: signal = 13'b1_0_0_1_0_000_0_00_0_0; //add ALU 00
					6'b100010: signal = 13'b1_0_0_1_0_000_0_01_0_0;//sub ALU 01
					6'b001000: signal = 13'b0_0_0_0_0_110_0_00_0_0;//jr only nPC_sel have problems
					6'b000000: signal = 13'b0_0_0_0_0_000_0_00_0_0; //sll & nop nothing to do
					default: signal = 13'b0_0_0_0_0_000_0_00_0_0; //无效指令均为nop
					endcase //R instr
	 
	6'b001101: signal = 13'b0_1_0_1_0_000_0_10_0_0; //ori I ALUSrc, regWrite, ALUCtr = 10
	6'b100011: signal = 13'b0_1_1_1_0_000_1_00_0_0; //lw I
	6'b101011: signal = 13'b0_1_0_0_1_000_1_00_0_0; //sw I
	6'b000100: signal = 13'b0_0_0_0_0_001_0_01_0_0; //beq I ALUCtr[0] = 1, nPC_sel[0] = 1 //也可以不聚合在一起，
	//像课上讲的一样分开
	6'b001111: signal = 13'b0_0_0_0_1_000_0_00_1_0; //lui I regWtire = 1, Imm_high_zero  = 1
	
	
	6'b000010: signal = 13'b0_0_0_0_0_010_0_00_0_0; // j J nPC_sel[1] = 0
	6'b000011: signal = 13'b0_0_0_0_1_010_0_00_0_0; // jal J regWrite = 1 nPC_sel[1] = 0
	default: signal = 13'b0_0_0_0_0_000_0_00_0_0; //无效指令均为nop
	endcase

end
	assign {regDist, ALUSrc, MemtoReg, RegWrite, MemWrite, nPC_sel, ExtOp, ALUCtr, Imm_high_zero, ByteSel} = signal;

endmodule

