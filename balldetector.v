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
	input key1,
	output [9:0] pwm
);

wire write;
wire [15:0] wrdata;
wire done;

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
reg [8:0] hue_buf;
reg [4:0] value_buf;
reg [4:0] satbuf;

wire [7:0] paraspi;
wire [7:0] ledshadow;

wire acapture;
wire newframe;
wire [9:0] horiz_address;
wire clk;
wire locked_sig;
wire res;


//red
assign ledshadow[0] = ((9'd300 < hue_buf) || (hue_buf < 9'd50));
//blue
assign ledshadow[1] = ((9'd160 < hue_buf) && (hue_buf < 9'd250));
//yellow
assign ledshadow[2] = ((9'd50 < hue_buf) && (hue_buf < 9'd80));

//
assign ledshadow[3] = (value_buf > 5'ha && value_buf < 5'h1a);
assign ledshadow[4] = (satbuf > 5'h10);

assign led = key1 ? (key0 ? paraspi : hue_buf[8:1]) : ledshadow;

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
			hue_buf <= hue;
			value_buf <= value;
			satbuf <= saturation;
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

assign busy = acapture;

vline_capture ld0 (
	ahref,
	avsync,
	acapture,
	newframe
);

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
wire ioclk;

function turlet;
	input [1:0] encode;
	begin
		case (encode)
			2'b00: turlet = 128;
			2'b01: turlet = 192; 
			2'b10: turlet = 64;
			2'b11: turlet = 128;
		endcase
	end
endfunction


servo_timer st0 ( 
	.ioclk(ioclk),
	.write_enable(1'b1),
	.duty0(paraspi[0] ? 167 : 33 ),
	.duty1(paraspi[1] ? 17 : 128 ),
	.duty2(paraspi[0] ? 89 : 223 ),

	.duty3(paraspi[2] ? 167 : 33 ),
	.duty4(paraspi[3] ? 17 : 128 ),
	.duty5(paraspi[2] ? 89 : 223 ),

	.duty6(paraspi[4] ? 167 : 33 ),
	.duty7(paraspi[5] ? 17 : 128 ),
	.duty8(paraspi[4] ? 89 : 223 ),

	.duty9(turlet(paraspi[7:6])),
	.res(res),
	.pwm_out(pwm)
);

spi_module sm0 ( .clk (clk),
	.cs (cs),
	.mclk (sync_spi_clk),
	.miso (spi_miso),
	.mosi (sync_spi_mosi),
	.paraout(paraspi),
	.parain(8'hca)
);


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

