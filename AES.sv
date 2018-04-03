/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

enum logic [7:0] {
	Wait,
	WaitKeyExpansion,
	AddRoundKey,
	ShiftRows_Loop,
	SubBytes_Loop,
	AddRoundKey_Loop,
	MixColumns_0,
	MixColumns_1,
	MixColumns_2,
	MixColumns_3,
	ShiftRows_Done,
	SubBytes_Done,
	AddRoundKey_Done,
	Done} State, State_n;
logic [7:0] Count, Count_n;

logic AES_DONE_n;
logic [127:0] AES_MSG_DEC_n, ShiftOut, SubOut;
logic [10:0][127:0] KeySchedule;

logic [31:0] MixIn,MixOut;

KeyExpansion ke0(.*,.clk(CLK),.Cipherkey(AES_KEY));
InvShiftRows isr0(.data_in(AES_MSG_DEC),.data_out(ShiftOut));
InvMixColumns imc0(.in(MixIn),.out(MixOut));

genvar i;
generate
for(i = 0; i < 16; i = i + 1) begin : _a_thing
	InvSubBytes isb(.clk(CLK),.in(AES_MSG_DEC[(i+1)*8-1:i*8]),.out(SubOut[(i+1)*8-1:i*8]));
end
endgenerate

always_ff @ (posedge CLK) begin
	if (RESET) begin
		State = Wait;
		Count = 8'd0;
		AES_DONE = 1'b0;
		AES_MSG_DEC = AES_MSG_ENC;
	end
	else begin
		State = State_n;
		Count = Count_n;
		AES_DONE = AES_DONE_n;
		AES_MSG_DEC = AES_MSG_DEC_n;
	end
end

always_comb begin
		State_n = State;
		Count_n = Count;
		AES_DONE_n = AES_DONE;
		AES_MSG_DEC_n = AES_MSG_DEC;
		MixIn = 32'd0;
	case (State)
		Wait: begin
			if (AES_START) State_n = WaitKeyExpansion;
			Count_n = 8'd0;
			AES_DONE_n = 1'b0;
			AES_MSG_DEC_n = AES_MSG_ENC;
		end
		WaitKeyExpansion: begin
			if(Count == 8'd10) begin
				State_n = AddRoundKey;
			end
			Count_n = Count + 8'd1;
		end
		AddRoundKey: begin
			AES_MSG_DEC_n = AES_MSG_DEC ^ KeySchedule[0];
			State_n = ShiftRows_Loop;
			Count_n = 8'd0;
		end
		ShiftRows_Loop: begin
			State_n = SubBytes_Loop;
			AES_MSG_DEC_n = ShiftOut;
		end
		SubBytes_Loop: begin
			State_n = AddRoundKey_Loop;
			AES_MSG_DEC_n = SubOut;
		end
		AddRoundKey_Loop: begin
			State_n = MixColumns_0;
			AES_MSG_DEC_n = AES_MSG_DEC ^ KeySchedule[Count+1];
		end
		MixColumns_0: begin
			State_n = MixColumns_1;
			MixIn = AES_MSG_DEC[31:0];
			AES_MSG_DEC_n[31:0] = MixOut;
		end
		MixColumns_1: begin
			State_n = MixColumns_2;
			MixIn = AES_MSG_DEC[63:32];
			AES_MSG_DEC_n[63:32] = MixOut;
		end
		MixColumns_2: begin
			State_n = MixColumns_3;
			MixIn = AES_MSG_DEC[95:64];
			AES_MSG_DEC_n[95:64] = MixOut;
		end
		MixColumns_3: begin
			State_n = (Count == 8'd8)?(ShiftRows_Done):(ShiftRows_Loop);
			MixIn = AES_MSG_DEC[127:96];
			AES_MSG_DEC_n[127:96] = MixOut;
			Count_n = Count + 8'd1;
		end
		ShiftRows_Done: begin
			State_n = SubBytes_Done;
			AES_MSG_DEC_n = ShiftOut;
		end
		SubBytes_Done: begin
			State_n = AddRoundKey_Done;
			AES_MSG_DEC_n = SubOut;
		end
		AddRoundKey_Done: begin
			State_n = Done;
			AES_MSG_DEC_n = AES_MSG_DEC ^ KeySchedule[10];
			AES_DONE_n = 1'b1;
		end
		Done: begin
			if (~AES_START) begin
				State_n = Wait;
				AES_DONE_n = 1'b0;
			end
		end
	endcase
end

endmodule
