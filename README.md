[![Actions Status](https://github.com/raku-community-modules/Data-TextOrBinary/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Data-TextOrBinary/actions) [![Actions Status](https://github.com/raku-community-modules/Data-TextOrBinary/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Data-TextOrBinary/actions) [![Actions Status](https://github.com/raku-community-modules/Data-TextOrBinary/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/Data-TextOrBinary/actions)

NAME
====

Data::TextOrBinary - Heuristic detection of text vs. binary data

SYNOPSIS
========

```raku
use Data::TextOrBinary;

# Test a Buf/Blob
say is-text('Vánoční stromek'.encode('utf-8')); # True
say is-text(Buf.new(0x02, 0xFF, 0x00, 0x38));   # False

# Test a file
say is-text('/bin/bash'.IO);             # False
say is-text('/usr/share/dict/words'.IO); # True
```

DESCRIPTION
===========

Implements a heuristic algorithm, very much like the one used by Git, to decide if some data is most likely to be text or binary.

SUBROUTINES
===========

The module exports a single subroutine `is-text`, which has candidates for `Blob` and `IO::Path`, enabling it to be used on data that has already been read into memory as well as data in a file.

  * On a Blob

```raku
my $text = is-text($the-blob, test-bytes => 8192);
```

When called on a `Blob`, `is-text` will test the first `test-bytes` bytes of it to decide if it contains text or binary data. The `test-bytes` named argument is optional, and its default value is 4096.

  * On an IO::Path

```raku
my $text = is-text($filename.IO, test-bytes => 8192);
```

When called on an `IO::Path`, `is-text` will read the first `test-bytes` bytes from the file it points to. It will then test these to decide if the file is text or binary. The `test-bytes` named argument is optional, and its default value is 4096.

Algorithm
=========

The algorithm will flag a file as binary if it encounters a NULL byte or a lone carriage return (`\r`). Otherwise, it considers the ratio of printable to ASCII-range control characters, with newline sequences excluded. If there is less than one byte representing an unprintable ASCII character per 128 bytes representing printable ASCII characters, then the data is considered to be text.

Thread safety
=============

The function exported by this module is safe to call from multiple threads at the same time.

AUTHOR
======

Jonathan Worthington

COPYRIGHT AND LICENSE
=====================

Copyright 2017 - 2022 Jonathan Worthington

Copyright 2024, 2025 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

