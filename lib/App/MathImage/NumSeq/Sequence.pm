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

package App::MathImage::NumSeq::Sequence;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use vars '$VERSION';
$VERSION = 48;

# uncomment this to run the ### lines
#use Smart::Comments;

sub name {
  my ($class_or_self) = @_;
  my $name = ref($class_or_self) || $class_or_self;
  $name =~ s/^App::MathImage::NumSeq::Sequence:://;
  return $name;
}

use constant description => undef;
use constant parameter_list => ();
use constant density => 'unknown';
use constant oeis => undef;
sub values_min {
  my ($self) = @_;
  return $self->{'values_min'};
}
sub values_max {
  my ($self) = @_;
  return $self->{'values_max'};
}
sub is_type {
  my ($self, $type) = @_;
  if (my $type_hash = $self->{'type_hash'}) {
    return $self->{'type_hash'}->{$type};
  }
  return 0;
}
use constant finish => undef;

my %parameter_hash;
sub parameter_hash {
  my ($class_or_self) = @_;
  my $class = (ref $class_or_self || $class_or_self);
  return ($parameter_hash{$class}
          ||= { map {($_->{'name'} => $_)} $class_or_self->parameter_list });
}

sub parameter_default {
  my ($class_or_self, $name) = @_;
  ### NumSeq parameter_default: @_
  ### info: $class_or_self->parameter_hash->{$name}
  my $info;
  return (($info = $class_or_self->parameter_hash->{$name})
          && $info->{'default'});
}

use constant parameter_common_pairs =>
  { name    => 'pairs',
    display => __('Pairs'),
    type    => 'enum',
    default => 'first',
    choices => ['first','second','both'],
    choices_display => [__('First'),__('Second'),__('Both')],
    description => __('Which of a pair of values to show.'),
  };
1;
__END__
