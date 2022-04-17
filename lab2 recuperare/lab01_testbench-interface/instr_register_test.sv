/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
 // inafara de inital begin totul intra intr-o clasa, functii task-uri, interfata si variabile interne cum ar fi seed u
class first_class;
  virtual tb_ifc.tb test_laborator_4; // e o variabila de tip interfata
  parameter gen_no_operation = 100;



  covergroup my_coverGroup();
    coverpoint test_laborator_4.cb.operand_a {
      bins op_a_values_neg = {[-15:-1]};
      bins op_a_values_zero = {0};
      bins op_a_values_pos = {[1:15]};
    }
    coverpoint test_laborator_4.cb.operand_b {
      bins op_b_values = {[0:15]};
    }
    coverpoint test_laborator_4.cb.opcode {
      bins op_code_values = {[0:8]};
    }
    coverpoint test_laborator_4.cb.result{
      bins result_values_neg = {[-225:-1]};
      bins result_values_zero = {0};
      bins result_values_pos = {[1:225]};
    }
  endgroup

  // my_coverGroup cov_test;
  //virtual tb_ifc.tb test_laborator_4 asta e o variabila declarata in clasa
  //int seed = 555;  // reprezinta valoarea initiala cu care se incepe randomizare

  function  new(virtual tb_ifc.tb intermediar); // preia ca argument un obiect de tip interfata
    test_laborator_4 = intermediar; //atribui primei variabile argumentul
  //  cov_test = new();
  endfunction

  task run();
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    $display("first header");

    $display("\nReseting the instruction register...");
    test_laborator_4.cb.write_pointer <= 5'h00;         // initialize write pointer
    test_laborator_4.cb.read_pointer  <= 5'h1F;         // initialize read pointer
    test_laborator_4.cb.load_en       <= 1'b0;          // initialize load control line
    test_laborator_4.cb.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge test_laborator_4.cb) ;     // hold in reset for 2 clock cycles
    test_laborator_4.cb.reset_n       <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge test_laborator_4.cb) test_laborator_4.cb.load_en <= 1'b1;  // enable writing to register

    repeat (gen_no_operation) begin
      //TEMA cover point pentru rezultat
  
      @(posedge test_laborator_4.cb) randomize_transaction; // se apeleaza functia, task-ul poate contine valori temporale @posedge sau #5ns, timpul de simulare la functii e 0
      @(negedge test_laborator_4.cb) print_transaction;
      my_coverGroup.sample();
   //   cov_test.sample();
    end
    @(posedge test_laborator_4.cb) test_laborator_4.cb.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    // repeat(10) begin
    //   automatic int i = $random(10);
    //   $display(i);
    //   @(posedge test_laborator_4.cb) test_laborator_4.cb.read_pointer <= i;
    //   @(negedge test_laborator_4.cb) print_results;    
    // end
    for (int i=0; i<=gen_no_operation; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge test_laborator_4.cb) test_laborator_4.cb.read_pointer <= i;
      @(negedge test_laborator_4.cb) print_results;
      my_coverGroup.sample();
      // cov_test.sample();

    end

    @(posedge test_laborator_4.cb) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
   //  end
  endtask

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0; //declaram temp
    // test_laborator_4.cb.operand_a     <= $random(seed)%16;                 // pe 32 de biti between -15 and 15 lu operand a i se da val random dintre seed%16
    // test_laborator_4.cb.operand_b     <= $unsigned($random)%16;            // between 0 and 15 pe 32 de biti
    // test_laborator_4.cb.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type trece din index in val in enum
    test_laborator_4.cb.operand_a     <= $urandom%16;                 // pe 32 de biti between -15 and 15 lu operand a i se da val random dintre seed%16
    test_laborator_4.cb.operand_b     <= $unsigned($urandom)%16;            // between 0 and 15 pe 32 de biti
    test_laborator_4.cb.opcode        <= opcode_t'($unsigned($urandom)%8);  // between 0 and 7, cast to opcode_t type trece din index in val in enum
    test_laborator_4.cb.write_pointer <= temp++;                           // primeste temp dupa ce este luat temp apoi incrementat
  endfunction: randomize_transaction
//urandom stabil pe clasa
//random stabil pe thread
//regresie suite de teste

  function void print_transaction; //printeaza din randomize_transaction
    $display("Writing to register location %0d: ", test_laborator_4.cb.write_pointer);
    $display("  opcode = %0d (%s)", test_laborator_4.cb.opcode, test_laborator_4.cb.opcode.name);
    $display("  operand_a = %0d",   test_laborator_4.cb.operand_a);
    $display("  operand_b = %0d\n", test_laborator_4.cb.operand_b);
    $display("Time = ns",$time());
  endfunction: print_transaction

  function void print_results;  //instruction_word este generat de DUT
    $display("Read from register location %0d: ", test_laborator_4.cb.read_pointer);
    $display("  opcode = %0d (%s)", test_laborator_4.cb.instruction_word.opc, test_laborator_4.cb.instruction_word.opc.name);
    $display("  operand_a = %0d",   test_laborator_4.cb.instruction_word.op_a);
    $display("  operand_b = %0d", test_laborator_4.cb.instruction_word.op_b);
    $display(" result = %0d\n", test_laborator_4.cb.instruction_word.r);
    $display("Time = ns", $time());
  endfunction: print_results

endclass



module instr_register_test (tb_ifc.tb test_laborator_4); //e o instatiere a interfetei pentru a prelua de acolo 
  // import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  
  //( input  logic          clk,
  //  output logic          load_en,
  //  output logic          reset_n,
  //  output operand_t      operand_a,
  //  output operand_t      operand_b,
  //  output opcode_t       opcode,
  //  output address_t      write_pointer,
  //  output address_t      read_pointer,
  //  input  instruction_t  instruction_word
  //tb_ifc test_laborator_4
  //);

 // timeunit 1ns/1ns;
  initial begin 
    // run();
    //declari clasa si ii atribui new si o conectezi
    first_class first_test;
    first_test = new(test_laborator_4); //ii dai parametru pentru functia new  instantierea de la module de sus
    // first_test.test_laborator_4 = test_laborator_4;
    first_test.run();
  end


 // initial begin    // timpul de simulare 0 e un exemplu de task contine d-alea de timp, nu poate returna o valoare

 

endmodule: instr_register_test
