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
use Test;
BEGIN { plan tests => 50 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::MathImageCellularRule;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

sub streq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      MyTestHelpers::diag ("differ: ", $a1->[0], ' ', $a2->[0]);
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

# A078176 something rule 225, but what ?


#------------------------------------------------------------------------------
# bignum rows

foreach my $elem ([ 'A001045',  28 ], # Jacobsthal
                  [ 'A110240',  30 ], # cf A074890 some strange form
                  [ 'A118108',  54 ],
                  [ 'A001317',  60 ], # Sierpinski triangle
                  [ 'A038183',  90 ],
                  [ 'A118101',  94 ],
                  [ 'A117998', 102 ],
                  [ 'A117999', 110 ],
                  [ 'A038184', 150 ],
                  [ 'A118171', 158 ],
                  [ 'A118173', 188 ],
                  [ 'A037576', 190 ],
                  [ 'A002450', 250 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($anum eq 'A001045') {  # Jacobsthal extra 0,1
      push @got, 0,1;
    }
    if ($anum eq 'A002450') {  # (4^n-1)/3 10101 extra 0 at start
      push @got, 0;
    }
    require Math::BigInt;
    my $y = 0;
    while (@got < @$bvalues) {
      my $b = Math::BigInt->new(0);
      foreach my $x (-$y .. $y) {
        my $bit = ($path->xy_to_n ($x, $y) ? 1 : 0);
        $b = 2*$b + $bit;
      }
      push @got, "$b";
      $y++;
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum bignum rows rule $rule");
}

#------------------------------------------------------------------------------
# bignum left half

foreach my $elem ([ 'A038185', 150 ], # cut after central column
                  [ 'A006977', 230 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($anum eq 'A001045') {  # Jacobsthal extra 0,1
      push @got, 0,1;
    }
    if ($anum eq 'A002450') {  # (4^n-1)/3 10101 extra 0 at start
      push @got, 0;
    }
    require Math::BigInt;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $b = Math::BigInt->new(0);
      foreach my $x (-$y .. 0) {
        my $bit = ($path->xy_to_n ($x, $y) ? 1 : 0);
        $b = 2*$b + $bit;
      }
      push @got, "$b";
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# bignum central vertical column

foreach my $elem ([ 'A092539',  30 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my $b = Math::BigInt->new(0);
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $bit = ($path->xy_to_n (0, $y) ? 1 : 0);
      $b = 2*$b + $bit;
      push @got, "$b";
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# various 0/1 by rows

foreach my $elem (# [ 'A071029',  22 ],  # starting from 0 ?
                  [ 'A070950',  30 ],
                  [ 'A071028',  50 ],
                  # [ 'A071030',  54 ], starting from 0 ?
                  [ 'A118109',  54 ],
                  [ 'A075438',  60 ], # including 0s in left half
                  # [ 'A047999',  60 ], # Sierpinski triangle  in right
                  # [ 'A047999', 102 ], # Sierpinski triangle  in left
                  # [ 'A071031',  62 ], # starting from 0?
                  # [ 'A071032',  86 ], # starting from 0?
                  [ 'A070886',  90 ],
                  [ 'A118102',  94 ],
                  # [ 'A071033',  94 ],  # some other start ?
                  [ 'A075439', 102 ],
                  [ 'A075437', 110 ],
                  # [ 'A071034', 118 ],  # some other start ?
                  # [ 'A071035', 126 ],  # FIXME some other start ?
                  # [ 'A071036', 150 ],  # FIXME some other start ?
                  [ 'A118110', 150 ],
                  [ 'A118172', 158 ],
                  # [ 'A071037', 158 ], # starting from 0?
                  # [ 'A071038', 182 ], # starting from 0?
                  [ 'A118174', 188 ],
                  [ 'A118111', 190 ],
                  # [ 'A071040', 214 ],  # FIXME some other start ?
                  [ 'A118175', 220 ],
                  # [ 'A071041', 246 ], # something fishy ?
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $x = 0;
    my $y = 0;
    while (@got < @$bvalues) {
      push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
      $x++;
      if ($x > $y) {
        $y++;
        $x = -$y;
      }
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum 0/1 rows rule $rule");
}


#------------------------------------------------------------------------------
# 0/1 left half

foreach my $elem (# [ 'A071022',  70 ],  FIXME ???
                  # [ 'A071023',  78 ],  FIXME ???
                  # [ 'A071022', 198 ],  FIXME ???
                  # [ 'A071027', 230 ],  FIXME ???
                  [ 'A070887', 110 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $x = 0;
    my $y = 0;
    while (@got < @$bvalues) {
      push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
      $x++;
      if ($x > 0) {  # left half only
        $y++;
        $x = -$y;
      }
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum 0/1 left half rule $rule");
}

#------------------------------------------------------------------------------
# 0/1 right half

foreach my $elem ([ 'A070909',  28 ],
                  # [ 'A071024',  92 ],  # FIXME some other start ?
                  [ 'A070909', 156 ],
                  # [ 'A071025', 124 ],  # FIXME some other start ?
                  # [ 'A071026', 188 ],  # FIXME some other start ?
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $x = 0;
    my $y = 0;
    while (@got < @$bvalues) {
      push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
      $x++;
      if ($x > $y) {
        $y++;
        $x = 0;  # right half only
      }
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum 0/1 right half rule $rule");
}

#------------------------------------------------------------------------------
# 0/1 central vertical column

foreach my $elem ([ 'A051023',  30 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, ($path->xy_to_n (0, $y) ? 1 : 0);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# number of 0s in row

foreach my $elem ([ 'A071042',  90 ],
                  [ 'A071043',  22 ],
                  #  [ 'A070951', 30 ],   # is this one right ?
                  # [ 'A071045',  54 ],  # FIXME: not rule 54 ?
                  [ 'A071046',  62 ],
                  [ 'A071050', 126 ],
                  [ 'A071052', 150 ],
                  [ 'A071055', 182 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($anum eq 'A071045') {  # extra 0 at start for some reason
      push @got, 0;
    }
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (-$y .. $y) {
        my $n = $path->xy_to_n ($x, $y);
        if (! defined $n) {
          $count++;
        }
      }
      push @got, $count;
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum count 0s in rows rule $rule");
}

#------------------------------------------------------------------------------
# number of 0s in left half

foreach my $elem ([ 'A071048', 110 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($anum eq 'A071045') {  # extra 0 at start for some reason
      push @got, 0;
    }
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (-$y .. 0) {
        my $n = $path->xy_to_n ($x, $y);
        if (! defined $n) {
          $count++;
        }
      }
      push @got, $count;
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum count 0s in left half rule $rule");
}


#------------------------------------------------------------------------------
# number of 1s in row

foreach my $elem ([ 'A071044',  22 ],
                  [ 'A070952',  30 ],
                  [ 'A071047',  62 ],
                  [ 'A001316',  90 ], # Gould's sequence
                  [ 'A071049', 110 ],
                  [ 'A071051', 126 ],
                  [ 'A071053', 150 ],
                  [ 'A071054', 158 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($#$bvalues > 200) {  # trim A070952
      $#$bvalues = 200;
    }
    if ($anum eq 'A071049' || $anum eq 'A070952') {
      # extra 0 at start for some reason
      push @got, 0;
    }
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (-$y .. $y) {
        if ($path->xy_to_n ($x, $y)) {
          $count++;
        }
      }
      push @got, $count;
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# number of 1s in row, first differences

foreach my $elem (['A151929', 30 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($#$bvalues > 200) {  # trim A151929
      $#$bvalues = 200;
    }
    my $prev_count = 0;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (-$y .. $y) {
        if ($path->xy_to_n ($x, $y)) {
          $count++;
        }
      }
      push @got, $count - $prev_count;
      $prev_count = $count;
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# number of 1s at the right hand end

foreach my $elem ([ 'A094603', 30 ],
                 ) {
  my ($anum, $rule) = @$elem;
  my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    if ($#$bvalues > 200) {
      $#$bvalues = 200;
    }
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (reverse -$y .. $y) {
        if ($path->xy_to_n ($x, $y)) {
          $count++;
        } else {
          last;
        }
      }
      push @got, $count;
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum count 1s at right hand end");
}


#------------------------------------------------------------------------------
# A071041 - 0/1 something rule 246, but what ?

# {
#   my $anum = 'A071041';
#   require Math::PlanePath::MathImageCellularRule;
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   foreach my $rule (0 .. 255) {
#       print "rule $rule\n";
#     my $path = Math::PlanePath::MathImageCellularRule->new (rule => $rule);
#     my @got;
#     if ($bvalues) {
#       my $x = 0;
#       my $y = 0;
#       while (@got < @$bvalues) {
#         push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
#         $x++;
#         if ($x > $y) {
#           $y++;
#           $x = -$y;
#         }
#       }
#     }
#     if (streq_array(\@got, $bvalues)) {
#       print "equal\n";
#     }
#   }
# }

#                            1,
#                         1, 1, 0,
#                      1, 0, 1, 1, 0,
#                   1, 1, 1, 0, 0, 1, 1,
#                1, 1, 0, 1, 1, 0, 1, 1, 1,
#             1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1,
#          0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1,
#       1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1,
#    1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1,
# 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1

# 1 _ _ _ 1 1 _ 1 1 _ 1 1 _ 1 1 1 1 1
#   1 1 _ 1 1 _ 1 1 _ 1 1 1 _ _ 1 1 1
#     1 _ 1 1 _ 1 1 1 1 1 _ 1 _ 1 1
#       _ 1 1 1 _ _ _ 1 1 _ 1 _ 1
#         1 1 1 _ _ _ 1 1 _ 1 1
#           1 1 _ 1 1 _ 1 1 1
#             1 1 1 _ _ 1 1
#               1 _ 1 1 _
#                 1 1 _
#                   1



# A071029 ... ?

#                            0,
#                         1, 0, 1,
#                      0, 1, 0, 1, 0,
#                   1, 0, 1, 0, 1, 0, 1,
#                0, 1, 0, 1, 0, 1, 0, 1, 0,
#             1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
#          1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
#       0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 
#    1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0,
# 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0

#                            0,
#                            1,
#                         0, 1, 0,
#                      1, 0, 1, 0, 1,
#                   0, 1, 0, 1, 0, 1, 0,
#                1, 0, 1, 0, 1, 0, 1, 0, 1,
#             0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1,
#          0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
#       1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
#    0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0

exit 0;
