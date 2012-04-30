# Copyright 2012 Kevin Ryde

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

package Math::NumSeq::MathImageMaxDigitCount;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 97;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


# use constant name => Math::NumSeq::__('...');
# use constant description => Math::NumSeq::__('...');
use constant default_i_start => 1;
use constant parameter_info_array =>
  [
   {
    name        => 'values_type',
    type        => 'enum',
    default     => 'count',
    choices     => ['count','radix'],
    # description => Math::NumSeq::__('...'),
   },
   {
    name      => 'digit',
    share_key => 'digit_0',
    type      => 'integer',
    display   => Math::NumSeq::__('Digit'),
    default   => 0,
    minimum   => 0,
    width     => 2,
    description => Math::NumSeq::__('Digit to count.'),
   },
  ];

sub characteristic_count {
  my ($self) = @_;
  return $self->{'values_type'} eq 'count';
}
sub characteristic_value_is_radix {
  my ($self) = @_;
  return $self->{'values_type'} eq 'radix';
}
use constant characteristic_smaller => 1;
use constant characteristic_integer => 1;

sub values_min {
  my ($self) = @_;
  if ($self->{'values_type'} eq 'count') {
    if ($self->{'digit'} == 1) {
      return 1;
    }
  } else { # radix
    if ($self->i_start >= 2) {
      return 2;
    }
  }
  return 0;
}

#------------------------------------------------------------------------------

# cf A033093 number of zeros in base 2 to n+1
#
my %oeis_anum;
$oeis_anum{'count'}->[0] = 'A062842'; # max 0s count
$oeis_anum{'count'}->[1] = 'A062843'; # max 1s count
# OEIS-Catalogue: A062842
# OEIS-Catalogue: A062843 digit=1
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{$self->{'values_type'}}->[$self->{'digit'}];
}

#------------------------------------------------------------------------------

sub ith {
  my ($self, $i) = @_;
  ### MathImageMaxDigitCount ith(): $i

  if (_is_infinite($i)) {
    return $i;
  }

  my $digit = $self->{'digit'};
  if ($i <= 1) {
    return ($digit == $i ? 1 : 0);
  }

  my $max_count = 0;
  my $max_radix = 0;
  foreach my $radix (2 .. $i) {
    my $digits = _digit_split($i,$radix); # low to high

    ### $radix
    ### $digits

    if (@$digits < $max_count) {
      last;  # fewer digits now than max already found
    }
    my $count = grep {$_ == $digit} @$digits;
    if ($count > $max_count) {
      $max_count = $count;
      $max_radix = $radix;
      if ($count == scalar(@$digits) - ($digit==0)) {
        last;  # "x0000" or "ddddd" maximum is this radix
      }
    }
  }
  return ($self->{'values_type'} eq 'radix' ? $max_radix : $max_count);
}

sub _digit_split {
  my ($n, $radix) = @_;
  ### _digit_split(): $n
  my @ret;
  while ($n) {
    push @ret, $n % $radix;
    $n = int($n/$radix);
  }
  return \@ret;   # array[0] low digit
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

Math::NumSeq::MathImageMaxDigitCount -- maximum zeros in any radix

=head1 SYNOPSIS

 use Math::NumSeq::MathImageMaxDigitCount;
 my $seq = Math::NumSeq::MathImageMaxDigitCount->new (values_type => 'count');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

I<In progress ...>

The maximum number of zeros which occur when i is written out in any radix,
starting from i=1

    0, 1, 1, 2, 1, 1, 1, 3, 2, 2, 1, 2, 1, 1, 1, 4, 3, 3, 2, 3, 2, ...

Option C<values_type =E<gt> 'radix'> gives the radix where the maximum
occurs,

    0, 2, 3, 2, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, ...

i=1 has no zeros in any radix and the radix returned is 0.  For any higher i
there's always at most radix=i for "10" with one zero.  But usually some
much smaller radix has one or more zeros.  Most of the time the maximum
occurs in binary or ternary.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::MathImageMaxDigitCount-E<gt>new ()>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of ways C<$i> can be expressed as the sum of two squares.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::DigitCount>

=cut
