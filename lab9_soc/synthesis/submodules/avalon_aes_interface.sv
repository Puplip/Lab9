/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

logic [31:0] Registers [15:0];
logic [31:0] Registers_Next [15:0];
logic [31:0] Registers_Write;
logic VALID_ADDR;

AES aes0(.*,.AES_START(Registers[14] != 0),
	.AES_DONE(Registers_Next[15][0]),
	.AES_KEY({Registers[3],Registers[2],Registers[1],Registers[0]}),
	.AES_MSG_ENC({Registers[7],Registers[6],Registers[5],Registers[4]}),
	.AES_MSG_DEC({Registers_Next[11],Registers_Next[10],Registers_Next[9],Registers_Next[8]})
	);

assign Registers_Write[31:24] = (AVL_BYTE_EN[3])?(AVL_WRITEDATA[31:24]):(Registers[AVL_ADDR][31:24]);
assign Registers_Write[23:16] = (AVL_BYTE_EN[2])?(AVL_WRITEDATA[23:16]):(Registers[AVL_ADDR][23:16]);
assign Registers_Write[15:8] = (AVL_BYTE_EN[1])?(AVL_WRITEDATA[15:8]):(Registers[AVL_ADDR][15:8]);
assign Registers_Write[7:0] = (AVL_BYTE_EN[0])?(AVL_WRITEDATA[7:0]):(Registers[AVL_ADDR][7:0]);

assign Registers_Next[00] = (AVL_WRITE && AVL_ADDR == 4'd00)?Registers_Write:Registers[00];
assign Registers_Next[01] = (AVL_WRITE && AVL_ADDR == 4'd01)?Registers_Write:Registers[01];
assign Registers_Next[02] = (AVL_WRITE && AVL_ADDR == 4'd02)?Registers_Write:Registers[02];
assign Registers_Next[03] = (AVL_WRITE && AVL_ADDR == 4'd03)?Registers_Write:Registers[03];
assign Registers_Next[04] = (AVL_WRITE && AVL_ADDR == 4'd04)?Registers_Write:Registers[04];
assign Registers_Next[05] = (AVL_WRITE && AVL_ADDR == 4'd05)?Registers_Write:Registers[05];
assign Registers_Next[06] = (AVL_WRITE && AVL_ADDR == 4'd06)?Registers_Write:Registers[06];
assign Registers_Next[07] = (AVL_WRITE && AVL_ADDR == 4'd07)?Registers_Write:Registers[07];

assign Registers_Next[14] = (AVL_WRITE && AVL_ADDR == 4'd14)?Registers_Write:Registers[14];

assign EXPORT_DATA[31:16] = Registers[7][31:16];
assign EXPORT_DATA[15:0] = Registers[4][15:0];

assign AVL_READDATA = Registers[AVL_ADDR];

always_ff @ (posedge CLK) begin
	Registers = Registers_Next;
end

endmodule
