# N_low
# N_high
# N_middle
# position_offset
#
# DigitExtract
# DigitAverage




# Copyright 2011, 2012 Kevin Ryde

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

package Math::NumSeq::MathImageDigitExtract;
use 5.004;
use strict;
use List::Util 'min','max';

use vars '$VERSION', '@ISA';
$VERSION = 95;

use Math::NumSeq::Base::IterateIth;
use Math::NumSeq::Base::Digits;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq::Base::Digits');

use Math::NumSeq 7; # v.7 for _is_infinite()
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Extract digit from i.');
use constant default_i_start => 0;
use constant characteristic_count => 1;
use constant characteristic_increasing => 0;

use constant parameter_info_array =>
  [
   {
    name    => 'extract_type',
    type    => 'enum',
    default => 'low',
    choices => ['low','high','second_low','second_high','middle',
                'minimum','maximum',
                'mean','median','mode',
                'geometric_mean','quadratic_mean',
               ],
   },
   Math::NumSeq::Base::Digits::parameter_common_radix(),
   {
    name    => 'round',
    # display => Math::NumSeq::__('Round'),
    type    => 'enum',
    default => 'unrounded',
    choices => ['unrounded','down','up'],
    description => Math::NumSeq::__('Rounding direction'),
   },
  ];

sub values_min {
  my ($self) = @_;
  if ($self->{'extract_type'} eq 'high') {
    return ($self->i_start > 0 ? 1 : 0);
  }
  return 0;
}

my %type_is_integer = (low => 1,
                       high => 1,
                       second_low => 1,
                       second_high => 1,
                       middle => 1,
                       minimum => 1,
                       maximum => 1,
                       mean => 0,
                       median => 0,
                       mode => 0,
                       geometric_mean => 0,
                       quadratic_mean => 0,
                      );
my %round_is_integer = (down => 1,
                        up => 1);
sub characteristic_integer {
  my ($self) = @_;
  return $type_is_integer{$self->{'extract_type'}}
    || $round_is_integer{$self->{'round'}};
}


#------------------------------------------------------------------------------
my @oeis_anum;

# ENHANCE-ME: low is n mod radix -- anum by radix

# cf A134777 minimum alphabetical english names of digits
#    A134778 minimum alphabetical english names of digits
#    A061383 arithmetic mean is an integer
#    A037897 base 3 maxdigit-mindigit

$oeis_anum[0]->{'low'}->{'unrounded'}->[10] = 'A010879';  # 0 to 9 rep
# OEIS-Catalogue: A010879 extract_type=low
$oeis_anum[0]->{'low'}->{'down'} = $oeis_anum[0]->{'low'}->{'unrounded'};
$oeis_anum[0]->{'low'}->{'up'} = $oeis_anum[0]->{'low'}->{'unrounded'};

$oeis_anum[1]->{'high'}->{'unrounded'}->[3] = 'A122586'; # starting OFFSET=1
$oeis_anum[1]->{'high'}->{'unrounded'}->[4] = 'A122587'; # starting OFFSET=1
$oeis_anum[0]->{'high'}->{'unrounded'}->[10] = 'A000030';
# OEIS-Catalogue: A122586 extract_type=high radix=3 i_start=1
# OEIS-Catalogue: A122587 extract_type=high radix=4 i_start=1
# OEIS-Catalogue: A000030 extract_type=high
$oeis_anum[0]->{'high'}->{'down'} = $oeis_anum[0]->{'high'}->{'unrounded'};
$oeis_anum[0]->{'high'}->{'up'} = $oeis_anum[0]->{'high'}->{'unrounded'};

$oeis_anum[1]->{'middle'}->{'down'}->[10] = 'A179636'; # less significant
$oeis_anum[1]->{'middle'}->{'up'}->[10]   = 'A179635'; # more significant
# OEIS-Catalogue: A179636 extract_type=middle round=down i_start=1
# OEIS-Catalogue: A179635 extract_type=middle round=up i_start=1

$oeis_anum[0]->{'minimum'}->{'unrounded'}->[10] = 'A054054';
# OEIS-Catalogue: A054054 extract_type=minimum
$oeis_anum[0]->{'minimum'}->{'up'}
  = $oeis_anum[0]->{'minimum'}->{'unrounded'};
$oeis_anum[0]->{'minimum'}->{'down'}
  = $oeis_anum[0]->{'minimum'}->{'unrounded'};

$oeis_anum[0]->{'maximum'}->{'unrounded'}->[3] = 'A190592';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[4] = 'A190593';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[5] = 'A190594';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[6] = 'A190595';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[7] = 'A190596';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[8] = 'A190597';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[9] = 'A190598';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[10] = 'A054055';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[11] = 'A190599';
$oeis_anum[0]->{'maximum'}->{'unrounded'}->[12] = 'A190600';
# OEIS-Catalogue: A190592 extract_type=maximum radix=3
# OEIS-Catalogue: A190593 extract_type=maximum radix=4
# OEIS-Catalogue: A190594 extract_type=maximum radix=5
# OEIS-Catalogue: A190595 extract_type=maximum radix=6
# OEIS-Catalogue: A190596 extract_type=maximum radix=7
# OEIS-Catalogue: A190597 extract_type=maximum radix=8
# OEIS-Catalogue: A190598 extract_type=maximum radix=9
# OEIS-Catalogue: A054055 extract_type=maximum
# OEIS-Catalogue: A190599 extract_type=maximum radix=11
# OEIS-Catalogue: A190600 extract_type=maximum radix=12
$oeis_anum[0]->{'maximum'}->{'up'}
  = $oeis_anum[0]->{'maximum'}->{'unrounded'};
$oeis_anum[0]->{'maximum'}->{'down'}
  = $oeis_anum[0]->{'maximum'}->{'unrounded'};

$oeis_anum[0]->{'mean'}->{'down'}->[10] = 'A004426';
$oeis_anum[0]->{'mean'}->{'up'}->[10]   = 'A004427';
# OEIS-Catalogue: A004426 extract_type=mean round=down
# OEIS-Catalogue: A004427 extract_type=mean round=up

$oeis_anum[0]->{'geometric_mean'}->{'down'}->[10]    = 'A004428';
$oeis_anum[0]->{'geometric_mean'}->{'nearest'}->[10] = 'A004429';
$oeis_anum[0]->{'geometric_mean'}->{'up'}->[10]      = 'A004430';
# OEIS-Catalogue: A004428 extract_type=geometric_mean round=down
# OEIS-Catalogue: A004430 extract_type=geometric_mean round=up

# $oeis_anum[0]->{'median'}->{'down'}->[10] = '';
# $oeis_anum[0]->{'median'}->{'up'}->[10]   = ''
# # OEIS-Catalogue:  extract_type=median round=down
# # OEIS-Catalogue:  extract_type=median round=up

$oeis_anum[0]->{'mode'}->{'down'}->[2] = 'A115516';  # mode of bits
$oeis_anum[0]->{'mode'}->{'up'}->[2]   = 'A115517';
# OEIS-Catalogue: A115516 extract_type=mode round=down radix=2
# OEIS-Catalogue: A115517 extract_type=mode round=up radix=2
$oeis_anum[0]->{'mode'}->{'down'}->[10] = 'A115353';  # mode of decimal
# OEIS-Catalogue: A115353 extract_type=mode round=down

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->i_start]
    ->{$self->{'extract_type'}}
      ->{$self->{'round'}}
        ->[$self->{'radix'}];
}

#------------------------------------------------------------------------------

sub ith {
  my ($self, $i) = @_;
  ### DigitExtract ith(): $i

  $i = abs($i);
  if (_is_infinite($i)) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $radix = $self->{'radix'};
  my $extract_type = $self->{'extract_type'};

  if ($extract_type eq 'low') {
    return $i % $radix;
  }

  if ($extract_type eq 'second_low') {
    return int($i/$radix) % $radix;
  }

  my @digits;
  do {
    push @digits, $i % $radix;
    $i = int($i/$radix);
  } while ($i);

  if ($extract_type eq 'high') {
    return $digits[-1];
  }
  if ($extract_type eq 'second_high') {
    return @digits >= 2 ? $digits[-2] : 0;
  }

  if ($extract_type eq 'minimum') {
    return min(@digits);
  }
  if ($extract_type eq 'maximum') {
    return max(@digits);
  }

  if ($extract_type eq 'middle') {
    if ($self->{'round'} eq 'up') {
      return $digits[scalar(@digits)/2];
    }
    if ($self->{'round'} eq 'down') {
      return $digits[$#digits/2];
    }
    return ($digits[$#digits/2] + $digits[scalar(@digits)/2]) / 2;
  }
  if ($extract_type eq 'median') {
    # 6 digits 0,1,2,3,4,5 int(6/2)=3 is up
    # 6 digits 0,1,2,3,4,5 int((6-1)/2)=2 is down
    # 7 digits 0,1,2,3,4,5,6 int(7/2)=3
    # 7 digits 0,1,2,3,4,5,6 int((7-1)/2)=3 too
    @digits = sort {$a<=>$b} @digits;
    if ($self->{'round'} eq 'up') {
      return $digits[scalar(@digits)/2];
    }
    if ($self->{'round'} eq 'down') {
      return $digits[$#digits/2];
    }
    return ($digits[$#digits/2] + $digits[scalar(@digits)/2]) / 2;
  }
  if ($extract_type eq 'mode') {
    my @count;
    my $max_count = 0;
    foreach my $digit (@digits) {
      if (++$count[$digit] > $max_count) {
        $max_count = $count[$digit];
      }
    }
    my $sum = 0;
    my $sumcount = 0;
    my $last = 0;
    foreach my $digit (0 .. $#count) {
      if (($count[$digit]||0) == $max_count) {
        if ($self->{'round'} eq 'down') {
          return $digit;
        }
        $sum += $digit; $sumcount++;
        $last = $digit;
      }
    }
    if ($self->{'round'} eq 'up') {
      return $last;
    }
    return $sum/$sumcount;
  }

  my $ret;
  if ($extract_type eq 'mean') {
    $ret = List::Util::sum(@digits) / scalar(@digits);

  } elsif ($extract_type eq 'geometric_mean') {
    $ret = (List::Util::reduce {$a*$b} @digits) ** (1/scalar(@digits));

  } elsif ($extract_type eq 'quadratic_mean') {
    $ret = sqrt(List::Util::sum(map{$_*$_}@digits)/scalar(@digits));

  } else {
    die "Unrecognised extract_type: ",$extract_type;
  }

  if ($self->{'round'} eq 'down') {
    return int($ret);
  }
  if ($self->{'round'} eq 'up') {
    my $int = int($ret);
    return $int + ($ret != int($ret));
  }
  return $ret;
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::MathImageDigitExtract -- one of the digits of integers 0 upwards

=head1 SYNOPSIS

 use Math::NumSeq::MathImageDigitExtract;
 my $seq = Math::NumSeq::MathImageDigitExtract->new (extract_type => 'median');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

Extract one of the digits from the index i.  C<extract_type> (a string) can
be

    "low"               least significant digit
    "high"              most significant digit
    "second_low"        second least significant digit
    "second_high"       second most significant digit
    "middle"            middle digit
    "minimum"           smallest digit
    "maximum"           largest digit
    "mean"              average sum/n
    "geometric_mean"    nthroot(product)
    "quadratic_mean"    sqrt(sumsquares/n)
    "median"            middle digit when sorted
    "mode"              most frequent digit

For "middle" and "median" when there's an even number of digits the average
(mean) of the two middle ones is returned, or the C<round> parameter can be
"up" or "down" to go to the more/less significant for the middle or the
higher/lower for the median.

For the averages the result is a fractional value in general, but the
C<round> parameter "up" or "down can round to the next integer.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::MathImageDigitExtract-E<gt>new (length =E<gt> $integer)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the C<$i>'th value from the sequence.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Digit>

=cut
