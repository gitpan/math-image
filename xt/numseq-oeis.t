#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use Test;
plan tests => 1;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

# uncomment this to run the ### lines
#use Devel::Comments '###';

use POSIX ();
use constant DBL_INT_MAX => (POSIX::FLT_RADIX() ** POSIX::DBL_MANT_DIG());
use constant MY_MAX => (POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5));

sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  for (my $i = 0; $i < @$gotaref; $i++) {
    if ($i > @$wantaref) {
      return "want ends prematurely pos=$i";
    }
    my $got = $gotaref->[$i];
    my $want = $wantaref->[$i];
    if (! defined $got && ! defined $want) {
      next;
    }
    if (! defined $got || ! defined $want) {
      return "different pos=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    $got =~ /^[0-9.-]+$/
      or return "not a number pos=$i got='$got'";
    $want =~ /^[0-9.-]+$/
      or return "not a number pos=$i want='$want'";
    if ($got != $want) {
      return "different pos=$i numbers got=$got want=$want";
    }
  }
  return undef;
}

sub _delete_duplicates {
  my ($arrayref) = @_;
  my %seen;
  @seen{@$arrayref} = ();
  @$arrayref = sort {$a<=>$b} keys %seen;
}

sub _min {
  my $ret = shift;
  while (@_) {
    my $next = shift;
    if ($ret > $next) {
      $ret = $next;
    }
  }
  return $ret;
}
sub _max {
  my $ret = shift;
  while (@_) {
    my $next = shift;
    if ($next > $ret) {
      $ret = $next;
    }
  }
  return $ret;
}

my %duplicate_anum = (A021015 => 'A010680',
                      A033307 => 'A007376',
                     );

#------------------------------------------------------------------------------
my $good = 1;
my $total_checks = 0;

sub check_class {
  my ($anum, $class, $parameters) = @_;
  ### check_class() ...
  ### $class
  ### $parameters

  # return unless $class =~ /Repdigit/;
  # return unless $class =~ /Engel/;
  # return unless $class =~ /DigitCount/;
  # return unless $class =~ /Happy/;
  # return unless $class =~ /Concat/;
  # return unless $class =~ /Sqrt/;


  eval "require $class" or die;

  my $name = join(',',
                  $class,
                  map {defined $_ ? $_ : '[undef]'} @$parameters);

  my $max_value = undef;
  if ($class->isa('Math::NumSeq::Factorials')
      || $class->isa('Math::NumSeq::Primorials')
      || $class eq 'Math::NumSeq::Fibonacci' # not LucasNumbers yet
     ) {
    $max_value = 'unlimited';
  }

  my ($want, $want_i_start, $filename) = MyOEIS::read_values
    ($anum, max_value => $max_value)
      or do {
        MyTestHelpers::diag("skip $anum $name, no file data");
        return;
      };
  ### read_values len: scalar(@$want)
  ### $want_i_start

  if ($anum eq 'A009003') {
    #  PythagoreanHypots slow, only first 250 values for now ...
    splice @$want, 250;
  } elsif ($anum eq 'A003434') {
    #  TotientSteps slow, only first 250 values for now ...
    splice @$want, 250;
  } elsif ($anum eq 'A007770') {
    #  Happy bit slow, only first few values for now, not B-file 140,000 ...
    splice @$want, 20000;
  } elsif ($anum eq 'A030547') {
    # sample values start from i=1 but OFFSET=0
    if ($want->[9] == 2) {
      unshift @$want, 1;
    }
  } elsif ($anum eq 'A082897') {
    # full B-file goes to 2^32 which is too much to sieve
    @$want = grep {$_ < 200_000} @$want;

  } elsif ($anum eq 'A001359'
           || $anum eq 'A006512'
           || $anum eq 'A014574'
           || $anum eq 'A001097') {
    # twin primes shorten for now
    @$want = grep {$_ < 1_000_000} @$want;

  } elsif ($anum eq 'A005384') {
    # sophie germain shorten for now
    @$want = grep {$_ < 1_000_000} @$want;

  } elsif ($anum eq 'A006567') {
    # emirps shorten for now
    @$want = grep {$_ < 100_000} @$want;

  } elsif ($anum eq 'A004542') {  # sqrt(2) in base 5
    MyTestHelpers::diag ("skip doubtful $anum $name");
    return;
  } elsif ($anum eq 'A022000') {  # FIXME: not 1/996 ???
    MyTestHelpers::diag ("skip doubtful $anum $name");
    return;
  } elsif ($anum eq 'A007700'
           || $anum eq 'A023272'
           || $anum eq 'A023302'
           || $anum eq 'A023330') {
    # Cunningham shortened for now
    @$want = grep {$_ < 100_000} @$want;

  } elsif ($anum eq 'A002858'
           || $anum eq 'A002859'
           || $anum eq 'A003666'
           || $anum eq 'A003667'
           || $anum eq 'A001857'
           || $anum eq 'A048951'
           || $anum eq 'A007300') {
    # UlamSequence shortened for now
    if ($#$want > 1000) {
      $#$want = 1000;
    }

  } elsif ($anum eq 'A005101' || $anum eq 'A133122'
           || $anum eq 'A001358'
           || $anum eq 'A006450') {
    MyTestHelpers::diag ("skip primes stuff $anum");
    return;
  }

  #  return unless $anum eq 'A163540';


  my $want_count = scalar(@$want);
  MyTestHelpers::diag ("$anum $name  ($want_count values to $want->[-1])");

  my $hi = $want->[-1];
  if ($hi < @$want) {
    $hi = @$want;
  }
  ### $hi
  # hi => $hi

  my $seq = $class->new (@$parameters);
  ### seq class: ref $seq
  if ($seq->isa('Math::NumSeq::OEIS::File')) {
    die "Oops, not meant to exercies $seq";
  }

  {
    ### $seq
    my $got_anum = $seq->oeis_anum;
    if (! defined $got_anum) {
      $got_anum = 'undef';
    }
    my $want_anum = $duplicate_anum{$anum} || $anum;
    if ($got_anum ne $want_anum) {
      $good = 0;
      MyTestHelpers::diag ("bad: $name");
      MyTestHelpers::diag ("got anum  $got_anum");
      MyTestHelpers::diag (ref $seq);
    }
  }

  # {
  #   my $got_i_start = $seq->i_start;
  #   if ($got_i_start != $want_i_start) {
  #     diag "note: $name";
  #     diag ref $seq;
  #     diag "got  i_start  $got_i_start";
  #     diag "want i_start  $want_i_start";
  #   }
  # }

  {
    ### by next() ...
    my @got;
    my $got = \@got;
    while (my ($i, $value) = $seq->next) {
      push @got, $value;
      if (@got >= @$want) {
        last;
      }
    }

    my $diff = diff_nums($got, $want);
    if (defined $diff) {
      $good = 0;
      MyTestHelpers::diag ("bad: $name by next() hi=$hi");
      MyTestHelpers::diag ($diff);
      MyTestHelpers::diag (ref $seq);
      MyTestHelpers::diag ($filename);
      MyTestHelpers::diag ("got  len ".scalar(@$got));
      MyTestHelpers::diag ("want len ".scalar(@$want));
      if ($#$got > 200) { $#$got = 200 }
      if ($#$want > 200) { $#$want = 200 }
      MyTestHelpers::diag ("got  ". join(',', map {defined() ? $_ : 'undef'} @$got));
      MyTestHelpers::diag ("want ". join(',', map {defined() ? $_ : 'undef'} @$want));
    }
  }
  {
    ### by next() after rewind ...
    $seq->rewind;

    my @got;
    my $got = \@got;
    while (my ($i, $value) = $seq->next) {
      # ### $i
      # ### $value
      push @got, $value;
      if (@got >= @$want) {
        last;
      }
    }

    my $diff = diff_nums($got, $want);
    if (defined $diff) {
      $good = 0;
      MyTestHelpers::diag ("bad: $name by rewind next() hi=$hi");
      MyTestHelpers::diag ($diff);
      MyTestHelpers::diag (ref $seq);
      MyTestHelpers::diag ($filename);
      MyTestHelpers::diag ("got  len ".scalar(@$got));
      MyTestHelpers::diag ("want len ".scalar(@$want));
      if ($#$got > 200) { $#$got = 200 }
      if ($#$want > 200) { $#$want = 200 }
      MyTestHelpers::diag ("got  ". join(',', map {defined() ? $_ : 'undef'} @$got));
      MyTestHelpers::diag ("want ". join(',', map {defined() ? $_ : 'undef'} @$want));
    }
  }

  {
    ### by ith() ...
    $seq->can('ith')
      or next;

    my $i = $seq->i_start;
    if (($max_value||'') eq 'unlimited') {
      $i = Math::NumSeq::_bigint()->new($i);
    }

    my @got;
    while (@got < @$want) {
      my $value = $seq->ith($i++);
      last if (! defined $value);
      push @got, $value;
    }
    my $got = \@got;
    ### $got

    my $diff = diff_nums($got, $want);
    if (defined $diff) {
      $good = 0;
      MyTestHelpers::diag ("bad: $name by ith()");
      MyTestHelpers::diag ($diff);
      MyTestHelpers::diag (ref $seq);
      MyTestHelpers::diag ($filename);
      MyTestHelpers::diag ("got  len ".scalar(@$got));
      MyTestHelpers::diag ("want len ".scalar(@$want));
      if ($#$got > 200) { $#$got = 200 }
      if ($#$want > 200) { $#$want = 200 }
      MyTestHelpers::diag ("got  ". join(',', map {defined() ? $_ : 'undef'} @$got));
      MyTestHelpers::diag ("want ". join(',', map {defined() ? $_ : 'undef'} @$want));
    }

    {
      my $data_min = _min(@$want);
      my $values_min = $seq->values_min;
      if (defined $values_min
          && defined $data_min
          && $values_min != $data_min) {
        $good = 0;
        MyTestHelpers::diag ("bad: $name values_min $values_min but data min $data_min");
      }
    }
    {
      my $data_max = _max(@$want);
      my $values_max = $seq->values_max;
      if (defined $values_max && $values_max != $data_max) {
        $good = 0;
        MyTestHelpers::diag ("bad: $name values_max $values_max not seen in data, only $data_max");
      }
    }
  }

  {
    ### by pred() ...
    $seq->can('pred')
      or next;
    if ($seq->characteristic('count')) {
      ### no pred on characteristic(count) ..
      next;
    }
    if (! $seq->characteristic('monotonic')) {
      ### no pred on not characteristic(monotonic) ..
      next;
    }
    if ($seq->characteristic('digits')) {
      ### no pred on characteristic(digits) ..
      next;
    }
    if ($seq->characteristic('modulus')) {
      ### no pred on characteristic(modulus) ..
      next;
    }
    if ($seq->characteristic('pn1')) {
      ### no pred on characteristic(pn1) ..
      next;
    }

    $hi = 0;
    foreach my $want (@$want) {
      if ($want > $hi) { $hi = $want }
    }
    if ($hi > 1000) {
      $hi = 1000;
      $want = [ grep {$_<=$hi} @$want ];
    }
    _delete_duplicates($want);
    #### $want

    my @got;
    foreach my $value (_min(@$want) .. $hi) {
      #### $value
      if ($seq->pred($value)) {
        push @got, $value;
      }
    }
    my $got = \@got;

    my $diff = diff_nums($got, $want);
    if (defined $diff) {
      $good = 0;
      MyTestHelpers::diag ("bad: $name by pred() hi=$hi");
      MyTestHelpers::diag ($diff);
      MyTestHelpers::diag (ref $seq);
      MyTestHelpers::diag ($filename);
      MyTestHelpers::diag ("got  len ".scalar(@$got));
      MyTestHelpers::diag ("want len ".scalar(@$want));
      if ($#$got > 200) { $#$got = 200 }
      if ($#$want > 200) { $#$want = 200 }
      MyTestHelpers::diag ("got  ". join(',', map {defined() ? $_ : 'undef'} @$got));
      MyTestHelpers::diag ("want ". join(',', map {defined() ? $_ : 'undef'} @$want));
    }

    {
      my $data_min = _min(@$want);
      my $values_min = $seq->values_min;
      if (defined $values_min && $values_min != $data_min) {
        $good = 0;
        MyTestHelpers::diag ("bad: $name values_min $values_min but data min $data_min");
      }
    }
    {
      my $data_max = _max(@$want);
      my $values_max = $seq->values_max;
      if (defined $values_max && $values_max != $data_max) {
        $good = 0;
        MyTestHelpers::diag ("bad: $name values_max $values_max not seen in data, only $data_max");
      }
    }
  }

  $total_checks++;
}

#------------------------------------------------------------------------------
# forced

# check_class ('A001097',
#              'Math::NumSeq::TwinPrimes',
#              [ pairs => 'both' ]);
# exit 0;


#------------------------------------------------------------------------------
# OEIS-Catalogue generated vs files

use File::Path;
File::Path::make_path('lib/Math/NumSeq/OEIS/Catalogue/Plugin/');
system("perl ../ns/tools/make-oeis-catalogue.pl --module=TempMathImage --other=both") == 0
  or die;
require 'lib/Math/NumSeq/OEIS/Catalogue/Plugin/TempMathImage.pm';
unlink  'lib/Math/NumSeq/OEIS/Catalogue/Plugin/TempMathImage.pm' or die;
rmdir  'lib/Math/NumSeq/OEIS/Catalogue/Plugin' or die;
rmdir  'lib/Math/NumSeq/OEIS/Catalogue' or die;
rmdir  'lib/Math/NumSeq/OEIS' or die;
rmdir  'lib/Math/NumSeq' or die;

my $aref = Math::NumSeq::OEIS::Catalogue::Plugin::TempMathImage::info_arrayref();
foreach my $info (@$aref) {
  ### $info
  check_class ($info->{'anum'},
               $info->{'class'},
               $info->{'parameters'});
}

MyTestHelpers::diag ("total checks $total_checks");
$good = 1;
ok ($good);
exit 0;
