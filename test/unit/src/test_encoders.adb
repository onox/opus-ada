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

with Opus.Encoders;

use Opus;
use Opus.Encoders;

package body Test_Encoders is

   Unexpected_Sampling_Rate_Message : constant String := "Unexpected sampling rate";
   Unexpected_Application_Message   : constant String := "Unexpected application";
   Unexpected_Configuration_Message : constant String := "Unexpected configuration";

   overriding
   procedure Initialize (T : in out Test) is
   begin
      T.Set_Name ("Encoders");

      T.Add_Test_Routine (Test_Create_VoIP_Encoder'Access,      "Create encoder for VoIP applications");
      T.Add_Test_Routine (Test_Create_Audio_Encoder'Access,     "Create encoder for audio applications");
      T.Add_Test_Routine (Test_Create_Low_Delay_Encoder'Access, "Create encoder for low delay applications");

      T.Add_Test_Routine (Test_Destroy_Encoder'Access, "Destroy encoder");
      T.Add_Test_Routine (Test_Reset_State'Access, "Reset state of encoder");

      T.Add_Test_Routine (Test_Default_Configuration'Access,    "Test the default configuration of the encoder");
      T.Add_Test_Routine (Test_Change_Configuration'Access,     "Test changing the configuration of the encoder");
   end Initialize;

   generic
      Application : Application_Type;
   procedure Test_Create_Encoder;

   procedure Test_Create_Encoder is
      Encoder_Mono_8_kHz, Encoder_Mono_16_kHz, Encoder_Stereo_48_kHz : Encoder_Data;
   begin
      Encoder_Mono_8_kHz := Create (Rate_8_kHz, Mono, Application);
      Assert (Get_Sample_Rate (Encoder_Mono_8_kHz) = Rate_8_kHz, Unexpected_Sampling_Rate_Message);
      Assert (Get_Application (Encoder_Mono_8_kHz) = Application, Unexpected_Application_Message);

      Encoder_Mono_16_kHz := Create (Rate_16_kHz, Mono, Application);
      Assert (Get_Sample_Rate (Encoder_Mono_16_kHz) = Rate_16_kHz, Unexpected_Sampling_Rate_Message);
      Assert (Get_Application (Encoder_Mono_16_kHz) = Application, Unexpected_Application_Message);

      Encoder_Stereo_48_kHz := Create (Rate_48_kHz, Stereo, Application);
      Assert (Get_Sample_Rate (Encoder_Stereo_48_kHz) = Rate_48_kHz, Unexpected_Sampling_Rate_Message);
      Assert (Get_Application (Encoder_Stereo_48_kHz) = Application, Unexpected_Application_Message);
   end Test_Create_Encoder;

   procedure Internal_Create_VoIP_Encoder      is new Test_Create_Encoder (VoIP);
   procedure Internal_Create_Audio_Encoder     is new Test_Create_Encoder (Audio);
   procedure Internal_Create_Low_Delay_Encoder is new Test_Create_Encoder (Restricted_Low_Delay);

   procedure Test_Create_VoIP_Encoder      renames Internal_Create_VoIP_Encoder;
   procedure Test_Create_Audio_Encoder     renames Internal_Create_Audio_Encoder;
   procedure Test_Create_Low_Delay_Encoder renames Internal_Create_Low_Delay_Encoder;

   procedure Test_Destroy_Encoder is
      Encoder : constant Encoder_Data := Create (Rate_8_kHz, Mono, VoIP);
   begin
      Destroy (Encoder);
   end Test_Destroy_Encoder;

   procedure Test_Reset_State is
      Encoder : constant Encoder_Data := Create (Rate_8_kHz, Stereo, Audio);
   begin
      Reset_State (Encoder);
   end Test_Reset_State;

   procedure Test_Default_Configuration is
      Encoder : constant Encoder_Data := Create (Rate_8_kHz, Mono, VoIP);
   begin
      Assert    (Get_Sample_Rate (Encoder) = Rate_8_kHz, Unexpected_Configuration_Message);
      Assert    (Get_Application (Encoder) = VoIP,       Unexpected_Configuration_Message);
      Assert       (Get_Channels (Encoder) = Mono,       Unexpected_Configuration_Message);
      Assert      (Get_Bandwidth (Encoder) = Full_Band,  Unexpected_Configuration_Message);
      Assert  (Get_Max_Bandwidth (Encoder) = Full_Band,  Unexpected_Configuration_Message);
      Assert     (Get_Complexity (Encoder) = 9,          Unexpected_Configuration_Message);
      Assert        (not Get_DTX (Encoder),              Unexpected_Configuration_Message);
      Assert (Get_Force_Channels (Encoder) = Auto,       Unexpected_Configuration_Message);
      Assert (not Get_Inband_FEC (Encoder),              Unexpected_Configuration_Message);
      Assert      (Get_LSB_Depth (Encoder) = 24,         Unexpected_Configuration_Message);
      Assert    (Get_Packet_Loss (Encoder) = 0,          Unexpected_Configuration_Message);
      Assert         (Get_Signal (Encoder) = Auto,       Unexpected_Configuration_Message);
      Assert            (Get_VBR (Encoder),              Unexpected_Configuration_Message);
      Assert (Get_VBR_Constraint (Encoder),              Unexpected_Configuration_Message);
      Assert (not Get_Prediction_Disabled (Encoder),            Unexpected_Configuration_Message);
      Assert   (Get_Expert_Frame_Duration (Encoder) = Argument, Unexpected_Configuration_Message);
   end Test_Default_Configuration;

   procedure Test_Change_Configuration is
      Encoder : constant Encoder_Data := Create (Rate_8_kHz, Mono, VoIP);
   begin
      Set_Application (Encoder, Audio);
      Assert (Get_Application (Encoder) = Audio, Unexpected_Configuration_Message);
      Set_Application (Encoder, Restricted_Low_Delay);
      Assert (Get_Application (Encoder) = Restricted_Low_Delay, Unexpected_Configuration_Message);

      Set_Max_Bandwidth (Encoder, Narrow_Band);
      Assert (Get_Max_Bandwidth (Encoder) = Narrow_Band, Unexpected_Configuration_Message);
      Set_Max_Bandwidth (Encoder, Medium_Band);
      Assert (Get_Max_Bandwidth (Encoder) = Medium_Band, Unexpected_Configuration_Message);

      Set_Complexity (Encoder, 5);
      Assert (Get_Complexity (Encoder) = 5, Unexpected_Configuration_Message);
      Set_Complexity (Encoder, 10);
      Assert (Get_Complexity (Encoder) = 10, Unexpected_Configuration_Message);

      Assert (Get_Bitrate (Encoder) = 32_000, Unexpected_Configuration_Message);
      Set_Bitrate (Encoder, 50_000);
      Assert (Get_Bitrate (Encoder) = 50_000, Unexpected_Configuration_Message);
      Set_Bitrate (Encoder, Auto);
      Assert (Get_Bitrate (Encoder) = 32_000, Unexpected_Configuration_Message);

      Set_DTX (Encoder, True);
      Assert (Get_DTX (Encoder), Unexpected_Configuration_Message);
      Set_DTX (Encoder, False);
      Assert (not Get_DTX (Encoder), Unexpected_Configuration_Message);

      Set_Inband_FEC (Encoder, True);
      Assert (Get_Inband_FEC (Encoder), Unexpected_Configuration_Message);
      Set_Inband_FEC (Encoder, False);
      Assert (not Get_Inband_FEC (Encoder), Unexpected_Configuration_Message);

      Set_LSB_Depth (Encoder, 8);
      Assert (Get_LSB_Depth (Encoder) = 8, Unexpected_Configuration_Message);
      Set_LSB_Depth (Encoder, 20);
      Assert (Get_LSB_Depth (Encoder) = 20, Unexpected_Configuration_Message);

      Set_VBR_Constraint (Encoder, False);
      Assert (not Get_VBR_Constraint (Encoder), Unexpected_Configuration_Message);
      Set_VBR_Constraint (Encoder, True);
      Assert (Get_VBR_Constraint (Encoder), Unexpected_Configuration_Message);

      Set_VBR (Encoder, False);
      Assert (not Get_VBR (Encoder), Unexpected_Configuration_Message);
      Set_VBR (Encoder, True);
      Assert (Get_VBR (Encoder), Unexpected_Configuration_Message);

      Set_Prediction_Disabled (Encoder, True);
      Assert (Get_Prediction_Disabled (Encoder), Unexpected_Configuration_Message);
      Set_Prediction_Disabled (Encoder, False);
      Assert (not Get_Prediction_Disabled (Encoder), Unexpected_Configuration_Message);

      Set_Expert_Frame_Duration (Encoder, Frame_10_ms);
      Assert (Get_Expert_Frame_Duration (Encoder) = Frame_10_ms, Unexpected_Configuration_Message);
      Set_Expert_Frame_Duration (Encoder, Argument);
      Assert (Get_Expert_Frame_Duration (Encoder) = Argument, Unexpected_Configuration_Message);
   end Test_Change_Configuration;

end Test_Encoders;
