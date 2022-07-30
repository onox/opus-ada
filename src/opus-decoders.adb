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

   subtype Opus_Decoder is Opus.API.Opus_Decoder;
   use all type Opus.API.Get_Request_Type_Decoder;
   use all type Opus.API.Set_Request_Type_Decoder;

   generic
      Request : Opus.API.Get_Request_Type_Decoder;
      type Return_Type is (<>);
   function Get_Request (Decoder : Decoder_Data) return Return_Type;

   function Get_Request (Decoder : Decoder_Data) return Return_Type is
      Result : Return_Type;

      function Opus_Decoder_Ctl
        (State   : Opus_Decoder;
         Request : Opus.API.Get_Request_Type_Decoder;
         Result  : out Return_Type) return Interfaces.C.int
      with Import, Convention => C, External_Name => "opus_decoder_ctl";

      Error : constant Interfaces.C.int := Opus_Decoder_Ctl (Decoder.Decoder, Request, Result);
   begin
      Check_Error (Error);
      if not Result'Valid then
         raise Invalid_Result;
      end if;
      return Result;
   end Get_Request;

   generic
      Request : Opus.API.Set_Request_Type_Decoder;
      type Argument_Type is (<>);
   procedure Set_Request (Decoder : Decoder_Data; Argument : Argument_Type);

   procedure Set_Request (Decoder : Decoder_Data; Argument : Argument_Type) is
      function Opus_Decoder_Ctl
        (State    : Opus_Decoder;
         Request  : Opus.API.Set_Request_Type_Decoder;
         Argument : Argument_Type) return Interfaces.C.int
      with Import, Convention => C, External_Name => "opus_decoder_ctl";

      Error : constant Interfaces.C.int := Opus_Decoder_Ctl (Decoder.Decoder, Request, Argument);
   begin
      Check_Error (Error);
   end Set_Request;

   ----------------------------------------------------------------------------

   function Create
     (Frequency : Sampling_Rate;
      Channels  : Channel_Type) return Decoder_Data
   is
      Error   : Interfaces.C.int;
      Decoder : Decoder_Data;
   begin
      Decoder.Decoder  := Opus.API.Decoder_Create (Frequency, Channels, Error);
      Decoder.Channels := Channels;

      Check_Error (Error);
      return Decoder;
   end Create;

   procedure Destroy (Decoder : Decoder_Data) is
   begin
      Opus.API.Decoder_Destroy (Decoder.Decoder);
   end Destroy;

   function Decode
     (Decoder    : Decoder_Data;
      Data       : Byte_Array;
      Max_Samples_Per_Channel : Positive;
      Decode_FEC : Boolean) return PCM_Buffer
   is
      Length_Audio : Interfaces.C.int;

      Channels : constant Integer := (if Get_Channels (Decoder) = Mono then 1 else 2);
      Result   : PCM_Buffer (0 .. Max_Samples_Per_Channel * Channels);
   begin
      --  TODO if Data = null or Decode_Fec then assert Max_Samples = multiple of 2.5 ms

      Length_Audio := Opus.API.Decode
         (Decoder.Decoder, Data, Data'Length,
          Result, Max_Samples_Per_Channel, C_Boolean (Decode_FEC));

      Check_Error (Length_Audio);
      return Result (0 .. Integer (Length_Audio) * Channels);
      --  TODO Assuming docs mean samples per channel
   end Decode;

   procedure Reset_State (Decoder : Decoder_Data) is
      function Opus_Decoder_Ctl
        (State   : Opus_Decoder;
         Request : Interfaces.C.int) return Interfaces.C.int
      with Import, Convention => C, External_Name => "opus_decoder_ctl";

      Reset_State_Request : constant := 4028;
      Error : constant Interfaces.C.int := Opus_Decoder_Ctl (Decoder.Decoder, Reset_State_Request);
   begin
      Check_Error (Error);
   end Reset_State;

   ----------------------------------------------------------------------------

   package Internal is
      function Get_Bandwidth   is new Get_Request (Get_Bandwidth_Request, Bandwidth);
      function Get_Gain        is new Get_Request (Get_Gain_Request, Q8_dB);
      function Get_Pitch       is new Get_Request (Get_Pitch_Request, Interfaces.C.int);
      function Get_Sample_Rate is new Get_Request (Get_Final_Range_Request, Interfaces.C.int);
      function Get_Sample_Rate is new Get_Request (Get_Sample_Rate_Request, Sampling_Rate);

      function Get_Last_Packet_Duration is
        new Get_Request (Get_Last_Packet_Duration_Request, Interfaces.C.int);

      procedure Set_Gain is new Set_Request (Set_Gain_Request, Q8_dB);
   end Internal;

   ----------------------------------------------------------------------------

   function Get_Bandwidth (Decoder : Decoder_Data) return Bandwidth is
   begin
      return Internal.Get_Bandwidth (Decoder);
   exception
      when Invalid_Result =>
         raise No_Packets_Decoded;
   end Get_Bandwidth;

   function Get_Channels (Decoder : Decoder_Data) return Channel_Type is (Decoder.Channels);

   procedure Set_Gain
     (Decoder : Decoder_Data;
      Factor  : Q8_dB) renames Internal.Set_Gain;

   function Get_Gain (Decoder : Decoder_Data) return Q8_dB renames Internal.Get_Gain;

   function Get_Pitch (Decoder : Decoder_Data) return Integer is
   begin
      return Integer (Internal.Get_Pitch (Decoder));
   end Get_Pitch;

   function Get_Final_Range (Decoder : Decoder_Data) return Integer is
   begin
      return Integer (Interfaces.C.int'(Internal.Get_Sample_Rate (Decoder)));
   end Get_Final_Range;

   function Get_Sample_Rate (Decoder : Decoder_Data) return Sampling_Rate
     renames Internal.Get_Sample_Rate;

   function Get_Last_Packet_Duration (Decoder : Decoder_Data) return Natural is
   begin
      return Natural (Internal.Get_Last_Packet_Duration (Decoder));
   end Get_Last_Packet_Duration;

end Opus.Decoders;
