module balldetector(
	input inclk,
	input res,
	input ahref,
	input avsync,
	input apclk,
	input button,
	input force_enable,
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
	output [8:0] hue
);

wire hue_invalid;
reg [1:0] cdiv;
reg href;
reg vsync;
reg [7:0] data;

reg loaded;
reg sync_href;
reg sync_vsync;
reg sync_spi_clk;
reg sync_spi_mosi;

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
		sync_vsync <= 1;
	end else begin
		cdiv <= cdiv + 2'b01;
		xclk <= (cdiv) ? xclk : ~xclk;

		sync_href <= ahref;
		sync_vsync <= avsync;
		sync_spi_clk <= spi_clk;
		sync_spi_mosi <= spi_mosi;

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
wire [8:0] horiz_address;

assign busy = acapture;

vline_capture ld0 (
	ahref,
	avsync,
	force_enable,
	acapture,
	newframe
);

wire write;
wire [15:0] wrdata;

pixcopy pc0 (
	clk,
	(sync_href & loaded),
	data,
	acapture,
	write,
	wrdata,
	horiz_address
);

rgb2hsv rh0(
	clk,
	sync_vsync,
	write,
	wrdata,
	saturation,
	value,
	hue,
	hue_invalid,
	done
);

spi_module sm0 (
	.clk (clk),
	.reset (button),
	.mclk (sync_spi_clk),
	.miso (spi_miso),
	.mosi (sync_spi_mosi)
);

pll	pll_inst (
	.inclk0 ( inclk ),
	.c0 ( clk ),
	.locked ( locked_sig )
);

endmodule
