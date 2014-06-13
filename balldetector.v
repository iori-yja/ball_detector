module balldetector(
	input inclk,
	input ahref,
	input avsync,
	input apclk,
	output xclk,
	input [7:0] adata,
	input spi_clk,
	output spi_miso,
	input spi_mosi,
	input cs,
	output [7:0] led,
	output [8:0] hue,
	output i2c_clk,
	inout i2c_sda,
	output busy
);

wire hue_invalid;
wire [4:0] saturation;
wire [4:0] value;
//wire [8:0] hue;
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
wire locked_sig;
wire res;

assign res = ~locked_sig;

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
		loaded <= 0;
		sync_href <= 0;
		sync_vsync <= 1;
	end else begin
		cdiv <= cdiv + 2'b01;

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
wire [9:0] horiz_address;

assign busy = acapture;

vline_capture ld0 (
	ahref,
	avsync,
	acapture,
	newframe
);

wire write;
wire [15:0] wrdata;
wire done;

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

/*
pipette_center pp0 (
	.clk (clk),
	.write (done),
	.hue (hue),
	.shot (button),
	.indicate (ind)
);
*/

spi_module sm0 (
	.clk (clk),
	.cs (cs),
	.mclk (sync_spi_clk),
	.miso (spi_miso),
	.mosi (sync_spi_mosi),
	.paraout(led)
);

wire ioclk;

pll	pll_inst (
	.inclk0 ( inclk ),
	.c0 ( clk ),
	.c1 ( ioclk ),
	.c2 ( xclk ),
	.locked ( locked_sig )
);

i2c_control ic0 (
	res,
	clk,
	ioclk,
	i2c_clk,
	i2c_sda
);


//assign clk = inclk;

endmodule
