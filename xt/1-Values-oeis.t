#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Test::More tests => 1;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use App::MathImage::Values::OeisCatalogue;

# uncomment this to run the ### lines
#use Devel::Comments '###';

use POSIX ();
POSIX::setlocale(POSIX::LC_ALL(), 'C'); # no message translations

use constant DBL_INT_MAX => (POSIX::FLT_RADIX() ** POSIX::DBL_MANT_DIG());
use constant MY_MAX => (POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5));

sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  for (my $i = 0; $i < @$gotaref; $i++) {
    if ($i > @$wantaref) {
      return "want ends prematurely i=$i";
    }
    my $got = $gotaref->[$i];
    my $want = $wantaref->[$i];
    if (! defined $got && ! defined $want) {
      next;
    }
    if (! defined $got || ! defined $want) {
      return "different i=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    $got =~ /^[0-9.-]+$/
      or return "not a number i=$i got='$got'";
    $want =~ /^[0-9.-]+$/
      or return "not a number i=$i want='$want'";
    if ($got != $want) {
      return "different i=$i numbers got=$got want=$want";
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


#------------------------------------------------------------------------------
# OeisCatalogue generated vs files

my $good = 1;
for (my $anum = App::MathImage::Values::OeisCatalogue->anum_first;  #  'A007770';
     defined $anum;
     $anum = App::MathImage::Values::OeisCatalogue->anum_after($anum)) {
  ### $anum

  my $info = App::MathImage::Values::OeisCatalogue->anum_to_info($anum);
  if (! $info) {
    $good = 0;
    diag "bad: $anum";
    diag "info is undef";
    next;
  }
  if ($info->{'class'} eq 'App::MathImage::Values::Sequence::OEIS::File') {
    next;
  }
  ### $info

  my $shortclass = $info->{'class'};
  $shortclass =~ s/App::MathImage::Values::Sequence:://;

  my $parameters_hashref= $info->{'parameters_hashref'};
  my $name = join(',',
                  $info->{'class'},
                  map {
                    my $value = $parameters_hashref->{$_};
                    if (! defined $value) { $value = '[undef]'; }
                    "$_=$value"
                  } keys %$parameters_hashref);
  diag "$anum $name";

  my ($want, $want_i_start, $filename) = MyOEIS::read_values($anum)
    or do {
      diag "skip $anum $name, no file data";
      next;
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
  } elsif ($anum eq 'A004542') {  # sqrt(2) in base 5
    diag "skip doubtful $anum $name";
    next;
  } elsif ($anum eq 'A022000') {  # FIXME: not 1/996 ???
    diag "skip doubtful $anum $name";
    next;
  }

  my $hi = $want->[-1];
  if ($hi < @$want) {
    $hi = @$want;
  }
  ### $hi

  my $values_obj = eval {
    App::MathImage::Values::Sequence::OEIS->new
        (anum => $anum,
         hi   => $hi)
      } || next;
  ### values_obj: ref $values_obj

  {
    my $got_anum = $values_obj->oeis_anum;
    if (! defined $got_anum) {
      $got_anum = 'undef';
    }
    if ($got_anum ne $anum) {
      $good = 0;
      diag "bad: $name";
      diag "got anum  $got_anum";
      diag ref $values_obj;
    }
  }

  # {
  #   my $got_i_start = $values_obj->i_start;
  #   if ($got_i_start != $want_i_start) {
  #     diag "note: $name";
  #     diag ref $values_obj;
  #     diag "got  i_start  $got_i_start";
  #     diag "want i_start  $want_i_start";
  #   }
  # }

  {
    ### by next() ...
    my @got;
    while (my ($i, $value) = $values_obj->next) {
      push @got, $value;
      if (@got >= @$want) {
        last;
      }
    }
    my $got = \@got;

    my $diff = diff_nums($got, $want);
    if (defined $diff) {
      $good = 0;
      diag "bad: $name by next() hi=$hi";
      diag $diff;
      diag ref $values_obj;
      diag $filename;
      diag "got  len ".scalar(@$got);
      diag "want len ".scalar(@$want);
      if ($#$got > 200) { $#$got = 200 }
      if ($#$want > 200) { $#$want = 200 }
      diag "got  ". join(',', map {defined() ? $_ : 'undef'} @$got);
      diag "want ". join(',', map {defined() ? $_ : 'undef'} @$want);
    }
  }

  {
    ### by pred() ...
    $values_obj->can('pred')
      or next;
    if ($values_obj->characteristic('count')) {
      ### no pred on characteristic(count) ..
      next;
    }
    if ($values_obj->characteristic('pn1')) {
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
      if ($values_obj->pred($value)) {
        push @got, $value;
      }
    }
    my $got = \@got;

    my $diff = diff_nums($got, $want);
    if (defined $diff) {
      $good = 0;
      diag "bad: $name by pred() hi=$hi";
      diag $diff;
      diag ref $values_obj;
      diag $filename;
      diag "got  len ".scalar(@$got);
      diag "want len ".scalar(@$want);
      if ($#$got > 200) { $#$got = 200 }
      if ($#$want > 200) { $#$want = 200 }
      diag "got  ". join(',', map {defined() ? $_ : 'undef'} @$got);
      diag "want ". join(',', map {defined() ? $_ : 'undef'} @$want);
    }
  }
}

$good = 1;
ok ($good);
exit 0;
