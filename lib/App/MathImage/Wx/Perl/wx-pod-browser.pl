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
use Getopt::Long;
use Wx;
use App::MathImage::Wx::Perl::PodBrowser;

my $app = Wx::SimpleApp->new;
$app->SetAppName(Wx::gettext('POD Browser'));

my $browser = App::MathImage::Wx::Perl::PodBrowser->new;
$browser->Show;

my @goto_pod;
Getopt::Long::Configure ('no_ignore_case');
Getopt::Long::Configure ('pass_through');
Getopt::Long::GetOptions
  ('module=s' => sub {
     my ($optname, $value) = @_;
     @goto_pod = (module => $value);
   },
   'file=s' => sub {
     my ($optname, $value) = @_;
     @goto_pod = (filename => $value);
   },
   'stdin' => sub {
     my ($optname, $value) = @_;
     @goto_pod = (filehandle => \*STDIN);
   },
  )
  or return 1;

if (@ARGV) {
  @goto_pod = (guess => shift @ARGV);
}
$browser->goto_pod (@goto_pod);

$app->MainLoop;
exit 0;
