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
	output i2c_clk,
	inout i2c_sda,
	output busy,
	input key0,
	input key1
);

wire hue_invalid;
wire [4:0] saturation;
wire [4:0] value;
wire [8:0] hue;
reg [1:0] cdiv;
reg href;
reg vsync;
reg [7:0] data;

reg loaded;
reg sync_href;
reg sync_vsync;
reg sync_spi_clk;
reg sync_spi_mosi;
reg [9:0] hue_buf;
reg [4:0] value_buf;
reg [4:0] satbuf;

wire clk;
wire locked_sig;
wire res;

//red
assign led[0] = ((9'd330 < hue_buf) || (hue_buf < 9'd20));
//blue
assign led[1] = ((9'd160 < hue_buf) && (hue_buf < 9'd250));
//yellow
assign led[2] = ((9'd50 < hue_buf) && (hue_buf < 9'd70));

//
assign led[3] = (value_buf > 5'hc);
assign led[4] = (satbuf > 5'hc);

assign res = ~(locked_sig);


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

		if ((horiz_address == 320)) begin
			if (write) begin
				hue_buf <= hue;
				value_buf <= value;
				satbuf <= saturation;
			end
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

/*
spi_module sm0 (
	.clk (clk),
	.cs (cs),
	.mclk (sync_spi_clk),
	.miso (spi_miso),
	.mosi (sync_spi_mosi),
	.paraout(led)
);
*/

wire ioclk;

pll	pll_inst (
	.inclk0 ( inclk ),
	.c0 ( clk ),
	.c1 ( ioclk ),
	.c2 ( xclk ),
	.locked ( locked_sig )
);

i2c_test it0 (
	res,
	ioclk,
	wreq,
	dreq
);

i2c_control ic0 (
	res,
	clk,
	ioclk,
	0,
	0,
	8'h30,
	i2c_clk,
	i2c_sda
);


//assign clk = inclk;

endmodule

module i2c_test (
	input res,
	input ioclk,
	output reg wreq,
	output reg dreq);

reg [29:0] counter;

always @(ioclk) begin
	if (res) begin
		wreq <= 0;
		dreq <= 0;
		counter <= 0;
	end
	counter <= counter + 1'b1;

	if (counter == 30'h100_0000) begin
		dreq <= 1;
	end

end

endmodule

