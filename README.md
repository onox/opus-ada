opus-ada
========

Ada bindings for the Opus audio codec.

Status
------

Only the encoder and decoder have been binded. The TODO shows some few functions that are yet to be binded. Some other functions like `opus_encoder_get_size`, `opus_encoder_init`, `opus_decoder_get_size`, and `opus_decoder_init` will never be binded at all. Other function may or may not be binded in the future. These are: `opus_repacketizer_*`, `opus_multistream_*`, and `opus_packet_*`.

Dependencies
------------

* Ada 2012 compiler

* Ahven 2.x for the unit tests

License
-------

The Ada code is licensed under the ISC license. Most of the documentation in the `*.ads` files has been copied from `opus.h` and `opus_defines.h` and is licensed under the license of those files; the Simplified BSD License.

Tasking
-------

The `Opus.Encoders.Encoder_Data` and `Opus.Decoders.Decoder_Data` are not designed to be used by multiple tasks.

Installation
------------

To compile the sources, run `make`. Currently only `make test` and `make run_unit_tests` work.

TODO
----

* Fix `make` and add `make install`
* Write some tests for Opus.Encoder.Encode and Opus.Decoder.Decode
* Bind `opus_decode_float` and `opus_encode_float`
* Bind `opus_decoder_get_nb_samples` and `opus_pcm_soft_clip`
