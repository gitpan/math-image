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

package App::MathImage::Values::Expression;
use 5.004;
use strict;
use warnings;
use Carp;
use List::Util;
use Math::Libm;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 41;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Arbitrary Expression');
use constant description => __('An arbitrary expression.  It should have a single variable which will be evaluated at 0,1,2, etc.  For example (2*x)^2 would give the even perfect squares.

Syntax is per the chosen evaluator, an invalid expression displays an error message.
Math::Symbolic is like 2*x^2.
Math::Expression::Evaluator is like t=2*x;t^2
Language::Expr is like $k**2 + $k - 1.'); 

my @evaluators;
BEGIN {
  @evaluators
    = ((defined(Module::Util::find_installed('Math::Symbolic'))
        ? 'MS' : ()),
       (defined(Module::Util::find_installed('Math::Expression::Evaluator'))
        ? 'MEE' : ()),
       (defined(Module::Util::find_installed('Language::Expr'))
        ? 'LE' : ()));
}
use constant parameter_list => ({ name    => 'expression',
                                  display => __('Expression'),
                                  type    => 'string',
                                  default => ($evaluators[0] eq 'LE'
                                              ? '3*$x**2 + $x + 2'
                                              : '3*x^2 + x + 2'),
                                  width   => 30,
                                  description => __('A mathematical expression giving values to display, for example x^2+x+41.  Only one variable is allowed, see the chosen evaluator Math::Symbolic or Math::Expression::Evaluator for possible operators and function.'),
                                },
                                { name    => 'expression_evaluator',
                                  display => __('Evaluator'),
                                  type    => 'enum',
                                  default => $evaluators[0],
                                  choices => \@evaluators,
                                  description => __('The expression evaluator module, either MS for Math::Symbolic or MEE for Math::Expression::Evaluator.'),
                                },
                               );

### parameter_list: parameter_list
  ### parameter_hash: __PACKAGE__->parameter_hash
  ### evaluator default: __PACKAGE__->parameter_default('expression_evaluator')

  {
    package App::MathImage::Values::Expression::LanguageExpr;
    use List::Util 'min', 'max';
    our $pi = Math::Libm::M_PI();
    our $e = Math::Libm::M_E();
    our $phi = (1+sqrt(5))/2;
    our $gam = 0.5772156649015328606065120;
  }

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $expression = $options{'expression'};
  if (! defined $expression) {
    $expression = $class->parameter_default('expression');
  }

  my $evaluator = $options{'expression_evaluator'}
    || $class->parameter_default('expression_evaluator')
      || croak "No expression evaluator modules available";
  ### $evaluator

  my $subr;
  if ($evaluator eq 'MS') {
    require Math::Symbolic;
    my $tree = Math::Symbolic->parse_from_string($expression);
    if (! defined $tree) {
      croak "Cannot parse MS expression: $expression";
    }

    # simplify wrong result on x+(-5)*y before 0.605 ...
    if (eval { $tree->VERSION(0.605); 1 }) {
      $tree = $tree->simplify;
    }

    my @vars = $tree->signature;
    if (@vars > 1) {
      croak "More than one variable in MS expression: $expression\n(simplified to $tree)";
    }
    ### code: $tree->to_code
    ($subr) = $tree->to_sub(\@vars);
    ### $subr

  } elsif ($evaluator eq 'MEE') {
    require Math::Expression::Evaluator;
    my $me = Math::Expression::Evaluator->new;
    $me->set_function('min',  \&List::Util::min);
    $me->set_function('max',  \&List::Util::max);
    $me->parse('pi='.Math::Libm::M_PI()
               .'; e='.Math::Libm::M_E()
               .'; phi=(1+sqrt(5))/2'
               .'; gam=0.5772156649015328606065120');
    $me->val;

    eval { $me->parse ($expression); 1 }
      or croak "Cannot parse MEE expression: $expression\n$@";

    # my @vars = $me->variables;
    my @vars = _me_free_variables($me);
    if (@vars > 1) {
      croak "More than one variable in MEE expression: $expression";
    }

    my $hashsub = $me->compiled;
    ### $hashsub
    ### _ast_to_perl: $me->_ast_to_perl($me->{ast})

    my $v = $vars[0];
    my %vars;
    $subr = sub {
      $vars{$v} = $_[0];
      return &$hashsub(\%vars);
    };

  } elsif ($evaluator eq 'LE') {
    require Language::Expr;
    my $le = Language::Expr->new;
    my $varef;
    eval { $varef = $le->enum_vars ($expression); 1 }
      or croak "Cannot parse LE expression: $expression\n$@";
    ### $varef
    my @vars = grep {
      do {
        no strict;
        ! defined ${"App::MathImage::Values::Expression::LanguageExpr::$_"}
      }
    } @$varef;
    if (@vars > 1) {
      croak "More than one variable in LE expression: $expression";
    }

    require Language::Expr::Compiler::Perl;
    my $pe = Language::Expr::Compiler::Perl->new;
    my $perlstr;
    eval { $perlstr = $pe->perl ($expression); 1 }
      or croak "Cannot parse LE expression: $expression\n$@";

    my $v = $vars[0] || 'k';
    ### $v
    ### eval: "sub { my \$$v = \$_[0]; $perlstr }"
    $subr = eval "package App::MathImage::Values::Expression::LanguageExpr;
                  use strict;
                  sub { my \$$v = \$_[0]; $perlstr }"
      or croak "Cannot compile $expression\n$perlstr\n$@";
    ### $subr
    ### at zero: $subr->(0)

  } else {
    croak "Unknown evaluator: $evaluator";
  }

  return bless { i     => 0,
                 hi    => $options{'hi'},
                 above => 0,
                 subr  => $subr,
               }, $class;
}

sub _me_free_variables {
  my ($me) = @_;
  my %assigned = %{$me->{'variables'}};
  my %free;
  my @pending = ($me->{'ast'});
  while (@pending) {
    my $node = shift @pending;
    ref $node or next;
    # ### $node
    push @pending, @$node[1..$#$node];

    if ($node->[0] eq '$') {
      my $varname = $node->[1];
      if (! $assigned{$varname}) {
        ### free: $varname
        $free{$varname} = 1;
      }
    } elsif ($node->[0] eq '=') {
      my $vnode = $node->[1];
      if ($vnode->[0] eq '$') {
        ### assigned: $vnode->[1]
        $assigned{$vnode->[1]} = 1;
      }
    }
  }
  return keys %free;
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
