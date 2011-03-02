# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::LayoutBits;
use 5.008;
use strict;
use warnings;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw(move_maybe);

our $VERSION = 46;

# uncomment this to run the ### lines
#use Smart::Comments;

sub move_maybe {
  my ($layout, $child, $x, $y) = @_;
  ### LayoutBits move_maybe()
  if ($layout->child_get_property($child,'x') != $x
      || $layout->child_get_property($child,'y') != $y) {
    ### move to: "$x,$y"
    $layout->move ($child, $x, $y)
  }
}

1;
__END__

=for stopwords Ryde Gtk Gtk2

=head1 NAME

App::MathImage::Gtk2::Ex::LayoutBits -- misc Gtk2::Layout helpers

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::LayoutBits;

=head1 FUNCTIONS

=over

=item C<< App::MathImage::Gtk2::Ex::LayoutBits::move_maybe ($layout, $child, $x, $y) >>

Do a C<< $layout->move >> if C<$child> is not already at the given C<$x,$y>
position.

As of Gtk 2.22 a plain C<move> or C<child_set_property> always does a
C<queue_resize>.  This function checks if the child is already in the right
place to avoid that when not needed.

=back

=cut
