module DATA_SYNC #(parameter BUS_WIDTH = 8,
	               parameter NUM_STAGES = 2)
(
	input clk,   
	input rst,
	input [BUS_WIDTH-1:0] unsync_bus,
	input bus_enable,
	output reg [BUS_WIDTH-1:0] sync_bus,
	output reg enable_pulse  
);

reg [NUM_STAGES-1:0] sync_reg;
reg enable_ff;
wire enable_pulse_reg;
wire [BUS_WIDTH-1:0] sync_bus_reg;

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