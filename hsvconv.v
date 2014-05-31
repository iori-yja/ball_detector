module rgb2hsv (
	input clk,
	input res,
	input read,
	input [15:0] data,
	output [4:0] saturation,
	output [4:0] value,
	output reg [6:0] hue,
	output reg hue_invalid,
	output reg done
);
parameter DIVLATENCY = 4'h8;
parameter FETCH = 3'h0,
					COMPARE = 3'h1,
					DIVIDE = 3'h2,
					HUE = 3'h3;

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

reg [2:0] colorcomp;

parameter RED = 3'h1;
parameter BLUE = 3'h2;
parameter GREEN = 3'h4;
parameter WHITE = 3'h0;

function [3:0] maxsel;
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

function [3:0] minsel;
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

reg [3:0] clkcount;

divider	div0 (
	.clken ( (state == DIVIDE) ),
	.clock ( clkcount[3] ),
	.denom ( saturation ),
	.numer ( numer ),
	.quotient ( quot ),
	.remain ( rem )
);

wire [10:0] quot;

assign value = max;
assign saturation = max - min;
reg [3:0] divwait;

always @(posedge clk)
begin
	clkcount <= clkcount + 4'b1;
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
			done <= 0;
			colorcomp[2] <= (r >= g);
			colorcomp[1] <= (g >= b);
			colorcomp[0] <= (b >= r);
			state <= COMPARE;

		end else if (state == COMPARE) begin

			divwait <= 4'h0;

			case (maxsel(colorcomp))
				RED: max <= rbuf;
				BLUE: max <= bbuf;
				GREEN: max <= gbuf;
				WHITE: max <= 5'h00;
			endcase;

			case (minsel(colorcomp))
				RED: begin
					min <= rbuf;
					numer <= (bbuf - gbuf) << 5;
					state <= DIVIDE;
				end
				BLUE: begin
					min <= bbuf;
					numer <= (gbuf - rbuf) << 5;
					state <= DIVIDE;
				end
				GREEN: begin
					min <= gbuf;
					numer <= (rbuf - bbuf) << 5;
					state <= DIVIDE;
				end
				WHITE: begin
					min <= 5'h00;
					hue_invalid <= 1;
					done <= 1;
					state <= FETCH;
				end
			endcase

		end else if (state == DIVIDE) begin

			if (divwait == DIVLATENCY) begin
				hue <= quot[10:4];
				state <= FETCH;
				divwait <= 4'h0;
			end else begin
				divwait <= divwait + 4'h1;
			end
		end else if (state == HUE) begin

		end
	end
end

endmodule
