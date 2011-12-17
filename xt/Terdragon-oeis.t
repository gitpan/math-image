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
BEGIN { plan tests => 5 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::MathImageTerdragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::MathImageTerdragonCurve->new;

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

my %dxdy_to_dir = ('2,0' => 0,
                   '1,1' => 1,
                   '-1,1' => 2,
                   '-2,0' => 3,
                   '-1,-1' => 4,
                   '1,-1' => 5);

# return 0 if X,Y's are straight, 2 if left, 1 if right
sub xy_turn_6 {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  my $prev_dx = $x - $prev_x;
  my $prev_dy = $y - $prev_y;
  my $dx = $next_x - $x;
  my $dy = $next_y - $y;

  my $prev_dir = $dxdy_to_dir{"$prev_dx,$prev_dy"};
  if (! defined $prev_dir) { die "oops, unrecognised $prev_dx,$prev_dy"; }

  my $dir = $dxdy_to_dir{"$dx,$dy"};
  if (! defined $dir) { die "oops, unrecognised $dx,$dy"; }

  return ($dir - $prev_dir) % 6;
}

sub xy_left_right {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  my $turn = xy_turn_6 ($prev_x,$prev_y, $x,$y, $next_x,$next_y);
  if ($turn == 2) {
    return 0; # left;
  }
  if ($turn == 4) {
    return 1; # right;
  }
  die "unrecognised turn $turn";
}

#------------------------------------------------------------------------------
# A080846 - turn 0=left, 1=right

{
  my $anum = 'A080846';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - 0,1 turns");
}

#------------------------------------------------------------------------------
# A060236 - turn 1=left, 2=right

{
  my $anum = 'A060236';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1)) + 1;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - 0,1 turns");
}

#------------------------------------------------------------------------------
# A038502 - taken mod 3 is 1=left, 2=right

{
  my $anum = 'A038502';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    @$bvalues = map { $_ % 3 } @$bvalues;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1)) + 1;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - taken mod 3 for 0,1 turns");
}

#------------------------------------------------------------------------------
# A026225 - positions of left turns

{
  my $anum = 'A026225';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      if (xy_left_right ($path->n_to_xy($n-1),
                         $path->n_to_xy($n),
                         $path->n_to_xy($n+1))
          == 0) {
        push @got, $n;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - left turns");
}

#------------------------------------------------------------------------------
# A026179 - positions of right turns

{
  my $anum = 'A026179';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    push @got, 1;     # extra 1 ...
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      if (xy_left_right ($path->n_to_xy($n-1),
                         $path->n_to_xy($n),
                         $path->n_to_xy($n+1))
          == 1) {
        push @got, $n;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - right turns");
}

#------------------------------------------------------------------------------
exit 0;
