module rgb2hsv (
	input clk,
	input res,
	input read,
	input [15:0] data,
	output reg [4:0] saturation,
	output [4:0] value,
	output reg [6:0] hue,
	output reg hue_invalid,
	output reg done
);

parameter FETCH = 2'b00,
					COMPARE = 2'b01,
					SETDIV = 2'b10,
					DIVIDE = 2'b11;

wire [4:0] r;
wire [4:0] g;
wire [4:0] b;

reg [4:0] rbuf;
reg [4:0] gbuf;
reg [4:0] bbuf;

reg [4:0] min;
reg [4:0] max;

reg [1:0] state;

reg signed [10:0] numer;
reg [9:0] denomi;

assign {r, g, b} = data [14:0];

wire [2:0] colorcomp;

assign colorcomp[2] = rbuf >= gbuf;
assign colorcomp[1] = gbuf >= bbuf;
assign colorcomp[0] = bbuf >= rbuf;

parameter RED = 2'h0;
parameter BLUE = 2'h1;
parameter GREEN = 2'h2;
parameter WHITE = 2'h3;

function [1:0] maxsel;
	input [3:0] colorcomp;
begin
	casex (colorcomp)
		4'b1x0: maxsel = RED;
		4'bx01: maxsel = BLUE;
		4'b01x: maxsel = GREEN;
		default: maxsel = WHITE;
	endcase
end
endfunction

function [1:0] minsel;
	input [3:0] colorcomp;
begin
	casex (colorcomp)
		4'b0x1: minsel = RED;
		4'bx10: minsel = BLUE;
		4'b10x: minsel = GREEN;
		default: minsel = WHITE;
	endcase
end
endfunction

assign value = max;

always @(posedge clk)
begin
	if(res) begin
		rbuf <= 5'h00;
		gbuf <= 5'h00;
		bbuf <= 5'h00;
		state <= FETCH;
	end else begin
		if (read && (state == FETCH)) begin
			rbuf <= r;
			gbuf <= g;
			bbuf <= b;
			state <= COMPARE;

		end else if (state == COMPARE) begin

			case (maxsel(colorcomp))
				RED: max <= rbuf;
				BLUE: max <= bbuf;
				GREEN: max <= gbuf;
				WHITE: max <= 5'h00;
			endcase;

			case (minsel(colorcomp))
				RED: min <= rbuf;
				BLUE: min <= bbuf;
				GREEN: min <= gbuf;
				WHITE: min <= 5'h00;
			endcase;

			state <= SETDIV;

		end else if (state == SETDIV) begin

			if (min == rbuf)
				numer <= (bbuf - gbuf) << 6;
			else if (min == bbuf)
				numer <= (gbuf - rbuf) << 6;
			else
				numer <= (rbuf - bbuf) << 6;

			state <= DIVIDE;

		end else begin
			if (max == min) begin
				hue_invalid <= 1;
				done <= 1;
				hue <= 0;
			end

			state <= FETCH;
			
		end
	end
end

endmodule
