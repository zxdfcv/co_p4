module alu(
	input [31:0] A,
	input [31:0] B,
	input [1:0] ALUCtr,
	output [31:0] result,
	output zero
);
	assign result = (ALUCtr== 2'b00) ? A + B : 
						(ALUCtr == 2'b01) ? A - B : 
						(ALUCtr == 2'b10) ? A | B :
						(ALUCtr == 2'b11) ? A & B : //增加功能
						32'h0000_0000; //error
	

endmodule
