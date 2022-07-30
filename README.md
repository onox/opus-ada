[![Build status](https://github.com/onox/opus-ada/actions/workflows/build.yaml/badge.svg)](https://github.com/onox/opus-ada/actions/workflows/build.yaml)
[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/opus_ada.json)](https://alire.ada.dev/crates/opus_ada.html)
[![License](https://img.shields.io/github/license/onox/opus-ada.svg?color=blue)](https://github.com/onox/opus-ada/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/onox/opus-ada.svg)](https://github.com/onox/opus-ada/releases/latest)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/ada-lang/Lobby)

# opus-ada

Ada 2012 bindings for the Opus audio codec.

## Status

Only the encoder and decoder have been binded. The TODO shows some few functions
that are yet to be binded.
Some other functions like `opus_encoder_get_size`, `opus_encoder_init`,
`opus_decoder_get_size`, and `opus_decoder_init` will never be binded at all.
Other function may or may not be binded in the future.
These are: `opus_repacketizer_*`, `opus_multistream_*`, and `opus_packet_*`.

## Tasking

The `Opus.Encoders.Encoder_Data` and `Opus.Decoders.Decoder_Data` are not designed
to be used by multiple tasks.

## TODO

* Write some tests for Opus.Encoder.Encode and Opus.Decoder.Decode
* Bind `opus_decode_float` and `opus_encode_float`
* Bind `opus_decoder_get_nb_samples` and `opus_pcm_soft_clip`

## Dependencies

In order to build the library, you need to have:

 * An Ada 2012 compiler

 * [Alire][url-alire] package manager

 * Ahven 2.x for the unit tests

## License

The Ada code is licensed under the [Apache License 2.0][url-apache].
The first line of each Ada file should contain an SPDX license identifier tag that
refers to this license:

    SPDX-License-Identifier: Apache-2.0

Most of the documentation in the `*.ads` files has been copied from `opus.h` and
`opus_defines.h` and is licensed under the license of those files; the Simplified BSD License.

  [url-alire]: https://alire.ada.dev/
  [url-apache]: https://opensource.org/licenses/Apache-2.0
