module spi_module (
	input clk,
	input mclk,
	input mosi,
	input cs,
	input write,
	input [7:0] parain,
	output reg [7:0] paraout,
	output reg miso
);

parameter CPOL = 1'b0;
parameter CPHA = 1'b0;

wire [2:0] mode;
assign mode = {CPOL,CPHA};
reg mclk_prev;

reg [7:0] inbuf;
reg [7:0] outbuf;

reg cs_buf;

always @(posedge clk)
begin

	mclk_prev <= mclk;

	cs_buf <= cs;

	case (mode)
		2'h0: begin
			if ({cs_buf, cs} == 2'b10) begin
				if (write) begin
					outbuf <= parain;
				end
			end else if (2'b01) begin
				paraout <= inbuf;
			end
			if ({mclk_prev, mclk} == 2'b01) begin
				inbuf <= {inbuf[6:0], mosi};
				miso <= outbuf[7];
				outbuf[7:1] <= outbuf[6:0];
			end
		end
	endcase
end

endmodule
