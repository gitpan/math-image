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



# A010751 runs incr then decr



package App::MathImage::NumSeq::Runs;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 85;

use Math::NumSeq 21; # v.21 for oeis_anum field
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

# use constant description => Math::NumSeq::__('...');
use constant i_start => 1;
use constant characteristic_smaller => 1;
use constant characteristic_increasing => 0;

# d = -1/2 + sqrt(2 * $n + -3/4)
#   = (sqrt(8*$n-3) - 1)/2

use constant parameter_info_array =>
  [
   {
    name    => 'runs_type',
    display => Math::NumSeq::__('Runs Type'),
    type    => 'enum',
    default => '0toN',
    choices => ['0toN','1toN',
                'Nto0','Nto1',
                '0toNinc',
                'Nrep',
                'N+1rep',
               ],
    # description => Math::NumSeq::__(''),
   },
  ];

# cf A049581 diagonals absdiff, abs(x-y) not plain runs
#
my %runs_type_data
  = ('0toN' => { i_start    => 0,
                 value      => -1, # initial
                 values_min => 0,
                 limit      => 1,
                 vstart     => 0,
                 vstart_inc => 0,
                 value_inc  => 1,
                 c          => 1, # initial
                 count      => 0,
                 count_inc  => 1,
                 oeis_anum  => 'A002262',
                 # OEIS-Catalogue: A002262 runs_type=0toN
               },

     '1toN' => { value      => 0, # initial
                 values_min => 1,
                 limit      => 1,
                 vstart     => 1,
                 vstart_inc => 0,
                 value_inc  => 1,
                 c          => 1, # initial
                 count      => 0,
                 count_inc  => 1,
                 oeis_anum  => 'A002260',  # 1 to N, is 0toN + 1
                 # OEIS-Catalogue: A002260 runs_type=1toN
               },
     '1to2N' => { value      => 0, # initial
                  values_min => 1,
                  limit      => 1,
                  vstart     => 1,
                  vstart_inc => 0,
                  value_inc  => 1,
                  c          => 2, # initial
                  count      => 1,
                  count_inc  => 2,
                  oeis_anum  => 'A074294',
                  # OEIS-Catalogue: A074294 runs_type=1to2N
                },
     'Nto0' => { value      => 1, # initial
                 values_min => 0,
                 vstart     => 0,
                 vstart_inc => 1,
                 value_inc  => -1,
                 c          => 1, # initial
                 count      => 0,
                 count_inc  => 1,
                 oeis_anum  => 'A025581',
                 # OEIS-Catalogue: A025581 runs_type=Nto0
               },
     'Nto1' => { value      => 2, # initial
                 values_min => 1,
                 vstart     => 1,
                 vstart_inc => 1,
                 value_inc  => -1,
                 c          => 1, # initial
                 count      => 0,
                 count_inc  => 1,
                 oeis_anum  => 'A004736',
                 # OEIS-Catalogue: A004736 runs_type=Nto1
               },
     'Nrep' => { i_start    => 0,
                 value      => 1,
                 values_min => 1,
                 value_inc  => 0,
                 vstart     => 1,
                 vstart_inc => 1,
                 limit      => 1,
                 c          => 1, # initial
                 count      => 0,
                 count_inc  => 1,
                 oeis_anum  => 'A002024', # N appears N times
                 # OEIS-Catalogue: A002024 runs_type=Nrep
               },
     'N+1rep' => { i_start    => 0,
                   value      => 0,
                   values_min => 0,
                   value_inc  => 0,
                   vstart     => 0,
                   vstart_inc => 1,
                   limit      => 1,
                   c          => 1, # initial
                   count      => 0,
                   count_inc  => 1,
                   oeis_anum  => 'A003056', # N appears N+1 times
                   # OEIS-Catalogue: A003056 runs_type=N+1rep
                 },
     'rep3' => { i_start    => 0,
                 value      => 0,
                 values_min => 0,
                 value_inc  => 0,
                 vstart     => 0,
                 vstart_inc => 1,
                 limit      => 1,
                 c          => 3, # initial
                 count      => 2,
                 count_inc  => 0,
                 oeis_anum  => 'A002264', # N appears 3 times
                 # OEIS-Catalogue: A002264 runs_type=rep3
               },
     '0toNinc' => { value      => -1,
                    values_min => 0,
                    value_inc  => 1,
                    vstart     => 0,
                    vstart_inc => 1,
                    limit      => 1,
                    c          => 1, # initial
                    count      => 0,
                    count_inc  => 1,
                    oeis_anum  => 'A051162',
                    # OEIS-Catalogue: A051162 runs_type=0toNinc
                  },
    );
sub rewind {
  my ($self) = @_;
  $self->{'runs_type'} ||= '0toN';
  %$self = (%$self,
            i => 0,
            %{$runs_type_data{$self->{'runs_type'}}});
}

sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  if (--$self->{'c'} >= 0) {
    return ($i,
            ($self->{'value'} += $self->{'value_inc'}));
  } else {
    $self->{'c'} = ($self->{'count'} += $self->{'count_inc'});
    return ($i,
            ($self->{'value'} = ($self->{'vstart'} += $self->{'vstart_inc'})));
  }
}

sub ith {
  my ($self, $i) = @_;
  ### Runs ith(): $i

  if ($i < 0) {
    return undef;
  }
  if ($self->{'runs_type'} eq 'Nto0' || $self->{'runs_type'} eq 'Nto1') {
    # d-(i-(d-1)*d/2)
    #   = d-i+(d-1)*d/2
    #   = d*(1+(d-1)/2) - i
    #   = d*((d+1)/2) - i
    #   = (d+1)d/2 - i

    my $d = int((sqrt(8*int($i)+1) + 1) / 2);
    ### $d
    ### base: ($d-1)*$d/2
    ### rem: $i - ($d-1)*$d/2
    return -$i + ($d+1)*$d/2 - 1 + $self->{'values_min'};

  } elsif ($self->{'runs_type'} eq 'Nrep'
           || $self->{'runs_type'} eq 'N+1rep') {
    return int((sqrt(8*int($i)+1) - 1) / 2) + $self->{'values_min'};

  } elsif ($self->{'runs_type'} eq '0toNinc') {
    # i-(d-1)d/2 + d
    #   = i-((d-1)d/2 - d)
    #   = i-(d-3)d/2
    my $d = int((sqrt(8*int($i)+1) + 1) / 2);
    return $i - ($d-3)*$d/2 - 1;

  } elsif ($self->{'runs_type'} eq 'rep3') {
    return int($i/3);

  } elsif ($self->{'runs_type'} eq '1to2N') {
    # N = (d^2 + d)
    #   = (($d + 1)*$d)
    # d = -1/2 + sqrt(1 * $n + 1/4)
    #   = (-1 + 2*sqrt($n + 1/4)) / 2
    #   = (-1 + sqrt(4*$n + 1)) / 2
    #   = (sqrt(4*$n + 1) - 1) / 2

    my $d = int((sqrt(4*int($i)+1) - 1) / 2);

    ### $d
    ### base: ($d-1)*$d/2
    ### rem: $i - ($d-1)*$d/2

    return $i - ($d+1)*$d + $self->{'vstart'};

  } else {
    my $d = int((sqrt(8*int($i)+1) + 1) / 2);

    ### $d
    ### base: ($d-1)*$d/2
    ### rem: $i - ($d-1)*$d/2

    return $i - ($d-1)*$d/2 + $self->{'vstart'};
  }
}

sub pred {
  my ($self, $value) = @_;
  ### Runs pred(): $value

  unless ($value == int($value)) {
    return 0;
  }
  if (defined $self->{'values_min'}) {
    return ($value >= $self->{'values_min'});
  } else {
    return ($value <= $self->{'values_max'});
  }
}

1;
__END__

=for stopwords Ryde

=head1 NAME

App::MathImage::NumSeq::Runs -- runs of consecutive integers

=head1 SYNOPSIS

 use App::MathImage::NumSeq::Runs;
 my $seq = App::MathImage::NumSeq::Runs->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

A sequence 0,0,1,0,1,2,0,1,2,3,etc of increasing runs of integers 0 to N.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::Runs-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs in the sequence.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut

# Local variables:
# compile-command: "math-image --values=Runs"
# End:
