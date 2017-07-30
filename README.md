# TI-DCC
Direct z80 ASM DCC implementation for the TI-84 Plus C Silver Edition and similar calculators.

Interrupt Documentation
-----------------------
1. Swap registers
2. Output the accumulator to the link port
3. Figure out what bit will be sent on the next iteration
4. Swap the registers back

Some notes from discussion:
* Use memory and registers, don't try to register-juggle everything
* Instead of trying to special-case the preamble and postamble, just make those bits part of
  bytes and don't worry about byte alignment, then count bits instead of bytes for the loop,
  and because max message size is ~6 bytes + preamble/postamble, we'll be able to fit the
  bit count in an 8-bit register
* Use bit-counting to figure out when we need to bump a pointer to the bytes of our packet
  over to the next byte, load it, and start rotating it.
* Will also need to handle rotating between multiple messages