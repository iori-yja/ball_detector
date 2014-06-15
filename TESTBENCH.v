`timescale 10ns/10ns
module test;

wire button;
reg clk;
/* camera signal generator */

reg href;
reg vsync;
reg pclk;
reg [7:0] data;


parameter Tline = 786 * 2;

reg spi_clk,
		spi_mosi,
		cs;

initial begin
	forever begin
		spi_clk = 0;
		spi_mosi = 0;
		cs = 1;
		//start
		#50 spi_mosi = 1;
		#10 cs = 0;
		#40 spi_clk = 1;
		#50 spi_clk = 0;

		//2nd bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//3rd bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//4th bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//5th bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//6th bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//7th bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//8th bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;
		#20 cs = 1;
		//=========//
		spi_clk = 0;
		spi_mosi = 0;
		cs = 1;
		//start
		#50 spi_mosi = 0;
		#10 cs = 0;
		#40 spi_clk = 1;
		#50 spi_clk = 0;

		//2nd bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//3rd bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//4th bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//5th bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//6th bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//7th bit
		spi_mosi = 0;
		#50 spi_clk = 1;
		#50 spi_clk = 0;

		//8th bit
		spi_mosi = 1;
		#50 spi_clk = 1;
		#50 spi_clk = 0;
		#20 cs = 1;
	end
end

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
		repeat (1 * Tline) @(negedge pclk);
		vsync <= 0;
		repeat (3 * Tline) @(negedge pclk);

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

wire capture;
wire [7:0] led;
wire busy;
wire locked;

balldetector bd0 (
	.inclk(clk),
	.ahref(href),
	.avsync(vsync),
	.apclk(pclk),
	.xclk(xclk),
	.adata(data),
	.spi_clk(spi_clk),
	.spi_miso(spi_miso),
	.spi_mosi(spi_mosi),
	.cs(cs),
	.led(led),
	.i2c_clk(i2c_clk),
	.i2c_sda(i2c_sda),
	.busy(busy),
	.pwm0(pwm)
);

endmodule
