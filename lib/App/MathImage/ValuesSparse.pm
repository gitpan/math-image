# Copyright 2010 Kevin Ryde

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

package App::MathImage::ValuesSparse;
use 5.004;
use strict;
use warnings;

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 27;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant density => 'sparse';

sub new {
  my $class = shift;
  my $self = bless { @_ }, $class;
  my $lo = ($self->{'lo'} ||= 0);
  while ($self->{'f0'} < $lo) {
    $self->next;
  }
  return $self;
}

sub pred {
  my ($self, $n) = @_;
  ### ValuesSparse pred(): $n
  my $iter = ($self->{'pred_iter'} ||= do {
    $self->{'pred_n'} = -1;
    my $class = ref $self;
    my $it = $class->new (%$self);
    while ($self->{'pred_n'} < 10) {
      my ($pred_n) = $it->next;
      $self->{'pred_hash'}->{$self->{'pred_n'}=$pred_n} = undef;
    }
    $it
  });
  while ($n > $self->{'pred_n'}) {
    my ($pred_n) = $iter->next;
    next if ($pred_n < $self->{'lo'});
    $self->{'pred_hash'}->{$self->{'pred_n'}=$pred_n} = undef;
    ### ValuesSparse pred_iter extend: $self->{'pred_n'}
  }
  ### ValuesSparse pred result: exists($self->{'pred_hash'}->{$n})
  return exists($self->{'pred_hash'}->{$n});
}

1;
__END__
