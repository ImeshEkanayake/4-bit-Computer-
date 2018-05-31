module TestModule;
	reg [3:0] A;
    reg [3:0] B;
    reg [2:0] Select;
	reg C0;
	
    wire [3:0] S;
    wire O;
		
	mux OFA(A,B,Select,S);

	initial begin
		
		$dumpfile("OFA1.vcd");
		$dumpvars(0,OFA);
		$monitor("num1=%d  + num2=%d = sum=%d  select=%b",A,B,S,Select);
		C0=0;
		Select[0]=0;
		Select[1]=1;
		Select[2]=1;
		A[1]=0;
		B[1]=0;
		A[2]=0;
		B[2]=0;
		A[3]=0;
		B[3]=0;
		A[0]=0;
		B[0]=0;
		#64 $finish;
		
	end
	
	
	//always #256 C0 = ~C0;
	always #1 	A[0]=~A[0];
	always #2 	B[0]=~B[0];
	always #4  	A[1]=~A[1];
	always #8  	B[1]=~B[1];
	always #16  A[2]=~A[2];
	always #32  B[2]=~B[2];
	always #64  A[3]=~A[3];
	always #128	B[3]=~B[3];
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//------------------- MUX for 4bits and 8 operations---------------------
module mux(input [3:0]A,input [3:0]B,input [2:0]select,output [3:0]out);

	wire [3:0] result [7:0];
	wire cin=0;
	wire coutadd;
	
	Tows_Complement OtscA(A,result[0]);
	Tows_Complement OtscB(B,result[1]);
	Four_Bit_Adder O4ba(A,B,cin,result[2],coutadd);
	Four_Bit_Subtraction O4bs(A,B,result[3]);
	Bitwise_AND OBwA(A,B,result[4]);
	Bitwise_OR OBwO(A,B,result[5]);
	Multiply Omul(A, B,result[6]);
	
	assign out = result[select];
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//------------------- Multily a 4bit by 4bits-----------------------------
module Multiply(input [3:0] A,input [3:0] B,output [3:0] mul);
	wire cin=0;
	wire [3:0] mul1;
	wire [3:0] mul2;
	wire [3:0] mul3;
	wire [3:0] mult;
	wire [3:0] SL1;
	wire [3:0] SL2;
	wire [3:0] SL3;
	wire [3:0] BSL1;
	wire [3:0] BSL2;
	wire [3:0] BSL3;
	wire [3:0] BSL4;
	wire [3:0] BSL0=0;
	
	Four_bit_into_A_Bit FBITB1(A,B[0],BSL1);
	Four_Bit_Adder A1(BSL1,BSL0,cin,mul1,c1);
	
	shiftL sl1(A,SL1);
	Four_bit_into_A_Bit FBITB2(SL1,B[1],BSL2);
	Four_Bit_Adder A2(mul1,BSL2,cin,mul2,c2);
	
	shiftL sl2(SL1,SL2);
	Four_bit_into_A_Bit FBITB3(SL2,B[2],BSL3);
	Four_Bit_Adder A3(mul2,BSL3,cin,mul3,c3);
	
	shiftL sl3(SL2,SL3);
	Four_bit_into_A_Bit FBITB4(SL3,B[3],BSL4);
	Four_Bit_Adder A4(mul3,BSL4,cin,mul,c4);
endmodule


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//------------------- Multily a 4bit from a single bit -------------------
module Four_bit_into_A_Bit(input [3:0] A,input B,output [3:0] bitmul );
	and(bitmul[0],B,A[0]);
	and(bitmul[1],B,A[1]);
	and(bitmul[2],B,A[2]);
	and(bitmul[3],B,A[3]);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//---------------------- Shifting one bit --------------------------------
module shiftL(input [3:0] A,output [3:0] ShL);
	wire c=0;
	
	or(ShL[0],c,c);
	or(ShL[1],A[0],c);
	or(ShL[2],A[1],c);
	or(ShL[3],A[2],c);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//---------------------- Bitwise OR --------------------------------------

module Bitwise_OR (input [3:0] A,input [3:0] B,output [3:0] BWS);
	or(BWS[0],A[0],B[0]);
	or(BWS[1],A[1],B[1]);
	or(BWS[2],A[2],B[2]);
	or(BWS[3],A[3],B[3]);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//---------------------- Bitwise AND--------------------------------------

module Bitwise_AND(input [3:0] A,input [3:0] B,output [3:0] BWS);
	and(BWS[0],A[0],B[0]);
	and(BWS[1],A[1],B[1]);
	and(BWS[2],A[2],B[2]);
	and(BWS[3],A[3],B[3]);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//---------------------- A-B Subtraction ---------------------------------

module Four_Bit_Subtraction(input [3:0] A,input [3:0] B,output [3:0] sub);
	wire c=0;
	wire Co;
	wire [3:0] S;
	
	Tows_Complement TsCmplt(B,S);
	Four_Bit_Adder SUB(A,S,c,sub,Co);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//----------------------2's Complement------------------------------------

module Tows_Complement(input [3:0] A,output [3:0] TsC);
	reg [0:3] B;
	wire c=0;
	wire Co;
	
	initial begin
		B[3]=1;
		B[2]=0;
		B[1]=0;
		B[0]=0;
	end
	Four_Bit_Adder TSC(~A,B,c,TsC,Co);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//----------------------Four_Bit_FullADDER--------------------------------
 
module Four_Bit_Adder(input [3:0] A,input [3:0] B,input cin,
						output [3:0] S,output c4);
	wire c1,c2,c3,c4;
	
	Full_Adder FA1 (A[0],B[0],cin,S[0],c1);
	Full_Adder FA2 (A[1],B[1],c1,S[1],c2);
	Full_Adder FA3 (A[2],B[2],c2,S[2],c3);
	Full_Adder FA4 (A[3],B[3],c3,S[3],c4);
endmodule

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//---------------------------Full_ADDER------------------------------------
module Full_Adder(input A,input B,input Cin,output Sum,output Cout);
	wire p,q,r;
	
	xor (p,A,B);
	xor (Sum,p,Cin);
	and(r,A,B);
	and(q,p,Cin);
	or(Cout,q,r);
endmodule