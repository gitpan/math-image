# Copyright 2011 Kevin Ryde

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

package App::MathImage::NumSeq::HypotCount;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 79;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Count Hypotenuses');
use constant description => Math::NumSeq::__('Count of how many ways a given N = A^2+B^2 occurs, for integer A,B >=0 (and no swaps, so B<=A).');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant values_min => 1;
use constant oeis_anum => 'A000161'; # num ways sum of two squares, no swaps

# sub new {
#   my ($class, %options) = @_;
#   ### HypotCount new()
# 
#   $options{'lo'} = max (0, $options{'lo'}||0);
#   my $hi = $options{'hi'} = max (0, $options{'hi'});
# 
#   my $str = "\0\0\0\0" x ($options{'hi'}+1);
#   for (my $j = 2; $j <= $hi; $j += 2) {
#     vec($str, $j,8) = 2*1-1;
#   }
#   return $class->SUPER::new (%options,
#                              string => $str);
# }
# 
# sub rewind {
#   my ($self) = @_;
#   ### HypotCount rewind()
#   $self->{'i'} = 0;
#   while ($self->{'i'} < $self->{'lo'}-1) {
#     $self->next;
#   }
# }
# 
# sub next {
#   my ($self) = @_;
#   ### HypotCount next() from: $self->{'i'}
# 
#   my $i = $self->{'i'}++;
#   my $hi = $self->{'hi'};
#   if ($i > $hi) {
#     return;
#   }
#   my $cref = \$self->{'string'};
# 
#   my $ret = vec ($$cref, $i,8);
#   if ($ret == 0 && $i >= 3 && ($i&3) == 1) {
#     ### prime 4k+1: $i
#     $ret = 1;
#     for (my $j = $i; $j <= $hi; $j += $i) {
#       vec($$cref, $j,8) ++;
#     }
# 
#     # print "applied: $i\n";
#     # for (my $j = 0; $j < $hi; $j++) {
#     #   printf "  %2d %2d\n", $j, vec($$cref, $j,8);
#     # }
#   }
#   return ($i, $ret);
# }
# 
# sub pred {
#   my ($self, $n) = @_;
#   ### HypotCount pred(): $n
#   return 1;
# }



sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub ith {
  my ($self, $i) = @_;
  ### HypotCount: $i

  my $count = 0;
  my $r = int(sqrt($i));
  for (my $x = ceil(sqrt($i)/2); $x <= $r; $x++) {
    my $y = sqrt($i - $x*$x);
    $count += ($y <= $x && $y == int($y));
    ### add: "$x,$y  ".($y == int($y))
  }
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  ### HypotCount pred(): $value
  return ($value >= 0);
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::HypotCount -- how many times as a Pythagorean hypotenuse

=head1 SYNOPSIS

 use App::MathImage::NumSeq::HypotCount;
 my $seq = App::MathImage::NumSeq::HypotCount->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The counts of how many times each integer occurs as the hypotenuse of a
Pythagorean triangle, being the number of ways an integer can be expressed
as the sum of two squares a^2+b^2.  For example at i=25 the values is 2
since 25 can be expressed two ways, 3^3+4^4 and 0^2+5^2.

Because 0^2+k^2 == k^2 is counted, the perfect squares always have a count
at least 1, but it may be more.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::HypotCount-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of ways C<$i> can be expressed as the sum of two squares.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a count.  All counts occur so this is
simply any non-negative C<$value>.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
