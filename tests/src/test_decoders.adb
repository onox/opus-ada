--  Copyright (c) 2014 onox <denkpadje@gmail.com>
--
--  Permission to use, copy, modify, and/or distribute this software for any
--  purpose with or without fee is hereby granted, provided that the above
--  copyright notice and this permission notice appear in all copies.
--
--  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
--  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
--  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
--  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
--  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
--  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
--  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

with Ahven; use Ahven;

with Opus.Decoders;

use Opus;
use Opus.Decoders;

package body Test_Decoders is

   Unexpected_Sampling_Rate_Message    : constant String := "Unexpected sampling rate";
   Unexpected_Configuration_Message    : constant String := "Unexpected configuration";
   Expected_No_Packets_Decoded_Message : constant String := "Expected No_Packets_Decoded exception";

   overriding
   procedure Initialize (T : in out Test) is
   begin
      T.Set_Name ("Decoders");

      T.Add_Test_Routine (Test_Create_Decoder'Access,  "Create decoder");
      T.Add_Test_Routine (Test_Destroy_Decoder'Access, "Destroy decoder");
      T.Add_Test_Routine (Test_Reset_State'Access, "Reset state of decoder");

      T.Add_Test_Routine (Test_Default_Configuration'Access, "Test the default configuration of the decoder");
      T.Add_Test_Routine (Test_Change_Configuration'Access,  "Test changing the configuration of the decoder");
   end Initialize;

   procedure Test_Create_Decoder is
      Decoder_Mono_8_kHz : Decoder_Data;
   begin
      Decoder_Mono_8_kHz := Create (Rate_8_kHz, Mono);
      Assert (Get_Sample_Rate (Decoder_Mono_8_kHz) = Rate_8_kHz, Unexpected_Sampling_Rate_Message);
   end Test_Create_Decoder;

   procedure Test_Destroy_Decoder is
      Decoder : constant Decoder_Data := Create (Rate_8_kHz, Mono);
   begin
      Destroy (Decoder);
   end Test_Destroy_Decoder;

   procedure Test_Reset_State is
      Decoder : constant Decoder_Data := Create (Rate_8_kHz, Stereo);
   begin
      Reset_State (Decoder);
   end Test_Reset_State;

   procedure Test_Default_Configuration is
      Decoder : constant Decoder_Data := Create (Rate_8_kHz, Mono);
   begin
      Assert (Get_Sample_Rate (Decoder) = Rate_8_kHz, Unexpected_Configuration_Message);
      Assert    (Get_Channels (Decoder) = Mono,       Unexpected_Configuration_Message);
      Assert       (Get_Pitch (Decoder) = 0,          Unexpected_Configuration_Message);
      Assert        (Get_Gain (Decoder) = 0,          Unexpected_Configuration_Message);
      Assert (Get_Last_Packet_Duration (Decoder) = 0, Unexpected_Configuration_Message);

      declare
         Result : Bandwidth
            with Unreferenced;
      begin
         Result := Get_Bandwidth (Decoder);
         Fail (Expected_No_Packets_Decoded_Message);
      exception
         when No_Packets_Decoded =>
            null;
      end;
   end Test_Default_Configuration;

   procedure Test_Change_Configuration is
      Decoder : constant Decoder_Data := Create (Rate_8_kHz, Mono);
   begin
      null;
      Set_Gain (Decoder, 1);
      Assert (Get_Gain (Decoder) = 1, Unexpected_Configuration_Message);
      Set_Gain (Decoder, 0);
      Assert (Get_Gain (Decoder) = 0, Unexpected_Configuration_Message);
   end Test_Change_Configuration;

end Test_Decoders;
