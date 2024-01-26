my constant PRINTABLE_TABLE = do {
    my int @table;
    @table[flat ords("\t\b\o33\o14"), 32..126, 128..255] = 1 xx *;
    @table
}

multi is-text(Blob $content, Int(Cool) :$test-bytes = 4096) is export {
    my int $limit = $content.elems min $test-bytes;
    my int $printable;
    my int $unprintable;
    loop (my int $i = 0; $i < $limit; ++$i) {
        my uint $check = $content[$i];
        if $check {
            if $check == 13 {
                # \r not followed by \n hints binary
                return False if $content[++$i] != 10;
            }
            elsif $check == 10 {
                # Ignore lone \n
            }
            elsif PRINTABLE_TABLE[$check] {
                $printable++;
            }
            else {
                $unprintable++;
            }
        }
        else {
            # NULL byte, so binary.
            return False;
        }
    }

    ($printable +> 7) >= $unprintable;
}

multi is-text(IO::Path $path, Int(Cool) :$test-bytes = 4096) is export {
    my $fh := $path.open(:r, :bin);
    LEAVE .close with $fh;

    is-text($fh.read($test-bytes), :$test-bytes);
}

=begin pod

=head1 NAME

Data::TextOrBinary - Heuristic detection of text vs. binary data

=head1 SYNOPSIS

=begin code :lang<raku>

use Data::TextOrBinary;

# Test a Buf/Blob
say is-text('Vánoční stromek'.encode('utf-8')); # True
say is-text(Buf.new(0x02, 0xFF, 0x00, 0x38));   # False

# Test a file
say is-text('/bin/bash'.IO);             # False
say is-text('/usr/share/dict/words'.IO); # True

=end code

=head1 DESCRIPTION

Implements a heuristic algorithm, very much like the one used by
Git, to decide if some data is most likely to be text or binary.

=head1 SUBROUTINES

The module exports a single subroutine C<is-text>, which has
candidates for C<Blob> and C<IO::Path>, enabling it to be used
on data that has already been read into memory as well as data
in a file.

=item On a Blob

=begin code :lang<raku>

my $text = is-text($the-blob, test-bytes => 8192);

=end code

When called on a C<Blob>, C<is-text> will test the first
C<test-bytes> bytes of it to decide if it contains text or
binary data. The C<test-bytes> named argument is optional,
and its default value is 4096.

=item On an IO::Path

=begin code :lang<raku>

my $text = is-text($filename.IO, test-bytes => 8192);

=end code

When called on an C<IO::Path>, C<is-text> will read the first
C<test-bytes> bytes from the file it points to. It will then test
these to decide if the file is text or binary. The C<test-bytes>
named argument is optional, and its default value is 4096.

=head1 Algorithm

The algorithm will flag a file as binary if it encounters a NULL
byte or a lone carriage return (`\r`). Otherwise, it considers
the ratio of printable to ASCII-range control characters, with
newline sequences excluded. If there is less than one byte
representing an unprintable ASCII character per 128 bytes
representing printable ASCII characters, then the data is
considered to be text.

=head1 Thread safety

The function exported by this module is safe to call from multiple threads at
the same time.

=head1 AUTHOR

Jonathan Worthington

=head1 COPYRIGHT AND LICENSE

Copyright 2017 - 2024 Jonathan Worthington

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
