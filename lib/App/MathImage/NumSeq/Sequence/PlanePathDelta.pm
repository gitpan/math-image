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

package App::MathImage::NumSeq::Sequence::PlanePathDelta;
use 5.004;
use strict;
use Carp;
use List::Util 'max';
use Math::Libm 'hypot';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 54;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('PlanePath Deltas');
# use constant description => __('');
my @choices = (map { s/.*:://; $_ }
               Module::Util::find_in_namespace('Math::PlanePath'),
              );
### @choices
use constant parameter_list => ({ name    => 'planepath_class',
                                  display => __('PlanePath Class'),
                                  type    => 'enum',
                                  default => 'SquareSpiral',
                                  choices => \@choices,
                                  # width   => 3 + max(0,map{length}@choices),
                                  # description => __(''),
                                },
                                { name    => 'delta_type',
                                  display => __('Delta Type'),
                                  type    => 'enum',
                                  default => 'X',
                                  choices => ['X','Y','Dist','SqDist'],
                                  # description => __(''),
                                },
                               );
# OeisCatalogue: A163538 planepath_class=HilbertCurve delta_type=x
# OeisCatalogue: A163539 planepath_class=HilbertCurve delta_type=y
# OeisCatalogue: A163532 planepath_class=PeanoCurve delta_type=x
# OeisCatalogue: A163533 planepath_class=PeanoCurve delta_type=y


sub new {
  my ($class, %options) = @_;
  ### PlanePathDelta new(): @_

  my $planepath_object = $options{'planepath_object'}
    || do {
      my $path_class = $options{'planepath_class'}
        || (parameter_list)[0]->{'default'};
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

  my $delta_type = $options{'delta_type'} || (parameter_list)[1]->{'default'};
  my $delta_func = $class->can("delta_func_$delta_type")
    || croak "Unrecognised delta_type: ",$delta_type;

  my ($n_start, undef) = $planepath_object->rect_to_n_range (0,0, 0,0);
  ### $n_start

  my $self = bless { planepath_object => $planepath_object,
                     delta_func => $delta_func,
                     type_hash  => {},
                     n_start    => $n_start,
                     i          => 0,
                     prev_x     => 0,
                     prev_y     => 0,
                   }, $class;

  if ($delta_type eq 'X' || $delta_type eq 'Y') {
    $self->{'type_hash'}->{'pn1'} = 1;
    $self->{'values_min'} = -1;  # or maybe bigger ...
    $self->{'values_max'} = 1;
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
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($i + $self->{'n_start'});
  my $ret = &{$self->{'delta_func'}}
    ($self->{'prev_x'},$self->{'prev_y'}, $x,$y);
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;
  ### $ret
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
