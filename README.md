
# soundpipe-d

dlang bindings to [soundpipe](https://github.com/xdrie/soundpipe)

## usage

all you need to do is add this package as a dependency and it should automatically build the C library and link it in.

note that `soundpipe` depends on `libsndfile`.

## example

see [example](example/), which is adapated from [ex_music](https://github.com/xdrie/soundpipe/blob/master/examples/ex_music.c) from the original library. run the binary to generate `test.wav`, a short sample with some synths.

## licenses

- `soundpipe-d` (xdrie) apache-2.0
- `soundpipe` (Paul Batchelor) mit