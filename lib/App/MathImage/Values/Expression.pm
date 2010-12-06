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

package App::MathImage::Values::Expression;
use 5.004;
use strict;
use warnings;
use Carp;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 36;

use constant name => __('Arbitrary Expression');
use constant description => __('An arbitrary expression, to be parsed by Math::Symbolic.  It should have a single variable which will be evaluated at 0,1,2, etc.  For example (2*x)^2 would give the even perfect squares.

An invalid expression produces a blank display and a message in the status bar.');

use constant parameters => { expression => { type => 'string',
                                             default => '3*x^2 + x + 2',
                                           },
                           };

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $expression = $options{'expression'};
  if (! defined $expression) {
    $expression = $class->parameters->{'expression'}->{'default'};
  }
  require Math::Symbolic;
  my $tree = Math::Symbolic->parse_from_string($expression);
  if (! defined $tree) {
    croak "Cannot parse expression: $expression";
  }
  $tree = $tree->simplify;
  my @vars = $tree->signature;
  if (@vars != 1) {
    croak "More than one variable in expression: $expression\n(simplified to $tree)";
  }
  ### code: $tree->to_code
  my ($subr) = $tree->to_sub(\@vars);
  ### $subr

  return bless { i     => 0,
                 hi    => $options{'hi'},
                 above => 0,
                 subr  => $subr,
               }, $class;
}

sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;

  for (;;) {
    if ($self->{'above'} >= 10 || $i > $self->{'hi'}) {
      return;
    }
    my $n = eval { $self->{'subr'}->($i) };
    if (! defined $n) {
      # eg. division by zero
      ### expression undef: $@
      $self->{'above'}++;
      next;
    }
    ### expression result: $n
    if ($n > $self->{'hi'}) {
      $self->{'above'}++;
    }
    return $n;
  }
}

1;
__END__
