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

package App::MathImage::NumSeq::Sequence::Squares;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 52;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Perfect Squares');
use constant description => __('The perfect squares 1,4,9,16,25, etc k*k.');
use constant values_min => 0;
use constant oeis_anum => 'A000290'; # squares

sub rewind {
  my ($self) = @_;
  $self->{'i'} = ceil (sqrt (max(0,$self->{'lo'})));
}
sub next {
  my ($self) = @_;
  ### Squares next(): $self->{'i'}
  my $i = $self->{'i'}++;
  return ($i, $i*$i);
}
sub pred {
  my ($class_or_self, $n) = @_;
  return (($n >= 0)
          && do {
            $n = sqrt($n);
            $n == int($n)
          });
}
sub ith {
  my ($class_or_self, $i) = @_;
  return $i*$i;
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::Sequence::Squares -- perfect squares

=head1 SYNOPSIS

 use App::MathImage::NumSeq::Sequence::Squares;
 my $seq = App::MathImage::NumSeq::Sequence::Squares->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The sequence of perfect squares, 0, 1, 4, 9, 16, 25, etc.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::Sequence::Squares-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return C<$i ** 2>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a perfect square.

=back

=head1 SEE ALSO

L<App::MathImage::NumSeq::Sequence>,
L<App::MathImage::NumSeq::Cubes>

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
