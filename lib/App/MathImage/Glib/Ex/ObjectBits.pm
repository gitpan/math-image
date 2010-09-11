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

package App::MathImage::Glib::Ex::ObjectBits;
use 5.008;
use strict;
use warnings;
use Carp;

# uncomment this to run the ### lines
#use Smart::Comments;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw(set_property_maybe);

our $VERSION = 19;

sub set_property_maybe {
  my $object = shift;
  if (@_ & 1) {
    croak "set_property_maybe() expects even number of pname,value arguments";
  }
  while (@_) {
    my $pname = shift;
    my $value = shift;
    if ($object->find_property($pname)) {
      $object->set_property ($pname, $value);
    }
  }
}

1;
__END__

=for stopwords Ryde Glib-Ex-ObjectBits

=head1 NAME

App::MathImage::Glib::Ex::ObjectBits -- misc Glib::Object helpers

=head1 SYNOPSIS

 use App::MathImage::Glib::Ex::ObjectBits;

=head1 FUNCTIONS

=over

=item C<< $str = App::MathImage::Glib::Ex::ObjectBits::set_property_maybe ($object, $propname, $value, ...) >>

Set each C<$propname> to C<$value> per C<< $object->set_property ($propname,
$value) >>, if C<$object> has such a property.  If C<$object> has some of
the given properties but not others then just those which exist are set and
the rest ignored.

This can be used for properties which only exist in a new enough version of
the object.  For example C<Gtk2::Widget> C<tooltip-text> property is new in
Gtk 2.12.  With C<set_property_maybe> any tooltip settings can be skipped
for earlier Gtk.

Be careful to avoid typos in the property names.  A misspelling will be
ignored as a non-existent property.

=back

=head1 SEE ALSO

L<Glib::Object>,
L<Glib::Ex::ObjectBits>

=cut
