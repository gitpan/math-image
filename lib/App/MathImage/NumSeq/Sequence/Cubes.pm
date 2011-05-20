# Copyright 2010, 2011 Kevin Ryde

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

package App::MathImage::NumSeq::Sequence::Cubes;
use 5.004;
use strict;
use Math::Libm 'cbrt';
use POSIX 'floor','ceil';
use List::Util 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 57;

use constant name => __('Cubes');
use constant description => __('The cubes 1, 8, 27, 64, 125, etc, k*k*k.');
use constant values_min => 0;
use constant oeis_anum => 'A000578';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = ceil (cbrt (max(0,$self->{'lo'})));
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $i*$i*$i);
}
sub ith {
  my ($class_or_self, $i) = @_;
  return $i*$i*$i;
}

# this was a test for cbrt($n) being an integer, but found some amd64 glibc
# where cbrt(27) was not 3 but instead 3.00000000000000044.  Dunno if an
# exact integer can be expected from cbrt() on a cube, so instead try
# multiplying back the integer nearest cbrt().
#
# FIXME: If $n is bigger than 2^53 or so then the $c*$c*$c product might be
# rounded, making some non-cube $n look like a cube.
#
sub pred {
  my ($class_or_self, $n) = @_;
  my $c = floor (0.5 + cbrt ($n));
  return ($c*$c*$c == $n);
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::Sequence::Cubes -- cubes

=head1 SYNOPSIS

 use App::MathImage::NumSeq::Sequence::Cubes;
 my $seq = App::MathImage::NumSeq::Sequence::Cubes->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The sequence of cubes, 0, 1, 8, 27, 64, 125, etc, i^3.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::Sequence::Cubes-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return C<$i ** 2>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a cube.

=back

=head1 SEE ALSO

L<App::MathImage::NumSeq::Sequence>,
L<App::MathImage::NumSeq::Sequence::Squares>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
