#!/usr/bin/perl -w

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

use 5.010;
use strict;
use warnings;
use Language::Expr;

use Smart::Comments;

# Language::Expr::Manual::Syntax
{
  my $le = Language::Expr->new (interpreted => 1);
  $le->var (x => 123);
  # $le->compiler->var_mapping->{'t'} = 123;
  my $comp = $le->compiler;
  my $perl = $comp->perl('2 * $x');
  ### eval: eval "my \$x = 123; $perl"

  my $subr = eval "sub { my \$x = \$_[0]; $perl }" || die $@;
  ### $subr
  ### sub: $subr->(99)
  exit 0;
}

{
  use Language::Expr;
  my $le = new Language::Expr;
  $le->var('a' => 1, 'b' => 2);

  # evaluate expression
  say $le->eval('$a + $b');

  exit 0;
}

{
  my $le = Language::Expr->new (interpreted => 1);
  $le->func (sqr => sub { $_[0] ** 2 });
  $le->compiler->func_mapping->{'sqr'} = sub { $_[0] ** 2 };
  ### $le
  ### vars: $le->enum_vars('2*$x')

  foreach my $i (0 .. 10) {
    $le->var(x => $i);
    say $i, ' ', $le->eval('2*$x');
  }
  exit 0;
}

{
  use Language::Expr::Compiler::Perl;
  my $plc = Language::Expr::Compiler::Perl->new;
  ### perl: $plc->perl('-123 + 2*$x')
  exit 0;
}

{
  use Language::Expr;
  my $le = new Language::Expr;
  $le->var('a' => 1, 'b' => 2);
  $le->func(sqr => sub { $_[0] ** 2 });

  # evaluate expression
  say $le->eval('$a + sqr($b)'); # 5

  exit 0;
}
