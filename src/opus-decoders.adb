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

package body Opus.Decoders is

   type Get_Request_Type is
     (Get_Bandwidth_Request,
      Get_Sample_Rate_Request,
      Get_Final_Range_Request,
      Get_Pitch_Request,
      Get_Last_Packet_Duration_Request,
      Get_Gain_Request)
   with
      Convention => C;

   for Get_Request_Type use
     (Get_Bandwidth_Request            => 4009,
      Get_Sample_Rate_Request          => 4029,
      Get_Final_Range_Request          => 4031,
      Get_Pitch_Request                => 4033,
      Get_Last_Packet_Duration_Request => 4039,
      Get_Gain_Request                 => 4045);

   type Set_Request_Type is
     (Set_Gain_Request)
   with
      Convention => C;

   for Set_Request_Type use
     (Set_Gain_Request                 => 4034);

   generic
      Request : Get_Request_Type;
      type Return_Type is (<>);
   function Get_Request (Decoder : in Decoder_Data) return Return_Type;

   function Get_Request (Decoder : in Decoder_Data) return Return_Type is
      Result : Return_Type;

      function Opus_Decoder_Ctl
        (State   : in  Opus_Decoder;
         Request : in  Get_Request_Type;
         Result  : out Return_Type) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_decoder_ctl";

      Error : constant Interfaces.C.int := Opus_Decoder_Ctl (Decoder.Decoder, Request, Result);
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
   procedure Set_Request (Decoder : in Decoder_Data; Argument : in Argument_Type);

   procedure Set_Request (Decoder : in Decoder_Data; Argument : in Argument_Type) is
      function Opus_Decoder_Ctl
        (State    : in Opus_Decoder;
         Request  : in Set_Request_Type;
         Argument : in Argument_Type) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_decoder_ctl";

      Error : constant Interfaces.C.int := Opus_Decoder_Ctl (Decoder.Decoder, Request, Argument);
   begin
      Check_Error (Error);
   end Set_Request;

   ----------------------------------------------------------------------------

   function Create
     (Frequency : in Sampling_Rate;
      Channels  : in Channel_Type) return Decoder_Data
   is
      function Opus_Decoder_Create
        (Frequency : in  Sampling_Rate;
         Channels  : in  Channel_Type;
         Error     : out Interfaces.C.int) return Opus_Decoder
      with
         Import, Convention => C, External_Name => "opus_decoder_create";

      Error   : Interfaces.C.int;
      Decoder : Decoder_Data;
   begin
      Decoder.Decoder  := Opus_Decoder_Create (Frequency, Channels, Error);
      Decoder.Channels := Channels;

      Check_Error (Error);
      return Decoder;
   end Create;

   procedure Destroy (Decoder : in Decoder_Data) is
      procedure Opus_Decoder_Destroy (Decoder : in Opus_Decoder)
         with Import, Convention => C, External_Name => "opus_decoder_destroy";
   begin
      Opus_Decoder_Destroy (Decoder.Decoder);
   end Destroy;

   function Decode
     (Decoder    : in Decoder_Data;
      Data       : in Byte_Array;
      Max_Samples_Per_Channel : in Positive;
      Decode_FEC : in Boolean) return PCM_Buffer
   is
      function Opus_Decode
        (State     : in Opus_Decoder;
         Data      : in Byte_Array;
         Data_Size : in Integer;
         Audio_Frame : out PCM_Buffer;
         Samples_Per_Channel : in Integer;
         Decode_FEC : in C_Boolean) return Interfaces.C.int
      with Import, Convention => C, External_Name => "opus_decode";

      Length_Audio : Interfaces.C.int;

      Channels : constant Integer := (if Get_Channels (Decoder) = Mono then 1 else 2);
      Result   : PCM_Buffer (0 .. Max_Samples_Per_Channel * Channels);
   begin
      --  TODO if Data = null or Decode_Fec then assert Max_Samples = multiple of 2.5 ms

      Length_Audio := Opus_Decode (Decoder.Decoder, Data, Data'Length, Result, Max_Samples_Per_Channel, C_Boolean (Decode_FEC));

      Check_Error (Length_Audio);
      return Result (0 .. Integer (Length_Audio) * Channels);  -- TODO Assuming docs mean samples per channel
   end Decode;

   procedure Reset_State (Decoder : in Decoder_Data) is
      function Opus_Decoder_Ctl
        (State   : in Opus_Decoder;
         Request : in Interfaces.C.int) return Interfaces.C.int
      with
         Import, Convention => C, External_Name => "opus_decoder_ctl";

      Reset_State_Request : constant := 4028;
      Error : constant Interfaces.C.int := Opus_Decoder_Ctl (Decoder.Decoder, Reset_State_Request);
   begin
      Check_Error (Error);
   end Reset_State;

   ----------------------------------------------------------------------------

   function Get_Bandwidth (Decoder : in Decoder_Data) return Bandwidth is
      function Internal_Get_Bandwidth is new Get_Request (Get_Bandwidth_Request, Bandwidth);
   begin
      return Internal_Get_Bandwidth (Decoder);
   exception
      when Invalid_Result =>
         raise No_Packets_Decoded;
   end Get_Bandwidth;

   function Get_Channels (Decoder : in Decoder_Data) return Channel_Type is
   begin
      return Decoder.Channels;
   end Get_Channels;

   procedure Internal_Set_Gain is new Set_Request (Set_Gain_Request, Q8_dB);
   procedure Set_Gain
     (Decoder : in Decoder_Data;
      Factor  : in Q8_dB) renames Internal_Set_Gain;

   function Internal_Get_Gain is new Get_Request (Get_Gain_Request, Q8_dB);
   function Get_Gain (Decoder : in Decoder_Data) return Q8_dB
      renames Internal_Get_Gain;

   function Get_Pitch (Decoder : in Decoder_Data) return Integer is
      function Internal_Get_Pitch is new Get_Request (Get_Pitch_Request, Interfaces.C.int);
   begin
      return Integer (Internal_Get_Pitch (Decoder));
   end Get_Pitch;

   function Get_Final_Range (Decoder : in Decoder_Data) return Integer is
      function Internal_Get_Sample_Rate is new Get_Request (Get_Final_Range_Request, Interfaces.C.int);
   begin
      return Integer (Internal_Get_Sample_Rate (Decoder));
   end Get_Final_Range;

   function Internal_Get_Sample_Rate is new Get_Request (Get_Sample_Rate_Request, Sampling_Rate);
   function Get_Sample_Rate (Decoder : in Decoder_Data) return Sampling_Rate
      renames Internal_Get_Sample_Rate;

   function Get_Last_Packet_Duration (Decoder : in Decoder_Data) return Natural is
      function Internal_Get_Last_Packet_Duration is new Get_Request (Get_Last_Packet_Duration_Request, Interfaces.C.int);
   begin
      return Natural (Internal_Get_Last_Packet_Duration (Decoder));
   end Get_Last_Packet_Duration;

end Opus.Decoders;
