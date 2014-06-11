`timescale 10ns/10ns
module test;

wire button;
reg clk;
/* camera signal generator */

reg href;
reg vsync;
reg pclk;
reg [7:0] data;


parameter Tline = 784 * 2;

initial begin
	clk = 0;
	data = 0;
	forever begin
		#1 clk = ~clk;
	end
end

initial begin
	pclk = 1;
	forever begin
		#16 pclk = ~pclk;
	end
end

always @(negedge pclk) begin
		data <= data + 8'b1;
end

always @(posedge href) begin
		data <= 8'h00;
end

always @(negedge href) begin
		data <= 8'hxx;
end

initial begin
	$dumpfile("test.vcd");
	$dumpvars(0, test);
#10

	repeat (10) begin
		vsync = 1;
		href = 0;
		repeat (3 * Tline) @(negedge pclk);
		vsync <= 0;
		repeat (17 * Tline) @(negedge pclk);

		repeat (480) begin
			href <= 1;
			repeat (640 * 2) @(negedge pclk);
			href <= 0;
			repeat (144 * 2) @(negedge pclk);
		end

		repeat (10 * Tline) @(negedge pclk);
	end

	#100 $stop;
end

wire res, capture;
wire spi_clk,
		spi_miso,
		spi_mosi,
		cs;
wire [7:0] led;
wire busy;

wire [4:0] sat;
wire [4:0] value;
wire [6:0] hue;

balldetector bd0 (
	.force_enable(href),
	.inclk(clk),
	.res(res),
	.ahref(href),
	.avsync(vsync),
	.apclk(pck),
	.capture(capture),
	.button(button),
	.xclk(xclk),
	.adata(data),
	.spi_clk(spi_clk),
	.spi_miso(spi_miso),
	.spi_mosi(spi_mosi),
	.cs(cs),
	.led(led),
	.busy(busy),
	.saturation(sat),
	.value(value),
	.hue(hue)
);

endmodule
