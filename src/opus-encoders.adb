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

package body Opus.Encoders is

   type Get_Request_Type is
     (Get_Application_Request,
      Get_Bitrate_Request,
      Get_Max_Bandwidth_Request,
      Get_VBR_Request,
      Get_Bandwidth_Request,
      Get_Complexity_Request,
      Get_Inband_FEC_Request,
      Get_Packet_Loss_Request,
      Get_DTX_Request,
      Get_VBR_Constraint_Request,
      Get_Force_Channels_Request,
      Get_Signal_Request,
      Get_Lookahead_Request,
      Get_Sample_Rate_Request,
      Get_Final_Range_Request,
      Get_LSB_Depth_Request,
      Get_Expert_Frame_Duration_Request,
      Get_Prediction_Disabled_Request)
   with
      Convention => C;

   for Get_Request_Type use
     (Get_Application_Request           => 4001,
      Get_Bitrate_Request               => 4003,
      Get_Max_Bandwidth_Request         => 4005,
      Get_VBR_Request                   => 4007,
      Get_Bandwidth_Request             => 4009,
      Get_Complexity_Request            => 4011,
      Get_Inband_FEC_Request            => 4013,
      Get_Packet_Loss_Request           => 4015,
      Get_DTX_Request                   => 4017,
      Get_VBR_Constraint_Request        => 4021,
      Get_Force_Channels_Request        => 4023,
      Get_Signal_Request                => 4025,
      Get_Lookahead_Request             => 4027,
      Get_Sample_Rate_Request           => 4029,
      Get_Final_Range_Request           => 4031,
      Get_LSB_Depth_Request             => 4037,
      Get_Expert_Frame_Duration_Request => 4041,
      Get_Prediction_Disabled_Request   => 4043);

   type Set_Request_Type is
     (Set_Application_Request,
      Set_Bitrate_Request,
      Set_Max_Bandwidth_Request,
      Set_VBR_Request,
      Set_Bandwidth_Request,
      Set_Complexity_Request,
      Set_Inband_FEC_Request,
      Set_Packet_Loss_Request,
      Set_DTX_Request,
      Set_VBR_Constraint_Request,
      Set_Force_Channels_Request,
      Set_Signal_Request,
      Reset_State,
      Set_LSB_Depth_Request,
      Set_Expert_Frame_Duration_Request,
      Set_Prediction_Disabled_Request)
   with
      Convention => C;

   for Set_Request_Type use
     (Set_Application_Request           => 4000,
      Set_Bitrate_Request               => 4002,
      Set_Max_Bandwidth_Request         => 4004,
      Set_VBR_Request                   => 4006,
      Set_Bandwidth_Request             => 4008,
      Set_Complexity_Request            => 4010,
      Set_Inband_FEC_Request            => 4012,
      Set_Packet_Loss_Request           => 4014,
      Set_DTX_Request                   => 4016,
      Set_VBR_Constraint_Request        => 4020,
      Set_Force_Channels_Request        => 4022,
      Set_Signal_Request                => 4024,
      Reset_State                       => 4028,
      Set_LSB_Depth_Request             => 4036,
      Set_Expert_Frame_Duration_Request => 4040,
      Set_Prediction_Disabled_Request   => 4042);

   generic
      Request : Get_Request_Type;
      type Return_Type is (<>);
   function Get_Request (Encoder : in Encoder_Data) return Return_Type;

   function Get_Request (Encoder : in Encoder_Data) return Return_Type is
      Result : Return_Type;

      function Opus_Encoder_Ctl
        (State   : in  Opus_Encoder;
         Request : in  Get_Request_Type;
         Result  : out Return_Type) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_encoder_ctl";

      Error : constant Interfaces.C.int := Opus_Encoder_Ctl (Encoder.Encoder, Request, Result);
   begin
      Check_Error (Error);
      if not Result'Valid then
         raise Invalid_Result;
      end if;
      return Result;
   end Get_Request;

   generic
      Request : Set_Request_Type;
      type Argument_Type is (<>);
   procedure Set_Request (Encoder : in Encoder_Data; Argument : in Argument_Type);

   procedure Set_Request (Encoder : in Encoder_Data; Argument : in Argument_Type) is
      function Opus_Encoder_Ctl
        (State    : in Opus_Encoder;
         Request  : in Set_Request_Type;
         Argument : in Argument_Type) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_encoder_ctl";

      Error : constant Interfaces.C.int := Opus_Encoder_Ctl (Encoder.Encoder, Request, Argument);
   begin
      Check_Error (Error);
   end Set_Request;

   ----------------------------------------------------------------------------

   function Create
     (Frequency   : in Sampling_Rate;
      Channels    : in Channel_Type;
      Application : in Application_Type) return Encoder_Data
   is
      function Opus_Encoder_Create
        (Frequency   : in Sampling_Rate;
         Channels    : in Channel_Type;
         Application : in Application_Type;
         Error       : out Interfaces.C.int) return Opus_Encoder
      with
         Import, Convention => C, External_Name => "opus_encoder_create";

      Error   : Interfaces.C.int;
      Encoder : Encoder_Data;
   begin
      Encoder.Encoder  := Opus_Encoder_Create (Frequency, Channels, Application, Error);
      Encoder.Channels := Channels;

      Check_Error (Error);
      return Encoder;
   end Create;

   procedure Destroy (Encoder : in Encoder_Data) is
      procedure Opus_Encoder_Destroy (Encoder : in Opus_Encoder)
         with Import, Convention => C, External_Name => "opus_encoder_destroy";
   begin
      Opus_Encoder_Destroy (Encoder.Encoder);
   end Destroy;

   function Encode
     (Encoder        : in Encoder_Data;
      Audio_Frame    : in PCM_Buffer;
      Max_Data_Bytes : in Positive) return Byte_Array
   is
      Result : Byte_Array (0 .. Max_Data_Bytes);

      function Opus_Encode
        (State      : in  Opus_Encoder;
         Frame      : in  PCM_Buffer;
         Frame_Size : in  Interfaces.C.int;
         Data       : out Byte_Array;
         Data_Size  : in  Integer) return Interfaces.C.int
      with Import, Convention => C, External_Name => "opus_encode";

      Length_Data : Interfaces.C.int;

      Channels            : constant Integer          := (if Get_Channels (Encoder) = Mono then 1 else 2);
      Samples_Per_Channel : constant Interfaces.C.int := Interfaces.C.int (Audio_Frame'Length / Channels);
   begin
      --  TODO Assert PCM_Buffer'First = 1 and PCM_Buffer'Last >= 20

      --  sampling_rate_hz / 1_000 => samples_per_ms
      --  samples_per_ms * frame_size_in_ms / channels => samples_per_frame

      --  Samples_Per_Millisecond    : constant := Natural (Get_Sampling_Rate (Encoder)) / 1_000;
      --  Frame_Size_In_Milliseconds : constant := Samples_Per_Channel / Samples_Per_Millisecond;
      --  TODO Assert Frame_Size_In_Milliseconds = 2.5 | 5 | 10 | 20 | 40 | 60

      Length_Data := Opus_Encode (Encoder.Encoder, Audio_Frame, Samples_Per_Channel, Result, Result'Length);

      Check_Error (Length_Data);
      return Result (0 .. Integer (Length_Data));
   end Encode;

   procedure Reset_State (Encoder : in Encoder_Data) is
      function Opus_Encoder_Ctl
        (State   : in Opus_Encoder;
         Request : in Interfaces.C.int) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_encoder_ctl";

      Reset_State_Request : constant := 4028;
      Error : constant Interfaces.C.int := Opus_Encoder_Ctl (Encoder.Encoder, Reset_State_Request);
   begin
      Check_Error (Error);
   end Reset_State;

   ----------------------------------------------------------------------------

   procedure Internal_Set_Application is new Set_Request (Set_Application_Request, Application_Type);
   procedure Set_Application
     (Encoder     : in Encoder_Data;
      Application : in Application_Type) renames Internal_Set_Application;

   function Internal_Get_Application is new Get_Request (Get_Application_Request, Application_Type);
   function Get_Application (Encoder : in Encoder_Data) return Application_Type
      renames Internal_Get_Application;

   procedure Internal_Set_Bitrate is new Set_Request (Set_Bitrate_Request, Bitrate);
   procedure Set_Bitrate
     (Encoder : in Encoder_Data;
      Rate    : in Bitrate) renames Internal_Set_Bitrate;

   function Internal_Get_Bitrate is new Get_Request (Get_Bitrate_Request, Bitrate);
   function Get_Bitrate (Encoder : in Encoder_Data) return Bitrate
      renames Internal_Get_Bitrate;

   procedure Internal_Set_Bitrate_Type is new Set_Request (Set_Bitrate_Request, Bitrate_Type);
   procedure Set_Bitrate
     (Encoder : in Encoder_Data;
      Rate : in Bitrate_Type) renames Internal_Set_Bitrate_Type;

   procedure Internal_Set_Bandwidth is new Set_Request (Set_Bandwidth_Request, Bandwidth);
   procedure Set_Bandwidth
     (Encoder : in Encoder_Data;
      Width : in Bandwidth) renames Internal_Set_Bandwidth;

   function Internal_Get_Bandwidth is new Get_Request (Get_Bandwidth_Request, Bandwidth);
   function Get_Bandwidth (Encoder : in Encoder_Data) return Bandwidth
      renames Internal_Get_Bandwidth;

   procedure Internal_Set_Max_Bandwidth is new Set_Request (Set_Max_Bandwidth_Request, Bandpass);
   procedure Set_Max_Bandwidth
     (Encoder : in Encoder_Data;
      Width   : in Bandpass) renames Internal_Set_Max_Bandwidth;

   function Internal_Get_Max_Bandwidth is new Get_Request (Get_Max_Bandwidth_Request, Bandpass);
   function Get_Max_Bandwidth (Encoder : in Encoder_Data) return Bandpass
      renames Internal_Get_Max_Bandwidth;

   function Get_Channels (Encoder : in Encoder_Data) return Channel_Type is
   begin
      return Encoder.Channels;
   end Get_Channels;

   procedure Internal_Set_Complexity is new Set_Request (Set_Complexity_Request, Complexity);
   procedure Set_Complexity
     (Encoder : in Encoder_Data;
      Scale   : in Complexity) renames Internal_Set_Complexity;

   function Internal_Get_Complexity is new Get_Request (Get_Complexity_Request, Complexity);
   function Get_Complexity (Encoder : in Encoder_Data) return Complexity
      renames Internal_Get_Complexity;

   procedure Set_DTX
     (Encoder : in Encoder_Data;
      Enable  : in Boolean)
   is
      procedure Internal_Set_DTX is new Set_Request (Set_DTX_Request, C_Boolean);
   begin
      Internal_Set_DTX (Encoder, C_Boolean (Enable));
   end Set_DTX;

   function Get_DTX (Encoder : in Encoder_Data) return Boolean is
      function Internal_Get_DTX is new Get_Request (Get_DTX_Request, C_Boolean);
   begin
      return Boolean (Internal_Get_DTX (Encoder));
   end Get_DTX;

   procedure Internal_Set_Force_Channels is new Set_Request (Set_Force_Channels_Request, Force_Channels);
   procedure Set_Force_Channels
     (Encoder  : in Encoder_Data;
      Channels : in Force_Channels) renames Internal_Set_Force_Channels;

   function Internal_Get_Force_Channels is new Get_Request (Get_Force_Channels_Request, Force_Channels);
   function Get_Force_Channels (Encoder : in Encoder_Data) return Force_Channels
      renames Internal_Get_Force_Channels;

   procedure Set_Inband_FEC
     (Encoder : in Encoder_Data;
      Enable  : in Boolean)
   is
      procedure Internal_Set_Inband_FEC is new Set_Request (Set_Inband_FEC_Request, C_Boolean);
   begin
      Internal_Set_Inband_FEC (Encoder, C_Boolean (Enable));
   end Set_Inband_FEC;

   function Get_Inband_FEC (Encoder : in Encoder_Data) return Boolean is
      function Internal_Get_Inband_FEC is new Get_Request (Get_Inband_FEC_Request, C_Boolean);
   begin
      return Boolean (Internal_Get_Inband_FEC (Encoder));
   end Get_Inband_FEC;

   procedure Internal_Set_LSB_Depth is new Set_Request (Set_LSB_Depth_Request, Signal_Depth);
   procedure Set_LSB_Depth
     (Encoder : in Encoder_Data;
      Depth   : in Signal_Depth) renames Internal_Set_LSB_Depth;

   function Internal_Get_LSB_Depth is new Get_Request (Get_LSB_Depth_Request, Signal_Depth);
   function Get_LSB_Depth (Encoder : in Encoder_Data) return Signal_Depth
      renames Internal_Get_LSB_Depth;

   procedure Internal_Set_Packet_Loss is new Set_Request (Set_Packet_Loss_Request, Percentage);
   procedure Set_Packet_Loss
     (Encoder       : in Encoder_Data;
      Expected_Loss : in Percentage) renames Internal_Set_Packet_Loss;

   function Internal_Get_Packet_Loss is new Get_Request (Get_Packet_Loss_Request, Percentage);
   function Get_Packet_Loss (Encoder : in Encoder_Data) return Percentage
      renames Internal_Get_Packet_Loss;

   procedure Set_Prediction_Disabled
     (Encoder : in Encoder_Data;
      Disable : in Boolean)
   is
      procedure Internal_Set_Prediction_Disabled is new Set_Request (Set_Prediction_Disabled_Request, C_Boolean);
   begin
      Internal_Set_Prediction_Disabled (Encoder, C_Boolean (Disable));
   end Set_Prediction_Disabled;

   function Get_Prediction_Disabled (Encoder : in Encoder_Data) return Boolean is
      function Internal_Get_Prediction_Disabled is new Get_Request (Get_Prediction_Disabled_Request, C_Boolean);
   begin
      return Boolean (Internal_Get_Prediction_Disabled (Encoder));
   end Get_Prediction_Disabled;

   procedure Internal_Set_Signal is new Set_Request (Set_Signal_Request, Signal);
   procedure Set_Signal
     (Encoder : in Encoder_Data;
      Hint    : in Signal) renames Internal_Set_Signal;

   function Internal_Get_Signal is new Get_Request (Get_Signal_Request, Signal);
   function Get_Signal (Encoder : in Encoder_Data) return Signal
      renames Internal_Get_Signal;

   procedure Set_VBR
     (Encoder : in Encoder_Data;
      Enable  : in Boolean)
   is
      procedure Internal_Set_VBR is new Set_Request (Set_VBR_Request, C_Boolean);
   begin
      Internal_Set_VBR (Encoder, C_Boolean (Enable));
   end Set_VBR;

   function Get_VBR (Encoder : in Encoder_Data) return Boolean is
      function Internal_Get_VBR is new Get_Request (Get_VBR_Request, C_Boolean);
   begin
      return Boolean (Internal_Get_VBR (Encoder));
   end Get_VBR;

   procedure Set_VBR_Constraint
     (Encoder   : in Encoder_Data;
      Constrain : in Boolean)
   is
      procedure Internal_Set_VBR_Constraint is new Set_Request (Set_VBR_Constraint_Request, C_Boolean);
   begin
      Internal_Set_VBR_Constraint (Encoder, C_Boolean (Constrain));
   end Set_VBR_Constraint;

   function Get_VBR_Constraint (Encoder : in Encoder_Data) return Boolean is
      function Internal_Get_VBR_Constraint is new Get_Request (Get_VBR_Constraint_Request, C_Boolean);
   begin
      return Boolean (Internal_Get_VBR_Constraint (Encoder));
   end Get_VBR_Constraint;

   procedure Internal_Set_Expert_Frame_Duration is new Set_Request (Set_Expert_Frame_Duration_Request, Frame_Duration);
   procedure Set_Expert_Frame_Duration
     (Encoder  : in Encoder_Data;
      Duration : in Frame_Duration) renames Internal_Set_Expert_Frame_Duration;

   function Internal_Get_Expert_Frame_Duration is new Get_Request (Get_Expert_Frame_Duration_Request, Frame_Duration);
   function Get_Expert_Frame_Duration (Encoder : in Encoder_Data) return Frame_Duration
      renames Internal_Get_Expert_Frame_Duration;

   function Get_Final_Range (Encoder : in Encoder_Data) return Integer is
      function Internal_Get_Final_Range is new Get_Request (Get_Final_Range_Request, Interfaces.C.int);
   begin
      return Integer (Internal_Get_Final_Range (Encoder));
   end Get_Final_Range;

   function Get_Lookahead (Encoder : in Encoder_Data) return Positive is
      function Internal_Get_Lookahead is new Get_Request (Get_Lookahead_Request, Interfaces.C.int);
   begin
      return Positive (Internal_Get_Lookahead (Encoder));
   end Get_Lookahead;

   function Internal_Get_Sample_Rate is new Get_Request (Get_Sample_Rate_Request, Sampling_Rate);
   function Get_Sample_Rate (Encoder : in Encoder_Data) return Sampling_Rate
      renames Internal_Get_Sample_Rate;

end Opus.Encoders;
