module pixcopy (
	input clk,
	input rdclk,
	input [7:0] data,
	input acapture,
	output reg write,
	output reg [15:0] wrdata,
	output reg [9:0] horiz_count
);

reg uphalf;
reg [7:0] upbyte;
reg loaded;

always @(posedge clk)
begin
	if (write) begin
		write <= 1'b0;
	end
	if (!acapture) begin
		uphalf <= 1'b1;
		loaded <= 1'b0;
		write <= 1'b0;
		horiz_count<= 0;
	end else begin
		if (rdclk) begin
			if (!loaded) begin
				if (uphalf) begin
					upbyte <= data;
					uphalf <= 1'b0;
					loaded <= 1'b1;
				end else begin
					horiz_count <= horiz_count + 1'b1;
					wrdata <= {upbyte, data};
					uphalf <= 1'b1;
					write <= 1'b1;
					loaded <= 1'b1;
				end
			end
		end else begin
			loaded <= 1'b0;
		end
	end
end

endmodule

module vline_capture (
	input ahref,
	input avsync,
	output acapture,
	output newframe
);

reg [9:0] linecount;
reg [2:0] state;

parameter
	ABOVE_SKIP = 3'h0,
	HOTLINE = 3'h1,
	LINEOMIT = 3'h2;

assign acapture = ((state == HOTLINE) & ahref);

function [2:0] nextstate;
	input [2:0] state;
	input [9:0] linecount;
	begin
		case (state)
			ABOVE_SKIP:
			begin
				if (linecount == 10'h0f4) begin
					nextstate = HOTLINE;
				end else begin
					nextstate = state;
				end
			end
			HOTLINE:
				nextstate = LINEOMIT;
			LINEOMIT:
			begin
				if (linecount == 10'h00a) begin
					nextstate = HOTLINE;
				end else begin
					nextstate = state;
				end
			end
			default:
				nextstate = state;
		endcase
	end
endfunction

always @(posedge avsync or posedge ahref)
begin
	if (avsync) begin
		linecount <= 8'h00;
		state <= ABOVE_SKIP;
	end else begin
		linecount <= (state == ABOVE_SKIP || state == LINEOMIT)
									? linecount + 10'b1
									: 10'h000;
		state <= nextstate(state, linecount);
	end
end

endmodule
