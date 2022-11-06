`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:05:31 10/29/2022 
// Design Name: 
// Module Name:    im 
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
module im(
	input [31:0] pc,
	output [31:0] instruct
);
	reg [31:0] mem[0:4095]; //����Ĵ�������
	initial begin
		$readmemh("code.txt", mem); //��ʼ��
	end
	
	assign instruct = mem[pc - 32'h0000_3000]; //������
endmodule 