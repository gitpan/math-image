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

package App::MathImage::NumSeq::MobiusFunction;
use 5.004;
use strict;
use List::Util 'min','max';

use Math::NumSeq;
use base 'Math::NumSeq';

use vars '$VERSION';
$VERSION = 67;

use constant name => Math::NumSeq::__('Mobius Function');
use constant description => Math::NumSeq::__('The Mobius function, being 1 for an even number of prime factors, -1 for an odd number, or 0 if any repeated factors (ie. not square-free).');
use constant characteristic_pn1 => 1;
use constant characteristic_monotonic => 0;
use constant values_min => -1;
use constant values_max => 1;
use constant oeis_anum => 'A008683'; # mobius -1,0,1
#
# cf A030059 the -1 positions, odd distinct primes
#    A030229 the 1 positions, even distinct primes
#    A013929 the 0 positions, square factor, ie. non-square-frees
#    A005117 the square frees, mobius -1 or +1


# uncomment this to run the ### lines
#use Smart::Comments;

# each 2-bit vec() value is
#    0 unset
#    1 square factor
#    2 even count of factors
#    3 odd count of factors

my @transform = (0, 0, 1, -1);

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  my $self =  bless { i  => 1,
                      hi => $hi,
                    }, $class;
  $self->{'string'} = "\0" x (($hi+1)/4);  # 4 of 2 bits each
  vec($self->{'string'}, 0,2) = 1;  # N=0 treated as square
  vec($self->{'string'}, 1,2) = 2;  # N=1 treated as even

  while ($self->{'i'} < $lo) {
    $self->next;
  }
  return $self;
}
sub next {
  my ($self) = @_;

  my $i = $self->{'i'}++;
  my $hi = $self->{'hi'};
  if ($i > $hi) {
    return;
  }
  if ($i <= 1) {
    if ($i <= 0) {
      return ($i, 0);
    }
    else {
      return ($i, 1);
    }
  }

  my $sref = \$self->{'string'};

  my $ret = vec($$sref, $i,2);
  if ($ret == 0) {
    ### prime: $i
    $ret = 3; # odd

    # existing squares $v==1 left alone, others toggle 2=odd,3=even
    for (my $j = $i; $j <= $hi; $j += $i) {
      ### p: "$j ".vec($$sref, $j,2)
      if ((my $v = vec($$sref, $j,2)) != 1) {
        vec($$sref, $j,2) = ($v ^ 1) | 2;
        ### set: vec($$sref, $j,2)
      }
    }

    # squares set to $v==1
    my $step = $i * $i;
    for (my $j = $step; $j <= $hi; $j += $step) {
      vec($$sref, $j,2) = 1;
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, vec($$sref,$j,2);
    # }
  }
  ### ret: "$i, $ret -> ".($ret != 1 && 4-$ret)
  return ($i, $transform[$ret]);
}

sub pred {
  my ($self, $n) = @_;
  ### MobiusFunction pred(): $n
  if ($self->{'i'} <= $n) {
    ### extend from: $self->{'i'}
    my $i;
    while ((($i) = $self->next) && $i < $n) { }
  }
  return $transform[ vec($self->{'string'}, $n,2) ];
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::MobiusFunction -- Mobius function sequence

=head1 SYNOPSIS

 use App::MathImage::NumSeq::MobiusFunction;
 my $seq = App::MathImage::NumSeq::MobiusFunction->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The sequence of the Mobius function, 1, -1, -1, 0, -1, 1, etc,

    1   if i has an even number of distinct prime factors
    -1  if i has an odd number of distinct prime factors
    0   if i has a repeated prime factor

The sequence starts from i=1 and it's reckoned as no prime factors, ie. 0
factors, which is considered even, hence Mobius function 1.  Then i=2 and
i=3 are value -1 since they have one prime factor (they're primes), and i=4
is value 0 because it's 2*2 which is a repeated prime 2.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::MobiusFunction-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the Mobius function of C<$i>, being 1, 0 or -1 according to the prime
factors of C<$i>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is 1, 0 or -1.

=back

=head1 SEE ALSO

L<App::MathImage::NumSeq>,
L<App::MathImage::NumSeq::PrimeFactorCount>

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
