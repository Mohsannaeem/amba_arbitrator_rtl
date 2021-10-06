/*****************************************
* Author  Mohsan Naeem
* Date    2/oct/2021
*******************************
*Description
* **************************************/

module apb_noc #(
				parameter A_WIDTH = 32				,
				parameter WD_WIDTH= 32				,
				parameter RD_WIDTH= 32				,
				parameter N_MASTER=4 				,
				parameter  N_SLAVE=4
				)
				(
				/**** system level interface ****/
				input      sys_clk    				,
				input      sys_rstn 				,
				
				/**** APB_SLAVE_Interface ****/
				input    [A_WIDTH-1:0]  	paddr   ,
				input      					pwrite  ,
				input    [WD_WIDTH-1:0]  	pwdata  ,
				input      					penable ,
				input      					psel    ,
				output   [RD_WIDTH-1:0]  	prdata  ,
				output 	  					pready  ,
				output     					pslverr 
	
	);

/************Local parameters******************/
   

 localparam IDLE =0,SETUP=1, ACCESS =2;
 reg [RD_WIDTH-1 : 0] paddr_r  ;
 reg [WD_WIDTH-1 : 0] pwdata_r ;
 reg [RD_WIDTH-1 : 0] prdata_r ;
 reg                  pwrite_r ;



/*******************Singal declaration ***************/

wire [1:0] state;

/******************* APB NOC Slave  State Machine ************/
// TODO: 1) wait  logic is not handled  
//       2) pprot and pslverr is not handled well


always @(posedge sys_pclk or negedge sys_rstn) begin : apb_slave_state_machine
	if(~sys_rstn) begin
		 state<= IDLE;
	end else begin
		case(state)
			IDLE:
			   if(psel && ~penable)begin
			   	state     <= SETUP  ; 
			   end

			SETUP:
			   state <= ACCESS;
			   paddr_r   <= paddr  ;
			   pwrite_r  <= pwrite ;

			ACCESS:
			   if(psel && penable)begin
			   	 if(pwrite_r) begin 
			   	 	pwdata_r <= pwrite;
			   	 	pready   <= 1;
			   	 end else
			   	    prdata  <= prdata_r ;
			   	    pready 	<= 1        ;
			   	  end
			   	  state<=SETUP;
			   end
			  else begin 
			  	 state<=IDLE;
			  	 // pslverr <= 1; 
			  end



	end
end


/****************Dut Instansiate *********************/

/***************Arbiterator Design ***************************/

/***************Decoder Design ******************************/






endmodule : apb_noc