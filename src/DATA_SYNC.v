`default_nettype none
module tt_um_data_sync #(parameter BUS_WIDTH = 8,
	               parameter NUM_STAGES = 2)
(
	input  wire       ena,      // always 1 when the design is powered, so you can ignore it
	input clk,   
	input rst,
	input [BUS_WIDTH-1:0] unsync_bus,
	input bus_enable,
	input  wire [6:0] uio_in,   // IOs: Input path
	output wire [6:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
	output reg [BUS_WIDTH-1:0] sync_bus,
	output reg enable_pulse  
);

reg [NUM_STAGES-1:0] sync_reg;
reg enable_ff;
wire enable_pulse_reg;
wire [BUS_WIDTH-1:0] sync_bus_reg;

wire _unused = &{ena,uio_in, 1'b0};
	
assign uio_out = 0;
assign uio_oe  = 0;	
	
assign enable_pulse_reg = sync_reg[NUM_STAGES-1] && !enable_ff;
assign sync_bus_reg = enable_pulse_reg ? unsync_bus: sync_bus;


always @(posedge clk or negedge rst)
 begin
  if(!rst)      
   begin
    sync_reg <= 'b0 ;
   end
  else
   begin
    sync_reg <= {sync_reg[NUM_STAGES-2:0],bus_enable};
   end  
 end

always @(posedge clk or negedge rst) begin 
	if(~rst) begin
		enable_ff <= 0;
	end 
	else begin
		enable_ff <= sync_reg[NUM_STAGES-1];
	end
end

always @(posedge clk or negedge rst) begin 
	if(~rst) begin
		enable_pulse <= 0;
	end 
	else begin
		enable_pulse <= enable_pulse_reg;
	end
end

always @(posedge clk or negedge rst) begin 
	if(~rst) begin
		sync_bus <= 0;
	end 
	else begin
		sync_bus <= sync_bus_reg;
	end
end

endmodule 
