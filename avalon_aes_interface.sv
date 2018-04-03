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
logic [31:0] Registers_Next;

assign Registers_Next[31:24] = (AVL_BYTE_EN[3])?(AVL_WRITEDATA[31:24]):(Registers[AVL_ADDR][31:24]);
assign Registers_Next[23:16] = (AVL_BYTE_EN[2])?(AVL_WRITEDATA[23:16]):(Registers[AVL_ADDR][23:16]);
assign Registers_Next[15:8] = (AVL_BYTE_EN[1])?(AVL_WRITEDATA[15:8]):(Registers[AVL_ADDR][15:8]);
assign Registers_Next[7:0] = (AVL_BYTE_EN[0])?(AVL_WRITEDATA[7:0]):(Registers[AVL_ADDR][7:0]);

assign EXPORT_DATA[31:16] = Registers[3][31:16];
assign EXPORT_DATA[15:0] = Registers[0][15:0];

assign AVL_READDATA = Registers[AVL_ADDR];

always_ff @ (posedge CLK) begin
	if(RESET)
		
	if(AVL_WRITE)
		Registers[AVL_ADDR] = Registers_Next;
end


endmodule
