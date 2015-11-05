module soc_toplevel(/*autoport*/
//inout
            ram_data,
//output
            ram_address,
            ram_wr_n,
            ram_rd_n,
            ram_dataenable,
//input
            rst_in_n,
            clk_in);

input wire rst_in_n;
input wire clk_in;

wire clk2x,clk,locked,rst_n;

sys_pll pll1(
    1'b0,
    clk_in,
    clk,
    clk2x,
    locked);
clk_ctrl clk_ctrl1(/*autoinst*/
         .rst_out_n(rst_n),
         .clk(clk),
         .rst_in_n(locked));

output wire[29:0] ram_address;
inout wire[31:0] ram_data;
output wire ram_wr_n;
output wire ram_rd_n;
output wire[3:0] ram_dataenable;

wire [31:0]ram_address_orig;
assign ram_address = ram_address_orig[31:2];

wire dbus_write;
wire [31:0]dbus_rddata;
wire ibus_read;
wire [3:0]ibus_byteenable;
wire [3:0]dbus_byteenable;
wire [31:0]dbus_wrdata;
wire [31:0]ibus_wrdata;
wire ibus_write;
wire dbus_read;
wire [31:0]ibus_rddata;
wire [31:0]dbus_address;
wire [31:0]ibus_address;

wire [31:0]rom_data;
prog_rom rom(/*autoinst*/
           .data(rom_data),
           .address(ibus_address));

naive_mips cpu(/*autoinst*/
         .ibus_address(ibus_address[31:0]),
         .ibus_byteenable(ibus_byteenable[3:0]),
         .ibus_read(ibus_read),
         .ibus_write(ibus_write),
         .ibus_wrdata(ibus_wrdata[31:0]),
         .dbus_address(dbus_address[31:0]),
         .dbus_byteenable(dbus_byteenable[3:0]),
         .dbus_read(dbus_read),
         .dbus_write(dbus_write),
         .dbus_wrdata(dbus_wrdata[31:0]),
         .rst_n(rst_n),
         .clk(clk),
         .ibus_rddata(rom_data/*ibus_rddata[31:0]*/),
         .dbus_rddata(dbus_rddata[31:0]));

two_port mainram(/*autoinst*/
           .ram_data(ram_data[31:0]),
           .rddata1(ibus_rddata),
           .rddata2(dbus_rddata),
           .ram_address(ram_address_orig),
           .ram_wr_n(ram_wr_n),
           .ram_rd_n(ram_rd_n),
           .dataenable(ram_dataenable),
           .rst_n(rst_n),
           .clk2x(clk2x),
           .address1(ibus_address),
           .wrdata1(ibus_wrdata),
           .rd1(ibus_read),
           .wr1(ibus_write),
           .dataenable1(ibus_byteenable),
           .address2(dbus_address),
           .wrdata2(dbus_wrdata),
           .rd2(dbus_read),
           .wr2(dbus_write),
           .dataenable2(dbus_byteenable));

endmodule