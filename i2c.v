module i2c_control (
	input res,
	input clk,
	input ioclk,
	input write_req,
	input delete_req,
	input [7:0] inbyte,
	output i2c_clk,
	inout i2c_sda
);

parameter LCD_ADDR = 8'h7c;
parameter TRANSMIT = 12'h4_00;
parameter START = 12'h2_00;
parameter END = 12'h1_00;

parameter WAITSTABLE = 3'h0,
					LCDSETUP = 3'h1,
					LCDSETUP_WAIT = 3'h2,
					CAMERA_SETUP = 3'h3,
					CAMERA_SETUP_WAIT = 3'h4,
					WRITE_CHAR = 3'h5;

parameter CAMERA_MAX = 8'h71;

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

reg [7:0] dataindex;
reg [7:0] inbyte_buf;

reg delete_buf;
reg write_buf;

always @(posedge ioclk or posedge res)
begin

	if (res) begin
		programcount <= 8'h00;
		waitcount <= 18'h00000;
		state <= WAITSTABLE;
		dataindex <= 0;
		delete_buf <= 0;
		write_buf <= 0;
	end else begin
		case (state)
			WAITSTABLE: begin
				waitcount <= waitcount + 1'b1;
				//if (waitcount == 18'h1_0000) begin
				if (waitcount == 18'h0_0100) begin
					state <= CAMERA_SETUP;
				end
			end
			CAMERA_SETUP: begin
				inst <= cameramem(programcount[2:0], addr_dict(dataindex), data_dict(dataindex));
				waitcount <= 18'h00000;
				if (dataindex != CAMERA_MAX) begin
					state <= CAMERA_SETUP_WAIT;
					programcount <= programcount + 1'b1;
				end else begin
					state <= LCDSETUP;
					programcount <= 8'h0;
				end
			end
			CAMERA_SETUP_WAIT: begin
				inst <= 12'h0_00;
				waitcount <= waitcount + 1'b1;
				if (done && waitcount > 18'h0_0018) begin
					state <= CAMERA_SETUP;
					dataindex <= dataindex + 1'b1;
				end
			end
			LCDSETUP: begin
				inst <= instmem(programcount, inbyte_buf);
				waitcount <= 18'h00000;
				state <= instmem(programcount, inbyte_buf) ? LCDSETUP_WAIT : WRITE_CHAR;
				programcount <= programcount + 1'b1;
			end
			LCDSETUP_WAIT: begin
				inst <= 12'h0_00;
				waitcount <= waitcount + 1'b1;
				if ((programcount != 8'h30) && done && waitcount > 18'h0_0018) begin
					state <= LCDSETUP;
				end
				//if ((programcount == 8'h30) && (waitcount == 18'h3_ffff)) begin
				if ((programcount == 8'h30) && (waitcount == 18'h0_0800)) begin
					state <= LCDSETUP;
				end
			end
			WRITE_CHAR: begin
				if (write_req ^ write_buf) begin
					write_buf <= write_req;
					programcount <= 8'h40;
					state <= LCDSETUP;
				end else if (delete_req ^ delete_buf) begin
					delete_buf <= delete_req;
					programcount <= 8'h60;
					state <= LCDSETUP;
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
input [7:0] data;
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
	8'h4d: instmem = {4'h8, data};
	8'h4e: instmem = TRANSMIT;
	8'h53: instmem = END;
	8'h54: instmem = 0;

	8'h60: instmem = START;
	8'h61: instmem = {4'h8, LCD_ADDR};
	8'h62: instmem = TRANSMIT;
	8'h63: instmem = {4'h8, 8'h80};
	8'h64: instmem = TRANSMIT;
	8'h65: instmem = {4'h8, 8'h01};
	8'h66: instmem = TRANSMIT;
	8'h67: instmem = END;                            
	8'h68: instmem = 0;


	default:
		instmem = 0;
endcase
endfunction

parameter CAM_ADDR = 8'h42;

function [11:0] cameramem;
input [2:0] pc;
input [7:0] addr;
input [7:0] data;
case (pc)
	3'h0: cameramem = START;
	3'h1: cameramem = {4'h8, CAM_ADDR};
	3'h2: cameramem = TRANSMIT;
	3'h3: cameramem = {4'h8, addr};
	3'h4: cameramem = TRANSMIT;
	3'h5: cameramem = {4'h8, data};
	3'h6: cameramem = TRANSMIT;
	3'h7: cameramem = END;
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

function [7:0] addr_dict;
	input [7:0] index;
	case (index)
		8'h00: addr_dict = 8'h01;
		8'h01: addr_dict = 8'h02;
		8'h02: addr_dict = 8'h03;
		8'h03: addr_dict = 8'h0c;
		8'h04: addr_dict = 8'h0e;
		8'h05: addr_dict = 8'h0f;
		8'h06: addr_dict = 8'h15;
		8'h07: addr_dict = 8'h16;
		8'h08: addr_dict = 8'h17;
		8'h09: addr_dict = 8'h18;
		8'h0a: addr_dict = 8'h19;
		8'h0b: addr_dict = 8'h1a;
		8'h0c: addr_dict = 8'h1e;
		8'h0d: addr_dict = 8'h21;
		8'h0e: addr_dict = 8'h22;
		8'h0f: addr_dict = 8'h29;

		8'h10: addr_dict = 8'h32;
		8'h11: addr_dict = 8'h33;
		8'h12: addr_dict = 8'h34;
		8'h13: addr_dict = 8'h35;
		8'h14: addr_dict = 8'h37;
		8'h15: addr_dict = 8'h38;
		8'h16: addr_dict = 8'h39;
		8'h17: addr_dict = 8'h3b;
		8'h18: addr_dict = 8'h3c;
		8'h19: addr_dict = 8'h3d;
		8'h1a: addr_dict = 8'h3e;
		8'h1b: addr_dict = 8'h3f;
		8'h1c: addr_dict = 8'h41;
		8'h1d: addr_dict = 8'h41; //????
		8'h1e: addr_dict = 8'h43;
		8'h1f: addr_dict = 8'h44;

		8'h20: addr_dict = 8'h45;
		8'h21: addr_dict = 8'h46;
		8'h22: addr_dict = 8'h47;
		8'h23: addr_dict = 8'h48;
		8'h24: addr_dict = 8'h4b;
		8'h25: addr_dict = 8'h4c;
		8'h26: addr_dict = 8'h4d;
		8'h27: addr_dict = 8'h4e;
		8'h28: addr_dict = 8'h4f;
		8'h29: addr_dict = 8'h50;
		8'h2a: addr_dict = 8'h51;
		8'h2b: addr_dict = 8'h52;
		8'h2c: addr_dict = 8'h53;
		8'h2d: addr_dict = 8'h54;
		8'h2e: addr_dict = 8'h56;
		8'h2f: addr_dict = 8'h58;

		8'h30: addr_dict = 8'h59;
		8'h31: addr_dict = 8'h5a;
		8'h32: addr_dict = 8'h5b;
		8'h33: addr_dict = 8'h5c;
		8'h34: addr_dict = 8'h5d;
		8'h35: addr_dict = 8'h5e;
		8'h36: addr_dict = 8'h69;
		8'h37: addr_dict = 8'h6a;
		8'h38: addr_dict = 8'h6b;
		8'h39: addr_dict = 8'h6c;
		8'h3a: addr_dict = 8'h6d;
		8'h3b: addr_dict = 8'h6e;
		8'h3c: addr_dict = 8'h6f;
		8'h3d: addr_dict = 8'h70;
		8'h3e: addr_dict = 8'h71;
		8'h3f: addr_dict = 8'h72;

		8'h40: addr_dict = 8'h73;
		8'h41: addr_dict = 8'h74;
		8'h42: addr_dict = 8'h75;
		8'h43: addr_dict = 8'h76;
		8'h44: addr_dict = 8'h77;
		8'h45: addr_dict = 8'h78;
		8'h46: addr_dict = 8'h79;
		8'h47: addr_dict = 8'h8d;
		8'h48: addr_dict = 8'h8e;
		8'h49: addr_dict = 8'h8f;
		8'h4a: addr_dict = 8'h90;
		8'h4b: addr_dict = 8'h91;
		8'h4c: addr_dict = 8'h96;
		8'h4d: addr_dict = 8'h96;
		8'h4e: addr_dict = 8'h97;
		8'h4f: addr_dict = 8'h98;

		8'h50: addr_dict = 8'h99;
		8'h51: addr_dict = 8'h9a;
		8'h52: addr_dict = 8'h9a;
		8'h53: addr_dict = 8'h9b;
		8'h54: addr_dict = 8'h9c;
		8'h55: addr_dict = 8'h9d;
		8'h56: addr_dict = 8'h9e;
		8'h57: addr_dict = 8'ha2;
		8'h58: addr_dict = 8'ha4;
		8'h59: addr_dict = 8'hb0;
		8'h5a: addr_dict = 8'hb1;
		8'h5b: addr_dict = 8'hb2;
		8'h5c: addr_dict = 8'hb3;
		8'h5d: addr_dict = 8'hb8;
		8'h5e: addr_dict = 8'hc8;
		8'h5f: addr_dict = 8'hc9;
		8'h60: addr_dict = 8'h12;
		8'h61: addr_dict = 8'h40;


	endcase
endfunction

function [7:0] data_dict;
	input [7:0] index;
	case (index)
		8'h00: data_dict = 8'h40;
		8'h01: data_dict = 8'h60;
		8'h02: data_dict = 8'h0a;
		8'h03: data_dict = 8'h00;
		8'h04: data_dict = 8'h61;
		8'h05: data_dict = 8'h4b;
		8'h06: data_dict = 8'h00;
		8'h07: data_dict = 8'h02;
		8'h08: data_dict = 8'h13;
		8'h09: data_dict = 8'h01;
		8'h0a: data_dict = 8'h02;
		8'h0b: data_dict = 8'h7a;
		8'h0c: data_dict = 8'h07;
		8'h0d: data_dict = 8'h02;
		8'h0e: data_dict = 8'h91;
		8'h0f: data_dict = 8'h07;

		8'h10: data_dict = 8'hb6;
		8'h11: data_dict = 8'h0b;
		8'h12: data_dict = 8'h11;
		8'h13: data_dict = 8'h0b;
		8'h14: data_dict = 8'h1d;
		8'h15: data_dict = 8'h71;
		8'h16: data_dict = 8'h2a;
		8'h17: data_dict = 8'h12;
		8'h18: data_dict = 8'h78;
		8'h19: data_dict = 8'hc3;
		8'h1a: data_dict = 8'h00;
		8'h1b: data_dict = 8'h00;
		8'h1c: data_dict = 8'h08;
		8'h1d: data_dict = 8'h38; //????
		8'h1e: data_dict = 8'h0a;
		8'h1f: data_dict = 8'hf0;

		8'h20: data_dict = 8'h34;
		8'h21: data_dict = 8'h58;
		8'h22: data_dict = 8'h28;
		8'h23: data_dict = 8'h3a;
		8'h24: data_dict = 8'h09;
		8'h25: data_dict = 8'h00;
		8'h26: data_dict = 8'h40;
		8'h27: data_dict = 8'h20;
		8'h28: data_dict = 8'h80;
		8'h29: data_dict = 8'h80;
		8'h2a: data_dict = 8'h00;
		8'h2b: data_dict = 8'h22;
		8'h2c: data_dict = 8'h5e;
		8'h2d: data_dict = 8'h80;
		8'h2e: data_dict = 8'h40;
		8'h2f: data_dict = 8'h9e;

		8'h30: data_dict = 8'h88;
		8'h31: data_dict = 8'h88;
		8'h32: data_dict = 8'h44;
		8'h33: data_dict = 8'h67;
		8'h34: data_dict = 8'h49;
		8'h35: data_dict = 8'h0e;
		8'h36: data_dict = 8'h00;
		8'h37: data_dict = 8'h40;
		8'h38: data_dict = 8'h0a;
		8'h39: data_dict = 8'h0a;
		8'h3a: data_dict = 8'h55;
		8'h3b: data_dict = 8'h11;
		8'h3c: data_dict = 8'h9f;
		8'h3d: data_dict = 8'h3a;
		8'h3e: data_dict = 8'h35;
		8'h3f: data_dict = 8'h11;

		8'h40: data_dict = 8'hf0;
		8'h41: data_dict = 8'h10;
		8'h42: data_dict = 8'h05;
		8'h43: data_dict = 8'he1;
		8'h44: data_dict = 8'h01;
		8'h45: data_dict = 8'h04;
		8'h46: data_dict = 8'h01;
		8'h47: data_dict = 8'h4f;
		8'h48: data_dict = 8'h00;
		8'h49: data_dict = 8'h00;
		8'h4a: data_dict = 8'h00;
		8'h4b: data_dict = 8'h00;
		8'h4c: data_dict = 8'h00;
		8'h4d: data_dict = 8'h00;
		8'h4e: data_dict = 8'h30;
		8'h4f: data_dict = 8'h20;

		8'h50: data_dict = 8'h30;
		8'h51: data_dict = 8'h00;
		8'h52: data_dict = 8'h84;
		8'h53: data_dict = 8'h29;
		8'h54: data_dict = 8'h03;
		8'h55: data_dict = 8'h4c;
		8'h56: data_dict = 8'h3f;
		8'h57: data_dict = 8'h02;
		8'h58: data_dict = 8'h88;
		8'h59: data_dict = 8'h84;
		8'h5a: data_dict = 8'h0c;
		8'h5b: data_dict = 8'h0e;
		8'h5c: data_dict = 8'h82;
		8'h5d: data_dict = 8'h0a;
		8'h5e: data_dict = 8'hf0;
		8'h5f: data_dict = 8'h60;
		8'h60: data_dict = 8'h04;
		8'h61: data_dict = 8'hf0;

	endcase
endfunction
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

