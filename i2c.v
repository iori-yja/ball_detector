module i2c_control (
	input res,
	input clk,
	input ioclk,
	output i2c_clk,
	inout i2c_sda
);

parameter LCD_ADDR = 8'h7c;
parameter TRANSMIT = 12'h4_00;
parameter START = 12'h2_00;
parameter END = 12'h1_00;

parameter WAITSTABLE = 3'h0,
					FIRSTSETUP = 3'h1,
					WAITSETUP  = 3'h2;
		

reg [2:0] state;
reg [7:0] programcount;
reg [17:0] waitcount;

wire [7:0] byte;

reg [11:0] inst;

wire write;
wire send;
wire start;
wire endcomm;
wire done;

assign write = inst[11];
assign send  = inst[10];
assign start = inst[9];
assign endcomm = inst[8];
assign byte = inst[7:0];

always @(posedge ioclk or posedge res)
begin
	if (res) begin
		programcount <= 8'h00;
		waitcount <= 18'h00000;
		state <= WAITSTABLE;
	end else begin
		case (state)
			WAITSTABLE: begin
				waitcount <= waitcount + 1'b1;
				//if (waitcount == 18'h1_0000) begin
				if (waitcount == 18'h0_0100) begin
					state <= FIRSTSETUP;
				end
			end
			FIRSTSETUP: begin
				inst <= instmem(programcount);
				waitcount <= 18'h00000;
				state <= WAITSETUP;
				programcount <= instmem(programcount) ? programcount + 1'b1 : programcount;
			end
			WAITSETUP: begin
				inst <= 12'h0_00;
				waitcount <= waitcount + 1'b1;
				if ((programcount != 8'h30) && done && waitcount > 18'h0_0018) begin
					state <= FIRSTSETUP;
				end
				//if ((programcount == 8'h30) && (waitcount == 18'h3_ffff)) begin
				if ((programcount == 8'h30) && (waitcount == 18'h0_0800)) begin
					state <= FIRSTSETUP;
				end
			end
		endcase
	end
end

/*
 * Instractions:
	 * 1xxx = set data
	 * 01xx = transmit data
	 * 001x = make start condition
	 * 0001 = make end condition
	 * 0000 = stop
*/
function [11:0] instmem;
input [7:0] pc;
case (pc)

	8'h0: instmem = START;
	8'h1: instmem = {4'h8, LCD_ADDR};
	8'h2: instmem = TRANSMIT;
	8'h3: instmem = {4'h8, 8'h80};
	8'h4: instmem = TRANSMIT;
	8'h5: instmem = {4'h8, 8'h38};
	8'h6: instmem = TRANSMIT;
	8'h7: instmem = END;

	8'h8: instmem = START;
	8'h9: instmem = {4'h8, LCD_ADDR};
	8'ha: instmem = TRANSMIT;
	8'hb: instmem = {4'h8, 8'h80};
	8'hc: instmem = TRANSMIT;
	8'hd: instmem = {4'h8, 8'h39};
	8'he: instmem = TRANSMIT;
	8'hf: instmem = END;

	8'h10: instmem = START;
	8'h11: instmem = {4'h8, LCD_ADDR};
	8'h12: instmem = TRANSMIT;
	8'h13: instmem = {4'h8, 8'h80};
	8'h14: instmem = TRANSMIT;
	8'h15: instmem = {4'h8, 8'h14};
	8'h16: instmem = TRANSMIT;
	8'h17: instmem = END;

	8'h18: instmem = START;
	8'h19: instmem = {4'h8, LCD_ADDR};
	8'h1a: instmem = TRANSMIT;
	8'h1b: instmem = {4'h8, 8'h80};
	8'h1c: instmem = TRANSMIT;
	8'h1d: instmem = {4'h8, 8'h74};
	8'h1e: instmem = TRANSMIT;
	8'h1f: instmem = END;

	8'h20: instmem = START;
	8'h21: instmem = {4'h8, LCD_ADDR};
	8'h22: instmem = TRANSMIT;
	8'h23: instmem = {4'h8, 8'h80};
	8'h24: instmem = TRANSMIT;
	8'h25: instmem = {4'h8, 8'h56};
	8'h26: instmem = TRANSMIT;
	8'h27: instmem = END;

	8'h28: instmem = START;
	8'h29: instmem = {4'h8, LCD_ADDR};
	8'h2a: instmem = TRANSMIT;
	8'h2b: instmem = {4'h8, 8'h80};
	8'h2c: instmem = TRANSMIT;
	8'h2d: instmem = {4'h8, 8'h6c};
	8'h2e: instmem = TRANSMIT;
	8'h2f: instmem = END;

	//wait here
	//
	8'h30: instmem = START;
	8'h31: instmem = {4'h8, LCD_ADDR};
	8'h32: instmem = TRANSMIT;
	8'h33: instmem = {4'h8, 8'h80};
	8'h34: instmem = TRANSMIT;
	8'h35: instmem = {4'h8, 8'h38};
	8'h36: instmem = TRANSMIT;
	8'h37: instmem = END;

	8'h38: instmem = START;
	8'h39: instmem = {4'h8, LCD_ADDR};
	8'h3a: instmem = TRANSMIT;
	8'h3b: instmem = {4'h8, 8'h80};
	8'h3c: instmem = TRANSMIT;
	8'h3d: instmem = {4'h8, 8'h0c};
	8'h3e: instmem = TRANSMIT;
	8'h3f: instmem = END;

	8'h40: instmem = START;
	8'h41: instmem = {4'h8, LCD_ADDR};
	8'h42: instmem = TRANSMIT;
	8'h43: instmem = {4'h8, 8'h80};
	8'h44: instmem = TRANSMIT;
	8'h45: instmem = {4'h8, 8'h01};
	8'h46: instmem = TRANSMIT;
	8'h47: instmem = END;

	8'h48: instmem = START;
	8'h49: instmem = {4'h8, LCD_ADDR};
	8'h4a: instmem = TRANSMIT;
	8'h4b: instmem = {4'h8, 8'hc0};
	8'h4c: instmem = TRANSMIT;
	8'h4d: instmem = {4'h8, 8'h30};
	8'h4e: instmem = TRANSMIT;
	8'h4f: instmem = END;
	8'h50: instmem = 0;

endcase
endfunction

i2c_master im0 (
	.clk(clk),
	.write(write),
	.send(send),
	.start(start),
	.endcomm(endcomm),
	.ioclk(ioclk),
	.byte(byte),
	.i2c_clk(i2c_clk),
	.i2c_sda(i2c_sda),
	.done(done)
);

endmodule


module i2c_master (
	input clk,
	input write,
	input send,
	input start,
	input endcomm,
	input ioclk,
	input [7:0] byte,
	output reg i2c_clk,
	inout i2c_sda,
	output reg done
);

reg sda_out;
reg sda_oe;

assign i2c_sda = sda_oe ? sda_out : 1'bz;

reg [3:0] sendcount;
reg [7:0] byte_buf;
reg [1:0] phase;

reg sending;
reg starting;
reg ending;
reg ioclk_now;
reg ioclk_prev;


always @(posedge ioclk)
begin
	if (write) begin
		byte_buf <= byte;
	end

	if (send) begin
		sda_oe <= 1'b1;

		sending <= 1'b1;
		starting <= 1'b0;
		ending <= 1'b0;

		phase <= 1'b0;
		done <= 0;
		sendcount <= 4'h0;
	end else if (start) begin
		sda_oe <= 1'b1;

		starting <= 1'b1;
		sending <= 1'b0;
		ending <= 1'b0;

		phase <= 1'b0;
		done <= 0;
		i2c_clk <= 1'b1;
	end else if (endcomm) begin
		starting <= 1'b0;
		sending <= 1'b0;
		ending <= 1'b1;

		phase <= 1'b0;
		done <= 0;
	end
	if (sending) begin
		case (phase)
			0:
			begin
				i2c_clk <= 1'b0;
				phase <= 2'h1;
			end
			1:
			begin
				if (sendcount == 8) begin
					sda_oe <= 1'b0;
				end
				if (sendcount == 9) begin
					sending <= 1'b0;
					done <= 1;
					sda_oe <= 1'b1;
					phase <= 2'h0;
				end
				sda_out <= byte_buf[7];
				byte_buf[7:1] <= byte_buf[6:0];
				phase <= 2'h2;
			end
			2:
			begin
				i2c_clk <= 1'b1;
				phase <= 2'h3;
			end
			3:
			begin
				phase <= 2'h0;
				sendcount <= sendcount + 1'b1;
			end
		endcase
	end else if (starting) begin
		case (phase)
			0:
			begin
				i2c_clk <= 1'b1;
				sda_out <= 1'b1;
				phase <= 2'h1;
			end
			1:
			begin
				sda_out <= 1'b0;
				starting <= 1'b0;
				phase <= 2'b0;
				done <= 1'b1;
			end
		endcase
	end else if (ending) begin
		case (phase)
			0:
			begin
				phase <= 2'h1;
				i2c_clk <= 1'b0;
				phase <= 2'h1;
			end
			1:
			begin
				sda_oe <= 1'b1;
				sda_out <= 1'b0;
				phase <= 2'h2;
			end
			2:
			begin
				i2c_clk <= 1'b1;
				phase <= 2'h3;
			end
			3:
			begin
				sda_out <= 1'b1;
				ending <= 1'b0;
				phase <= 2'b0;
				done <= 1'b1;
			end
		endcase
	end
end

endmodule

