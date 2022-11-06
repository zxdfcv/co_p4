//?根据你设计的数据通路架构图以及各个部件模块的输入输出端口，在 datapath.v 中定义一些内部的 wire 型变量，
//利用模块间的逻辑关系，对各个部件模块进行实例化，串接在一起，
//使之成为一个整体，最后预留出控制器信号的输入和输出端口即可。

//这句话相当重要
module datapath(
	input clk,
	input reset
);
	wire [31:0] A;
	wire [31:0] B;
	wire zero;//ALU结果是否为零0输出
	wire [31:0] result;
	wire ALUSrc;
	
	//PC related wires
	wire [31:0] next_pc;
	wire [31:0] pc;
	wire [31:0] pcAdd4;//order; //PC四种跳转
	wire [31:0] branch; //beq分支
	wire [31:0] jal;//or j(no link)
	wire [31:0] jr; //jump reg
	
	//ALUCtr输出 outputCtr //注意无l
	wire [31:0] instruct;
	wire [31:26] op;
	wire [5:0] funct; // 仅作示例，并不真正连线
	wire regDist;
	wire MemtoReg;
	wire RegWrite;
	wire MemWrite;
	wire [2:0] nPC_sel; //输出信号 跳转指令相关
	wire ExtOp;
	wire [1:0] ALUCtr; //ALU两位控制信号
	wire Imm_high_zero;
	wire ByteSel;
	//
	wire [4:0] A1;
	wire [4:0] A2;
	wire [4:0] A3;
	wire [31:0] WriteDataF;//grf数据写入最终量
	wire [31:0] WriteData;//grf数据写入
	wire [31:0] dataOut1;//grf第一个输出
	wire [31:0] dataOut2;//grf第二个输出
	wire [31:0] ALUOut;//ALU输出
	//ALUA is single
	wire [31:0] ALUB; //ALU第二个输入
	//wire [31:0] DMdataIn;//数据存储器输出
	wire [31:0] DMdataInF;//数据存储器最终输出
	wire [31:0] DMdataOut;//数据存储器输出
	wire [31:0] signImm; //符号扩展数
	wire [31:0] extImm;//扩展符号的数
	wire [31:0] high;
	wire [31:0] shiftOut; //这个其实也可以优化, 转换成位拼接
	//byte operation
	wire [31:0] lbData;
	wire [31:0] sbData;//存储

	
	//control module
	controller controller(.op(instruct[31:26]), .funct(instruct[5:0]), .regDist(regDist), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), 
	.MemWrite(MemWrite), .nPC_sel(nPC_sel), .ExtOp(ExtOp), .ALUCtr(ALUCtr), .Imm_high_zero(Imm_high_zero), .ByteSel(ByteSel));//控制器传参
	
	//main modulee
	pc pc_reg(.clk(clk), .reset(reset), .next_pc(next_pc), .pc(pc));//PC状态转换
	im im(.pc(pc), .instruct(instruct)); //fetch instructions
	grf grf(.clk(clk), .reset(reset), .WE(RegWrite), .A1(instruct[25:21]), .A2(instruct[20:16]), .A3(A3), .WD(WriteDataF), .pc(pc), //WriteData(F):final
	.RD1(dataOut1), .RD2(dataOut2)); //对应模块接线
	dm dm(.clk(clk), .reset(reset), .MemWrite(MemWrite), .addr(ALUOut[13:2]), .dataIn(DMdataInF), .pc(pc), .fullAddress(ALUOut), .dataOut(DMdataOut)); //DataMemory //DMdataIn(F):final
	alu alu(.A(dataOut1), .B(ALUB), .ALUCtr(ALUCtr), .result(ALUOut), .zero(zero));//alu-1 这个地方原来端口不匹配 Ctrl -> Ctr

	//small module detailed function
	PCcalculate PCcalculate(.order(pcAdd4), .branch(branch), .jal(jal), .jr(jr), .zero(zero), .nPC_sel(nPC_sel), .next_pc(next_pc));//计算pc
	highgen highgen(.in(instruct[15:0]), .out(high));//generate high signal
	
	//grf source
	WDgen WDgen(.ALUOut(ALUOut), .DMdataOut(DMdataOut), .high(high), .pcAdd4(pcAdd4),  .MemtoReg(MemtoReg), .Imm_high_zero(Imm_high_zero), 
	.nPC_sel_1(nPC_sel[1:1]), .out(WriteData));//locate the Mem to Reg;
	mux3_5bit mux3_1(.x0(instruct[20:16]), .x1(instruct[15:11]), .x2(5'b11111), .sel({nPC_sel[1:1], regDist}), .result(A3));//A3gen write reg signal. may modify $ra
	// A3 contains Write ADDR for grfr //5'b11111 -> jal
	//RegDist
	mux2 mux2_1(.x0(dataOut2), .x1(signImm), .sel(ALUSrc), .result(ALUB));//MUX prepare for ALU source B ALUSrc
	//generate data for grf
	//注意大小写
	
	//get PCcalculate param
	adder adder_1(.A(pc), .B(32'h0000_0004), .out(pcAdd4));//pc = pc + 4
	extender extender_1(.in(instruct[15:0]), .sel(ExtOp), .out(signImm));//扩展extend
	shifter_2bit shifter_2bit_1(.in(signImm), .out(shiftOut));//signImm ~ ExtImm
	adder adder_2(.A(shiftOut), .B(pcAdd4), .out(branch));//得到分支指令
	jalgen jalgen(.Imm(instruct[25:0]), .PC_4(pc[31:28]), .newPC(jal));//generate  jal pc //得到 jal //这里有问题
	assign jr = dataOut1; //tunnel //得到jr
	
	//	input MemtoReg 这里有待整合,可以增加选择多位信号的MUX //input Imm_high_zero, //input nPC_sel_1,
 
	//special lb, sb
	lbgen lbgen(.WriteData(WriteData), .Byte(ALUOut[1:0]), .lbData(lbData));	
	//input [31:0] WriteData, //即将写入grf的数据 input [1:0] Byte, //字节选择线 output [31:0] lbData
	mux2 mux2_2(.x0(WriteData), .x1(lbData), .sel(ByteSel), .result(WriteDataF));
	
	sbgen sbgen(.DMdataOut(DMdataOut), .dataOut2(dataOut2), .Byte(ALUOut[1:0]), .sbData(sbData));
	//input [31:0] DMdataOut //input [31:0] dataOut2 //input [1:0] Byte, //字节选择线 //output reg [31:0] sbData
	mux2 mux2_3(.x0(dataOut2), .x1(sbData), .sel(ByteSel), .result(DMdataInF));//确定sb最终写入数据 在ALUOut中选择
	//
	
	//notes:一共8个MUX(含PCcalculate, submodule)
	//MUX heap
	//always @(posedge clk) begin
	
		//$display("top is @%h: $%d <= %h, next_pc is %h， instruct is %h, RegWrite is %h, WriteData is %h, ALUOut is %h, ALUB is %h", pc, A3, WriteDataF, next_pc, instruct, RegWrite, WriteData, ALUOut, ALUB);
		//$display("ALUB is %h, dataOut1 is %h", ALUB, dataOut1);
		//$display("branch is %h", branch);
		//$display("top is @%h: $%d <= %h, next_pc is %h， instruct is %h, RegWrite is %d", pc, A3, WriteDataF, next_pc, instruct, RegWrite, ALUB);
	//end
endmodule
