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



# "Dir" on triangular give 0 to 5




package App::MathImage::NumSeq::PlanePathDelta;
use 5.004;
use strict;
use Carp;
use Module::Util;
use List::Util 'max';
use Math::Libm 'hypot';

use Math::NumSeq;
use base 'Math::NumSeq';

use vars '$VERSION';
$VERSION = 70;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => Math::NumSeq::__('PlanePath Deltas');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant description => Math::NumSeq::__('Step directions in a PlanePath');

my @choices = (map { s/.*:://; $_ }
               Module::Util::find_in_namespace('Math::PlanePath'),
              );
### @choices
use constant parameter_info_array => [ { name    => 'planepath_class',
                                         display => Math::NumSeq::__('PlanePath Class'),
                                         type    => 'enum',
                                         default => 'SquareSpiral',
                                         choices => \@choices,
                                         # width   => 3 + max(0,map{length}@choices),
                                         # description => Math::NumSeq::__(''),
                                       },
                                       { name    => 'delta_type',
                                         display => Math::NumSeq::__('Delta Type'),
                                         type    => 'enum',
                                         default => 'X',
                                         choices => ['X','Y','Dist','SqDist','Dir'],
                                         # description => Math::NumSeq::__(''),
                                       },
                                     ];
# OEIS-Catalogue: A163538 planepath_class=HilbertCurve delta_type=x
# OEIS-Catalogue: A163539 planepath_class=HilbertCurve delta_type=y
# OEIS-Catalogue: A163532 planepath_class=PeanoCurve delta_type=x
# OEIS-Catalogue: A163533 planepath_class=PeanoCurve delta_type=y


sub new {
  my ($class, %options) = @_;
  ### PlanePathDelta new(): @_

  my $planepath_object = $options{'planepath_object'}
    || do {
      my $path_class = $options{'planepath_class'}
        || $class->parameter_info_array->[0]->{'default'};
      unless ($path_class =~ /::/) {
        my $fullclass = "Math::PlanePath::$path_class";
        if (Module::Util::find_installed($fullclass)) {
          $path_class = $fullclass;
        } else {
          croak "No such planepath class: ",$path_class;
        }
      }
      Module::Load::load ($path_class);
      $path_class->new;
    };
  ### $planepath_object

  my $delta_type = $options{'delta_type'} || ($class->parameter_info_list)[1]->{'default'};
  my $delta_func = $class->can("delta_func_$delta_type")
    || croak "Unrecognised delta_type: ",$delta_type;

  my ($n_lo, undef) = $planepath_object->rect_to_n_range (0,0, 0,0);
  ### $n_lo

  my $self = bless { planepath_object => $planepath_object,
                     delta_func => $delta_func,
                     type_hash  => {},
                     n_lo    => $n_lo,
                     i          => 0,
                     prev_x     => 0,
                     prev_y     => 0,
                   }, $class;

  if ($delta_type eq 'X' || $delta_type eq 'Y') {
    $self->{'type_hash'}->{'pn1'} = 1;
    $self->{'values_min'} = -1;  # or maybe bigger ...
    $self->{'values_max'} = 1;
  } elsif ($delta_type eq 'Dir') {
    $self->{'values_min'} = 0;
    $self->{'values_max'} = 3;
  } else {
    $self->{'type_hash'}->{'count'} = 1;
    $self->{'values_min'} = -2;  # or maybe bigger ...
    $self->{'values_max'} = 2;
  }

  return $self;
}

sub next {
  my ($self) = @_;
  ### PlanePathDelta next(): $self->{'i'}
  my $i = $self->{'i'}++;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($i + $self->{'n_lo'});
  my $ret = &{$self->{'delta_func'}}
    ($self->{'prev_x'},$self->{'prev_y'}, $x,$y);
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;
  ### ret: [$i, $ret]
  return ($i, $ret);
}

sub delta_func_X {
  my ($prev_x,$prev_y, $x,$y) = @_;
  return $x - $prev_x;
}
sub delta_func_Y {
  my ($prev_x,$prev_y, $x,$y) = @_;
  return $y - $prev_y;
}
sub delta_func_Dist {
  my ($prev_x,$prev_y, $x,$y) = @_;
  return hypot ($x - $prev_x, $y - $prev_y);
}
sub delta_func_SqDist {
  my ($prev_x,$prev_y, $x,$y) = @_;
  $x -= $prev_x;
  $y -= $prev_y;
  return $x*$x + $y*$y;
}
sub delta_func_Dir {
  my ($prev_x,$prev_y, $x,$y) = @_;
  if ($y < $prev_y) { return 3 }  # south
  if ($x < $prev_x) { return 2 }  # west
  if ($y > $prev_y) { return 1 }  # north
  return 0;  # east
}

# sub pred {
#   my ($self, $n) = @_;
#   return (($n >= 0)
#           && do {
#             $n = sqrt($n);
#             $n == int($n)
#           });
# }

1;
__END__
