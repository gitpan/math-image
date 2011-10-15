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

# math-image --values=JugglerSteps

package App::MathImage::NumSeq::JugglerSteps;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 77;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Number of steps to reach 1 in the Juggler sqrt sequence.');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant values_min => 0;
use constant i_start => 1;

use constant parameter_info_array =>
  [
   { name    => 'step_type',
     display => Math::NumSeq::__('Step Type'),
     type    => 'enum',
     default => 'both',
     choices => ['up','down','both'],
     description => Math::NumSeq::__('Which steps to count, the n^(3/2) ups, the n^(1/2) downs, or both.'),
   },
   { name    => 'algorithm_type',
     display => Math::NumSeq::__('Algorithm Type'),
     type    => 'enum',
     default => '1/2-3/2',
     choices => ['1/2-3/2','2/3-3/2','3/4-4/3'],
     description => Math::NumSeq::__('Algorithm type, as even power and odd power.'),
   },
   # { name    => 'round_type',
   #   display => Math::NumSeq::__('Rounding Type'),
   #   type    => 'enum',
   #   default => 'floor',
   #   choices => ['floor','round'],
   #   description => Math::NumSeq::__('Rounding type.'),
   # },
  ];

# eg. 78901 peaks at about 370,000 digits ...
#
# cf
#    A094683 - iteration, ie. n^(1/2) or n^(3/2)
#    A094670 - smallest requiring n iterations
#    A094679 - start requiring n iterations
#    A094684 - records in plain seq
#    A094698 - num steps where new record
#    A143745 - next largest
#    A094716 - largest value in trajectory starting from n
#    A094778 - dropping time from odd
#    A094804 - num primes in trajectory
#    A094819 - steps starting 10^n
#    A143742 - producing larger value
#    A143743 - num digits
#    A143744 - steps next largest
#
#    A007321 - rounded steps
#    A094685 - rounded iteration, ie. single powering
#    A094693 - rounded records
#    A094725 - rounded largest value in trajectory starting from n
#    A095910 - rounded records
#    A095911 - rounded num steps to records
#
#    A095396 - 2/3-3/2 iteration
#    A095397 - 2/3-3/2 largest in trajectory starting from n
#    A095398 - 2/3-3/2 steps
#
#    A095399 - 3/4-4/3 iteration
#    A095400 - 3/4-4/3 largest value in trajectory starting from n
#    A095401 - 3/4-4/3 steps
#
# up   => '',
# # OEIS-Catalogue: A step_type=up
#
# down => '',
# # OEIS-Catalogue: A step_type=down
#
my %oeis_anum = (
                 # both up and down
                 both => { '1/2-3/2' => 'A007320',
                           # OEIS-Catalogue: A007320

                           '2/3-3/2' => 'A095398',
                           # OEIS-Catalogue: A095398 algorithm_type=2/3-3/2
                           '3/4-4/3' => 'A095401',
                           # OEIS-Catalogue: A095401 algorithm_type=3/4-4/3
                         },
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{$self->{'step_type'}}->{$self->{'algorithm_type'}};
}

sub rewind {
  my ($self) = @_;
  ($self->{'epow'},$self->{'eroot'}, $self->{'opow'},$self->{'oroot'})
    = ($self->{'algorithm_type'} =~ m{(\d+)/(\d+)-(\d+)/(\d+)});
  $self->{'i'} = i_start();
}

use constant _UV_LIMIT => do {
  my $limit = ~0;
  my $bits = 0;
  while ($limit) {
    $bits++;
    $limit >>= 1;
  }
  $bits = int($bits / 3);
  (1 << $bits) - 1
};
use constant::defer _bigint => sub {
  require Math::BigInt;
  eval { Math::BigInt->import (try => 'GMP') };
  return 'Math::BigInt';
};

use vars '%cache';
my $tempdir;
use constant::defer _cache => sub {
  require SDBM_File;
  require File::Temp;
  $tempdir = File::Temp->newdir;
  ### $tempdir
  ### tempdir: $tempdir->dirname
  tie (%cache, 'SDBM_File',
       File::Spec->catfile ($tempdir->dirname, "cache"),
       Fcntl::O_RDWR()|Fcntl::O_CREAT(),
       0666)
    or die "Couldn't tie SDBM file 'filename': $!; aborting";

  END {
    if ($tempdir) {
      ### unlink cache ...
      untie %cache;
      my $dirname = $tempdir->dirname;
      unlink File::Spec->catfile ($dirname, "cache.pag");
      unlink File::Spec->catfile ($dirname, "cache.dir");
    }
  };
  END {
    if ($tempdir) {
      ### cache diagnostics ...
      my $count = 0;
      while (each %cache) {
        $count++;
      }
      untie %cache;
      my $dirname = $tempdir->dirname;
      print "cache final $count file sizes cache.pag ",
        (-s File::Spec->catfile($dirname,"cache.pag")),
          " cache.dir ",
            (-s File::Spec->catfile($dirname,"cache.dir")),
              "\n";
    }
  };
  return \%cache;
};
my $cache_key = 0;
sub cache_key {
  my $params = join ('.', "CacheKey",@_);
  ### $params
  if (my $c = _cache()->{$params}) {
    return $c;
  }
  return sprintf '%X.', (_cache()->{$params} = $cache_key++);
}

my %cache_upto;
sub next {
  my ($self) = @_;
  ### JugglerSteps next(): $self->{'i'}
  my $i = $self->{'i'}++;
  my $pkey = ($self->{'pkey'} ||= do {
    ### make pkey ...
    my $k = cache_key('JugglerSteps',
                      $self->{'algorithm_type'},
                      $self->{'step_type'});
    $cache_upto{$k} ||= 0;
    $k
  });
  my $key_i = $pkey . $i;
  ### $pkey
  ### $key_i
  ### cache upto: "$cache_upto{$pkey} cf i=$i"
  if ($i < $cache_upto{$pkey}) {
    ### fetch from cache ...
    return ($i, $cache{$key_i});
  } else {
    ### store to cache ...
    my $ret = $self->ith($i);
    $cache{$key_i} = $ret;
    $cache_upto{$pkey} = $i;
    ### cache upto now: $cache_upto{$pkey}
    return ($i, $ret);
  }
}

sub ith {
  my ($self, $i) = @_;
  ### JugglerSteps ith(): $i
  my $count = 0;
  if ($i <= 1) {
    return $count;
  }
  my $step_type = $self->{'step_type'};
  my $count_up = ($step_type ne 'down');
  my $count_down = ($step_type ne 'up');

  if ($self->{'algorithm_type'} eq '1/2-3/2') {
    ### 1/2 and 3/2 ...
    for (;;) {
      if ($i & 1) {
        ### 1/2 odd: $i

        if ($i > _UV_LIMIT) {
          # stringize to avoid UV to Math::BigInt::GMP bug in its version 1.37
          $i = _bigint()->new("$i");
          ### using bigint: "$i"
          for (;;) {
            if ($i & 1) {
              ### 1/2 odd: "$i"
              $i->bmul($i*$i);
              $count += $count_up;
            } else {
              ### 1/2 even: "$i"
              $count += $count_down;
            }
            $i->bsqrt();
            if ($i <= 1) {
              return $count;
            }
            ### now: "$i  count=$count"
          }
        }


        $i *= $i*$i;
        $count += $count_up;
      } else {
        ### even: $i
        $count += $count_down;
      }
      $i = int(sqrt($i));
      if ($i <= 1) {
        return $count;
      }
      ### now: "$i  count=$count"
    }

  } else {
    ### general case: "$self->{'epow'}/$self->{'eroot'}-$self->{'opow'}/$self->{'oroot'}"
    # stringize to avoid Math::BigInt::GMP::_new(UV) bug in its version 1.37
    $i = _bigint()->new("$i");

    for (;;) {
      if ($i->is_odd) {
        ### odd: "$i"
        $i->bpow($self->{'opow'});
        $i->broot($self->{'oroot'});
        $count += $count_up;
      } else {
        ### even: "$i"
        $i->bpow($self->{'epow'});
        $i->broot($self->{'eroot'});
        $count += $count_down;
      }
      if ($i <= 1) {
        return $count;
      }
      ### now: "$i  count=$count"
    }
  }
}

sub pred {
  my ($self, $value) = @_;
  return ($value == int($value)
          && $value >= 0);
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::JugglerSteps -- steps in the juggler sqrt sequence

=head1 SYNOPSIS

 use Math::NumSeq::JugglerSteps;
 my $seq = Math::NumSeq::JugglerSteps->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The number of steps it takes to reach 1 by the Juggler sqrt sequence,

    n -> / floor(sqrt(n))      if n odd
         \ floor(sqrt(n*n*n))  if n even

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::JugglerSteps-E<gt>new ()>

=item C<$seq = Math::NumSeq::JugglerSteps-E<gt>new (step_type =E<gt> 'down')>

Create and return a new sequence object.

The optional C<step_type> parameter (a string) selects between

    "up"      upward steps sqrt(n^3)
    "down"    downward steps sqrt(n)
    "both"    both up and down, which is the default

=item C<$value = $seq-E<gt>ith($i)>

Return the number of steps to take C<$i> down to 1.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a step count.  This is simply C<$value
E<gt>= 0>.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
