
module STALL_CONT(
    //Inputs
    input logic [31:0] ip_instruction,
    
    //Control inputs
    input logic ip_R_format,
    input logic ip_I_format,
    input logic ip_Lw      ,
    input logic ip_Sw      ,
    input logic ip_Beq     ,
    
    //RegWrite flags from the different stages
    input logic ip_RegWrite_EX ,
    input logic ip_RegWrite_MEM,
    input logic ip_RegWrite_WB ,
    
    //The destination register from the different stages
    input logic [4:0] ip_dest_EX  ,
    input logic [4:0] ip_dest_MEM ,
    input logic [4:0] ip_dest_WB  ,
    
	input logic ip_load		  ,
	
	
    //Outputs
    output logic op_stall
    );

    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Pull out information from the instruction
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //local signals
    logic [5:0] sig_opcode;
    logic [4:0] sig_RS;
    logic [4:0] sig_RT; 
    assign sig_opcode = ip_instruction[31:26];
    assign sig_RS = ip_instruction[25:21];
    assign sig_RT = ip_instruction[20:16];
    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Determine if RS or RT are used
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
    //R type uses RS and RT as input.
    //I type uses RS as an input.
    //BEQ uses RS and RT as input.
    //LW uses RS as input
    //SW uses RS and RT as input
    
    logic use_RS;
    logic use_RT;
    assign use_RS = ip_R_format | ip_I_format | ip_Lw | ip_Sw | ip_Beq;
    assign use_RT = ip_R_format | ip_Sw | ip_Beq;
    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Check if there is a hazard on RS
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //(rs(IRID)==destEX)  && use_rs(IRID) && RegWriteEX 	or
    //(rs(IRID)==destMEM) && use_rs(IRID) && RegWriteMEM 	or
    //(rs(IRID)==destWB)  && use_rs(IRID) && RegWriteWB
    logic RS_EX_hazard  ;
    logic RS_MEM_hazard ;
    logic RS_WB_hazard  ;
    assign RS_EX_hazard  = (ip_dest_EX == sig_RS) & ip_RegWrite_EX & use_RS ;
    assign RS_MEM_hazard = (ip_dest_MEM == sig_RS) & ip_RegWrite_MEM & use_RS ;
    assign RS_WB_hazard  = (ip_dest_WB == sig_RS) & ip_RegWrite_WB & use_RS ;
    
    //Check to see if any of the stages have RS hazards
    logic RS_hazard;
    assign RS_hazard = RS_EX_hazard | RS_MEM_hazard | RS_WB_hazard;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Check if there is a hazard on RT
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //(rt(IRID)==destEX)  && use_rt(IRID) && RegWriteEX 	or
    //(rt(IRID)==destMEM) && use_rt(IRID) && RegWriteMEM 	or
    //(rt(IRID)==destWB)  && use_rt(IRID) && RegWriteWB
    logic RT_EX_hazard  ;
    logic RT_MEM_hazard ;
    logic RT_WB_hazard  ;
    assign RT_EX_hazard  = (ip_dest_EX == sig_RT) & ip_RegWrite_EX & use_RT;
    assign RT_MEM_hazard = (ip_dest_MEM == sig_RT) & ip_RegWrite_MEM & use_RT;
    assign RT_WB_hazard  = (ip_dest_WB == sig_RT) & ip_RegWrite_WB & use_RT;
    
    //Check to see if any of the stages have RS hazards
    logic RT_hazard;
    assign RT_hazard = RT_EX_hazard | RT_MEM_hazard | RT_WB_hazard;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Check Combine RS and RT hazards
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    assign op_stall = ip_load & (RS_hazard | RT_hazard);

endmodule
