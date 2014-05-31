module balldetector(
	input inclk,
	input res,
	input ahref,
	input avsync,
	input apclk,
	input capture,
	output reg xclk,
	input [7:0] adata,
	input spi_clk,
	output spi_miso,
	input spi_mosi,
	input cs,
	output [7:0] led,
	output busy,
	output [4:0] saturation,
	output [4:0] value,
	output [6:0] hue
);

reg [1:0] cdiv;
reg href;
reg vsync;
reg [7:0] data;

reg loaded;
reg sync_href;

wire clk;
assign led = data;

/* data readable
 *     v
 *      ____      ____
 * ____/    \____/    \_
 *          ^
 *    data clr&set
*/

/* async data capture */
always @(posedge clk or posedge res)
begin
	if (res) begin
		cdiv <= 0;
		xclk <= 0;
		loaded <= 0;
		sync_href <= 0;
	end else begin
		cdiv <= cdiv + 2'b01;
		xclk <= (cdiv) ? xclk : ~xclk;
		if (ahref) begin
			sync_href <= 1'b1;
		end else begin
			sync_href <= 1'b0;
		end
		if (apclk) begin
			if (!loaded) begin
				loaded <= 1'b1;
				data <= adata;
			end
		end else begin
			loaded <= 1'b0;
		end
	end
end

wire acapture;
wire newframe;

assign busy = acapture;

vline_capture ld0 (
	ahref,
	avsync,
	acapture,
	newframe
);

wire write;
wire [15:0] wrdata;
wire [11:0] wraddr;
wire [15:0] rddata;
wire [11:0] rdaddr;

pixcopy pc0 (
	clk,
	(sync_href & loaded),
	data,
	acapture,
	write,
	wrdata,
	wraddr,
	addrclr
);

rgb2hsv rh0(
	clk,
	res,
	write,
	data,
	saturation,
	value,
	hue,
	done
);

sram sram_inst (
	.clock ( clk ),
	.data ( wrdata ),
	.wraddress ( wraddr ),
	.wren ( write ),
	.rdaddress ( rdaddr ),
	.q ( rddata )
);

pll	pll_inst (
	.inclk0 ( inclk ),
	.c0 ( clk ),
	.locked ( locked_sig )
);

endmodule
