//?��������Ƶ�����ͨ·�ܹ�ͼ�Լ���������ģ�����������˿ڣ��� datapath.v �ж���һЩ�ڲ��� wire �ͱ�����
//����ģ�����߼���ϵ���Ը�������ģ�����ʵ������������һ��
//ʹ֮��Ϊһ�����壬���Ԥ�����������źŵ����������˿ڼ��ɡ�

//��仰�൱��Ҫ
module datapath(
	input clk,
	input reset
);
	wire [31:0] A;
	wire [31:0] B;
	wire zero;//ALU����Ƿ�Ϊ��0���
	wire [31:0] result;
	wire ALUSrc;
	
	//PC related wires
	wire [31:0] next_pc;
	wire [31:0] pc;
	wire [31:0] pcAdd4;//order; //PC������ת
	wire [31:0] branch; //beq��֧
	wire [31:0] jal;//or j(no link)
	wire [31:0] jr; //jump reg
	
	//ALUCtrl��� outputCtrl
	wire [31:0] instruct;
	wire [31:26] op;
	wire [5:0] funct; // ����ʾ����������������
	wire regDist;
	wire MemtoReg;
	wire RegWrite;
	wire MemWrite;
	wire [2:0] nPC_sel; //����ź� ��תָ�����
	wire ExtOp;
	wire [1:0] ALUCtr; //ALU��λ�����ź�
	wire Imm_high_zero;
	wire ByteSel;
	//
	wire [4:0] A1;
	wire [4:0] A2;
	wire [4:0] A3;
	wire [31:0] WriteDataF;//grf����д��������
	wire [31:0] WriteData;//grf����д��
	wire [31:0] dataOut1;//grf��һ�����
	wire [31:0] dataOut2;//grf�ڶ������
	wire [31:0] ALUOut;//ALU���
	wire [31:0] ALUB; //ALU�ڶ�������
	wire [31:0] DMdataIn;//���ݴ洢�����
	wire [31:0] DMdataInF;//���ݴ洢���������
	wire [31:0] DMdataOut;//���ݴ洢�����
	wire [31:0] signImm; //������չ��
	wire [31:0] extImm;//��չ���ŵ���
	wire [31:0] high;
	wire [31:0] shiftOut; //�����ʵҲ�����Ż�, ת����λƴ��
	//byte operation
	wire [31:0] lbData;
	wire [31:0] sbData;//�洢

	
	//control module
	controller controller(.op(instruct[31:26]), .funct(instruct[5:0]), .regDist(regDist), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), 
	.MemWrite(MemWrite), .nPC_sel(nPC_sel), .ExtOp(ExtOp), .ALUCtr(ALUCtr), .Imm_high_zero(Imm_high_zero), .ByteSel(ByteSel));//����������
	
	//main module
	pc pc_reg(.clk(clk), .reset(rest), .next_pc(pc), .pc(pc));//PC״̬ת��
	im im(.pc(pc), .instruct(instruct)); //fetch instructions
	grf grf(.clk(clk), .reset(reset), .WE(RegWrite), .A1(instruct[25:21]), .A2(instruct[20:16]), .A3(A3), .WD(writeDataF), .pc(pc), //WriteData(F):final
	.RD1(dataOut1), .RD2(dataOut2)); //��Ӧģ�����
	dm dm(.clk(clk), .reset(reset), .MemWrite(MemWrite), .addr(ALUOut[13:2]), .dataIn(DMdataInF), .pc(pc), .dataOut(DMdataOut)); //DataMemory //DMdataIn(F):final
	alu alu(.A(dataOut1), .B(ALUB), .ALUCtr(ALUCtr), .result(ALUOut), .zero(zero));//alu-1

	//small module detailed function
	PCcalculate PCcalculate(.order(pcAdd4), .branch(branch), .jal(jal), .jr(jr), .zero(zero), .nPC_sel(nPC_sel), .next_pc(next_pc));//����pc
	highgen highgen(.in(instruct[15:0]), .out(high));//generate high signal
	
	//grf source
	WDgen WDgen(.ALUOut(ALUOut), .DMdataOut(DMdataOut), .high(high), .pcAdd4(pcAdd4),  .MemtoReg(MemtoReg), .Imm_high_zero(Imm_high_zero), 
	.nPC_sel_1(nPC_sel[1:1]), .out(writeData));//locate the Mem to Reg;
	mux3_5bit mux3_1(.x0(instruct[20:16]), .x1(instruct[15:11]), .x2(5'b11111), .sel({nPC_sel[1:1], RegDist}), .result(A3));//A3gen write reg signal. may modify $ra
	// A3 contains Write ADDR for grf
	//
	mux2 mux2_1(.x0(dataOut1), .x1(signImm), .sel(ALUCtrl), .result(ALUB));//MUX prepare for ALU source B
	//generate data for grf
	//
	
	//get PCcalculate param
	adder adder_1(.A(pc), .B(32'h0000_0004), .out(pcAdd4));//pc = pc + 4
	extender extender_1(.in(instruct[15:0]), .sel(ExtOp), .out(signImm));//��չextend
	shifter_2bit shifter_2bit_1(.in(signImm), .out(shiftOut));//signImm ~ ExtImm
	adder adder_2(.A(shiftOut), .B(pcAdd4), .out(branch));//�õ���ָ֧��
	jalgen jalgen(.Imm(instruct[25:0]), .PC_4(pc[31:28]), .newPC());//generate  jal pc //�õ� jal
	assign jr = dataOut1; //tunnel //�õ�jr
	
	//	input MemtoReg �����д�����,��������ѡ���λ�źŵ�MUX //input Imm_high_zero, //input nPC_sel_1,
 
	//special lb, sb
	lbgen lbgen(.WriteData(WriteData), .Byte(ALUOut[1:0]), .lbData(lbData));	
	//input [31:0] WriteData, //����д��grf������ input [1:0] Byte, //�ֽ�ѡ���� output [31:0] lbData
	mux2 mux2_2(.x0(WriteData), .x1(lbData), .sel(ByteSel), .result(WriteDataF));
	
	sbgen sbgen(.DMdataOut(DMdataOut), .dataOut2(dataOut2), .Byte(ALUOut[1:0]), .sbData(sbData));
	//input [31:0] DMdataOut //input [31:0] dataOut2 //input [1:0] Byte, //�ֽ�ѡ���� //output reg [31:0] sbData
	mux2 mux2_3(.x0(DMdataIn), .x1(sbData), .sel(ByteSel), .result(DMdataInF));//ȷ��sb����д������
	//
	
	//notes:һ��8��MUX(��PCcalculate, submodule)
	//MUX heap
endmodule
