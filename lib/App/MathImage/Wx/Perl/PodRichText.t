#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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

use 5.008;
use strict;
use warnings;
use Wx;
use Test::More;

use lib 't', '../../../../../t';
use MyTestHelpers;
MyTestHelpers::nowarnings();

plan tests => 4;

my $app = Wx::SimpleApp->new;
my $frame = Wx::Frame->new (undef, Wx::wxID_ANY(), 'Test');
require App::MathImage::Wx::Perl::PodRichText;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 100;
{
  is ($App::MathImage::Wx::Perl::PodRichText::VERSION, $want_version,
      'VERSION variable');
  is (App::MathImage::Wx::Perl::PodRichText->VERSION, $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Wx::Perl::PodRichText->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Wx::Perl::PodRichText->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  # my $podtext = App::MathImage::Wx::Perl::PodRichText->new ($frame);
  # is ($podtext->VERSION,  $want_version, 'VERSION object method');
  #
  # ok (eval { $podtext->VERSION($want_version); 1 },
  #     "VERSION object check $want_version");
  # ok (! eval { $podtext->VERSION($check_version); 1 },
  #     "VERSION object check $check_version");
}


#-----------------------------------------------------------------------------
# Scalar::Util::weaken

my $podtext = App::MathImage::Wx::Perl::PodRichText->new ($frame);
{
  my @heading_list = $podtext->get_heading_list;
  is_deeply (\@heading_list, []);
}

diag "weakening";
require Scalar::Util;
$podtext->Destroy;
Scalar::Util::weaken ($podtext);
is ($podtext, undef, 'garbage collect when weakened');

exit 0;
