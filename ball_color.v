module ball_color(
	input clk,
	input [8:0] hue,
	input [4:0] saturation,
	input [4:0] value,
	input write,
	input [9:0] horiz_count,
	output reg capture,
	output [7:0] hue,
	output [4:0] saturation,
	output [4:0] value,
	output [2:0] color
);

reg [7:0] huebuf;
reg [4:0] satbuf;
reg [4:0] valbuf;

reg [3:0] state;

parameter OUT = 4'h0,
					VOID = 4'h1,
					VOID_COMP = 4'h2,
					RED = 4'h3,
					RED_COMP = 4'h4,
					BLUE = 4'h5,
					BLUE_COMP = 4'h6,
					YELLOW = 4'h7,
					YELLOW_COMP = 4'h8;

parameter BLACK = 4'hc;

reg [9:0] ball_edge_in;
reg [9:0] ball_edge_out;

function [3:0] color;
	input [7:0] hue;
	input [4:0] sat;
	input [4:0] val;
	begin
		if ((val > MIN_VAL) && (sat > MIN_SAT)) begin
			if ((0 <= hue && hue < RED_HIGH) || (RED_LOW < hue && hue <= 360)) begin
				color = RED;
			end else if (BLUE_LOW <= hue && hue <= BLUE_HIGH) begin
				color = BLUE;
			end else if (YELLOW_LOW <= hue && hue <= YE_HIGH) begin
				color = YELLOW;
			end else begin
				color = VOID;
			end
		end else if (val < BLACK_VAL) begin
			color = BLACK;
		end else begin
			color = VOID;
		end
	end
endfunction

always @(posedge clk)
begin
	case (mode)
		FIRSTLINE: begin
			case (state)
				OUT: begin
					state <= VOID;
				end
				VOID: begin
					if (write) begin
						state <= VOID_COMP;
						huebuf <= hue;
						satbuf <= sat;
						valbuf <= val;
						ball_edge_in <= horiz_count;
					end
				end

				VOID_COMP:
				begin
					case (color(.hue(huebuf), .val(valbuf), .sat(satbuf)) begin
						BLACK:
							state <= VOID;
						VOID:
							state <= VOID;
						default:
							state <= color(.hue(huebuf), .val(valbuf), .sat(satbuf));
					endcase
				end
				RED:
					if (write) begin
						state <= VOID_COMP;
						huebuf <= hue;
						satbuf <= sat;
						valbuf <= val;
					end
				RED_COMP:
				begin
					case (color(.hue(huebuf), .val(valbuf), .sat(satbuf)) begin
						BLACK:
							state <= RED;
						VOID:
							state <= VOID;
						default:
							state <= color(.hue(huebuf), .val(valbuf), .sat(satbuf));
					endcase
				end
				BLUE:
					if (write) begin
						state <= BLUE_COMP;
						huebuf <= hue;
						satbuf <= sat;
						valbuf <= val;
					end
				BLUE_COMP:
				begin
					case (color(.hue(huebuf), .val(valbuf), .sat(satbuf)) begin
						BLACK:
							state <= BLUE;
						VOID:
							state <= VOID;
						default:
							state <= color(.hue(huebuf), .val(valbuf), .sat(satbuf));
					endcase
				end
				YELLOW:
					if (write) begin
						state <= YELLOW_COMP;
						huebuf <= hue;
						satbuf <= sat;
						valbuf <= val;
					end
				YELLOW_COMP:
				begin
					case (color(.hue(huebuf), .val(valbuf), .sat(satbuf)) begin
						BLACK:
							state <= YELLOW;
						VOID:
							state <= VOID;
						default:
							state <= color(.hue(huebuf), .val(valbuf), .sat(satbuf));
					endcase
				end
			endcase
		end
		LINE_SAMPLING: begin
		end
	endcase
end

endmodule
