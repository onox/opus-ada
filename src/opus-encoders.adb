--  SPDX-License-Identifier: Apache-2.0
--
--  Copyright (c) 2014 - 2022 onox <denkpadje@gmail.com>
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.

package body Opus.Encoders is

   subtype Opus_Encoder is Opus.API.Opus_Encoder;
   use all type Opus.API.Get_Request_Type_Encoder;
   use all type Opus.API.Set_Request_Type_Encoder;

   generic
      Request : Opus.API.Get_Request_Type_Encoder;
      type Return_Type is (<>);
   function Get_Request (Encoder : Encoder_Data) return Return_Type;

   function Get_Request (Encoder : Encoder_Data) return Return_Type is
      Result : Return_Type;

      function Opus_Encoder_Ctl
        (State   : Opus_Encoder;
         Request : Opus.API.Get_Request_Type_Encoder;
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
      Request : Opus.API.Set_Request_Type_Encoder;
      type Argument_Type is (<>);
   procedure Set_Request (Encoder : Encoder_Data; Argument : Argument_Type);

   procedure Set_Request (Encoder : Encoder_Data; Argument : Argument_Type) is
      function Opus_Encoder_Ctl
        (State    : Opus_Encoder;
         Request  : Opus.API.Set_Request_Type_Encoder;
         Argument : Argument_Type) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_encoder_ctl";

      Error : constant Interfaces.C.int := Opus_Encoder_Ctl (Encoder.Encoder, Request, Argument);
   begin
      Check_Error (Error);
   end Set_Request;

   ----------------------------------------------------------------------------

   function Create
     (Frequency   : Sampling_Rate;
      Channels    : Channel_Type;
      Application : Application_Type) return Encoder_Data
   is
      Error   : Interfaces.C.int;
      Encoder : Encoder_Data;
   begin
      Encoder.Encoder  := Opus.API.Encoder_Create (Frequency, Channels, Application, Error);
      Encoder.Channels := Channels;

      Check_Error (Error);
      return Encoder;
   end Create;

   procedure Destroy (Encoder : Encoder_Data) is
   begin
      Opus.API.Encoder_Destroy (Encoder.Encoder);
   end Destroy;

   function Encode
     (Encoder        : Encoder_Data;
      Audio_Frame    : PCM_Buffer;
      Max_Data_Bytes : Positive) return Byte_Array
   is
      Result : Byte_Array (0 .. Max_Data_Bytes);

      Length_Data : Interfaces.C.int;

      Channels            : constant Integer :=
        (if Get_Channels (Encoder) = Mono then 1 else 2);
      Samples_Per_Channel : constant Interfaces.C.int :=
        Interfaces.C.int (Audio_Frame'Length / Channels);
   begin
      --  TODO Assert PCM_Buffer'First = 1 and PCM_Buffer'Last >= 20

      --  sampling_rate_hz / 1_000 => samples_per_ms
      --  samples_per_ms * frame_size_in_ms / channels => samples_per_frame

      --  Samples_Per_Millisecond    : constant := Natural (Get_Sampling_Rate (Encoder)) / 1_000;
      --  Frame_Size_In_Milliseconds : constant := Samples_Per_Channel / Samples_Per_Millisecond;
      --  TODO Assert Frame_Size_In_Milliseconds = 2.5 | 5 | 10 | 20 | 40 | 60

      Length_Data := Opus.API.Encode
        (Encoder.Encoder, Audio_Frame, Samples_Per_Channel, Result, Result'Length);

      Check_Error (Length_Data);
      return Result (0 .. Integer (Length_Data));
   end Encode;

   procedure Reset_State (Encoder : Encoder_Data) is
      function Opus_Encoder_Ctl
        (State   : Opus_Encoder;
         Request : Interfaces.C.int) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_encoder_ctl";

      Reset_State_Request : constant := 4028;
      Error : constant Interfaces.C.int := Opus_Encoder_Ctl (Encoder.Encoder, Reset_State_Request);
   begin
      Check_Error (Error);
   end Reset_State;

   ----------------------------------------------------------------------------

   package Internal is
      function Get_Application    is new Get_Request (Get_Application_Request, Application_Type);
      function Get_Bandwidth      is new Get_Request (Get_Bandwidth_Request, Bandwidth);
      function Get_Bitrate        is new Get_Request (Get_Bitrate_Request, Bitrate);
      function Get_Complexity     is new Get_Request (Get_Complexity_Request, Complexity);
      function Get_DTX            is new Get_Request (Get_DTX_Request, C_Boolean);
      function Get_Final_Range    is new Get_Request (Get_Final_Range_Request, Interfaces.C.int);
      function Get_Force_Channels is new Get_Request (Get_Force_Channels_Request, Force_Channels);
      function Get_Inband_FEC     is new Get_Request (Get_Inband_FEC_Request, C_Boolean);
      function Get_Lookahead      is new Get_Request (Get_Lookahead_Request, Interfaces.C.int);
      function Get_LSB_Depth      is new Get_Request (Get_LSB_Depth_Request, Signal_Depth);
      function Get_Max_Bandwidth  is new Get_Request (Get_Max_Bandwidth_Request, Bandpass);
      function Get_Packet_Loss    is new Get_Request (Get_Packet_Loss_Request, Percentage);
      function Get_Sample_Rate    is new Get_Request (Get_Sample_Rate_Request, Sampling_Rate);
      function Get_Signal         is new Get_Request (Get_Signal_Request, Signal);
      function Get_VBR            is new Get_Request (Get_VBR_Request, C_Boolean);
      function Get_VBR_Constraint is new Get_Request (Get_VBR_Constraint_Request, C_Boolean);

      function Get_Expert_Frame_Duration is
        new Get_Request (Get_Expert_Frame_Duration_Request, Frame_Duration);
      function Get_Prediction_Disabled is
        new Get_Request (Get_Prediction_Disabled_Request, C_Boolean);

      procedure Set_Application    is new Set_Request (Set_Application_Request, Application_Type);
      procedure Set_Bandwidth      is new Set_Request (Set_Bandwidth_Request, Bandwidth);
      procedure Set_Bitrate        is new Set_Request (Set_Bitrate_Request, Bitrate);
      procedure Set_Bitrate_Type   is new Set_Request (Set_Bitrate_Request, Bitrate_Type);
      procedure Set_Complexity     is new Set_Request (Set_Complexity_Request, Complexity);
      procedure Set_DTX            is new Set_Request (Set_DTX_Request, C_Boolean);
      procedure Set_Force_Channels is new Set_Request (Set_Force_Channels_Request, Force_Channels);
      procedure Set_Inband_FEC     is new Set_Request (Set_Inband_FEC_Request, C_Boolean);
      procedure Set_LSB_Depth      is new Set_Request (Set_LSB_Depth_Request, Signal_Depth);
      procedure Set_Max_Bandwidth  is new Set_Request (Set_Max_Bandwidth_Request, Bandpass);
      procedure Set_Packet_Loss    is new Set_Request (Set_Packet_Loss_Request, Percentage);
      procedure Set_Signal         is new Set_Request (Set_Signal_Request, Signal);
      procedure Set_VBR            is new Set_Request (Set_VBR_Request, C_Boolean);
      procedure Set_VBR_Constraint is new Set_Request (Set_VBR_Constraint_Request, C_Boolean);

      procedure Set_Expert_Frame_Duration is
        new Set_Request (Set_Expert_Frame_Duration_Request, Frame_Duration);
      procedure Set_Prediction_Disabled is
        new Set_Request (Set_Prediction_Disabled_Request, C_Boolean);
   end Internal;

   ----------------------------------------------------------------------------

   procedure Set_Application
     (Encoder     : Encoder_Data;
      Application : Application_Type) renames Internal.Set_Application;

   function Get_Application (Encoder : Encoder_Data) return Application_Type
     renames Internal.Get_Application;

   procedure Set_Bitrate
     (Encoder : Encoder_Data;
      Rate    : Bitrate) renames Internal.Set_Bitrate;

   function Get_Bitrate (Encoder : Encoder_Data) return Bitrate renames Internal.Get_Bitrate;

   procedure Set_Bitrate
     (Encoder : Encoder_Data;
      Rate : Bitrate_Type) renames Internal.Set_Bitrate_Type;

   procedure Set_Bandwidth
     (Encoder : Encoder_Data;
      Width : Bandwidth) renames Internal.Set_Bandwidth;

   function Get_Bandwidth (Encoder : Encoder_Data) return Bandwidth renames Internal.Get_Bandwidth;

   procedure Set_Max_Bandwidth
     (Encoder : Encoder_Data;
      Width   : Bandpass) renames Internal.Set_Max_Bandwidth;

   function Get_Max_Bandwidth (Encoder : Encoder_Data) return Bandpass
     renames Internal.Get_Max_Bandwidth;

   function Get_Channels (Encoder : Encoder_Data) return Channel_Type is
   begin
      return Encoder.Channels;
   end Get_Channels;

   procedure Set_Complexity
     (Encoder : Encoder_Data;
      Scale   : Complexity) renames Internal.Set_Complexity;

   function Get_Complexity (Encoder : Encoder_Data) return Complexity
     renames Internal.Get_Complexity;

   procedure Set_DTX
     (Encoder : Encoder_Data;
      Enable  : Boolean) is
   begin
      Internal.Set_DTX (Encoder, C_Boolean (Enable));
   end Set_DTX;

   function Get_DTX (Encoder : Encoder_Data) return Boolean is
   begin
      return Boolean (Internal.Get_DTX (Encoder));
   end Get_DTX;

   procedure Set_Force_Channels
     (Encoder  : Encoder_Data;
      Channels : Force_Channels) renames Internal.Set_Force_Channels;

   function Get_Force_Channels (Encoder : Encoder_Data) return Force_Channels
      renames Internal.Get_Force_Channels;

   procedure Set_Inband_FEC
     (Encoder : Encoder_Data;
      Enable  : Boolean) is
   begin
      Internal.Set_Inband_FEC (Encoder, C_Boolean (Enable));
   end Set_Inband_FEC;

   function Get_Inband_FEC (Encoder : Encoder_Data) return Boolean is
   begin
      return Boolean (Internal.Get_Inband_FEC (Encoder));
   end Get_Inband_FEC;

   procedure Set_LSB_Depth
     (Encoder : Encoder_Data;
      Depth   : Signal_Depth) renames Internal.Set_LSB_Depth;

   function Get_LSB_Depth (Encoder : Encoder_Data) return Signal_Depth
     renames Internal.Get_LSB_Depth;

   procedure Set_Packet_Loss
     (Encoder       : Encoder_Data;
      Expected_Loss : Percentage) renames Internal.Set_Packet_Loss;

   function Get_Packet_Loss (Encoder : Encoder_Data) return Percentage
     renames Internal.Get_Packet_Loss;

   procedure Set_Prediction_Disabled
     (Encoder : Encoder_Data;
      Disable : Boolean) is
   begin
      Internal.Set_Prediction_Disabled (Encoder, C_Boolean (Disable));
   end Set_Prediction_Disabled;

   function Get_Prediction_Disabled (Encoder : Encoder_Data) return Boolean is
   begin
      return Boolean (Internal.Get_Prediction_Disabled (Encoder));
   end Get_Prediction_Disabled;

   procedure Set_Signal
     (Encoder : Encoder_Data;
      Hint    : Signal) renames Internal.Set_Signal;

   function Get_Signal (Encoder : Encoder_Data) return Signal renames Internal.Get_Signal;

   procedure Set_VBR
     (Encoder : Encoder_Data;
      Enable  : Boolean) is
   begin
      Internal.Set_VBR (Encoder, C_Boolean (Enable));
   end Set_VBR;

   function Get_VBR (Encoder : Encoder_Data) return Boolean is
   begin
      return Boolean (Internal.Get_VBR (Encoder));
   end Get_VBR;

   procedure Set_VBR_Constraint
     (Encoder   : Encoder_Data;
      Constrain : Boolean) is
   begin
      Internal.Set_VBR_Constraint (Encoder, C_Boolean (Constrain));
   end Set_VBR_Constraint;

   function Get_VBR_Constraint (Encoder : Encoder_Data) return Boolean is
   begin
      return Boolean (Internal.Get_VBR_Constraint (Encoder));
   end Get_VBR_Constraint;

   procedure Set_Expert_Frame_Duration
     (Encoder  : Encoder_Data;
      Duration : Frame_Duration) renames Internal.Set_Expert_Frame_Duration;

   function Get_Expert_Frame_Duration (Encoder : Encoder_Data) return Frame_Duration
     renames Internal.Get_Expert_Frame_Duration;

   function Get_Final_Range (Encoder : Encoder_Data) return Integer is
   begin
      return Integer (Interfaces.C.int'(Internal.Get_Final_Range (Encoder)));
   end Get_Final_Range;

   function Get_Lookahead (Encoder : Encoder_Data) return Positive is
   begin
      return Positive (Internal.Get_Lookahead (Encoder));
   end Get_Lookahead;

   function Get_Sample_Rate (Encoder : Encoder_Data) return Sampling_Rate
     renames Internal.Get_Sample_Rate;

end Opus.Encoders;
