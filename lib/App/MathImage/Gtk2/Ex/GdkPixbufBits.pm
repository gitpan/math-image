# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::GdkPixbufBits;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use List::MoreUtils;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 14;

my %tiff_compression_types = (none    => 1,
                              huffman => 2,
                              lzw     => 5,
                              jpeg    => 7,
                              deflate => 8);

sub save_options {
  my $type = shift;
  my @first;
  my @rest;
  while (@_) {
    my $key = shift;
    my $value = shift;
    if ($key eq 'zlib_compression') {
      next unless $type eq 'png';
      $key = 'compression';

    } elsif ($key eq 'tiff_compression_type') {
      next unless $type eq 'tiff';
      next if Gtk2->check_version(2,20,0);
      $key = 'compression';
      $value = $tiff_compression_types{$value}
        || croak "Unrecognised compression_type";

    } elsif ($key =~ /^tEXt:/) {
      next unless $type eq 'png';
      next if Gtk2->check_version(2,8,0); # compression new in 2.8.0
      utf8::upgrade($value);
      # text before "compression" or Gtk 2.20.1 botches the file output
      push @first, $key, $value;
      next;

    } elsif ($key eq 'quality_percent') {
      next unless $type eq 'jpeg';
      $key = 'quality';

    } elsif ($key =~ /^[xy]_hot$/) {
      next unless $type eq 'ico'; # || $type eq 'xpm';

    } elsif ($key eq 'depth') {
      next unless $type eq 'ico';

    } elsif ($key eq 'icc-profile') {
      # not yet documented ....
      next unless $type eq 'png' ||  $type eq 'tiff';
      next if Gtk2->check_version(2,20,0);
    }
    push @rest, $key, $value;
  }
  return @first, @rest;
}

1;
__END__

=for stopwords Ryde pixbuf

=head1 NAME

App::MathImage::Gtk2::Ex::GdkPixbufBits -- misc pixbuf helpers

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::GdkPixbufBits;

=head1 FUNCTIONS

=over

=item C<< @args = App::MathImage::Gtk2::Ex::GdkPixbufBits::save_options (key => value, ...) >>

Filter and transform parameters for C<< Gtk2::Gdk::Pixbuf->save >>.

=back

=cut
