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

our $VERSION = 30;

sub save {
  my ($pixbuf, $filename, $type, @options) = @_;
  $pixbuf->save ($filename, $type, save_options($type,@options));
}

my %tiff_compression_types = (none    => 1,
                              huffman => 2,
                              lzw     => 5,
                              jpeg    => 7,
                              deflate => 8);

sub save_options {
  my $type = shift;
  if (@_ & 1) {
    croak 'GdkPixbufBits save: option key without value (odd number of arguments)';
  }
  my @first;
  my @rest;

  while (@_) {
    my $key = shift;
    my $value = shift;
    if ($key eq 'zlib_compression') {
      next unless $type eq 'png';
      # png saving always available, but compression option only in 2.8 up
      next if Gtk2->check_version(2,8,0);
      $key = 'compression';

    } elsif ($key eq 'tiff_compression_type') {
      next unless $type eq 'tiff';
      next if Gtk2->check_version(2,20,0);  # new in 2.20
      $key = 'compression';
      $value = $tiff_compression_types{$value} || $value;

    } elsif ($key =~ /^tEXt:/) {
      next unless $type eq 'png';
      next if Gtk2->check_version(2,8,0); # compression new in 2.8.0
      # Gtk2-Perl 1.221 doesn't upgrade byte values to utf8 the way it does
      # in other wrappers, ensure utf8 for output
      utf8::upgrade($value);
      # text before "compression" or Gtk 2.20.1 botches the file output
      push @first, $key, $value;
      next;

    } elsif ($key eq 'quality_percent') {
      next unless $type eq 'jpeg';
      $key = 'quality';

      # } elsif ($key eq 'x_hot' || $key eq 'y_hot') {
      #   # no xpm saving as of 2.20, but anticipate it would use x_hot/y_hot
      #   # same as ico if/when available
      #   next unless $type eq 'ico' || $type eq 'xpm';
      #
      # } elsif ($key eq 'depth') {
      #   next unless $type eq 'ico';
      #
      # } elsif ($key eq 'icc-profile') {
      #   # this mangling not yet documented ....
      #   next unless $type eq 'png' ||  $type eq 'tiff';
      #   next if Gtk2->check_version(2,20,0);
    }
    push @rest, $key, $value;
  }
  return @first, @rest;
}

sub filename_to_format {
  my ($filename) = @_;
  return List::Util::first
    { format_matches_filename($_, $filename) }
      Gtk2::Gdk::Pixbuf->get_formats;
}

sub format_matches_filename {
  my ($format, $filename) = @_;
  return List::Util::first
    { $filename =~ /.\Q$_\E$/i }
      @{$format->{'extensions'}};
}

1;
__END__

=for stopwords Ryde pixbuf Gtk Gtk2 PNG Zlib png huffman lzw jpeg lossy JPEG filename PixbufFormat Gtk2-Perl

=head1 NAME

App::MathImage::Gtk2::Ex::GdkPixbufBits -- misc pixbuf helpers

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::GdkPixbufBits;

=head1 FUNCTIONS

=over

=item C<< App::MathImage::Gtk2::Ex::GdkPixbufBits::save ($pixbuf, $filename, $type, key => value, ...) >>

=item C<< @args = App::MathImage::Gtk2::Ex::GdkPixbufBits::save_options ($type, key => value, ...) >>

C<save()> saves a C<Gtk2::Gdk::Pixbuf> with options adapted to what the Gtk
in use supports.  C<save_options()> adapts options and returns them.

The idea is to pass a full set of options which are automatically reduced if
not applicable to the C<$type> or not available at all.  For example the
C<compression> option must be set different ways for PNG or for TIFF.  The
two separate compression options here are used according to the C<$type>.

=over

=item C<zlib_compression> (integer 0 to 9 or -1)

A Zlib style compression level.  For C<$type> "png" in Gtk 2.8 this becomes
the C<compression> option.

=item C<tiff_compression_type> (integer or names "none", "huffman", "lzw", "jpeg" or "deflate")

A TIFF compression method.  For C<$type> "tiff" in Gtk 2.20 this becomes the
C<compression> option.  String names "deflate" etc are converted to the
corresponding integer value.

=item C<quality_percent> (0 to 100)

An image quality percentage, for lossy formats such as JPEG.  For C<$type>
"jpeg" this becomes the C<quality> option.

=item C<tEXt:foo> (string)

A PNG style keyword string.  For C<$type> "png" in Gtk 2.8 this is passed
through as C<tEXt>, with a C<utf8::upgrade> if necessary in Gtk2-Perl 1.221,
and moved to before any C<compression> option as a workaround for a Gtk bug.

=back

For example

    App::MathImage::Gtk2::Ex::GdkPixbufBits::save
      ($pixbuf,        # Gtk2::Gdk::Pixbuf object
       $user_filename, # eg. string "/tmp/foo"
       $user_type,     # eg. string "png"
       zlib_compression      => 9,
       quality_percent       => 100,
       tiff_compression_type => "deflate",
       tEXt:Author           => "Yorick");
       

=item C<< $format = App::MathImage::Gtk2::Ex::GdkPixbufBits::filename_to_format ($filename) >>

Return the C<Gtk2::Gdk::PixbufFormat> for the given C<$filename> based on
its extension.  For example F<foo.png> is PNG format.  If the filename is
not recognised then return C<undef>.

PixbufFormat is new in Gtk 2.2.  Currently C<filename_to_format> throws an
error in Gtk 2.0.  Would returning C<undef> be better?

=item C<< App::MathImage::Gtk2::Ex::GdkPixbufBits::format_matches_filename ($format, $filename) >>

C<$format> should be a C<Gtk2::Gdk::PixbufFormat> object.  Return true if
one of its extensions matches C<$filename>.  For example JPEG format matches
F<foo.jpg> or F<foo.jpeg>.

=back

=cut
