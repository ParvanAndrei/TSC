/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output result         r,
 output instruction_t  instruction_word

);
  //timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (load_en) begin
      case (opcode)
        PASSA : begin
                iw_reg[write_pointer] = '{opcode, operand_a, operand_b, operand_a};
                r <= operand_a;
        end
        PASSB : begin
                iw_reg[write_pointer] = '{opcode, operand_a, operand_b, operand_b};
                r <= operand_b;
        end
        ADD : begin
              iw_reg[write_pointer] = '{opcode, operand_a,  operand_b, $signed(operand_a + operand_b)};
              r <= $signed(operand_a + operand_b);
        end
        SUB : begin 
              iw_reg[write_pointer] = '{opcode, operand_a, operand_b, $signed(operand_a - operand_b)};
              r <= $signed(operand_a - operand_b);
        end
        MULT : begin
               iw_reg[write_pointer] = '{opcode, operand_a, operand_b, $signed(operand_a * operand_b)};
               r <= $signed(operand_a * operand_b);
        end
        DIV : begin
              iw_reg[write_pointer] = '{opcode, operand_a, operand_b, $signed(operand_a / operand_b)};
              r <= $signed(operand_a / operand_b);
        end
        MOD : begin 
              iw_reg[write_pointer] = '{opcode, operand_a, operand_b, $signed(operand_a % operand_b)};
              r <= $signed(operand_a % operand_b);
        end
      default: begin
               iw_reg[write_pointer] = '{opcode,operand_a,operand_b, 'b0};
               r <= 'b0;
      end
      endcase
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register

//tema: trebuie sa adaugati in pkg de instruction word un semnal care sa se numeasca result, tipul definit de noi, si in dut in functie de ce tip
//opcod trebuie sa facem operatia corespunzatoare poti face un case 